`default_nettype none





module dps_sci(
		input				iIF_CLOCK,
		input				iDPS_BASE_CLOCK,
		//Reset
		input				inRESET,
		//CPU Interface
		input				iREQ_VALID,
		output				oREQ_BUSY,		//Ignore
		input				iREQ_RW,
		input	[1:0]		iREQ_ADDR,
		input	[31:0]		iREQ_DATA,
		output				oREQ_VALID,
		output	[31:0]		oREQ_DATA,
		//IRQ
		output				oIRQ_VALID,
		input				iIRQ_ACK,
		//UART
		output				oUART_TXD,
		input				iUART_RXD
	);

	localparam SCITX = 2'h0;
	localparam SCIRX = 2'h1;
	localparam SCICFG = 2'h2;
	
	/**********************************
	SCI Config Register
	**********************************/
	reg						b_scicfg_ten;
	reg						b_scicfg_ren;
	reg		[3:0]			b_scicfg_bdr;
	reg		[2:0]			b_scicfg_ire;
	/*
	reg						b_scicfg_tclr;
	reg						b_scicfg_rclr;
	*/
	always@(posedge iIF_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_scicfg_ten		<=		1'b0;
			b_scicfg_ren		<=		1'b0;
			b_scicfg_bdr		<=		4'b0;
			b_scicfg_ire		<=		3'b0;
		end
		else begin
			if(iREQ_ADDR == SCICFG && iREQ_VALID && iREQ_RW)begin
				b_scicfg_ten		<=		iREQ_DATA[0];					
				b_scicfg_ren		<=		iREQ_DATA[1];
				b_scicfg_bdr		<=		iREQ_DATA[5:2];
				b_scicfg_ire		<=		iREQ_DATA[8:6];
			end
		end
	end
	

	
	/**********************************
	SCI Module
	**********************************/
	wire			uart_mod_full;
	wire			uart_mod_empty;
	wire	[7:0]	uart_mod_data;
	wire			uart_mod_irq;
	dps_uart UARTMOD(
		//Clock
		.iCLOCK(iIF_CLOCK),
		.inRESET(inRESET),
		//Request
		.iTX_EN(b_scicfg_ten),
		.iTX_REQ(iREQ_VALID && !uart_mod_full && (iREQ_ADDR == SCITX) && iREQ_RW),
		.oTX_BUSY(uart_mod_full),
		.iTX_DATA(iREQ_DATA[7:0]),
		.iRX_EN(b_scicfg_ren),
		.iRX_REQ(iREQ_VALID && !uart_mod_empty && (iREQ_ADDR == SCIRX) && !iREQ_RW),
		.oRX_EMPTY(uart_mod_empty),
		.oRX_DATA(uart_mod_data),
		//IRQ
		.oIRQ_VALID(uart_mod_irq),
		//UART
		.oUART_TXD(oUART_TXD),
		.iUART_RXD(iUART_RXD)
	);

	/**********************************
	IRQ Buffer
	**********************************/
	localparam IRQ_STT_IDLE = 1'b0;
	localparam IRQ_STT_IRQ = 1'b1;
	
	reg				b_irq_state;
	always@(posedge iIF_CLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_irq_state		<=		IRQ_STT_IDLE;
		end
		else begin
			case(b_irq_state)
				IRQ_STT_IDLE:
					begin
						if(uart_mod_irq)begin
							b_irq_state		<=		IRQ_STT_IRQ;
						end
					end
				IRQ_STT_IRQ:
					begin
						if(iIRQ_ACK && b_scicfg_ire == 3'h1)begin
							b_irq_state		<=		IRQ_STT_IDLE;
						end
					end
			endcase
		end
	end
	
	
	assign		oREQ_BUSY		=		1'b0;//!(iREQ_VALID && !uart_mod_full && (iREQ_ADDR == `SCITX) && iREQ_RW);
	assign		oREQ_VALID		=		iREQ_VALID && !uart_mod_empty && (iREQ_ADDR == SCIRX) && !iREQ_RW;
	assign		oREQ_DATA		=		(uart_mod_empty)? 32'h0 : 32'h80000000 | uart_mod_data;
	
	assign		oIRQ_VALID		=		(b_scicfg_ire == 3'h0)? 1'b0 : (b_irq_state == IRQ_STT_IRQ);
	
endmodule
			
`default_nettype wire


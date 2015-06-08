


`default_nettype none

module pipeline_control_hundler_read(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//System Register
		input wire [31:0] iSYSREG_IDTR,
		//Request
		input wire iRD_START,
		input wire [6:0] iRD_IRQ_NUM,
		output wire oRD_FINISH,
		output wire [31:0] oRD_HUNDLER,
		//Load Store
		output wire oLDST_USE,
		output wire oLDST_REQ,
		input wire iLDST_BUSY,
		output wire [1:0] oLDST_ORDER,	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		output wire oLDST_RW,		//0=Read 1=Write
		output wire [13:0] oLDST_ASID,
		output wire [1:0] oLDST_MMUMOD,
		output wire [31:0] oLDST_PDT,
		output wire [31:0] oLDST_ADDR,
		output wire [31:0] oLDST_DATA,
		input wire iLDST_REQ,
		input wire [31:0] iLDST_DATA
		
	);


	localparam L_PARAM_INTHUNDLE_STT_IDLE = 1'b0;
	localparam L_PARAM_INTHUNDLE_STT_LOAD = 1'b1;

	reg b_inthundl_read_state;
	reg b_inthundl_read;
	reg b_inthundl_readend;
	reg [31:0] b_inthundl_idt_data;


	wire [31:0] inthundle_read_addr = iSYSREG_IDTR + {iRD_IRQ_NUM, 3'h0} + 32'h4;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_inthundl_read_state <= L_PARAM_INTHUNDLE_STT_IDLE;
			b_inthundl_read <= 1'b0;
			b_inthundl_readend <= 1'b0;
			b_inthundl_idt_data <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_inthundl_read_state <= L_PARAM_INTHUNDLE_STT_IDLE;
			b_inthundl_read <= 1'b0;
			b_inthundl_readend <= 1'b0;
			b_inthundl_idt_data <= 32'h0;
		end
		else begin
			case(b_inthundl_read_state)
				L_PARAM_INTHUNDLE_STT_IDLE:
					begin
						if(iRD_START)begin
							b_inthundl_read_state <= L_PARAM_INTHUNDLE_STT_LOAD;
							b_inthundl_read <= 1'b1;
						end
						else begin
							b_inthundl_read <= 1'b0;
						end
						b_inthundl_readend <= 1'b0;
					end
				L_PARAM_INTHUNDLE_STT_LOAD:
					begin
						//Read Request
						if(!iLDST_BUSY && b_inthundl_read)begin
							b_inthundl_read <= 1'b0;
						end
						//Get Check
						if(iLDST_REQ)begin
							b_inthundl_readend <= 1'b1;
							b_inthundl_read_state <= L_PARAM_INTHUNDLE_STT_IDLE;
							b_inthundl_idt_data <= iLDST_DATA;
						end
					end
			endcase
		end
	end


	assign oRD_FINISH = b_inthundl_readend;
	assign oRD_HUNDLER = b_inthundl_idt_data;

	



	assign oLDST_USE = b_inthundl_read_state == L_PARAM_INTHUNDLE_STT_LOAD;
	assign oLDST_REQ = b_inthundl_read;
	assign oLDST_ORDER = 2'h2;	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
	assign oLDST_RW = 1'b0;		//0=Read 1=Write
	assign oLDST_ASID = 14'h0;
	assign oLDST_MMUMOD = 2'h0;
	assign oLDST_PDT = 32'h0;
	assign oLDST_ADDR = inthundle_read_addr;
	assign oLDST_DATA = 32'h0;

endmodule




`default_nettype wire 
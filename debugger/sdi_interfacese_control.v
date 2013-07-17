


`default_nettype none



module sdi_interface_control(
		input wire iCLOCK,
		input wire inRESET,
		//Interface Select
		input wire iIF_SELECT,				//(0)UART | (1)PARALLEL
		//UART
		input wire iDEBUG_UART_RXD,
		output wire oDEBUG_UART_TXD,
		//Parallel
		input wire iDEBUG_PARA_REQ,
		output wire oDEBUG_PARA_BUSY,
		input wire [7:0] iDEBUG_PARA_CMD,
		input wire [31:0] iDEBUG_PARA_DATA,
		output wire oDEBUG_PARA_VALID,
		input wire iDEBUG_PARA_BUSY,
		output wire oDEBUG_PARA_ERROR,
		output wire [31:0] oDEBUG_PARA_DATA,
		//Output Common Interface
		output wire iDEBUG_COM_REQ,
		input wire oDEBUG_COM_BUSY,
		output wire [7:0] iDEBUG_COM_CMD,
		output wire [31:0] iDEBUG_COM_DATA,
		input wire oDEBUG_COM_VALID,
		output wire iDEBUG_COM_BUSY,
		input wire oDEBUG_COM_ERROR,
		input wire [31:0] oDEBUG_COM_DATA
	);
	
	/*
	//Uart Module
	wire uartmod_txd_req;
	wire uartmod_txd_busy;
	wire [7:0] uartmod_txd_data;
	wire uartmod2rdqueue_rxd_valid;
	wire [7:0] uartmod2rdqueue_rxd_data;
	//ED Queue
	wire [7:0] rdqueue2commandcheck_data;
	wire rdqueue2commandcheck_empty;
	*/
	
	/****************************************************************
	Uart
	****************************************************************/
	//Uart Module
	//Baudrate (Clock / Baudrate = parameter) 9600bps = 13'h1458, 57600bps = 13'h364
	/*
	processor_debugger_uart #(13'h364) UART_IF(	
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Request
		.iTX_REQ(uartmod_txd_req),
		.oTX_BUSY(uartmod_txd_busy),
		.iTX_DATA(uartmod_txd_data),	
		.oRX_VALID(uartmod2rdqueue_rxd_valid),
		.oRX_DATA(uartmod2rdqueue_rxd_data),
		//UART
		.oUART_TXD(oUART_TXD),
		.iUART_RXD(iUART_RXD)
	);	
	
	//Rxd Queue
	mist1032isa_sync_fifo #(8, 16, 4) UART_RXD_BUFFER(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iREMOVE(1'b0), 
		.oCOUNT(), 	
		.iWR_EN(uartmod2rdqueue_rxd_valid), 
		.iWR_DATA(uartmod2rdqueue_rxd_data), 
		.oWR_FULL(),
		.iRD_EN(!b_uart_cmd_request && !rdqueue2commandcheck_empty), 
		.oRD_DATA(rdqueue2commandcheck_data), 
		.oRD_EMPTY(rdqueue2commandcheck_empty)
	);
	*/
	
	/****************************************************************
	Interface Select
	****************************************************************/
	
	reg debug_
	
	

	input wire iDEBUG_PARA_REQ,
	output wire oDEBUG_PARA_BUSY,
	input wire [7:0] iDEBUG_PARA_CMD,
	input wire [31:0] iDEBUG_PARA_DATA,
	output wire oDEBUG_PARA_VALID,
	input wire iDEBUG_PARA_BUSY,
	output wire oDEBUG_PARA_ERROR,
	output wire [31:0] oDEBUG_PARA_DATA
	
	
	always @* begin
		if()begin
			/
		end
		else begin
			//
		end
	end
	
	

		
endmodule


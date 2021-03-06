
`default_nettype none
`timescale 1ns/1ns

module tb_mist1032isa_normal_test;
	localparam PL_CORE_CYCLE = 20;
	localparam PL_BUS_CYCLE = 20;
	localparam PL_DPS_CYCLE = 18;
	localparam PL_RESET_TIME = 20;

	/****************************************
	System
	****************************************/
	reg iCORE_CLOCK;
	reg iBUS_CLOCK;
	reg iDPS_CLOCK;
	reg inRESET;
	/****************************************
	SCI
	****************************************/
	wire oSCI_TXD;
	reg iSCI_RXD;
	/****************************************
	Memory BUS
	****************************************/
	//Req
	wire oMEMORY_REQ;
	reg iMEMORY_LOCK;
	wire [1:0] oMEMORY_ORDER;				//00=Byte Order 01=2Byte Order 10= Word Order 11= None
	wire oMEMORY_RW;						//1:Write | 0:Read
	wire [31:0] oMEMORY_ADDR;
	//This -> Data RAM
	wire [31:0] oMEMORY_DATA;
	//Data RAM -> This
	reg iMEMORY_VALID;
	wire oMEMORY_BUSY;
	reg [63:0] iMEMORY_DATA;	
	/****************************************
	GCI BUS
	****************************************/
	//Request
	wire oGCI_REQ;					//Input
	reg iGCI_BUSY;
	wire oGCI_RW;						//0=Read : 1=Write
	wire [31:0] oGCI_ADDR;
	wire [31:0] oGCI_DATA;
	//Return
	reg iGCI_REQ;						//Output
	wire oGCI_BUSY;
	reg [31:0] iGCI_DATA;
	//Interrupt
	reg iGCI_IRQ_REQ;
	reg [5:0] iGCI_IRQ_NUM;
	wire oGCI_IRQ_ACK;
	//Interrupt Controll
	wire oIO_IRQ_CONFIG_TABLE_REQ;
	wire [5:0] oIO_IRQ_CONFIG_TABLE_ENTRY;
	wire oIO_IRQ_CONFIG_TABLE_FLAG_MASK;
	wire oIO_IRQ_CONFIG_TABLE_FLAG_VALID;
	wire [1:0] oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL;
	wire [31:0] oDEBUG_PC;
	wire [31:0] oDEBUG0;
	/****************************************
	Debug
	****************************************/
	reg iDEBUG_UART_RXD;
	wire oDEBUG_UART_TXD;
	reg iDEBUG_PARA_REQ;
	wire oDEBUG_PARA_BUSY;
	reg [7:0] iDEBUG_PARA_CMD;
	reg [31:0] iDEBUG_PARA_DATA;
	wire oDEBUG_PARA_VALID;
	reg iDEBUG_PARA_BUSY;
	wire oDEBUG_PARA_ERROR;
	wire [31:0] oDEBUG_PARA_DATA;



	/******************************************************
	Target
	******************************************************/
	module mist1032isa(
		/****************************************
		System
		****************************************/
		.iCORE_CLOCK(iCORE_CLOCK),
		.iBUS_CLOCK(),
		.iDPS_CLOCK(),
		.inRESET(),
		/****************************************
		SCI
		****************************************/
		.oSCI_TXD(),
		.iSCI_RXD(),
		/****************************************
		Memory BUS
		****************************************/
		//Req
		.oMEMORY_REQ(),
		.iMEMORY_LOCK(),
		.oMEMORY_ORDER(),				//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oMEMORY_RW(),						//1:Write | 0:Read
		.oMEMORY_ADDR(),
		//This -> Data RAM
		.oMEMORY_DATA(),
		//Data RAM -> This
		.iMEMORY_VALID(),
		.oMEMORY_BUSY(),
		.iMEMORY_DATA(),	
		/****************************************
		GCI BUS
		****************************************/
		//Request
		.oGCI_REQ(),					//Input
		.iGCI_BUSY(),
		.oGCI_RW(),						//0=Read : 1=Write
		.oGCI_ADDR(),
		.oGCI_DATA(),
		//Return
		.iGCI_REQ(),						//Output
		.oGCI_BUSY(),
		.iGCI_DATA(),
		//Interrupt
		.iGCI_IRQ_REQ(),
		.iGCI_IRQ_NUM(),
		.oGCI_IRQ_ACK(),
		//Interrupt Controll
		.oIO_IRQ_CONFIG_TABLE_REQ(),
		.oIO_IRQ_CONFIG_TABLE_ENTRY(),
		.oIO_IRQ_CONFIG_TABLE_FLAG_MASK(),
		.oIO_IRQ_CONFIG_TABLE_FLAG_VALID(),
		.oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL(),
		.oDEBUG_PC(),
		.oDEBUG0(),
		/****************************************
		Debug
		****************************************/
		.iDEBUG_UART_RXD(),
		.oDEBUG_UART_TXD(),
		.iDEBUG_PARA_REQ(),
		.oDEBUG_PARA_BUSY(),
		.iDEBUG_PARA_CMD(),
		.iDEBUG_PARA_DATA(),
		.oDEBUG_PARA_VALID(),
		.iDEBUG_PARA_BUSY(),
		.oDEBUG_PARA_ERROR(),
		.oDEBUG_PARA_DATA()
	);


	/******************************************************
	Clock
	******************************************************/
	always#(PL_CORE_CYCLE/2)begin
		iCORE_CLOCK = !iCORE_CLOCK;
	end

	always#(PL_BUS_CYCLE/2)begin
		iBUS_CLOCK = !iBUS_CLOCK;
	end

	always#(PL_DPS_CYCLE/2)begin
		iDPS_CLOCK = !iDPS_CLOCK;
	end
	

	/******************************************************
	State
	******************************************************/
	initial begin
		//Initial
		iCORE_CLOCK = 1'b0;
		iBUS_CLOCK = 1'b0;
		iDPS_CLOCK = 1'b0;
		inRESET = 1'b0;		
		iSCI_RXD = 1'b1;
		//iMEMORY_LOCK = 
		//iMEMORY_VALID = 
		//iMEMORY_DATA = 	
		iGCI_BUSY = 1'b0;
		iGCI_REQ = 1'b0;
		iGCI_DATA = 32'h0;
		iGCI_IRQ_REQ = 1'b0;
		iGCI_IRQ_NUM = 6'h0;
		iDEBUG_UART_RXD = 1'b1;
		iDEBUG_PARA_REQ = 1'b0;
		iDEBUG_PARA_CMD = 8'h0;
		iDEBUG_PARA_DATA = 32'h0;
		iDEBUG_PARA_BUSY = 1'b0;

		//Reset After
		#(PL_RESET_TIME);
		inRESET = 1'b1;

		

`default_nettype wire 


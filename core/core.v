/****************************************
	MIST1032 - Core
	
	Version	:	A0001
	Make	:	2011/01/20
	Update	:	2011/12/21
	
	Include file
		- core_info.h
		
	Update Histry
		2011/12/21 - IO Connect
		2011/01/20 - Make
****************************************/
`default_nettype none
`include "global.h"



module core
	#(
		parameter		CORE_ID		=	32'h0
	)(
		/****************************************
		System
		****************************************/
		input					iCLOCK,
		input					inRESET,	
		/****************************************
		Core
		****************************************/
		output					oCORE_FLASH,
		/****************************************
		GCI Controll
		****************************************/
		//Interrupt Controll
		output					oIO_IRQ_CONFIG_TABLE_REQ,
		output	[5:0]			oIO_IRQ_CONFIG_TABLE_ENTRY,
		output					oIO_IRQ_CONFIG_TABLE_FLAG_MASK,
		output					oIO_IRQ_CONFIG_TABLE_FLAG_VALID,
		output	[1:0]			oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL,		
		/****************************************
		Instruction Memory
		****************************************/
		//Req
		output					oINST_REQ,
		input					iINST_LOCK,
		output	[1:0]			oINST_MMUMOD,
		output	[31:0]			oINST_PDT,
		output	[31:0]			oINST_ADDR,
		//This -> Data RAM
		//output	[31:0]			oINST_DATA,
		//RAM -> This
		input					iINST_VALID,
		output					oINST_BUSY,		//new
		input	[63:0]			iINST_DATA,
		input	[27:0]			iINST_MMU_FLAGS,
		/****************************************
		Data Memory
		****************************************/
		//Req
		output					oDATA_REQ,
		input					iDATA_LOCK,
		output	[1:0]			oDATA_ORDER,
		output					oDATA_RW,		//0=Write 1=Read
		output	[13:0]			oDATA_TID,
		output	[1:0]			oDATA_MMUMOD,
		output	[31:0]			oDATA_PDT,
		output	[31:0]			oDATA_ADDR,
		//This -> Data RAM
		output	[31:0]			oDATA_DATA,
		//Data RAM -> This
		input					iDATA_VALID,
		input	[63:0]			iDATA_DATA,
		/****************************************
		IO
		****************************************/
		//Req
		output					oIO_REQ,
		input					iIO_BUSY,
		output	[1:0]			oIO_ORDER,
		output					oIO_RW,			//0=Write 1=Read
		output	[31:0]			oIO_ADDR,
		//Write
		output	[31:0]			oIO_DATA,
		//Rec
		input					iIO_VALID,
		input	[31:0]			iIO_DATA,
		/****************************************
		Interrupt
		****************************************/
		input					iINTERRUPT_VALID,
		output					oINTERRUPT_ACK,
		input	[5:0]			iINTERRUPT_NUM,
		/****************************************
		System Infomation
		****************************************/
		input					iSYSINFO_IOSR_VALID,
		input	[31:0]			iSYSINFO_IOSR,
		output	[31:0]			oDEBUG_PC,
		output	[31:0]			oDEBUG0,
		/****************************************
		Debug
		****************************************/
		input iDEBUG_CMD_REQ,
		output oDEBUG_CMD_BUSY,
		input [3:0] iDEBUG_CMD_COMMAND,
		input [11:0] iDEBUG_CMD_TARGET,
		input [31:0] iDEBUG_CMD_DATA,
		output oDEBUG_CMD_VALID,
		output oDEBUG_CMD_ERROR,
		output [31:0] oDEBUG_CMD_DATA
	);
		
	
	
	wire			inst_fetch2cache_request_lock_cc;
	wire			inst_cache2memory_request_lock_cc;
	wire			inst_cache_mem2fetch_request_lock_cc;
				
	/************************************************************************************
	Wire and Register
	************************************************************************************/		
	//IO Start Address Buffer
	reg				b_io_startaddr_valid;
	reg		[31:0]	b_io_startaddr;
	//Load State 
	reg				b_ldst_state;
	reg				b_ldst_type;	//0:IO | 1:DATA
	//Core Info
	wire			core_flash;
	//Instruction
	wire			core2inst_fetch_req;
	wire	[13:0]	core2inst_fetch_tid;
	wire	[1:0]	core2inst_fetch_mmumod;
	wire	[31:0]	core2inst_fetch_pdt;
	wire	[31:0]	core2inst_fetch_addr;
	wire			core2inst_fetch_busy;
	//Load Store
	wire			core2ldst_req;
	wire	[1:0]	core2ldst_order;
	wire			core2ldst_rw;
	wire	[13:0]	core2ldst_tid;
	wire	[1:0]	core2ldst_mmumod;
	wire	[31:0]	core2ldst_pdt;
	wire	[31:0]	core2ldst_addr;
	wire	[31:0]	core2ldst_data;
	//Instruction Cache
	wire			inst_l1_cache_rd_lock;
	wire			inst_l1_cache_rd_valid;
	wire			inst_l1_cache_rd_hit;
	wire	[63:0]	inst_l1_cache_rd_data;
	wire	[11:0]	inst_l1_cache_rd_mmuflags;		
	wire			inst_l1_cache_wr_lock;
	//Instruction Memory Acess Controllor
	reg				b_inst_mem_state;
	reg		[31:0]	b_inst_core2mem_addr;
	reg		[13:0]	b_inst_core2mem_tid;
	reg		[1:0]	b_inst_core2mem_mmumod;
	reg		[31:0]	b_inst_core2mem_pdt;
	//instruction Memory Matching Bridge
	wire		inst_matching_bridge_full;
	wire		inst_matching_bridge_valid;
	//Data Memory matching Bridge
	wire		dataio_matching_bridge_full;
	wire		dataio_valid;
	
	/************************************************************************************
	Core - Main Pipeline
	************************************************************************************/	
	core_pipeline #(CORE_ID) CORE_PIPELINE(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Core
		.oCORE_FLASH(core_flash),	
		//GCI Interrupt Controll
		//Interrupt Control
		.oIO_IRQ_CONFIG_TABLE_REQ(oIO_IRQ_CONFIG_TABLE_REQ),
		.oIO_IRQ_CONFIG_TABLE_ENTRY(oIO_IRQ_CONFIG_TABLE_ENTRY),
		.oIO_IRQ_CONFIG_TABLE_FLAG_MASK(oIO_IRQ_CONFIG_TABLE_FLAG_MASK),
		.oIO_IRQ_CONFIG_TABLE_FLAG_VALID(oIO_IRQ_CONFIG_TABLE_FLAG_VALID),
		.oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL(oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL),
		//Instruction Memory Request
		.oINST_FETCH_REQ(oINST_REQ),
		.iINST_FETCH_BUSY(iINST_LOCK),
		.oINST_FETCH_MMUMOD(oINST_MMUMOD),
		.oINST_FETCH_PDT(oINST_PDT),
		.oINST_FETCH_ADDR(oINST_ADDR),
		.iINST_VALID(iINST_VALID),
		.iINST_MMU_FLAGS(iINST_MMU_FLAGS),
		.oINST_BUSY(oINST_BUSY),
		.iINST_DATA(iINST_DATA),
		/****************************************
		Data Memory
		****************************************/
		//Req
		.oDATA_REQ(oDATA_REQ),
		.iDATA_LOCK(iDATA_LOCK),
		.oDATA_ORDER(oDATA_ORDER),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oDATA_RW(oDATA_RW),			//1=Write 0=Read
		.oDATA_TID(oDATA_TID),
		.oDATA_MMUMOD(oDATA_MMUMOD),
		.oDATA_PDT(oDATA_PDT),
		.oDATA_ADDR(oDATA_ADDR),
		//This -> Data RAM
		.oDATA_DATA(oDATA_DATA),
		//Data RAM -> This
		.iDATA_VALID(iDATA_VALID),
		.iDATA_DATA(iDATA_DATA),
		/****************************************
		IO
		****************************************/
		//Req
		.oIO_REQ(oIO_REQ),
		.iIO_BUSY(iIO_BUSY),
		.oIO_ORDER(oIO_ORDER),		//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oIO_RW(oIO_RW),			//0=Write 1=Read
		.oIO_ADDR(oIO_ADDR),
		//Write
		.oIO_DATA(oIO_DATA),
		//Rec
		.iIO_VALID(iIO_VALID),
		.iIO_DATA(iIO_DATA),	
		//Interrupt
		.iINTERRUPT_VALID(iINTERRUPT_VALID),
		.oINTERRUPT_ACK(oINTERRUPT_ACK),
		.iINTERRUPT_NUM(iINTERRUPT_NUM),
		.iSYSINFO_IOSR_VALID(iSYSINFO_IOSR_VALID),
		.iSYSINFO_IOSR(iSYSINFO_IOSR),
		.oDEBUG_PC(oDEBUG_PC),
		.oDEBUG0(debug0),
		/****************************************
		Debug
		****************************************/
		.iDEBUG_CMD_REQ(iDEBUG_CMD_REQ),
		.oDEBUG_CMD_BUSY(oDEBUG_CMD_BUSY),
		.iDEBUG_CMD_COMMAND(iDEBUG_CMD_COMMAND),
		.iDEBUG_CMD_TARGET(iDEBUG_CMD_TARGET),
		.iDEBUG_CMD_DATA(iDEBUG_CMD_DATA),
		.oDEBUG_CMD_VALID(oDEBUG_CMD_VALID),
		.oDEBUG_CMD_ERROR(oDEBUG_CMD_ERROR),
		.oDEBUG_CMD_DATA(oDEBUG_CMD_DATA)
	);
	
	
	
	wire [31:0] debug0;
	//assign oDEBUG0 = {iDATA_LOCK, iIO_BUSY, !b_io_startaddr_valid, dataio_valid, b_ldst_state, debug0[2:0]};
	assign oDEBUG0 = debug0;
	
	assign			inst_fetch2cache_request_lock_cc		=	inst_matching_bridge_full || iINST_LOCK || inst_l1_cache_rd_lock || (inst_l1_cache_rd_valid && !inst_l1_cache_rd_hit);
	
	assign			inst_cache2memory_request_lock_cc		=	iINST_LOCK;
	
	assign			inst_cache_mem2fetch_request_lock_cc	=	core2inst_fetch_busy || inst_l1_cache_wr_lock || iINST_LOCK;
	
	

	/************************************************************************************
	Data I/O Pipeline
	************************************************************************************/	

	
	
	/****************************************
	Assign
	****************************************/
	//Core
	assign		oCORE_FLASH			=		core_flash;
	//Instruction Memory
	/*
	assign		oINST_REQ			=		inst_l1_cache_rd_valid && !inst_l1_cache_rd_hit && !iINST_LOCK;
	assign		oINST_TID			=		b_inst_core2mem_tid;
	assign		oINST_MMUMOD		=		b_inst_core2mem_mmumod;
	assign		oINST_PDT			=		b_inst_core2mem_pdt;
	assign		oINST_ADDR			=		b_inst_core2mem_addr;
	assign		oINST_BUSY			=		inst_cache_mem2fetch_request_lock_cc;
	*/
	
	
	
	//Data Memory
	/*
	assign		oDATA_REQ			=		core2ldst_req && !(core2ldst_addr >= b_io_startaddr);
	assign		oDATA_ORDER			=		core2ldst_order;
	assign		oDATA_RW			=		core2ldst_rw;
	assign		oDATA_TID			=		core2ldst_tid;
	assign		oDATA_MMUMOD		=		core2ldst_mmumod;
	assign		oDATA_PDT			=		core2ldst_pdt;
	assign		oDATA_ADDR			=		core2ldst_addr;
	assign		oDATA_DATA			=		core2ldst_data;
	//IO
	assign		oIO_REQ				=		core2ldst_req && (core2ldst_addr >= b_io_startaddr);
	assign		oIO_ORDER			=		core2ldst_order;
	assign		oIO_RW				=		!core2ldst_rw;
	assign		oIO_ADDR			=		core2ldst_addr - b_io_startaddr;
	assign		oIO_DATA			=		core2ldst_data;
	*/
endmodule


`default_nettype wire
			
			
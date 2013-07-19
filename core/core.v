/****************************************
MIST1032 - Core
****************************************/
`default_nettype none



module core
	#(
		parameter CORE_ID = 32'h0
	)(
		/****************************************
		System
		****************************************/
		input wire iCLOCK,
		input wire inRESET,	
		/****************************************
		Core
		****************************************/
		//oCORE_FLASH,
		output wire oFREE_TLB_FLUSH,
		/****************************************
		GCI Controll
		****************************************/
		//Interrupt Controll
		output wire oIO_IRQ_CONFIG_TABLE_REQ,
		output wire [5:0] oIO_IRQ_CONFIG_TABLE_ENTRY,
		output wire oIO_IRQ_CONFIG_TABLE_FLAG_MASK,
		output wire oIO_IRQ_CONFIG_TABLE_FLAG_VALID,
		output wire [1:0] oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL,		
		/****************************************
		Instruction Memory
		****************************************/
		//Req
		output wire oINST_REQ,
		input wire iINST_LOCK,
		output wire [1:0] oINST_MMUMOD,
		output wire [31:0] oINST_PDT,
		output wire [31:0] oINST_ADDR,
		//RAM -> This
		input wire iINST_VALID,
		output wire oINST_BUSY,
		input wire iINST_PAGEFAULT,
		input wire iINST_QUEUE_FLUSH,
		input wire [63:0] iINST_DATA,
		input wire [27:0] iINST_MMU_FLAGS,
		/****************************************
		Data Memory
		****************************************/
		//Req
		output wire oDATA_REQ,
		input wire iDATA_LOCK,
		output wire [1:0] oDATA_ORDER,
		output wire oDATA_RW,		//0=Write 1=Read
		output wire [13:0] oDATA_TID,
		output wire [1:0] oDATA_MMUMOD,
		output wire [31:0] oDATA_PDT,
		output wire [31:0] oDATA_ADDR,
		//This -> Data RAM
		output wire [31:0] oDATA_DATA,
		//Data RAM -> This
		input wire iDATA_VALID,
		input wire iDATA_PAGEFAULT,
		input wire [63:0] iDATA_DATA,
		input wire [27:0] iDATA_MMU_FLAGS,
		/****************************************
		IO
		****************************************/
		//Req
		output wire oIO_REQ,
		input wire iIO_BUSY,
		output wire [1:0] oIO_ORDER,
		output wire oIO_RW,			//0=Write 1=Read
		output wire [31:0] oIO_ADDR,
		//Write
		output wire [31:0] oIO_DATA,
		//Rec
		input wire iIO_VALID,
		input wire [31:0] iIO_DATA,
		/****************************************
		Interrupt
		****************************************/
		input wire iINTERRUPT_VALID,
		output wire oINTERRUPT_ACK,
		input wire [5:0] iINTERRUPT_NUM,
		/****************************************
		System Infomation
		****************************************/
		input wire iSYSINFO_IOSR_VALID,
		input wire [31:0] iSYSINFO_IOSR,
		output wire [31:0] oDEBUG_PC,
		output wire [31:0] oDEBUG0,
		/****************************************
		Debug
		****************************************/
		input wire iDEBUG_CMD_REQ,
		output wire oDEBUG_CMD_BUSY,
		input wire [3:0] iDEBUG_CMD_COMMAND,
		input wire [7:0] iDEBUG_CMD_TARGET,
		input wire [31:0] iDEBUG_CMD_DATA,
		output wire oDEBUG_CMD_VALID,
		output wire oDEBUG_CMD_ERROR,
		output wire [31:0] oDEBUG_CMD_DATA
	);
		
	
	wire inst_fetch2cache_request_lock_cc;
	wire inst_cache2memory_request_lock_cc;
	wire inst_cache_mem2fetch_request_lock_cc;
				
	/************************************************************************************
	Wire and Register
	************************************************************************************/		
	//IO Start Address Buffer
	reg b_io_startaddr_valid;
	reg [31:0] b_io_startaddr;
	//Load State 
	reg b_ldst_state;
	reg b_ldst_type;	//0:IO | 1:DATA
	//Core Info
	//Instruction
	wire core2inst_fetch_req;
	wire [13:0] core2inst_fetch_tid;
	wire [1:0] core2inst_fetch_mmumod;
	wire [31:0] core2inst_fetch_pdt;
	wire [31:0] core2inst_fetch_addr;
	wire core2inst_fetch_busy;
	//Load Store
	wire core2ldst_req;
	wire [1:0] core2ldst_order;
	wire core2ldst_rw;
	wire [13:0] core2ldst_tid;
	wire [1:0] core2ldst_mmumod;
	wire [31:0] core2ldst_pdt;
	wire [31:0] core2ldst_addr;
	wire [31:0] core2ldst_data;
	//Instruction Cache
	wire inst_l1_cache_rd_lock;
	wire inst_l1_cache_rd_valid;
	wire inst_l1_cache_rd_hit;
	wire [63:0] inst_l1_cache_rd_data;
	wire [11:0] inst_l1_cache_rd_mmuflags;		
	wire inst_l1_cache_wr_lock;
	//Instruction Memory Acess Controllor
	reg b_inst_mem_state;
	reg [31:0] b_inst_core2mem_addr;
	reg [13:0] b_inst_core2mem_tid;
	reg [1:0] b_inst_core2mem_mmumod;
	reg [31:0] b_inst_core2mem_pdt;
	//instruction Memory Matching Bridge
	wire inst_matching_bridge_full;
	wire inst_matching_bridge_valid;
	//Data Memory matching Bridge
	wire dataio_matching_bridge_full;
	wire dataio_valid;
	
	/************************************************************************************
	Core - Main Pipeline
	************************************************************************************/	
	core_pipeline #(CORE_ID) CORE_PIPELINE(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Core
		.oFREE_TLB_FLUSH(oFREE_TLB_FLUSH),
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
		.oINST_BUSY(oINST_BUSY),
		.iINST_PAGEFAULT(iINST_PAGEFAULT),
		.iINST_QUEUE_FLUSH(iINST_QUEUE_FLUSH),
		.iINST_DATA(iINST_DATA),
		.iINST_MMU_FLAGS(iINST_MMU_FLAGS),
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
		.iDATA_PAGEFAULT(iDATA_PAGEFAULT),
		.iDATA_DATA(iDATA_DATA),
		.iDATA_MMU_FLAGS(iDATA_MMU_FLAGS),
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
	
	assign inst_fetch2cache_request_lock_cc = inst_matching_bridge_full || iINST_LOCK || inst_l1_cache_rd_lock || (inst_l1_cache_rd_valid && !inst_l1_cache_rd_hit);
	
	assign inst_cache2memory_request_lock_cc = iINST_LOCK;
	
	assign inst_cache_mem2fetch_request_lock_cc = core2inst_fetch_busy || inst_l1_cache_wr_lock || iINST_LOCK;
	

endmodule


`default_nettype wire
			
			
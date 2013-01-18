/****************************************
	MIST1032 - Core-Main Pipeline
	
	Make	:	2012/02/18
****************************************/
`default_nettype none

module core_pipeline
	#(
		parameter		CORE_ID		=	32'h0
	)(
		//System
		input					iCLOCK,
		input					inRESET,
		/****************************************
		System
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
		Instrution Memory
		****************************************/				
		//Memory Instruction-Request
		output					oINST_FETCH_REQ,
		input					iINST_FETCH_BUSY,
		output	[1:0]			oINST_FETCH_MMUMOD,
		output	[31:0]			oINST_FETCH_PDT,
		output	[31:0]			oINST_FETCH_ADDR,
		//Memory Instruction-Get
		input					iINST_VALID,
		input	[27:0]			iINST_MMU_FLAGS,
		output					oINST_BUSY,
		input	[63:0]			iINST_DATA,
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
		input	[5:0]			iINTERRUPT_NUM,
		output					oINTERRUPT_ACK,
		/****************************************
		System Infomation
		****************************************/
		//IOSR(Input Output Status Register)
		input					iSYSINFO_IOSR_VALID,	
		input	[31:0]			iSYSINFO_IOSR,
		output	[31:0]			oDEBUG_PC,
		output	[31:0]			oDEBUG0,
		/****************************************
		Debug Module
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
	
	
	assign oDEBUG0 = sysreg_ppcr;//{iINST_FETCH_BUSY, oINST_BUSY, icache2fetch_lock, fetch2icache_lock, lbuffer2fetch_fetch_lock, decoder2lbuffer_lock, dispatch2decoder_lock, execution2dispatch_lock, iLDST_BUSY, ldst2execution_ldst_busy, ldst2exception_ldst_busy};
	assign oDEBUG_PC = debug_register2debug_pcr;
	
	
	
	//Cache
	wire icache2fetch_valid;
	wire [31:0] icache2fetch_inst;
	wire [13:0] icache2fetch_mmu_flags;
	wire fetch2icache_lock;
	wire fetch2icache_req;
	wire [1:0] fetch2icache_mmumod;
	wire [31:0] fetch2icache_addr;
	wire icache2fetch_lock;
	wire cache_flash;
	//Free
	wire				free_pc_set;
	wire	[31:0]		free_pc;
	wire				free_ppcr_set;
	wire	[31:0]		free_ppcr;
	wire				free_register_lock;
	wire				free_pipeline_stop;
	wire				free_refresh;
	wire				free_restart;
	wire				free_set_irq_mode;
	wire				free_clr_irq_mode;
	wire				free_new_spr_valid;
	wire	[31:0]		free_new_spr;		
	//Fetch
	wire			fetch2lbuffer_inst_valid;
	wire	[13:0]	fetch2lbuffer_mmu_flags;
	wire fetch2lbuffer_paging_ena;
	wire fetch2lbuffer_kernel_access;
	wire	[31:0]	fetch2lbuffer_inst;
	wire	[31:0]	fetch2lbuffer_pc;
	wire			lbuffer2fetch_fetch_stop;
	wire			lbuffer2fetch_fetch_lock;	
	//Decoder
	wire			lbuffer2decoder_inst_valid;	
	wire	[13:0]	lbuffer2decoder_mmu_flags;	
	wire lbuffer2decoder_paging_ena;
	wire lbuffer2decoder_kernel_access;
	wire	[31:0]	lbuffer2decoder_inst;
	wire	[31:0]	lbuffer2decoder_pc;
	wire			decoder2lbuffer_lock;
	//Dispatch
	wire			decoder2dispatch_valid;
	wire			decoder2dispatch_source0_active;
	wire			decoder2dispatch_source1_active;
	wire			decoder2dispatch_source0_sysreg;
	wire			decoder2dispatch_source1_sysreg;
	wire			decoder2dispatch_destination_sysreg;
	wire			decoder2dispatch_writeback;
	wire			decoder2dispatch_flags_writeback;
	wire	[4:0]	decoder2dispatch_cmd;
	wire	[3:0]	decoder2dispatch_cc_afe;
	wire	[4:0]	decoder2dispatch_source0;
	wire	[31:0]	decoder2dispatch_source1;
	wire			decoder2dispatch_source0_flags;
	wire			decoder2dispatch_source1_imm;
	wire	[4:0]	decoder2dispatch_destination;
	wire			decoder2dispatch_ex_sys_reg;
	wire			decoder2dispatch_ex_sys_ldst;
	wire			decoder2dispatch_ex_logic;
	wire			decoder2dispatch_ex_shift;
	wire			decoder2dispatch_ex_addr;
	wire			decoder2dispatch_ex_mul;
	wire			decoder2dispatch_ex_sdiv;
	wire			decoder2dispatch_ex_udiv;
	wire			decoder2dispatch_ex_ldst;
	wire			decoder2dispatch_ex_branch;
	wire	[31:0]	decoder2dispatch_pc;
	wire			dispatch2decoder_lock;
	//Execution
	wire			dispatch2execution_valid;
	wire [31:0] dispatch2execution_sysreg_psr;
	wire [31:0] dispatch2execution_sysreg_tidr;
	wire [31:0] dispatch2execution_sysreg_pdtr;
	wire			dispatch2execution_destination_sysreg;
	wire			dispatch2execution_writeback;
	wire			dispatch2execution_flags_writeback;
	wire	[4:0]	dispatch2execution_cmd;
	wire	[3:0]	dispatch2execution_cc_afe;
	wire	[31:0]	dispatch2execution_spr;
	wire	[31:0]	dispatch2execution_source0;
	wire	[31:0]	dispatch2execution_source1;
	wire	[4:0]	dispatch2execution_source0_pointer;
	wire	[4:0]	dispatch2execution_source1_pointer;
	wire			dispatch2execution_source0_sysreg;
	wire			dispatch2execution_source1_sysreg;
	wire			dispatch2execution_source1_imm;
	wire			dispatch2execution_source0_flags;
	wire	[4:0]	dispatch2execution_destination;
	wire			dispatch2execution_ex_sys_reg;
	wire			dispatch2execution_ex_sys_ldst;
	wire			dispatch2execution_ex_logic;
	wire			dispatch2execution_ex_shift;
	wire			dispatch2execution_ex_addr;
	wire			dispatch2execution_ex_mul;
	wire			dispatch2execution_ex_sdiv;
	wire			dispatch2execution_ex_udiv;
	wire			dispatch2execution_ex_ldst;
	wire			dispatch2execution_ex_branch;
	wire	[31:0]	dispatch2execution_pc;
	wire			execution2dispatch_lock;
	//Writeback
	wire			execution2dispatch_valid;
	wire	[31:0]	execution2dispatch_data;
	wire	[4:0]	execution2dispatch_destination;
	wire			execution2dispatch_destination_sysreg;
	wire			execution2dispatch_writeback;
	wire			execution2dispatch_spr_writeback;
	wire	[31:0]	execution2dispatch_spr;		
	wire	[31:0]	execution2dispatch_pc;
	wire			execution2dispatch_branch;
	wire	[31:0]	execution2dispatch_branch_pc;
	//Load Store 
	wire			execution2ldst_ldst_req;
	wire	[1:0]	execution2ldst_ldst_order;
	wire			execution2ldst_ldst_rw;
	wire	[13:0]	execution2ldst_ldst_tid;
	wire	[1:0]	execution2ldst_ldst_mmumod;
	wire	[31:0]	execution2ldst_ldst_pdt;
	wire	[31:0]	execution2ldst_ldst_addr;
	wire	[31:0]	execution2ldst_ldst_data;
	wire			ldst2execution_ldst_busy;
	wire			ldst2execution_ldst_req;
	wire	[31:0]	ldst2execution_ldst_data;
	
	
	//System Register
	wire	[31:0]	sysreg_spr;
	wire	[31:0]	sysreg_idtr;
	wire	[31:0]	sysreg_tisr;
	wire	[31:0]	sysreg_tidr;
	wire	[31:0]	sysreg_psr;
	wire	[31:0]	sysreg_ppsr;
	wire	[31:0]	sysreg_pcr;
	wire	[31:0]	sysreg_ppcr;
	
	//Interrupt Lock
	wire interrupt_lock;
	wire dispatch_exception_lock;
	wire execute_exception_lock;
	
	//Exception Manager
	wire exception2ldst_ldst_use;
	wire exception2ldst_ldst_req;
	wire ldst2exception_ldst_busy;
	wire [1:0] exception2ldst_ldst_order;
	wire exception2ldst_ldst_rw;
	wire [13:0] exception2ldst_ldst_tid;
	wire [1:0] exception2ldst_ldst_mmumod;
	wire [31:0] exception2ldst_ldst_pdt;
	wire [31:0] exception2ldst_ldst_addr;
	wire [31:0] exception2ldst_ldst_data;
	wire ldst2exception_ldst_req;
	wire [31:0] ldst2exception_ldst_data;
	wire exception_jump_valid;
	wire [31:0] exception_branch_addr;
	wire exception_intr_valid;
	wire exception2cim_ict_req;
	wire [5:0] exception2cim_ict_entry;
	wire exception2cim_ict_conf_mask;
	wire exception2cim_ict_conf_valid;
	wire [1:0] exception2cim_ict_conf_level;
	
	wire exception2cim_irq_lock;	
	wire cim2exception_irq_req;
	wire [6:0] cim2exception_irq_num;
	wire exception2cim_irq_ack;
	wire exception_idtset_valid;
	wire exception_swi_valid;
	wire [6:0] exception_swi_num;
	
	wire sysreg_write_pdtr;
	
	//Debug
	wire [31:0] debug_register2debug_gr0;
	wire [31:0] debug_register2debug_gr1;
	wire [31:0] debug_register2debug_gr2;
	wire [31:0] debug_register2debug_gr3;
	wire [31:0] debug_register2debug_gr4;
	wire [31:0] debug_register2debug_gr5;
	wire [31:0] debug_register2debug_gr6;
	wire [31:0] debug_register2debug_gr7;
	wire [31:0] debug_register2debug_gr8;
	wire [31:0] debug_register2debug_gr9;
	wire [31:0] debug_register2debug_gr10;
	wire [31:0] debug_register2debug_gr11;
	wire [31:0] debug_register2debug_gr12;
	wire [31:0] debug_register2debug_gr13;
	wire [31:0] debug_register2debug_gr14;
	wire [31:0] debug_register2debug_gr15;
	wire [31:0] debug_register2debug_gr16;
	wire [31:0] debug_register2debug_gr17;
	wire [31:0] debug_register2debug_gr18;
	wire [31:0] debug_register2debug_gr19;
	wire [31:0] debug_register2debug_gr20;
	wire [31:0] debug_register2debug_gr21;
	wire [31:0] debug_register2debug_gr22;
	wire [31:0] debug_register2debug_gr23;
	wire [31:0] debug_register2debug_gr24;
	wire [31:0] debug_register2debug_gr25;
	wire [31:0] debug_register2debug_gr26;
	wire [31:0] debug_register2debug_gr27;
	wire [31:0] debug_register2debug_gr28;
	wire [31:0] debug_register2debug_gr29;
	wire [31:0] debug_register2debug_gr30;
	wire [31:0] debug_register2debug_gr31;
	wire [31:0] debug_register2debug_flagr;
	wire [31:0] debug_register2debug_spr;
	wire [31:0] debug_register2debug_pcr;
	wire [31:0] debug_register2debug_ppcr;	
	wire [31:0] debug_register2debug_psr;	
	wire [31:0] debug_register2debug_ppsr;
	wire debug_debug2corectrl_req;
	wire debug_debug2corectrl_stop;
	wire debug_debug2corectrl_start;
	wire debug_corectrl2debug_ack;
	
	
	
	
	core_interrupt_manager CORE_INT_M(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Exception
		.iFREE_IRQ_SETCONDITION(free_set_irq_mode),
		//Core Interrupt Configlation Table
		.iICT_VALID(exception2cim_ict_req),
		.iICT_ENTRY(exception2cim_ict_entry),
		.iICT_CONF_MASK(exception2cim_ict_conf_mask),
		.iICT_CONF_VALID(exception2cim_ict_conf_valid),	
		.iICT_CONF_LEVEL(exception2cim_ict_conf_level),	
		//Sysreg
		.iSYSREGINFO_PSR(sysreg_psr),
		//Interrupt Input
		.iEXT_ACTIVE(iINTERRUPT_VALID),
		.iEXT_NUM(iINTERRUPT_NUM),
		.oEXT_ACK(oINTERRUPT_ACK),
		//Internal IRQ
		.iSWI_ACTIVE(exception_swi_valid),
		.iSWI_NUM(exception_swi_num),
		//To Exception Manager
		.iEXCEPTION_LOCK(exception2cim_irq_lock),
		.oEXCEPTION_ACTIVE(cim2exception_irq_req),
		.oEXCEPTION_IRQ_NUM(cim2exception_irq_num),
		.iEXCEPTION_IRQ_ACK(exception2cim_irq_ack)
	);
	

	
	
	exception_manager CORE_IM(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		/************************************
		Free
		************************************/
		.oFREE_REGISTER_LOCK(free_register_lock),
		.oFREE_PIPELINE_STOP(free_pipeline_stop),
		.oFREE_REFRESH(free_refresh),
		.oFREE_RESTART(free_restart),
		.oFREE_PC_SET(free_pc_set),
		.oFREE_PC(free_pc),
		.oFREE_PPCR_SET(free_ppcr_set),
		.oFREE_PPCR(free_ppcr),
		.oFREE_SET_IRQ_MODE(free_set_irq_mode),
		.oFREE_CLR_IRQ_MODE(free_clr_irq_mode),
		/************************************
		Interrupt Lock
		************************************/
		.iINTERRUPT_LOCK(interrupt_lock),
		/************************************
		System Register
		************************************/
		//Input
		.iSYSREG_SPR(sysreg_spr),
		.iSYSREG_TIDR(sysreg_tidr),
		.iSYSREG_TISR(sysreg_tisr),
		.iSYSREG_PSR(sysreg_psr),
		.iSYSREG_PPSR(sysreg_ppsr),
		.iSYSREG_PCR(sysreg_pcr),
		.iSYSREG_PPCR(sysreg_ppcr),
		.iSYSREG_IDTR(sysreg_idtr),
		//Write
		.oSYSREG_SPR_WRITE(free_new_spr_valid),	
		.oSYSREG_SPR(free_new_spr),
		/************************************
		Load Store
		************************************/
		//IO Port
		.oLDST_USE(exception2ldst_ldst_use),
		.oLDST_REQ(exception2ldst_ldst_req),
		.iLDST_BUSY(ldst2exception_ldst_busy),
		.oLDST_ORDER(exception2ldst_ldst_order),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oLDST_RW(exception2ldst_ldst_rw),		//0=Read 1=Write
		.oLDST_TID(exception2ldst_ldst_tid),
		.oLDST_MMUMOD(exception2ldst_ldst_mmumod),
		.oLDST_PDT(exception2ldst_ldst_pdt),
		.oLDST_ADDR(exception2ldst_ldst_addr),
		.oLDST_DATA(exception2ldst_ldst_data),
		.iLDST_REQ(ldst2exception_ldst_req),
		.iLDST_DATA(ldst2exception_ldst_data),
		/************************************
		Interrupt Configlation Table
		************************************/
		//GCI Interrupt Configlation Table
		.oIO_IRQ_CONFIG_TABLE_REQ(oIO_IRQ_CONFIG_TABLE_REQ),
		.oIO_IRQ_CONFIG_TABLE_ENTRY(oIO_IRQ_CONFIG_TABLE_ENTRY),
		.oIO_IRQ_CONFIG_TABLE_FLAG_MASK(oIO_IRQ_CONFIG_TABLE_FLAG_MASK),
		.oIO_IRQ_CONFIG_TABLE_FLAG_VALID(oIO_IRQ_CONFIG_TABLE_FLAG_VALID),	
		.oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL(oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL),	
		//Core Interrupt Configlation Table
		.oICT_REQ(exception2cim_ict_req),
		.oICT_ENTRY(exception2cim_ict_entry),
		.oICT_CONF_MASK(exception2cim_ict_conf_mask),
		.oICT_CONF_VALID(exception2cim_ict_conf_valid),	
		.oICT_CONF_LEVEL(exception2cim_ict_conf_level),	
		/************************************
		Exception Input
		************************************/
		//Core Branch
		.iEXCEPT_JUMP(exception_jump_valid),					
		.iEXCEPT_JUMP_ADDR(exception_branch_addr),
		.iEXCEPT_IDTS(exception_idtset_valid),					
		.iEXCEPT_IDTS_ADDR(exception_branch_addr),
		.iEXCEPT_IB(exception_intr_valid),					
		.iEXCEPT_IB_ADDR(exception_branch_addr),
		//External Exception
		.iEXCEPT_IRQ_REQ(cim2exception_irq_req),
		.iEXCEPT_IRQ_NUM(cim2exception_irq_num),
		.oEXCEPT_IRQ_ACK(exception2cim_irq_ack),
		.oEXCEPT_IRQ_BUSY(exception2cim_irq_lock)
	);

	assign interrupt_lock = execute_exception_lock || dispatch_exception_lock;
	
	
	core_paging_support PAGING_SUPPORT(
		.iSYSREG_PSR(sysreg_psr),
		.iPDTR_WRITEBACK(sysreg_write_pdtr),
		//Cache
		.oCACHE_FLASH(cache_flash)
	);
	
	
	//Cache
	l1_instruction_cache L1_INST_CACHE(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Remove
		.iREMOVE(free_refresh),
		.iCACHE_FLASH(cache_flash),
		/****************************************
		Memory Port Memory
		****************************************/
		//Req
		.oINST_REQ(oINST_FETCH_REQ),
		.iINST_LOCK(iINST_FETCH_BUSY),
		.oINST_MMUMOD(oINST_FETCH_MMUMOD),
		.oINST_ADDR(oINST_FETCH_ADDR),
		//
		.iINST_VALID(iINST_VALID),
		.oINST_BUSY(oINST_BUSY),		//new
		.iINST_DATA(iINST_DATA),
		.iINST_MMU_FLAGS(iINST_MMU_FLAGS),
		/****************************************
		Fetch Module
		****************************************/
		//From Fetch
		.iNEXT_FETCH_REQ(fetch2icache_req),
		.oNEXT_FETCH_LOCK(icache2fetch_lock),
		.iNEXT_MMUMOD(fetch2icache_mmumod),
		.iNEXT_FETCH_ADDR(fetch2icache_addr),
		//To Fetch
		.oNEXT_0_INST_VALID(icache2fetch_valid),
		.oNEXT_0_MMU_FLAGS(icache2fetch_mmu_flags),
		.oNEXT_0_INST(icache2fetch_inst),
		.oNEXT_1_INST_VALID(),
		.oNEXT_1_MMU_FLAGS(),
		.oNEXT_1_INST(),
		.iNEXT_LOCK(fetch2icache_lock)
	);

	
	
	
	fetch FETCH(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Core
		.iSYSREG_PSR(sysreg_psr),
		//Exception
		.iEXCEPTION_EVENT(free_refresh),
		.iEXCEPTION_ADDR_SET(free_pc_set),
		.iEXCEPTION_ADDR(free_pc),
		.iEXCEPTION_RESTART(free_restart),
		//Previous
		.iPREVIOUS_INST_VALID(icache2fetch_valid),
		.iPREVIOUS_MMU_FLAGS(icache2fetch_mmu_flags),
		.iPREVIOUS_INST(icache2fetch_inst),
		.oPREVIOUS_LOCK(fetch2icache_lock),
		//Fetch
		.oPREVIOUS_FETCH_REQ(fetch2icache_req),
		.oPREVIOUS_MMUMOD(fetch2icache_mmumod),
		.oPREVIOUS_FETCH_ADDR(fetch2icache_addr),
		.iPREVIOUS_FETCH_LOCK(icache2fetch_lock),
		//Next
		.oNEXT_INST_VALID(fetch2lbuffer_inst_valid),
		.oNEXT_MMU_FLAGS(fetch2lbuffer_mmu_flags),
		.oNEXT_PAGING_ENA(fetch2lbuffer_paging_ena),
		.oNEXT_KERNEL_ACCESS(fetch2lbuffer_kernel_access),
		.oNEXT_INST(fetch2lbuffer_inst),
		.oNEXT_PC(fetch2lbuffer_pc),
		.iNEXT_FETCH_STOP(lbuffer2fetch_fetch_stop),
		.iNEXT_LOCK(lbuffer2fetch_fetch_lock)
	);
	
	
			
			
	loopbuffer LOOPBUFFER(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iFREE_REFRESH(free_refresh),
		//Prev
		.iPREVIOUS_INST_VALID(fetch2lbuffer_inst_valid),
		.iPREVIOUS_MMU_FLAGS(fetch2lbuffer_mmu_flags),
		.iPREVIOUS_PAGING_ENA(fetch2lbuffer_paging_ena),
		.iPREVIOUS_KERNEL_ACCESS(fetch2lbuffer_kernel_access),
		.iPREVIOUS_INST(fetch2lbuffer_inst),
		.iPREVIOUS_PC(fetch2lbuffer_pc),
		.oPREVIOUS_FETCH_STOP(lbuffer2fetch_fetch_stop),
		.oPREVIOUS_LOCK(lbuffer2fetch_fetch_lock),
		//Next
		.oNEXT_INST_VALID(lbuffer2decoder_inst_valid),
		.oNEXT_MMU_FLAGS(lbuffer2decoder_mmu_flags),
		.oNEXT_PAGING_ENA(lbuffer2decoder_paging_ena),
		.oNEXT_KERNEL_ACCESS(lbuffer2decoder_kernel_access),
		.oNEXT_INST(lbuffer2decoder_inst),
		.oNEXT_PC(lbuffer2decoder_pc),
		.iNEXT_LOCK(decoder2lbuffer_lock)
	);
					
			
			
	decoder DECODER(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Free
		.iFREE_DEFAULT(free_refresh),	
		//Previous
		.iPREVIOUS_INST_VALID(lbuffer2decoder_inst_valid),
		.iPREVIOUS_MMU_FLAGS(lbuffer2decoder_mmu_flags),
		.iPREVIOUS_PAGING_ENA(lbuffer2decoder_paging_ena),
		.iPREVIOUS_KERNEL_ACCESS(lbuffer2decoder_kernel_access),
		.iPREVIOUS_INST(lbuffer2decoder_inst),
		.iPREVIOUS_PC(lbuffer2decoder_pc),
		.oPREVIOUS_LOCK(decoder2lbuffer_lock),
		//Next-0		
		.oNEXT_VALID(decoder2dispatch_valid),
		.oNEXT_FAULT_PAGE_FAULT(),
		.oNEXT_FAULT_PRIVILEGE_ERROR(),
		.oNEXT_FAULT_INVALID_INST(),
		.oNEXT_SOURCE0_ACTIVE(decoder2dispatch_source0_active),			
		.oNEXT_SOURCE1_ACTIVE(decoder2dispatch_source1_active),		
		.oNEXT_SOURCE0_SYSREG(decoder2dispatch_source0_sysreg),		
		.oNEXT_SOURCE1_SYSREG(decoder2dispatch_source1_sysreg),		
		.oNEXT_SOURCE0_SYSREG_RENAME(),		
		.oNEXT_SOURCE1_SYSREG_RENAME(),		
		.oNEXT_DESTINATION_SYSREG(decoder2dispatch_destination_sysreg),	
		.oNEXT_DEST_RENAME(),		
		.oNEXT_WRITEBACK(decoder2dispatch_writeback),
		.oNEXT_FLAGS_WRITEBACK(decoder2dispatch_flags_writeback),
		.oNEXT_FRONT_COMMIT_WAIT(),				
		.oNEXT_CMD(decoder2dispatch_cmd),
		.oNEXT_CC_AFE(decoder2dispatch_cc_afe),
		.oNEXT_SOURCE0(decoder2dispatch_source0),
		.oNEXT_SOURCE1(decoder2dispatch_source1),
		.oNEXT_SOURCE0_FLAGS(decoder2dispatch_source0_flags),
		.oNEXT_SOURCE1_IMM(decoder2dispatch_source1_imm),
		.oNEXT_DESTINATION(decoder2dispatch_destination),
		.oNEXT_EX_SYS_REG(decoder2dispatch_ex_sys_reg),		
		.oNEXT_EX_SYS_LDST(decoder2dispatch_ex_sys_ldst),		
		.oNEXT_EX_LOGIC(decoder2dispatch_ex_logic),
		.oNEXT_EX_SHIFT(decoder2dispatch_ex_shift),
		.oNEXT_EX_ADDER(decoder2dispatch_ex_addr),
		.oNEXT_EX_MUL(decoder2dispatch_ex_mul),				
		.oNEXT_EX_SDIV(decoder2dispatch_ex_sdiv),		
		.oNEXT_EX_UDIV(decoder2dispatch_ex_udiv),		
		.oNEXT_EX_LDST(decoder2dispatch_ex_ldst),
		.oNEXT_EX_BRANCH(decoder2dispatch_ex_branch),
		.oNEXT_PC(decoder2dispatch_pc),
		.iNEXT_LOCK(dispatch2decoder_lock)
	);


	
	dispatch DISPATCH(
		//System 
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Exception Protect
		.oEXCEPTION_LOCK(dispatch_exception_lock),
		//IOSR
		.iSYSREGINFO_IOSR_VALID(iSYSINFO_IOSR_VALID),
		.iSYSREGINFO_IOSR(iSYSINFO_IOSR),
		.iFREE_REGISTER_LOCK(free_register_lock),
		.iFREE_PIPELINE_STOP(free_pipeline_stop),
		.iFREE_REFRESH(free_refresh),
		.iFREE_SYSREG_SET_IRQ_MODE(free_set_irq_mode),
		.iFREE_SYSREG_CLR_IRQ_MODE(free_clr_irq_mode),
		.iFREE_PPCR_SET(free_ppcr_set),
		.iFREE_PPCR(free_ppcr),
		//System Register
		.oSYSREG_PCR(sysreg_pcr),
		.oSYSREG_IDTR(sysreg_idtr),
		.oSYSREG_TISR(sysreg_tisr),
		.oSYSREG_TIDR(sysreg_tidr),
		.oSYSREG_PSR(sysreg_psr),
		.oSYSREG_PPSR(sysreg_ppsr),
		.oSYSREG_PPCR(sysreg_ppcr),
		.oSYSREG_SPR(sysreg_spr),
		//Pipeline 
		.iPREVIOUS_VALID(decoder2dispatch_valid),
		.iPREVIOUS_SOURCE0_ACTIVE(decoder2dispatch_source0_active),			
		.iPREVIOUS_SOURCE1_ACTIVE(decoder2dispatch_source1_active),		
		.iPREVIOUS_SOURCE0_SYSREG(decoder2dispatch_source0_sysreg),		
		.iPREVIOUS_SOURCE1_SYSREG(decoder2dispatch_source1_sysreg),		
		.iPREVIOUS_DESTINATION_SYSREG(decoder2dispatch_destination_sysreg),
		.iPREVIOUS_DESTINATION(decoder2dispatch_destination),			
		.iPREVIOUS_WRITEBACK(decoder2dispatch_writeback),	
		.iPREVIOUS_FLAGS_WRITEBACK(decoder2dispatch_flags_writeback),	
		.iPREVIOUS_CMD(decoder2dispatch_cmd),
		.iPREVIOUS_CC_AFE(decoder2dispatch_cc_afe),		
		.iPREVIOUS_SOURCE0(decoder2dispatch_source0),
		.iPREVIOUS_SOURCE1(decoder2dispatch_source1),
		.iPREVIOUS_SOURCE0_FLAGS(decoder2dispatch_source0_flags),
		.iPREVIOUS_SOURCE1_IMM(decoder2dispatch_source1_imm),	
		.iPREVIOUS_EX_SYS_REG(decoder2dispatch_ex_sys_reg),		
		.iPREVIOUS_EX_SYS_LDST(decoder2dispatch_ex_sys_ldst),		
		.iPREVIOUS_EX_LOGIC(decoder2dispatch_ex_logic),
		.iPREVIOUS_EX_SHIFT(decoder2dispatch_ex_shift),
		.iPREVIOUS_EX_ADDER(decoder2dispatch_ex_addr),
		.iPREVIOUS_EX_MUL(decoder2dispatch_ex_mul),
		.iPREVIOUS_EX_SDIV(decoder2dispatch_ex_sdiv),
		.iPREVIOUS_EX_UDIV(decoder2dispatch_ex_udiv),
		.iPREVIOUS_EX_LDST(decoder2dispatch_ex_ldst),
		.iPREVIOUS_EX_BRANCH(decoder2dispatch_ex_branch),
		.iPREVIOUS_PC(decoder2dispatch_pc),
		.oPREVIOUS_LOCK(dispatch2decoder_lock),
		//Next
		.oNEXT_VALID(dispatch2execution_valid),	
		.oNEXT_SYSREG_PSR(dispatch2execution_sysreg_psr),
		.oNEXT_SYSREG_TIDR(dispatch2execution_sysreg_tidr),
		.oNEXT_SYSREG_PDTR(dispatch2execution_sysreg_pdtr),
		.oNEXT_DESTINATION_SYSREG(dispatch2execution_destination_sysreg),
		.oNEXT_DESTINATION(dispatch2execution_destination),			
		.oNEXT_WRITEBACK(dispatch2execution_writeback),	
		.oNEXT_FLAGS_WRITEBACK(dispatch2execution_flags_writeback),	
		.oNEXT_CMD(dispatch2execution_cmd),
		.oNEXT_CC_AFE(dispatch2execution_cc_afe),
		.oNEXT_SPR(dispatch2execution_spr),
		.oNEXT_SOURCE0(dispatch2execution_source0),
		.oNEXT_SOURCE1(dispatch2execution_source1),
		.oNEXT_SOURCE0_POINTER(dispatch2execution_source0_pointer),
		.oNEXT_SOURCE1_POINTER(dispatch2execution_source1_pointer),
		.oNEXT_SOURCE0_SYSREG(dispatch2execution_source0_sysreg),
		.oNEXT_SOURCE1_SYSREG(dispatch2execution_source1_sysreg),
		.oNEXT_SOURCE1_IMM(dispatch2execution_source1_imm),
		.oNEXT_SOURCE0_FLAGS(dispatch2execution_source0_flags),
		.oNEXT_EX_SYS_REG(dispatch2execution_ex_sys_reg),		
		.oNEXT_EX_SYS_LDST(dispatch2execution_ex_sys_ldst),		
		.oNEXT_EX_LOGIC(dispatch2execution_ex_logic),
		.oNEXT_EX_SHIFT(dispatch2execution_ex_shift),
		.oNEXT_EX_ADDER(dispatch2execution_ex_addr),
		.oNEXT_EX_MUL(dispatch2execution_ex_mul),
		.oNEXT_EX_SDIV(dispatch2execution_ex_sdiv),
		.oNEXT_EX_UDIV(dispatch2execution_ex_udiv),
		.oNEXT_EX_LDST(dispatch2execution_ex_ldst),
		.oNEXT_EX_BRANCH(dispatch2execution_ex_branch),
		.oNEXT_PC(dispatch2execution_pc),
		.iNEXT_LOCK(execution2dispatch_lock),
		//Write Back
		.iWB_VALID(execution2dispatch_valid),
		.iWB_DATA(execution2dispatch_data),
		.iWB_DESTINATION(execution2dispatch_destination),
		.iWB_DESTINATION_SYSREG(execution2dispatch_destination_sysreg),
		.iWB_WRITEBACK(execution2dispatch_writeback),
		.iWB_SPR_WRITEBACK(execution2dispatch_spr_writeback),
		.iWB_SPR(execution2dispatch_spr),
		.iWB_PC(execution2dispatch_pc),
		.iWB_BRANCH(execution2dispatch_branch),
		.iWB_BRANCH_PC(execution2dispatch_branch_pc),
		//Debug
		.oDEBUG_REG_OUT_GR0(debug_register2debug_gr0),
		.oDEBUG_REG_OUT_GR1(debug_register2debug_gr1),
		.oDEBUG_REG_OUT_GR2(debug_register2debug_gr2),
		.oDEBUG_REG_OUT_GR3(debug_register2debug_gr3),
		.oDEBUG_REG_OUT_GR4(debug_register2debug_gr4),
		.oDEBUG_REG_OUT_GR5(debug_register2debug_gr5),
		.oDEBUG_REG_OUT_GR6(debug_register2debug_gr6),
		.oDEBUG_REG_OUT_GR7(debug_register2debug_gr7),
		.oDEBUG_REG_OUT_GR8(debug_register2debug_gr8),
		.oDEBUG_REG_OUT_GR9(debug_register2debug_gr9),
		.oDEBUG_REG_OUT_GR10(debug_register2debug_gr10),
		.oDEBUG_REG_OUT_GR11(debug_register2debug_gr11),
		.oDEBUG_REG_OUT_GR12(debug_register2debug_gr12),
		.oDEBUG_REG_OUT_GR13(debug_register2debug_gr13),
		.oDEBUG_REG_OUT_GR14(debug_register2debug_gr14),
		.oDEBUG_REG_OUT_GR15(debug_register2debug_gr15),
		.oDEBUG_REG_OUT_GR16(debug_register2debug_gr16),
		.oDEBUG_REG_OUT_GR17(debug_register2debug_gr17),
		.oDEBUG_REG_OUT_GR18(debug_register2debug_gr18),
		.oDEBUG_REG_OUT_GR19(debug_register2debug_gr19),
		.oDEBUG_REG_OUT_GR20(debug_register2debug_gr20),
		.oDEBUG_REG_OUT_GR21(debug_register2debug_gr21),
		.oDEBUG_REG_OUT_GR22(debug_register2debug_gr22),
		.oDEBUG_REG_OUT_GR23(debug_register2debug_gr23),
		.oDEBUG_REG_OUT_GR24(debug_register2debug_gr24),
		.oDEBUG_REG_OUT_GR25(debug_register2debug_gr25),
		.oDEBUG_REG_OUT_GR26(debug_register2debug_gr26),
		.oDEBUG_REG_OUT_GR27(debug_register2debug_gr27),
		.oDEBUG_REG_OUT_GR28(debug_register2debug_gr28),
		.oDEBUG_REG_OUT_GR29(debug_register2debug_gr29),
		.oDEBUG_REG_OUT_GR30(debug_register2debug_gr30),
		.oDEBUG_REG_OUT_GR31(debug_register2debug_gr31),
		.oDEBUG_REG_OUT_SPR(debug_register2debug_spr),
		.oDEBUG_REG_OUT_PCR(debug_register2debug_pcr),
		.oDEBUG_REG_OUT_PPCR(debug_register2debug_ppcr),
		.oDEBUG_REG_OUT_PSR(debug_register2debug_psr),
		.oDEBUG_REG_OUT_PPSR(debug_register2debug_ppsr)
	);
	
	
	execute EXECUTE(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iFREE_REGISTER_LOCK(free_register_lock),
		.iFREE_PIPELINE_STOP(free_pipeline_stop),
		.iFREE_REFRESH(free_refresh),
		//System Register
		//.oSYSREG_PCR(sysreg_pcr),
		.oEXCEPTION_LOCK(execute_exception_lock),
		//Pipeline 
		.iPREVIOUS_VALID(dispatch2execution_valid),	
		.iPREVIOUS_SYSREG_PSR(dispatch2execution_sysreg_psr),
		.iPREVIOUS_SYSREG_TIDR(dispatch2execution_sysreg_tidr),
		.iPREVIOUS_SYSREG_PDTR(dispatch2execution_sysreg_tidr),
		.iPREVIOUS_DESTINATION_SYSREG(dispatch2execution_destination_sysreg),
		.iPREVIOUS_DESTINATION(dispatch2execution_destination),			
		.iPREVIOUS_WRITEBACK(dispatch2execution_writeback),	
		.iPREVIOUS_FLAGS_WRITEBACK(dispatch2execution_flags_writeback),	
		.iPREVIOUS_CMD(dispatch2execution_cmd),
		.iPREVIOUS_CC_AFE(dispatch2execution_cc_afe),
		.iPREVIOUS_SPR(dispatch2execution_spr),
		.iPREVIOUS_SOURCE0(dispatch2execution_source0),
		.iPREVIOUS_SOURCE1(dispatch2execution_source1),
		.iPREVIOUS_SOURCE0_POINTER(dispatch2execution_source0_pointer),
		.iPREVIOUS_SOURCE1_POINTER(dispatch2execution_source1_pointer),
		.iPREVIOUS_SOURCE0_SYSREG(dispatch2execution_source0_sysreg),
		.iPREVIOUS_SOURCE1_SYSREG(dispatch2execution_source1_sysreg),
		.iPREVIOUS_SOURCE1_IMM(dispatch2execution_source1_imm),
		.iPREVIOUS_SOURCE0_FLAGS(dispatch2execution_source0_flags),
		.iPREVIOUS_EX_SYS_REG(dispatch2execution_ex_sys_reg),		
		.iPREVIOUS_EX_SYS_LDST(dispatch2execution_ex_sys_ldst),		
		.iPREVIOUS_EX_LOGIC(dispatch2execution_ex_logic),
		.iPREVIOUS_EX_SHIFT(dispatch2execution_ex_shift),
		.iPREVIOUS_EX_ADDER(dispatch2execution_ex_addr),
		.iPREVIOUS_EX_MUL(dispatch2execution_ex_mul),
		.iPREVIOUS_EX_SDIV(dispatch2execution_ex_sdiv),
		.iPREVIOUS_EX_UDIV(dispatch2execution_ex_udiv),
		.iPREVIOUS_EX_LDST(dispatch2execution_ex_ldst),
		.iPREVIOUS_EX_BRANCH(dispatch2execution_ex_branch),
		.iPREVIOUS_PC(dispatch2execution_pc),
		.oPREVIOUS_LOCK(execution2dispatch_lock),
		//Data Port		
		.oDATAIO_REQ(execution2ldst_ldst_req),
		.iDATAIO_BUSY(ldst2execution_ldst_busy),
		.oDATAIO_ORDER(execution2ldst_ldst_order),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oDATAIO_RW(execution2ldst_ldst_rw),		//0=Read 1=Write
		.oDATAIO_TID(execution2ldst_ldst_tid),
		.oDATAIO_MMUMOD(execution2ldst_ldst_mmumod),
		.oDATAIO_PDT(execution2ldst_ldst_pdt),
		.oDATAIO_ADDR(execution2ldst_ldst_addr),
		.oDATAIO_DATA(execution2ldst_ldst_data),
		.iDATAIO_REQ(ldst2execution_ldst_req),
		.iDATAIO_DATA(ldst2execution_ldst_data),
		//Next
		.oNEXT_VALID(execution2dispatch_valid),
		.oNEXT_DATA(execution2dispatch_data),
		.oNEXT_DESTINATION(execution2dispatch_destination),
		.oNEXT_DESTINATION_SYSREG(execution2dispatch_destination_sysreg),
		.oNEXT_WRITEBACK(execution2dispatch_writeback),
		.oNEXT_SPR_WRITEBACK(execution2dispatch_spr_writeback),
		.oNEXT_SPR(execution2dispatch_spr),
		.oNEXT_PC(execution2dispatch_pc),
		.oNEXT_BRANCH(execution2dispatch_branch),
		.oNEXT_BRANCH_PC(execution2dispatch_branch_pc),
		//System Register Write
		.oPDTR_WRITEBACK(sysreg_write_pdtr),
		//Branch
		.oBRANCH_ADDR(exception_branch_addr),
		.oJUMP_VALID(exception_jump_valid),
		.oINTR_VALID(exception_intr_valid),
		.oIDTSET_VALID(exception_idtset_valid),
		.oSWI_VALID(exception_swi_valid),
		.oSWI_NUM(exception_swi_num),
		//Debug
		.iDEBUG_CTRL_REQ(debug_debug2corectrl_req),
		.iDEBUG_CTRL_STOP(debug_debug2corectrl_stop),
		.iDEBUG_CTRL_START(debug_debug2corectrl_start),
		.oDEBUG_CTRL_ACK(debug_corectrl2debug_ack),
		.oDEBUG_REG_OUT_FLAGR(debug_register2debug_flagr)
	);

	
	
	
	wire ldst_arbiter2d_cache_req;
	wire d_cache2ldst_arbiter_busy;
	wire [1:0] ldst_arbiter2d_cache_order;
	wire ldst_arbiter2d_cache_rw;
	wire [31:0] ldst_arbiter2d_cache_tid;
	wire [1:0] ldst_arbiter2d_cache_mmumod;
	wire [31:0] ldst_arbiter2d_cache_pdt;
	wire [31:0] ldst_arbiter2d_cache_addr;
	wire [31:0] ldst_arbiter2d_cache_data;
	wire d_cache2ldst_arbiter_valid;
	wire [31:0] d_cache2ldst_arbiter_data;
	
	
	losd_store_pipe_arbiter LDST_PIPE_ARBITOR(
		.oLDST_REQ(ldst_arbiter2d_cache_req),
		.iLDST_BUSY(d_cache2ldst_arbiter_busy),	
		.oLDST_ORDER(ldst_arbiter2d_cache_order),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oLDST_RW(ldst_arbiter2d_cache_rw),		//0=Read 1=Write
		.oLDST_TID(ldst_arbiter2d_cache_tid),
		.oLDST_MMUMOD(ldst_arbiter2d_cache_mmumod),
		.oLDST_PDT(ldst_arbiter2d_cache_pdt),	
		.oLDST_ADDR(ldst_arbiter2d_cache_addr),
		.oLDST_DATA(ldst_arbiter2d_cache_data),
		.iLDST_VALID(d_cache2ldst_arbiter_valid),
		.iLDST_DATA(d_cache2ldst_arbiter_data),
		//Selector
		.iUSE_SEL(exception2ldst_ldst_use),		//0:Execution | 1:Exception
		//Execution Module
		.iEXE_REQ(execution2ldst_ldst_req),
		.oEXE_BUSY(ldst2execution_ldst_busy),
		.iEXE_ORDER(execution2ldst_ldst_order),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.iEXE_RW(execution2ldst_ldst_rw),		//0=Read 1=Write
		.iEXE_TID(execution2ldst_ldst_tid),
		.iEXE_MMUMOD(execution2ldst_ldst_mmumod),
		.iEXE_PDT(execution2ldst_ldst_pdt),
		.iEXE_ADDR(execution2ldst_ldst_addr),
		.iEXE_DATA(execution2ldst_ldst_data),
		.oEXE_REQ(ldst2execution_ldst_req),
		.oEXE_DATA(ldst2execution_ldst_data),
		//Exception Module
		.iEXCEPT_REQ(exception2ldst_ldst_req),
		.oEXCEPT_BUSY(ldst2exception_ldst_busy),
		.iEXCEPT_ORDER(exception2ldst_ldst_order),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.iEXCEPT_RW(exception2ldst_ldst_rw),		//0=Read 1=Write
		.iEXCEPT_TID(exception2ldst_ldst_tid),
		.iEXCEPT_MMUMOD(exception2ldst_ldst_mmumod),
		.iEXCEPT_PDT(exception2ldst_ldst_pdt),
		.iEXCEPT_ADDR(exception2ldst_ldst_addr),
		.iEXCEPT_DATA(exception2ldst_ldst_data),
		.oEXCEPT_REQ(ldst2exception_ldst_req),
		.oEXCEPT_DATA(ldst2exception_ldst_data)
	);

	
	l1_data_cache L1_DATA_CACHE(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Remove
		.iREMOVE(free_refresh),
		.iCACHE_FLASH(cache_flash),
		//IOSR
		.iSYSINFO_IOSR_VALID(iSYSINFO_IOSR_VALID),
		.iSYSINFO_IOSR(iSYSINFO_IOSR),
		/****************************************
		Load/Store Module
		****************************************/		
		//Load Store -> Cache
		.iLDST_REQ(ldst_arbiter2d_cache_req),
		.oLDST_BUSY(d_cache2ldst_arbiter_busy),
		.iLDST_ORDER(ldst_arbiter2d_cache_order),
		.iLDST_RW(ldst_arbiter2d_cache_rw),
		.iLDST_TID(ldst_arbiter2d_cache_tid),
		.iLDST_MMUMOD(ldst_arbiter2d_cache_mmumod),
		.iLDST_PDT(ldst_arbiter2d_cache_pdt),
		.iLDST_ADDR(ldst_arbiter2d_cache_addr),
		.iLDST_DATA(ldst_arbiter2d_cache_data),
		//Cache -> Load Store
		.oLDST_VALID(d_cache2ldst_arbiter_valid),
		.oLDST_DATA(d_cache2ldst_arbiter_data),
		/****************************************
		Data Memory
		****************************************/
		//Req
		.oDATA_REQ(oDATA_REQ),
		.iDATA_LOCK(iDATA_LOCK),
		.oDATA_ORDER(oDATA_ORDER),
		.oDATA_RW(oDATA_RW),		//0=Write 1=Read
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
		.oIO_ORDER(oIO_ORDER),
		.oIO_RW(oIO_RW),			//0=Write 1=Read
		.oIO_ADDR(oIO_ADDR),
		//Write
		.oIO_DATA(oIO_DATA),
		//Rec
		.iIO_VALID(iIO_VALID),
		.iIO_DATA(iIO_DATA)
	);
	
	
	core_debug CORE_DEBUG_MODULE(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//CMD
		.iCMD_REQ(iDEBUG_CMD_REQ),
		.oCMD_BUSY(oDEBUG_CMD_BUSY),
		.iCMD_COMMAND(iDEBUG_CMD_COMMAND),
		.iCMD_TARGET(iDEBUG_CMD_TARGET),
		.iCMD_DATA(iDEBUG_CMD_DATA),
		//Response
		.oRESP_VALID(oDEBUG_CMD_VALID),
		.oRESP_ERROR(oDEBUG_CMD_ERROR),
		.oRESP_DATA(oDEBUG_CMD_DATA),
		//System control
		.oDEBUG_CORE_REQ(debug_debug2corectrl_req),
		.oDEBUG_CORE_STOP(debug_debug2corectrl_stop),
		.oDEBUG_CORE_START(debug_debug2corectrl_start),
		.iDEBUG_CORE_ACK(debug_corectrl2debug_ack),
		//Register Read
		.iREG_R_GR0(debug_register2debug_gr0),
		.iREG_R_GR1(debug_register2debug_gr1),
		.iREG_R_GR2(debug_register2debug_gr2),
		.iREG_R_GR3(debug_register2debug_gr3),
		.iREG_R_GR4(debug_register2debug_gr4),
		.iREG_R_GR5(debug_register2debug_gr5),
		.iREG_R_GR6(debug_register2debug_gr6),
		.iREG_R_GR7(debug_register2debug_gr7),
		.iREG_R_GR8(debug_register2debug_gr8),
		.iREG_R_GR9(debug_register2debug_gr9),
		.iREG_R_GR10(debug_register2debug_gr10),
		.iREG_R_GR11(debug_register2debug_gr11),
		.iREG_R_GR12(debug_register2debug_gr12),
		.iREG_R_GR13(debug_register2debug_gr13),
		.iREG_R_GR14(debug_register2debug_gr14),
		.iREG_R_GR15(debug_register2debug_gr15),
		.iREG_R_GR16(debug_register2debug_gr16),
		.iREG_R_GR17(debug_register2debug_gr17),
		.iREG_R_GR18(debug_register2debug_gr18),
		.iREG_R_GR19(debug_register2debug_gr19),
		.iREG_R_GR20(debug_register2debug_gr20),
		.iREG_R_GR21(debug_register2debug_gr21),
		.iREG_R_GR22(debug_register2debug_gr22),
		.iREG_R_GR23(debug_register2debug_gr23),
		.iREG_R_GR24(debug_register2debug_gr24),
		.iREG_R_GR25(debug_register2debug_gr25),
		.iREG_R_GR26(debug_register2debug_gr26),
		.iREG_R_GR27(debug_register2debug_gr27),
		.iREG_R_GR28(debug_register2debug_gr28),
		.iREG_R_GR29(debug_register2debug_gr29),
		.iREG_R_GR30(debug_register2debug_gr30),
		.iREG_R_GR31(debug_register2debug_gr31),
		.iREG_R_FLAGR(debug_register2debug_flagr),
		.iREG_R_SPR(debug_register2debug_spr),
		.iREG_R_PCR(debug_register2debug_pcr),
		.iREG_R_PPCR(debug_register2debug_ppcr),
		.iREG_R_PSR(debug_register2debug_psr),
		.iREG_R_PPSR(debug_register2debug_ppsr)
	);

				
	assign		oINST_FETCH_PDT			=	{32{1'b0}};
	
	
	//System
	assign		oCORE_FLASH				=		free_refresh;
	
endmodule


`default_nettype wire


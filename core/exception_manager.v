/****************************************
Exception Manager
	
	
	Make	:	2010/12/07
	Update	:		
****************************************/



`include "core.h"
`include "global.h"
`default_nettype none



module exception_manager(
		input iCLOCK,
		input inRESET,
		//Free
		output oFREE_REGISTER_LOCK,
		output oFREE_PIPELINE_STOP,
		output oFREE_REFRESH,
		output oFREE_RESTART,
		output oFREE_PC_SET,
		output [31:0] oFREE_PC,
		output oFREE_PPCR_SET,	
		output [31:0] oFREE_PPCR,
		output oFREE_FI0R_SET,	
		output [31:0] oFREE_FI0R,	
		output oFREE_SET_IRQ_MODE,
		output oFREE_CLR_IRQ_MODE,
		output oFREE_CACHE_FLUSH,
		output oFREE_TLB_FLUSH,	
		//Interrupt Lock
		input iINTERRUPT_LOCK,
		//System Register - Input
		input [31:0] iSYSREG_SPR,
		input [31:0] iSYSREG_TIDR,
		input [31:0] iSYSREG_TISR,
		input [31:0] iSYSREG_PSR,
		input [31:0] iSYSREG_PPSR,
		input [31:0] iSYSREG_PCR,
		input [31:0] iSYSREG_PPCR,
		input [31:0] iSYSREG_IDTR,
		//System Register - Output(Writeback)
		output oSYSREG_SPR_WRITE,
		output [31:0] oSYSREG_SPR,
		//IO Port
		output oLDST_USE,
		output oLDST_REQ,
		input iLDST_BUSY,
		output [1:0] oLDST_ORDER,	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		output oLDST_RW,		//0=Read 1=Write
		output [13:0] oLDST_TID,
		output [1:0] oLDST_MMUMOD,
		output [31:0] oLDST_PDT,
		output [31:0] oLDST_ADDR,
		output [31:0] oLDST_DATA,
		input iLDST_REQ,
		input [31:0] iLDST_DATA,
		/*********************************
		Interrupt Configlation
		*********************************/	
		//GCI Interrupt Configlation Table
		output oIO_IRQ_CONFIG_TABLE_REQ,
		output [5:0] oIO_IRQ_CONFIG_TABLE_ENTRY,
		output oIO_IRQ_CONFIG_TABLE_FLAG_MASK,
		output oIO_IRQ_CONFIG_TABLE_FLAG_VALID,	
		output [1:0] oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL,	
		//Interrupt Configlation Table
		output oICT_REQ,
		output [5:0] oICT_ENTRY,
		output oICT_CONF_MASK,
		output oICT_CONF_VALID,	
		output [1:0] oICT_CONF_LEVEL,			
		//Core Branch
		input iEXCEPT_JUMP,					
		input [31:0] iEXCEPT_JUMP_ADDR,
		input iEXCEPT_IDTS,					
		input [31:0] iEXCEPT_IDTS_ADDR,
		input iEXCEPT_IB,					
		input [31:0] iEXCEPT_IB_ADDR,
		input iEXCEPT_PDTS,	
		//External Exception
		input iEXCEPT_IRQ_REQ,
		input [6:0] iEXCEPT_IRQ_NUM,
		input [31:0] iEXCEPT_IRQ_FI0R,
		output oEXCEPT_IRQ_ACK,
		output oEXCEPT_IRQ_BUSY
	);

	
	wire debug_im = iSYSREG_PSR[2];
	wire debug_idth = (b_main_state == L_PARAM_MAINSTT_IRQ_SET)? 1'b1 : 1'b0;
	
	//wire debug_
	//wire debug_ib_now = 
	
	
	/************************************************************
	Main State parameter
	************************************************************/
	parameter L_PARAM_MAINSTT_IDLE = 3'h0;
	parameter L_PARAM_MAINSTT_ALU_JUMP = 3'h1;
	parameter L_PARAM_MAINSTT_AUTO_TSWITCH = 3'h2;
	parameter L_PARAM_MAINSTT_IRQ_SET = 3'h3;
	parameter L_PARAM_MAINSTT_IRQ_RET = 3'h4;
	parameter L_PARAM_MAINSTT_IDTS = 3'h5;
	parameter L_PARAM_MAINSTT_PDTS = 3'h6;
	
	/************************************************************
	Sub State parameter
	************************************************************/
	//Int Set
	parameter L_PARAM_SUBSTT_SET_IRQ_VECTOR_LOAD_REQ = 3'h0;
	parameter L_PARAM_SUBSTT_SET_IRQ_VECTOR_LOAD_GETWAIT = 3'h1;
	parameter L_PARAM_SUBSTT_SET_IRQ_USER_SPR_WRITE = 3'h2;
	parameter L_PARAM_SUBSTT_SET_IRQ_KERNEL_SPR_REQ = 3'h3;
	parameter L_PARAM_SUBSTT_SET_IRQ_KERNEL_SPR_GETWAIT = 3'h4;
	parameter L_PARAM_SUBSTT_SET_IRQ_JUMP_HUNDLER = 3'h5;
	//Idt Return
	parameter L_PARAM_SUBSTT_CLR_IRQ_COREMODE_CHECK = 3'h0;
	parameter L_PARAM_SUBSTT_CLR_IRQ_KERNEL_SPR_WRITE = 3'h1;
	parameter L_PARAM_SUBSTT_CLR_IRQ_USER_SPR_REQ = 3'h2;
	parameter L_PARAM_SUBSTT_CLR_IRQ_USER_SPR_GETWAIT = 3'h3;
	parameter L_PARAM_SUBSTT_CLR_IRQ_JUMP_PPCR = 3'h4;
	//IDT Set
	parameter L_PARAM_SRMODE_SET_IDTR_LOAD_IDT_REQ = 3'h0;
	parameter L_PARAM_SRMODE_SET_IDTR_LOAD_IDT_GETWAIT = 3'h1;

	
	/************************************************************
	System Register Function
	************************************************************/
	parameter L_PARAM_SRMODE_NONE = 2'h0;
	parameter L_PARAM_SRMODE_IRQ_SET = 2'h1;
	parameter L_PARAM_SRMODE_IRQ_CLR = 2'h2;
	
	
	/************************************************************
	Sub Always@ Register
	************************************************************/
	reg b_kspr_read_state;
	reg b_kspr_read;
	reg b_kspr_readend;
	reg [31:0] b_kspr_idt_data;
	
	reg b_uspr_read_state;
	reg b_uspr_read;
	reg b_uspr_readend;
	reg [31:0] b_uspr_idt_data;
	
	reg b_inthundl_read_state;
	reg b_inthundl_read;
	reg b_inthundl_readend;
	reg [31:0] b_inthundl_idt_data;
	
	reg b_idt_read_state;
	reg [6:0] b_idt_read_counter;
	reg [6:0] b_idt_get_counter;
	reg b_idt_readend;
	reg b_idt_idt_data_valid;
	reg [31:0] b_idt_idt_data;
	
	/************************************************************
	Main Always@ Register
	************************************************************/
	reg [2:0] b_main_state;
	reg [2:0] b_sub_state;
	reg b_pipeline_flush_event /* synthesis syn_maxfan = 250 */;		//Altera QuartusII Synthesis Option : Max fanout
	reg b_cache_flush;
	reg b_tlb_flush;
	reg b_irq_ack;
	reg b_irq_request;
	reg b_branch_active;
	reg [31:0] b_branch_addr;
	reg b_ppcr_set;
	reg [31:0] b_ppcr;
	
	reg b_inthundl_read_req;	
	reg b_spr_mem_write_req;
	reg [31:0] b_spr_mem_write_addr;
	reg [31:0] b_spr_mem_write_spr;
	reg b_kspr_read_req;
	reg b_uspr_read_req;
	reg b_idt_read_req;
	reg b_new_spr_write_req;
	reg [31:0] b_new_spr;
	reg b_sysreg_set;
	reg [1:0] b_sysreg_set_mode;
	reg [6:0] b_irq_num;
	reg [31:0] b_irq_fi0r;
	
	
	reg [31:0] b_sysr_spr;
	reg [31:0] b_sysr_tidr;
	reg [31:0] b_sysr_tisr;
	reg [31:0] b_sysr_psr;
	reg [31:0] b_sysr_ppsr;
	reg [31:0] b_sysr_ppcr;
	reg [31:0] b_sysr_idtr;
	
	wire interrupt_condition = iEXCEPT_IRQ_REQ && !iINTERRUPT_LOCK && iSYSREG_PSR[2];
	wire interrupt_and_branch_condition = iEXCEPT_IRQ_REQ && iSYSREG_PSR[2];
	reg b_irq_request_test;
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_state <= L_PARAM_MAINSTT_IDLE;
			b_sub_state <= 3'h0;
			b_pipeline_flush_event <= 1'b0;
			b_cache_flush <= 1'b0;
			b_tlb_flush <= 1'b0;
			b_irq_ack <= 1'b0;
			b_irq_request <= 1'b0;
			b_branch_active <= 1'b0;
			b_branch_addr <= 32'h0;
			b_ppcr_set <= 1'b0;
			b_ppcr <= 32'h0;		
			b_inthundl_read_req <= 1'b0;
			b_spr_mem_write_req <= 1'b0;
			b_spr_mem_write_addr <= 32'h0;
			b_spr_mem_write_spr <= 32'h0;
			b_kspr_read_req <= 1'b0;
			b_uspr_read_req <= 1'b0;
			b_idt_read_req <= 1'b0;
			b_new_spr_write_req <= 1'b0;
			b_new_spr <= 32'h0;
			b_sysreg_set <= 1'b0;
			b_sysreg_set_mode <= 2'h0;
			b_irq_num <= 7'h0;
			b_irq_fi0r <= 32'h0;
			b_sysr_spr <= 32'h0;
			b_sysr_tidr <= 32'h0;
			b_sysr_tisr <= 32'h0;
			b_sysr_psr <= 32'h0;
			b_sysr_ppsr <= 32'h0;
			b_sysr_ppcr <= 32'h0;
			b_sysr_idtr <= 32'h0;
		end
		else begin
			case(b_main_state)
				L_PARAM_MAINSTT_IDLE:
					begin
						b_branch_active <= 1'b0;
						b_sub_state <= 3'h0;
						b_irq_ack <= 1'b0;
						
						b_sysr_spr <= iSYSREG_SPR;
						b_sysr_tidr <= iSYSREG_TIDR;
						b_sysr_tisr <= iSYSREG_TISR;
						b_sysr_psr <= iSYSREG_PSR;
						b_sysr_ppsr <= iSYSREG_PPSR;
						b_sysr_ppcr <= iSYSREG_PPCR;
						b_sysr_idtr <= iSYSREG_IDTR;
						//Core Jump Instruction
						if(iEXCEPT_JUMP)begin
							b_main_state <= L_PARAM_MAINSTT_ALU_JUMP;
							b_irq_request <= interrupt_and_branch_condition;
							b_branch_addr <= iEXCEPT_JUMP_ADDR;
							b_pipeline_flush_event <= 1'b1;
							b_sysreg_set <= 1'b0;
						end
						//Interrupt
						else if(interrupt_condition)begin 
							b_ppcr_set <= 1'b1;
							b_ppcr <= iSYSREG_PCR;
							b_sysreg_set_mode <= L_PARAM_SRMODE_IRQ_SET;
							b_sysreg_set <= 1'b1;
							b_main_state <= L_PARAM_MAINSTT_IRQ_SET;
							b_pipeline_flush_event <= 1'b1;
							//b_branch_addr <= iSYSREG_PCR;
							b_irq_num <= iEXCEPT_IRQ_NUM;
							b_irq_fi0r <= iEXCEPT_IRQ_FI0R;
						end
						//Page Directory Table Set
						else if(iEXCEPT_PDTS && iSYSREG_PSR[1:0] != 2'h0)begin
							b_main_state <= L_PARAM_MAINSTT_PDTS;
							b_branch_addr <= iEXCEPT_JUMP_ADDR;
							b_pipeline_flush_event <= 1'b1;
							b_sysreg_set <= 1'b0;
						end
						//Interrupt Return Instruction
						else if(iEXCEPT_IB)begin
							b_main_state <= L_PARAM_MAINSTT_IRQ_RET;
							b_pipeline_flush_event <= 1'b1;
							b_cache_flush <= 1'b1;
							b_tlb_flush <= 1'b1;
							b_sysreg_set <= 1'b0;
						end
						//IDT Set Instruction
						else if(iEXCEPT_IDTS)begin
							b_main_state <= L_PARAM_MAINSTT_IDTS;
							b_pipeline_flush_event <= 1'b1;
							b_branch_addr <= iEXCEPT_JUMP_ADDR;
							b_sysreg_set <= 1'b0;
						end
						else begin
							b_sysreg_set <= 1'b0;
						end
					end
				L_PARAM_MAINSTT_ALU_JUMP:
					begin
						//Branch -> Interrupt
						b_irq_request <= 1'b0;
						if(b_irq_request/*20121105 iEXCEPT_IRQ_REQ && iSYSREG_PSR[2]*/)begin		//interrupt_condition
							b_sysreg_set_mode <= L_PARAM_SRMODE_IRQ_SET;
							b_sysreg_set <= 1'b1;
							b_main_state <= L_PARAM_MAINSTT_IRQ_SET;
							b_pipeline_flush_event <= 1'b1;
							//b_branch_addr <= iSYSREG_PCR;
							b_ppcr_set <= 1'b1;
							b_ppcr <= iEXCEPT_JUMP_ADDR;
							b_irq_num <= iEXCEPT_IRQ_NUM;
							b_irq_fi0r <= iEXCEPT_IRQ_FI0R;
						end
						//Branch -> Idle
						else begin
							b_branch_active <= 1'b1;
							b_pipeline_flush_event <= 1'b0;
							b_sysreg_set_mode <= L_PARAM_SRMODE_NONE;
							b_main_state <= L_PARAM_MAINSTT_IDLE;
							b_sysreg_set <= 1'b1;	//1'b0?
						end
					end
				L_PARAM_MAINSTT_AUTO_TSWITCH:
					begin
						//
					end
				L_PARAM_MAINSTT_IRQ_SET:
					begin
						case(b_sub_state)
							L_PARAM_SUBSTT_SET_IRQ_VECTOR_LOAD_REQ:
								begin
									b_ppcr_set <= 1'b0;
									b_sysreg_set <= 1'b0;
									b_pipeline_flush_event <= 1'b0;
									b_inthundl_read_req <= 1'b1;
									b_sub_state <= L_PARAM_SUBSTT_SET_IRQ_VECTOR_LOAD_GETWAIT;	
								end
							L_PARAM_SUBSTT_SET_IRQ_VECTOR_LOAD_GETWAIT:
								begin
									b_inthundl_read_req		<=		1'b0;
									//Next Condition Check
									if(b_inthundl_readend)begin	
										b_branch_addr			<=		b_inthundl_idt_data;
										if(b_sysr_psr[6:5] == `CORE_MODE_KERNEL)begin
											//Hundler Jump
											b_sub_state				<=		L_PARAM_SUBSTT_SET_IRQ_JUMP_HUNDLER;
										end
										else begin
											//Kernel SPR Read
											b_sub_state				<=		L_PARAM_SUBSTT_SET_IRQ_USER_SPR_WRITE;	
										end
									end
								end
							L_PARAM_SUBSTT_SET_IRQ_USER_SPR_WRITE:
								begin
									if(!iLDST_BUSY)begin
										b_sub_state				<=		L_PARAM_SUBSTT_SET_IRQ_KERNEL_SPR_REQ;
										b_spr_mem_write_req		<=		1'b1;
										b_spr_mem_write_addr	<=		b_sysr_tisr + {b_sysr_tidr[13:0], 8'h0} + `TST_USPR;
										b_spr_mem_write_spr		<=		b_sysr_spr;
									end
								end
							L_PARAM_SUBSTT_SET_IRQ_KERNEL_SPR_REQ:
								begin
									if(iLDST_REQ)begin
										b_spr_mem_write_req		<=		1'b0;
										b_kspr_read_req			<=		1'b1;
										b_sub_state				<=		L_PARAM_SUBSTT_SET_IRQ_KERNEL_SPR_GETWAIT;	
									end
								end
							L_PARAM_SUBSTT_SET_IRQ_KERNEL_SPR_GETWAIT:
								begin
									b_kspr_read_req			<=		1'b0;
									if(b_kspr_readend)begin
										b_sub_state				<=		L_PARAM_SUBSTT_SET_IRQ_JUMP_HUNDLER;	
										b_new_spr_write_req		<=		1'b1;
										b_new_spr				<=		b_kspr_idt_data;
									end
								end
							L_PARAM_SUBSTT_SET_IRQ_JUMP_HUNDLER:
								begin
									b_main_state			<=		L_PARAM_MAINSTT_IDLE;
									b_sub_state				<=		6'h0;	
									b_branch_active			<=		1'b1;
									b_irq_ack <= 1'b1;
								end
							default:
								begin
									b_main_state			<=		L_PARAM_MAINSTT_IDLE;
									b_sub_state				<=		6'h0;	
									b_branch_active			<=		1'b1;
									b_irq_ack <= 1'b1;
								end
						endcase
					end
				L_PARAM_MAINSTT_IRQ_RET:
					begin
						case(b_sub_state)
							L_PARAM_SUBSTT_CLR_IRQ_COREMODE_CHECK:
								begin
									b_pipeline_flush_event <= 1'b0;
									b_branch_addr			<=		b_sysr_ppcr;
									if(b_sysr_ppsr[6:5] == `CORE_MODE_USER)begin
										b_sub_state				<=		L_PARAM_SUBSTT_CLR_IRQ_KERNEL_SPR_WRITE;	
									end
									else begin
										b_sub_state				<=		L_PARAM_SUBSTT_CLR_IRQ_JUMP_PPCR;
									end
								end
							//spr set check
							L_PARAM_SUBSTT_CLR_IRQ_KERNEL_SPR_WRITE:
								begin
									if(!iLDST_BUSY)begin
										b_sub_state				<=		L_PARAM_SUBSTT_CLR_IRQ_USER_SPR_REQ;
										b_spr_mem_write_req		<=		1'b1;
										b_spr_mem_write_addr	<=		b_sysr_tisr + {b_sysr_tidr[13:0], 8'h0} + `TST_KSPR;
										b_spr_mem_write_spr		<=		b_sysr_spr;
									end
								end
							L_PARAM_SUBSTT_CLR_IRQ_USER_SPR_REQ:
								begin
									if(iLDST_REQ)begin
										b_spr_mem_write_req		<=		1'b0;
										b_uspr_read_req			<=		1'b1;
										b_sub_state				<=		L_PARAM_SUBSTT_CLR_IRQ_USER_SPR_GETWAIT;	
									end
								end
							L_PARAM_SUBSTT_CLR_IRQ_USER_SPR_GETWAIT:
								begin
									b_uspr_read_req			<=		1'b0;
									if(b_uspr_readend)begin
										b_sub_state				<=		L_PARAM_SUBSTT_CLR_IRQ_JUMP_PPCR;	
										b_new_spr_write_req		<=		1'b1;
										b_new_spr				<=		b_uspr_idt_data;
									end
								end
							L_PARAM_SUBSTT_CLR_IRQ_JUMP_PPCR:
								begin
									b_main_state			<=		L_PARAM_MAINSTT_IDLE;
									b_sub_state				<=		6'h0;	
									b_branch_active			<=		1'b1;
									b_sysreg_set_mode	<=		L_PARAM_SRMODE_IRQ_CLR;
									b_sysreg_set <= 1'b1;
								end
							default:
								begin
									b_main_state			<=		L_PARAM_MAINSTT_IDLE;
									b_sub_state				<=		6'h0;	
									b_branch_active			<=		1'b1;
									b_sysreg_set_mode	<=		L_PARAM_SRMODE_IRQ_CLR;
									b_sysreg_set <= 1'b1;
								end
						endcase
					end
				L_PARAM_MAINSTT_IDTS:
					begin
						case(b_sub_state)
							L_PARAM_SRMODE_SET_IDTR_LOAD_IDT_REQ:
								begin
									b_pipeline_flush_event <= 1'b0;
									b_sub_state				<=		L_PARAM_SRMODE_SET_IDTR_LOAD_IDT_GETWAIT;
									b_idt_read_req			<=		1'b1;
								end
							L_PARAM_SRMODE_SET_IDTR_LOAD_IDT_GETWAIT:
								begin
									b_idt_read_req<= 1'b0;
									if(b_idt_readend)begin
										b_main_state <= L_PARAM_MAINSTT_IDLE;
										b_sub_state <= 6'h0;	
										b_branch_active <= 1'b1;
										b_sysreg_set_mode <= L_PARAM_SRMODE_NONE;
										b_sysreg_set <= 1'b1;
									end
								end
						endcase
					end
				L_PARAM_MAINSTT_PDTS:
					begin
						b_branch_active <= 1'b1;
						b_pipeline_flush_event <= 1'b0;
						b_cache_flush <= 1'b0;
						b_tlb_flush <= 1'b0;
						b_sysreg_set_mode <= L_PARAM_SRMODE_NONE;
						b_main_state <= L_PARAM_MAINSTT_IDLE;
						b_sysreg_set <= 1'b1;			
					end
				default:
					begin
						b_main_state <= L_PARAM_MAINSTT_IDLE;
					end
			endcase
		end
	end
	
	
	
	/****************************************
	IDT Read
	****************************************/
	parameter L_PARAM_IDTREAD_STT_REQ_WAIT = 1'b0;
	parameter L_PARAM_IDTREAD_STT_LOAD = 1'b1;
	
	wire idt_read_condition		=		(b_idt_read_state == L_PARAM_IDTREAD_STT_LOAD) && (b_idt_read_counter < (7'd64 + 7'h1)) && !iLDST_BUSY;
	wire [31:0]	idt_read_addr	=		b_sysr_idtr + {b_idt_get_counter, 3'h0};
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_idt_read_state		<=		L_PARAM_IDTREAD_STT_REQ_WAIT;
			b_idt_read_counter		<=		7'h0;
			b_idt_get_counter		<=		7'h0;
			b_idt_readend			<=		1'b0;
			b_idt_idt_data_valid	<=		1'b0;
			b_idt_idt_data			<=		{32{1'b0}};
		end
		else begin
			case(b_idt_read_state)
				L_PARAM_IDTREAD_STT_REQ_WAIT:
					begin
						if(b_idt_read_req)begin
							b_idt_read_state		<=		L_PARAM_IDTREAD_STT_LOAD;
							b_idt_read_counter		<=		7'h0;
							b_idt_get_counter		<=		7'h0;
						end
						b_idt_readend			<=		1'b0;
						b_idt_idt_data_valid	<=		1'b0;
						b_idt_idt_data			<=		{32{1'b0}};
					end
				L_PARAM_IDTREAD_STT_LOAD:
					begin
						if(b_idt_read_counter < 7'd64 + 7'h1)begin
							//Request Check
							if(!iLDST_BUSY)begin
								b_idt_read_counter		<=		b_idt_read_counter + 7'h1;
							end
						end
						//Get Check
						if(b_idt_get_counter < 7'd64 + 7'h1)begin
							if(iLDST_REQ)begin
								b_idt_get_counter		<=		b_idt_get_counter + 7'h1;
								b_idt_idt_data_valid	<=		iLDST_REQ;
								b_idt_idt_data			<=		iLDST_DATA;
							end
						end
						else begin
							b_idt_readend			<=		1'b1;		
							b_idt_read_state		<=		L_PARAM_IDTREAD_STT_REQ_WAIT;
						end
					end
			endcase
		end
	end
	

	/****************************************
	Interrupt Hundler Get
	****************************************/	
	parameter L_PARAM_INTHUNDLE_STT_REQ_WAIT = 1'b0;
	parameter L_PARAM_INTHUNDLE_STT_LOAD = 1'b1;
	
	wire [31:0] inthundle_read_addr = b_sysr_idtr + {b_irq_num, 3'h0} + 32'h4;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_inthundl_read_state		<=		L_PARAM_INTHUNDLE_STT_REQ_WAIT;
			b_inthundl_read				<=		1'b0;
			b_inthundl_readend			<=		1'b0;
			b_inthundl_idt_data			<=		32'h0;
		end
		else begin
			case(b_inthundl_read_state)
				L_PARAM_INTHUNDLE_STT_REQ_WAIT:
					begin
						if(b_inthundl_read_req)begin
							b_inthundl_read_state		<=		L_PARAM_INTHUNDLE_STT_LOAD;
							b_inthundl_read				<=		1'b1;
						end
						else begin
							b_inthundl_read				<=		1'b0;
						end
						b_inthundl_readend			<=		1'b0;
					end
				L_PARAM_INTHUNDLE_STT_LOAD:
					begin
						//Read Request
						if(!iLDST_BUSY && b_inthundl_read)begin
							b_inthundl_read				<=		1'b0;
						end
						//Get Check
						if(iLDST_REQ)begin
							b_inthundl_readend			<=		1'b1;
							b_inthundl_read_state		<=		L_PARAM_INTHUNDLE_STT_REQ_WAIT;
							b_inthundl_idt_data			<=		iLDST_DATA;
						end
					end
			endcase
		end
	end
	
	
	
	
	/****************************************
	Kernel Spr Read
	****************************************/	
	parameter L_PARAM_KSPR_READ_WAIT = 1'b0;	
	parameter L_PARAM_KSPR_READ_LOAD = 1'b1;
	
	wire	[31:0]	kspr_read_addr			=		b_sysr_tisr + {b_sysr_tidr[13:0], 8'h0} + `TST_KSPR;
		
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_kspr_read_state		<=		L_PARAM_KSPR_READ_WAIT;
			b_kspr_read				<=		1'b0;
			b_kspr_readend			<=		1'b0;
			b_kspr_idt_data			<=		32'h0;
		end
		else begin
			case(b_kspr_read_state)
				L_PARAM_KSPR_READ_WAIT:
					begin
						if(b_kspr_read_req)begin
							b_kspr_read_state		<=		L_PARAM_KSPR_READ_LOAD;
							b_kspr_read				<=		1'b1;
						end
						else begin
							b_kspr_read				<=		1'b0;
						end
						b_kspr_readend			<=		1'b0;
						b_kspr_idt_data			<=		{32{1'b0}};
					end
				L_PARAM_KSPR_READ_LOAD:
					begin
						//Read Request
						if(!iLDST_BUSY && b_kspr_read)begin
							b_kspr_read				<=		1'b0;
						end
						//Get Check
						if(iLDST_REQ)begin
							b_kspr_readend			<=		1'b1;
							b_kspr_read_state		<=		L_PARAM_KSPR_READ_WAIT;
							b_kspr_idt_data			<=		iLDST_DATA;
						end
					end
			endcase
		end
	end
	

	
	/****************************************
	User Spr Read
	****************************************/	
	parameter L_PARAM_USPR_READ_WAIT = 1'b0;	
	parameter L_PARAM_USPR_READ_LOAD = 1'b1;
	
	wire	[31:0]	uspr_read_addr			=		b_sysr_tisr + {b_sysr_tidr[13:0], 8'h0} + `TST_USPR;
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_uspr_read_state		<=		L_PARAM_USPR_READ_WAIT;
			b_uspr_read				<=		1'b0;
			b_uspr_readend			<=		1'b0;
			b_uspr_idt_data			<=		32'h0;
		end
		else begin
			case(b_uspr_read_state)
				L_PARAM_USPR_READ_WAIT:
					begin
						if(b_uspr_read_req)begin
							b_uspr_read_state		<=		L_PARAM_USPR_READ_LOAD;
							b_uspr_read				<=		1'b1;
						end
						else begin
							b_uspr_read				<=		1'b0;
						end
						b_uspr_readend			<=		1'b0;
						b_uspr_idt_data			<=		{32{1'b0}};
					end
				L_PARAM_USPR_READ_LOAD:
					begin
						//Read Request
						if(!iLDST_BUSY && b_uspr_read)begin
							b_uspr_read				<=		1'b0;
						end
						//Get Check
						if(iLDST_REQ)begin
							b_uspr_readend			<=		1'b1;
							b_uspr_read_state		<=		L_PARAM_USPR_READ_WAIT;
							b_uspr_idt_data			<=		iLDST_DATA;
						end
					end
			endcase
		end
	end
	
	assign oFREE_CACHE_FLUSH = b_cache_flush;
	assign oFREE_TLB_FLUSH = b_tlb_flush;
	
	assign oFREE_REGISTER_LOCK = (b_main_state != L_PARAM_MAINSTT_IDLE) || (!iEXCEPT_JUMP && (iEXCEPT_IRQ_REQ && !iINTERRUPT_LOCK && iSYSREG_PSR[2])) || b_pipeline_flush_event || b_branch_active;
	assign oFREE_PIPELINE_STOP = (b_main_state != L_PARAM_MAINSTT_IDLE || (!iEXCEPT_JUMP && (iEXCEPT_IRQ_REQ && !iINTERRUPT_LOCK && iSYSREG_PSR[2])))? 1'b1 : 1'b0;
	assign oFREE_REFRESH = b_pipeline_flush_event;//(b_main_state != L_PARAM_MAINSTT_IDLE)? 1'b1 : 1'b0;//b_branch_active;
	assign oFREE_RESTART = b_branch_active;	
	assign oFREE_PC_SET = b_branch_active;
	assign oFREE_PC = b_branch_addr;
	
	assign oFREE_PPCR_SET = b_ppcr_set;
	assign oFREE_PPCR = b_ppcr;
	
	assign oFREE_FI0R_SET = (b_main_state == L_PARAM_MAINSTT_IRQ_SET) && (b_sub_state == L_PARAM_SUBSTT_SET_IRQ_JUMP_HUNDLER);
	assign oFREE_FI0R = b_irq_fi0r;
	
	
	assign oFREE_SET_IRQ_MODE = (b_sysreg_set_mode == L_PARAM_SRMODE_IRQ_SET)? b_sysreg_set : 1'b0;
	assign oFREE_CLR_IRQ_MODE = (b_sysreg_set_mode == L_PARAM_SRMODE_IRQ_CLR)? b_sysreg_set : 1'b0;
	
	/********************************************************************
	System Register Write
	********************************************************************/
	assign oSYSREG_SPR_WRITE = b_new_spr_write_req;
	assign oSYSREG_SPR = b_new_spr;

	/********************************************************************
	GCI-Interrupt Configlation Table
	********************************************************************/
	assign oIO_IRQ_CONFIG_TABLE_REQ = b_idt_idt_data_valid;
	assign oIO_IRQ_CONFIG_TABLE_ENTRY = b_idt_get_counter[5:0] - 6'h1;
	assign oIO_IRQ_CONFIG_TABLE_FLAG_MASK = b_idt_idt_data[1];
	assign oIO_IRQ_CONFIG_TABLE_FLAG_VALID	= b_idt_idt_data[0];
	assign oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL	= b_idt_idt_data[17:16];
	
	/********************************************************************
	Core-Interrupt Configlation Table
	********************************************************************/
	assign oICT_REQ = b_idt_idt_data_valid;
	assign oICT_ENTRY = b_idt_get_counter[5:0] - 6'h1;
	assign oICT_CONF_MASK = b_idt_idt_data[1];
	assign oICT_CONF_VALID = b_idt_idt_data[0];
	assign oICT_CONF_LEVEL = b_idt_idt_data[17:16];
	
	/********************************************************************
	Load Store Pipe
	********************************************************************/
	assign oLDST_USE = (b_main_state != L_PARAM_MAINSTT_IDLE)? 1'b1 : 1'b0;
	assign oLDST_REQ = (b_main_state != L_PARAM_MAINSTT_IDLE) && (b_main_state != L_PARAM_MAINSTT_ALU_JUMP) && (b_main_state != L_PARAM_MAINSTT_PDTS) && !iLDST_BUSY && (b_uspr_read || b_kspr_read || b_inthundl_read || idt_read_condition || b_spr_mem_write_req);
	assign oLDST_ORDER = 2'b10;//Word Order
	assign oLDST_RW = b_spr_mem_write_req;
	assign oLDST_TID = b_sysr_tidr[13:0];
	assign oLDST_MMUMOD = 2'h0;
	assign oLDST_PDT = 32'h0;
	assign oLDST_ADDR = (b_uspr_read)? uspr_read_addr : (
															(b_kspr_read)? kspr_read_addr : (
																(b_inthundl_read)? inthundle_read_addr : (
																	(idt_read_condition)? idt_read_addr : b_spr_mem_write_addr
																)
															)
														);
	assign oLDST_DATA = b_spr_mem_write_spr;	
	
	
	//Exception
	assign oEXCEPT_IRQ_ACK = b_irq_ack;
	
	
	//IRQ Busy
	assign oEXCEPT_IRQ_BUSY = 1'b0;
	
	
	
endmodule



`default_nettype wire 



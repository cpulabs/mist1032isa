
`include "core.h"
`default_nettype none

module pipeline_control(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Core Internal Event
		output wire oEVENT_HOLD,
		output wire oEVENT_START,
		output wire oEVENT_IRQ_FRONT2BACK,		//
		output wire oEVENT_IRQ_BACK2FRONT,		//
		output wire oEVENT_CACHE_ERASE,
		output wire oEVENT_TLB_ERASE,
		output wire oEVENT_END,					//Set Register
		//Core Internal Event - Set System Register
		output wire oEVENT_SETREG_PCR_SET,
		output wire oEVENT_SETREG_PPCR_SET,
		output wire oEVENT_SETREG_SPR_SET,
		output wire oEVENT_SETREG_FI0R_SET,
		output wire oEVENT_SETREG_FI1R_SET,
		output wire [31:0] oEVENT_SETREG_PCR,
		output wire [31:0] oEVENT_SETREG_PPCR,
		output wire [31:0] oEVENT_SETREG_SPR,
		output wire [31:0] oEVENT_SETREG_FI0R,
		output wire [31:0] oEVENT_SETREG_FI1R,
		//System Register - Input
		input wire [31:0] iSYSREG_SPR,
		input wire [31:0] iSYSREG_TIDR,
		input wire [31:0] iSYSREG_TISR,
		input wire [31:0] iSYSREG_PSR,
		input wire [31:0] iSYSREG_PCR,
		input wire [31:0] iSYSREG_PPSR,
		input wire [31:0] iSYSREG_PPCR,
		input wire [31:0] iSYSREG_IDTR,
		//Interrupt Lock
		input wire iINTERRUPT_LOCK,
		input wire iINTERRUPT_LDST_LOCK,
		//IO Port
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
		input wire [31:0] iLDST_DATA,
		//Interrupt Configlation Table for GCI
		output wire oIO_IRQ_CONFIG_TABLE_REQ,
		output wire [5:0] oIO_IRQ_CONFIG_TABLE_ENTRY,
		output wire oIO_IRQ_CONFIG_TABLE_FLAG_MASK,
		output wire oIO_IRQ_CONFIG_TABLE_FLAG_VALID,
		output wire [1:0] oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL,
		//Interrupt Configlation Table for Interrupt Controler
		output wire oICT_REQ,
		output wire [5:0] oICT_ENTRY,
		output wire oICT_CONF_MASK,
		output wire oICT_CONF_VALID,
		output wire [1:0] oICT_CONF_LEVEL,
		//External Exception
		input wire iEXCEPT_IRQ_REQ,
		input wire [6:0] iEXCEPT_IRQ_NUM,
		input wire [31:0] iEXCEPT_IRQ_FI0R,
		input wire [31:0] iEXCEPT_IRQ_FI1R,
		output wire oEXCEPT_IRQ_ACK,
		output wire oEXCEPT_IRQ_BUSY,
		//Execute
		input wire [31:0] iEXE_JUMP_ADDR,			//Common Jump Addres
		input wire iEXE_BRANCH_VALID,
		input wire iEXE_IDTS_VALID,
		input wire iEXE_IB_VALID,
		input wire iEXE_RELOAD_VALID
	);

	//Interrupt - Call
	wire irq_call_finished;
	wire [31:0] irq_call_hundler;
	wire irq_call_spr_valid;
	wire [31:0] irq_call_spr;

	//Interrupt Return
	wire irq_return_finished;
	wire irq_return_spr_valid;
	wire [31:0] irq_return_spr;
	
	//IDT Read & Set
	wire idt_read_finished;

	
	/****************************************************************************************************
	State
	****************************************************************************************************/
	localparam L_PARAM_IDLE = 3'h0;
	localparam L_PARAM_ALU_JUMP_IRQ_CALL = 3'h1;
	localparam L_PARAM_ALU_JUMP = 3'h2;
	localparam L_PARAM_IRQ_CALL = 3'h3;
	localparam L_PARAM_IRQ_RETURN = 3'h4;
	localparam L_PARAM_IDT_SET = 3'h5;			//IDTS Instruction
	localparam L_PARAM_RELOAD = 3'h6;


	reg [2:0] state;
	reg [2:0] b_state;

	//Start Condition
	wire alu_jump_irq_call_start_condition = (b_state == L_PARAM_IDLE) && ((iEXCEPT_IRQ_REQ && !iINTERRUPT_LOCK && iSYSREG_PSR[2]) && iEXE_BRANCH_VALID);
	wire alu_jump_start_condition = (b_state == L_PARAM_IDLE) && iEXE_BRANCH_VALID;
	wire irq_call_start_condition = (b_state == L_PARAM_IDLE) && iEXCEPT_IRQ_REQ &&  !iINTERRUPT_LOCK && iSYSREG_PSR[2];
	wire irq_return_start_condition = (b_state == L_PARAM_IDLE) && iEXE_IB_VALID;
	wire idt_set_start_condition = (b_state == L_PARAM_IDLE) && iEXE_IDTS_VALID;
	wire reload_start_condition = (b_state == L_PARAM_IDLE) && iEXE_RELOAD_VALID;

	//Stop Condition
	wire alu_jump_irq_call_finish_condition = (b_state == L_PARAM_ALU_JUMP_IRQ_CALL) && irq_call_finished;
	wire alu_jump_finish_condition = (b_state == L_PARAM_ALU_JUMP);
	wire irq_call_finish_condition = (b_state == L_PARAM_IRQ_CALL) && irq_call_finished;
	wire irq_return_finish_condition = (b_state == L_PARAM_IRQ_RETURN) && irq_return_finished;
	wire idt_set_finish_condition = (b_state == L_PARAM_IDT_SET) && idt_read_finished;
	wire reload_finish_condition = (b_state == L_PARAM_RELOAD);




	always@*begin
		case(b_state)
			L_PARAM_IDLE:
				begin
					//Core Jump Instruction and Interrupt
					if(alu_jump_irq_call_start_condition)begin
						state = L_PARAM_ALU_JUMP_IRQ_CALL;
					end
					//Interrupt
					else if(irq_call_start_condition)begin
						state = L_PARAM_IRQ_CALL;
					end
					//Core Jump Instruction
					else if(alu_jump_start_condition)begin
						state = L_PARAM_ALU_JUMP;
					end
					//Page Directory Table Set
					//else if(iEXCEPT_PDTS && iSYSREG_PSR[1:0] != 2'h0)begin
					else if(reload_start_condition)begin
						state = L_PARAM_RELOAD;					//MMU Mode or PDRT Change, so nessesary instruction reload.
					end
					//IDT Set Instruction
					else if(idt_set_start_condition)begin
						state = L_PARAM_IDT_SET;
					end
					//Interrupt Return Instruction
					else if(irq_return_start_condition)begin
						state = L_PARAM_IRQ_RETURN;
					end
					else begin
						state = b_state;
					end
				end
			L_PARAM_ALU_JUMP_IRQ_CALL:
				begin
					if(alu_jump_irq_call_finish_condition)begin
						state = L_PARAM_IDLE;
					end
					else begin
						state = b_state;
					end
				end
			L_PARAM_ALU_JUMP:
				begin
					if(alu_jump_finish_condition)begin
						state = L_PARAM_IDLE;
					end
					else begin
						state = b_state;
					end
				end
			L_PARAM_IRQ_CALL:
				begin
					if(irq_call_finish_condition)begin
						state = L_PARAM_IDLE;
					end
					else begin
						state = b_state;
					end
				end
			L_PARAM_IRQ_RETURN:
				begin
					if(irq_return_finish_condition)begin
						state = L_PARAM_IDLE;
					end
					else begin
						state = b_state;
					end
				end
			L_PARAM_IDT_SET:
				begin
					if(idt_set_finish_condition)begin
						state = L_PARAM_IDLE;
					end
					else begin
						state = b_state;
					end
				end
			L_PARAM_RELOAD:
				begin
					if(reload_finish_condition)begin
						state = L_PARAM_IDLE;
					end
					else begin
						state = b_state;
					end
				end
			default:
				begin
					state = b_state;
				end
		endcase
	end

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_state <= L_PARAM_IDLE;
		end
		else if(iRESET_SYNC)begin
			b_state <= L_PARAM_IDLE;
		end
		else begin
			b_state <= state;
		end
	end
	
	/****************************************************************************************************
	Interrupt Controller
	****************************************************************************************************/
	reg b_irq_ack;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_irq_ack <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_irq_ack <= 1'b0;
		end
		else begin
			if(alu_jump_irq_call_finish_condition || irq_call_finish_condition)begin	
				b_irq_ack <= 1'b1;
			end
			else begin
				b_irq_ack <= 1'b0;
			end
		end
	end

	assign oEXCEPT_IRQ_ACK = b_irq_ack;
	assign oEXCEPT_IRQ_BUSY = 1'b0;
	
	/****************************************************************************************************
	Interrupt Call
	****************************************************************************************************/
	wire irq_call_ldst_use;
	wire irq_call_ldst_req;
	wire [1:0] irq_call_ldst_order;
	wire irq_call_ldst_rw;
	wire [13:0] irq_call_ldst_asid;
	wire [1:0] irq_call_ldst_mmumod;
	wire [31:0] irq_call_ldst_pdt;
	wire [31:0] irq_call_ldst_addr;
	wire [31:0] irq_call_ldst_data;

	pipeline_control_irq_call IRQ_CALL(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//System Register
		.iSYSREG_IDTR(iSYSREG_IDTR),
		.iSYSREG_PSR(iSYSREG_PSR),
		.iSYSREG_SPR(iSYSREG_SPR),
		.iSYSREG_TISR(iSYSREG_TISR),
		.iSYSREG_TIDR(iSYSREG_TIDR),
		//Request
		.iIRQ_START(alu_jump_irq_call_start_condition || irq_call_start_condition),
		.iIRQ_NUM(iEXCEPT_IRQ_NUM),
		//Finish
		.oFINISH(irq_call_finished),
		.oFINISH_HUNDLER(irq_call_hundler),
		.oFINISH_SPR_VALID(irq_call_spr_valid),
		.oFINISH_SPR(irq_call_spr),
		//Load Store
		.oLDST_USE(irq_call_ldst_use),
		.oLDST_REQ(irq_call_ldst_req),
		.iLDST_BUSY(iLDST_BUSY),
		.oLDST_ORDER(irq_call_ldst_order),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oLDST_RW(irq_call_ldst_rw),		//0=Read 1=Write
		.oLDST_ASID(irq_call_ldst_asid),
		.oLDST_MMUMOD(irq_call_ldst_mmumod),
		.oLDST_PDT(irq_call_ldst_pdt),
		.oLDST_ADDR(irq_call_ldst_addr),
		.oLDST_DATA(irq_call_ldst_data),
		.iLDST_REQ(iLDST_REQ),
		.iLDST_DATA(iLDST_DATA)
	);


	
	/****************************************************************************************************
	Interrupt Return
	****************************************************************************************************/
	wire irq_return_ldst_use;
	wire irq_return_ldst_req;
	wire [1:0] irq_return_ldst_order;
	wire irq_return_ldst_rw;
	wire [13:0] irq_return_ldst_asid;
	wire [1:0] irq_return_ldst_mmumod;
	wire [31:0] irq_return_ldst_pdt;
	wire [31:0] irq_return_ldst_addr;
	wire [31:0] irq_return_ldst_data;



	pipeline_control_irq_return IRQ_RETURN(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//System Register
		.iSYSREG_PPSR(iSYSREG_PPSR),
		.iSYSREG_SPR(iSYSREG_SPR),
		.iSYSREG_TISR(iSYSREG_TISR),
		.iSYSREG_TIDR(iSYSREG_TIDR),
		//Request
		.iRETURN_START(irq_return_start_condition),
		//Finish
		.oFINISH(irq_return_finished),
		.oFINISH_SPR_VALID(irq_return_spr_valid),
		.oFINISH_SPR(irq_return_spr),
		//Load Store
		.oLDST_USE(irq_return_ldst_use),
		.oLDST_REQ(irq_return_ldst_req),
		.iLDST_BUSY(iLDST_BUSY),
		.oLDST_ORDER(irq_return_ldst_order),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oLDST_RW(irq_return_ldst_rw),		//0=Read 1=Write
		.oLDST_ASID(irq_return_ldst_asid),
		.oLDST_MMUMOD(irq_return_ldst_mmumod),
		.oLDST_PDT(irq_return_ldst_pdt),
		.oLDST_ADDR(irq_return_ldst_addr),
		.oLDST_DATA(irq_return_ldst_data),
		.iLDST_REQ(iLDST_REQ),
		.iLDST_DATA(iLDST_DATA)
	);



	/****************************************************************************************************
	IDT Read & Set
	****************************************************************************************************/
	wire idt_read_ldst_use;
	wire idt_read_ldst_req;
	wire [1:0] idt_read_ldst_order;
	wire idt_read_ldst_rw;
	wire [13:0] idt_read_ldst_asid;
	wire [1:0] idt_read_ldst_mmumod;
	wire [31:0] idt_read_ldst_pdt;
	wire [31:0] idt_read_ldst_addr;
	wire [31:0] idt_read_ldst_data;


	pipeline_control_idt_read IDT_READ(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//System Register
		.iSYSREG_IDTR(iSYSREG_IDTR),
		//Request
		.iRD_START(idt_set_start_condition),
		.oRD_FINISH(idt_read_finished),
		//Load Store
		.oLDST_USE(idt_read_ldst_use),
		.oLDST_REQ(idt_read_ldst_req),
		.iLDST_BUSY(iLDST_BUSY),
		.oLDST_ORDER(idt_read_ldst_order),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oLDST_RW(idt_read_ldst_rw),		//0=Read 1=Write
		.oLDST_ASID(idt_read_ldst_asid),
		.oLDST_MMUMOD(idt_read_ldst_mmumod),
		.oLDST_PDT(idt_read_ldst_pdt),
		.oLDST_ADDR(idt_read_ldst_addr),
		.oLDST_DATA(idt_read_ldst_data),
		.iLDST_REQ(iLDST_REQ),
		.iLDST_DATA(iLDST_DATA),
		//IRQ_CONFIG_TABLE
		.oIRQ_CONF_TABLE_REQ(oIO_IRQ_CONFIG_TABLE_REQ),
		.oIRQ_CONF_TABLE_ENTRY(oIO_IRQ_CONFIG_TABLE_ENTRY),
		.oIRQ_CONF_TABLE_FLAG_MASK(oIO_IRQ_CONFIG_TABLE_FLAG_MASK),
		.oIRQ_CONF_TABLE_FLAG_VALID(oIO_IRQ_CONFIG_TABLE_FLAG_VALID),
		.oIRQ_CONF_TABLE_FLAG_LEVEL(oIO_IRQ_CONFIG_TABLE_FLAG_LEVEL),
		//Interrupt Configlation Table
		.oICT_REQ(oICT_REQ),
		.oICT_ENTRY(oICT_ENTRY),
		.oICT_CONF_MASK(oICT_CONF_MASK),
		.oICT_CONF_VALID(oICT_CONF_VALID),
		.oICT_CONF_LEVEL(oICT_CONF_LEVEL)
	);


	/****************************************************************************************************
	Load Store Pipe
	****************************************************************************************************/
	reg [1:0] ldst_pipe_order;
	reg ldst_pipe_rw;
	reg [13:0] ldst_pipe_asid;
	reg [1:0] ldst_pipe_mmumod;
	reg [31:0] ldst_pipe_pdt;
	reg [31:0] ldst_pipe_addr;
	reg [31:0] ldst_pipe_data;

	always@*begin
		if(idt_read_ldst_use)begin
			ldst_pipe_order = idt_read_ldst_order;
			ldst_pipe_rw = idt_read_ldst_rw;
			ldst_pipe_asid = idt_read_ldst_asid;
			ldst_pipe_mmumod = idt_read_ldst_mmumod;
			ldst_pipe_pdt = idt_read_ldst_pdt;
			ldst_pipe_addr = idt_read_ldst_addr;
			ldst_pipe_data = idt_read_ldst_data;
		end
		else if(irq_call_ldst_use)begin
			ldst_pipe_order = irq_call_ldst_order;
			ldst_pipe_rw = irq_call_ldst_rw;
			ldst_pipe_asid = irq_call_ldst_asid;
			ldst_pipe_mmumod = irq_call_ldst_mmumod;
			ldst_pipe_pdt = irq_call_ldst_pdt;
			ldst_pipe_addr = irq_call_ldst_addr;
			ldst_pipe_data = irq_call_ldst_data;
		end
		else if(irq_return_ldst_use)begin
			ldst_pipe_order = irq_return_ldst_order;
			ldst_pipe_rw = irq_return_ldst_rw;
			ldst_pipe_asid = irq_return_ldst_asid;
			ldst_pipe_mmumod = irq_return_ldst_mmumod;
			ldst_pipe_pdt = irq_return_ldst_pdt;
			ldst_pipe_addr = irq_return_ldst_addr;
			ldst_pipe_data = irq_return_ldst_addr;
		end
		else begin
			ldst_pipe_order = 2'h0;
			ldst_pipe_rw = 1'b0;
			ldst_pipe_asid = 14'h0;
			ldst_pipe_mmumod = 2'h0;
			ldst_pipe_pdt = 32'h0;
			ldst_pipe_addr = 32'h0;
			ldst_pipe_data = 32'h0;
		end
	end

	assign oLDST_USE = idt_read_ldst_use || irq_call_ldst_use || irq_return_ldst_use;
	assign oLDST_REQ = idt_read_ldst_req || irq_call_ldst_req || irq_return_ldst_req;
	assign oLDST_ORDER = ldst_pipe_order;
	assign oLDST_RW = ldst_pipe_rw;
	assign oLDST_ASID = ldst_pipe_asid;
	assign oLDST_MMUMOD = ldst_pipe_mmumod;
	assign oLDST_PDT = ldst_pipe_pdt;
	assign oLDST_ADDR = ldst_pipe_addr;
	assign oLDST_DATA = ldst_pipe_data;


	/****************************************************************************************************
	System - Register Set
	****************************************************************************************************/
	//PCR(for JUMP)
	reg b_sysreg_set_pcr_valid;
	reg [31:0] b_sysreg_set_pcr;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_sysreg_set_pcr_valid <= 1'b0;
			b_sysreg_set_pcr <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_sysreg_set_pcr_valid <= 1'b0;
			b_sysreg_set_pcr <= 32'h0;
		end
		else begin
			if(alu_jump_start_condition || reload_start_condition || idt_set_start_condition)begin
				b_sysreg_set_pcr_valid <= 1'b1;
				b_sysreg_set_pcr <= iEXE_JUMP_ADDR;
			end
			else if(alu_jump_irq_call_finish_condition || irq_call_finish_condition)begin
				b_sysreg_set_pcr_valid <= 1'b1;
				b_sysreg_set_pcr <= irq_call_hundler;
			end
			else if(irq_return_start_condition)begin
				b_sysreg_set_pcr_valid <= 1'b1;
				b_sysreg_set_pcr <= iSYSREG_PPCR;
			end
			else if(b_state == L_PARAM_IDLE)begin
				b_sysreg_set_pcr_valid <= 1'b0;
				b_sysreg_set_pcr <= 32'h0;
			end
		end
	end

	assign oEVENT_SETREG_PCR_SET = b_sysreg_set_pcr_valid;
	assign oEVENT_SETREG_PCR = b_sysreg_set_pcr;

	//PPCR
	reg b_sysreg_set_ppcr_valid;
	reg [31:0] b_sysreg_set_ppcr;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_sysreg_set_ppcr_valid <= 1'b0;
			b_sysreg_set_ppcr <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_sysreg_set_ppcr_valid <= 1'b0;
			b_sysreg_set_ppcr <= 32'h0;
		end
		else begin
			b_sysreg_set_ppcr_valid <= alu_jump_irq_call_finish_condition || irq_call_finish_condition;
			b_sysreg_set_ppcr <= /*iEXE_JUMP_ADDR;*/iSYSREG_PCR;
		end
	end

	assign oEVENT_SETREG_PPCR_SET = b_sysreg_set_ppcr_valid;
	assign oEVENT_SETREG_PPCR = b_sysreg_set_ppcr;					//Always PCR(Dispatch module) is True Date? like after jump true data?

	//SPR
	reg b_sysreg_set_spr_valid;
	reg [31:0] b_sysreg_set_spr;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_sysreg_set_spr_valid <= 1'b0;
			b_sysreg_set_spr <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_sysreg_set_spr_valid <= 1'b0;
			b_sysreg_set_spr <= 32'h0;
		end
		else begin
			b_sysreg_set_spr_valid <= irq_call_spr_valid || irq_return_spr_valid;
			b_sysreg_set_spr <= (irq_call_spr_valid)? irq_call_spr : irq_return_spr;
		end
	end
	
	assign oEVENT_SETREG_SPR_SET = b_sysreg_set_spr_valid;
	assign oEVENT_SETREG_SPR = b_sysreg_set_spr;

	//FI0R
	reg b_sysreg_set_fi0r_valid;
	reg [31:0] b_sysreg_set_fi0r;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_sysreg_set_fi0r_valid <= 1'b0;
			b_sysreg_set_fi0r <= 32'h0;
		end
		else if(b_state == L_PARAM_IDLE || iRESET_SYNC)begin
			b_sysreg_set_fi0r_valid <= 1'b0;
			b_sysreg_set_fi0r <= 32'h0;
		end
		else begin
			if(alu_jump_irq_call_start_condition || irq_call_start_condition)begin
				b_sysreg_set_fi0r_valid <= 1'b1;
				b_sysreg_set_fi0r <= iEXCEPT_IRQ_FI0R;
			end
		end
	end
	
	assign oEVENT_SETREG_FI0R_SET = b_sysreg_set_fi0r_valid;
	assign oEVENT_SETREG_FI0R = b_sysreg_set_fi0r;

	//FI1R
	reg b_sysreg_set_fi1r_valid;
	reg [31:0] b_sysreg_set_fi1r;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_sysreg_set_fi1r_valid <= 1'b0;
			b_sysreg_set_fi1r <= 32'h0;
		end
		else if(b_state == L_PARAM_IDLE || iRESET_SYNC)begin
			b_sysreg_set_fi1r_valid <= 1'b0;
			b_sysreg_set_fi1r <= 32'h0;
		end
		else begin
			if(alu_jump_irq_call_start_condition || irq_call_start_condition)begin
				b_sysreg_set_fi1r_valid <= 1'b1;
				b_sysreg_set_fi1r <= iEXCEPT_IRQ_FI1R;
			end
		end
	end
	
	assign oEVENT_SETREG_FI1R_SET = b_sysreg_set_fi1r_valid;
	assign oEVENT_SETREG_FI1R = b_sysreg_set_fi1r;


	
	/****************************************************************************************************
	Assign
	****************************************************************************************************/
	assign oEVENT_CACHE_ERASE = 1'b0;
	assign oEVENT_TLB_ERASE = 1'b0;


	
	/****************************************************************************************************
	Pipeline Control - Timing
	****************************************************************************************************/
	reg b_event_hold			/* synthesis syn_maxfan = 250 */;		//Altera QuartusII Synthesis Option : Max fanout
	reg b_event_start			/* synthesis syn_maxfan = 250 */;		//Altera QuartusII Synthesis Option : Max fanout
	reg b_event_irq_front2back	/* synthesis syn_maxfan = 250 */;		//Altera QuartusII Synthesis Option : Max fanout
	reg b_event_irq_back2front	/* synthesis syn_maxfan = 250 */;		//Altera QuartusII Synthesis Option : Max fanout
	reg b_event_end				/* synthesis syn_maxfan = 250 */;		//Altera QuartusII Synthesis Option : Max fanout


	assign oEVENT_HOLD = b_event_hold;
	assign oEVENT_START = b_event_start;
	assign oEVENT_IRQ_FRONT2BACK = b_event_irq_front2back;
	assign oEVENT_IRQ_BACK2FRONT = b_event_irq_back2front;
	assign oEVENT_END = b_event_end;


	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_event_hold <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_event_hold <= 1'b0;
		end
		else begin
			case(b_state)
				L_PARAM_IDLE:
					begin
						b_event_hold <= (state != L_PARAM_IDLE);
					end
				default:
					begin
						b_event_hold <= b_event_hold;
					end
			endcase
		end
	end



	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_event_start <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_event_start <= 1'b0;
		end
		else begin
			if(b_state == L_PARAM_IDLE)begin
				b_event_start = (state != L_PARAM_IDLE);
			end
			else begin
				b_event_start <= 1'b0;
			end
		end
	end



	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_event_irq_front2back <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_event_irq_front2back <= 1'b0;
		end
		else begin
			case(b_state)
				L_PARAM_IDLE:
					begin
						//Interrupt
						if(irq_call_start_condition || alu_jump_irq_call_start_condition)begin
							b_event_irq_front2back <= 1'b1;
						end
						else begin
							b_event_irq_front2back <= 1'b0;
						end
					end
				default:
					begin
						b_event_irq_front2back <= 1'b0;
					end
			endcase
		end
	end


	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_event_irq_back2front <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_event_irq_back2front <= 1'b0;
		end
		else begin
			case(b_state)
				L_PARAM_IDLE:
					begin
						//Interrupt Return Instruction
						if(irq_return_start_condition)begin
							b_event_irq_back2front <= 1'b1;
						end
						else begin
							b_event_irq_back2front <= 1'b0;
						end
					end
				default:
					begin
						b_event_irq_back2front <= 1'b0;
					end
			endcase
		end
	end


	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_event_end <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_event_end <= 1'b0;
		end
		else begin
			b_event_end <= alu_jump_irq_call_finish_condition || alu_jump_finish_condition || irq_call_finish_condition || irq_return_finish_condition || idt_set_finish_condition || reload_finish_condition;
		end
	end



endmodule

`default_nettype wire


`include "core.h"
`include "processor.h"
`default_nettype none


module dispatch
	#(
		parameter		CORE_ID		=		0
	)(
		//System 
		input iCLOCK,
		input inRESET,
		input iFREE_REGISTER_LOCK,
		input iFREE_PIPELINE_STOP,
		input iFREE_REFRESH,
		//Exception Lock
		output oEXCEPTION_LOCK,
		//IOSR
		input iSYSREGINFO_IOSR_VALID,
		input [31:0] iSYSREGINFO_IOSR,
		//System Register
		input iFREE_SYSREG_SET_IRQ_MODE,
		input iFREE_SYSREG_CLR_IRQ_MODE,		
		//PPCR Set
		input iFREE_PPCR_SET,
		input [31:0] iFREE_PPCR,
		//FI0R Set
		input iFREE_FI0R_SET,
		input [31:0] iFREE_FI0R,
		//System Register
		output [31:0] oSYSREG_PCR,
		output [31:0] oSYSREG_IDTR,
		output [31:0] oSYSREG_TISR,
		output [31:0] oSYSREG_TIDR,
		output [31:0] oSYSREG_PSR,
		output [31:0] oSYSREG_PPSR,
		output [31:0] oSYSREG_PPCR,
		output [31:0] oSYSREG_SPR,
		//Pipeline 
		input iPREVIOUS_VALID,
		input iPREVIOUS_FAULT_PAGEFAULT,
		input iPREVIOUS_FAULT_PRIVILEGE_ERROR,
		input iPREVIOUS_FAULT_INVALID_INST,
		input iPREVIOUS_SOURCE0_ACTIVE,			
		input iPREVIOUS_SOURCE1_ACTIVE,		
		input iPREVIOUS_SOURCE0_SYSREG,		
		input iPREVIOUS_SOURCE1_SYSREG,		
		input iPREVIOUS_DESTINATION_SYSREG,
		input [4:0] iPREVIOUS_DESTINATION,			
		input iPREVIOUS_WRITEBACK,	
		input iPREVIOUS_FLAGS_WRITEBACK,	
		input [4:0] iPREVIOUS_CMD,
		input [3:0] iPREVIOUS_CC_AFE,
		input [4:0] iPREVIOUS_SOURCE0,
		input [31:0] iPREVIOUS_SOURCE1,
		input iPREVIOUS_SOURCE0_FLAGS,
		input iPREVIOUS_SOURCE1_IMM,	
		input iPREVIOUS_EX_SYS_REG,		
		input iPREVIOUS_EX_SYS_LDST,		
		input iPREVIOUS_EX_LOGIC,
		input iPREVIOUS_EX_SHIFT,
		input iPREVIOUS_EX_ADDER,
		input iPREVIOUS_EX_MUL,
		input iPREVIOUS_EX_SDIV,
		input iPREVIOUS_EX_UDIV,
		input iPREVIOUS_EX_LDST,
		input iPREVIOUS_EX_BRANCH,
		input [31:0] iPREVIOUS_PC,
		output oPREVIOUS_LOCK,
		//Next
		output oNEXT_VALID,	
		output oNEXT_FAULT_PAGEFAULT,
		output oNEXT_FAULT_PRIVILEGE_ERROR,
		output oNEXT_FAULT_INVALID_INST,
		output [31:0] oNEXT_SYSREG_PSR,	
		output [31:0] oNEXT_SYSREG_TIDR,	
		output [31:0] oNEXT_SYSREG_PDTR,
		output oNEXT_DESTINATION_SYSREG,
		output [4:0] oNEXT_DESTINATION,			
		output oNEXT_WRITEBACK,	
		output oNEXT_FLAGS_WRITEBACK,	
		output [4:0] oNEXT_CMD,
		output [3:0] oNEXT_CC_AFE,			
		output [31:0] oNEXT_SPR,	
		output [31:0] oNEXT_SOURCE0,
		output [31:0] oNEXT_SOURCE1,	
		output [4:0] oNEXT_SOURCE0_POINTER,
		output [4:0] oNEXT_SOURCE1_POINTER,
		output oNEXT_SOURCE0_SYSREG,
		output oNEXT_SOURCE1_SYSREG,
		output oNEXT_SOURCE1_IMM,
		output oNEXT_SOURCE0_FLAGS,
		output oNEXT_EX_SYS_REG,		
		output oNEXT_EX_SYS_LDST,		
		output oNEXT_EX_LOGIC,
		output oNEXT_EX_SHIFT,
		output oNEXT_EX_ADDER,
		output oNEXT_EX_MUL,
		output oNEXT_EX_SDIV,
		output oNEXT_EX_UDIV,
		output oNEXT_EX_LDST,
		output oNEXT_EX_BRANCH,
		output [31:0] oNEXT_PC,
		input iNEXT_LOCK,
		//Write Back
		input iWB_VALID,
		input [31:0] iWB_DATA,
		input [4:0] iWB_DESTINATION,
		input iWB_DESTINATION_SYSREG,
		input iWB_WRITEBACK,
		input iWB_SPR_WRITEBACK,
		input [31:0] iWB_SPR,
		input [31:0] iWB_PC,
		input iWB_BRANCH,
		input [31:0] iWB_BRANCH_PC,
		//Debug Module
		output [31:0] oDEBUG_REG_OUT_GR0,
		output [31:0] oDEBUG_REG_OUT_GR1,
		output [31:0] oDEBUG_REG_OUT_GR2,
		output [31:0] oDEBUG_REG_OUT_GR3,
		output [31:0] oDEBUG_REG_OUT_GR4,
		output [31:0] oDEBUG_REG_OUT_GR5,
		output [31:0] oDEBUG_REG_OUT_GR6,
		output [31:0] oDEBUG_REG_OUT_GR7,
		output [31:0] oDEBUG_REG_OUT_GR8,
		output [31:0] oDEBUG_REG_OUT_GR9,
		output [31:0] oDEBUG_REG_OUT_GR10,
		output [31:0] oDEBUG_REG_OUT_GR11,
		output [31:0] oDEBUG_REG_OUT_GR12,
		output [31:0] oDEBUG_REG_OUT_GR13,
		output [31:0] oDEBUG_REG_OUT_GR14,
		output [31:0] oDEBUG_REG_OUT_GR15,
		output [31:0] oDEBUG_REG_OUT_GR16,
		output [31:0] oDEBUG_REG_OUT_GR17,
		output [31:0] oDEBUG_REG_OUT_GR18,
		output [31:0] oDEBUG_REG_OUT_GR19,
		output [31:0] oDEBUG_REG_OUT_GR20,
		output [31:0] oDEBUG_REG_OUT_GR21,
		output [31:0] oDEBUG_REG_OUT_GR22,
		output [31:0] oDEBUG_REG_OUT_GR23,
		output [31:0] oDEBUG_REG_OUT_GR24,
		output [31:0] oDEBUG_REG_OUT_GR25,
		output [31:0] oDEBUG_REG_OUT_GR26,
		output [31:0] oDEBUG_REG_OUT_GR27,
		output [31:0] oDEBUG_REG_OUT_GR28,
		output [31:0] oDEBUG_REG_OUT_GR29,
		output [31:0] oDEBUG_REG_OUT_GR30,
		output [31:0] oDEBUG_REG_OUT_GR31,
		output [31:0] oDEBUG_REG_OUT_SPR,
		output [31:0] oDEBUG_REG_OUT_PCR,
		output [31:0] oDEBUG_REG_OUT_PPCR,
		output [31:0] oDEBUG_REG_OUT_PSR,
		output [31:0] oDEBUG_REG_OUT_PPSR
	);
	
	
	wire w_sysreg_pcr_regist_valid;
	wire [31:0] w_sysreg_pcr_regist_data;
	wire [31:0] w_sysreg_pcr_info_data;
	
	assign	oSYSREG_PCR		=		w_sysreg_pcr_info_data;
	assign	oEXCEPTION_LOCK	=		!b_pcr_valid || !b_valid || (b_valid && b_ex_branch);
	//PCR
	system_register PCR	(
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_pcr_regist_valid), 
		.iREGIST_DATA(w_sysreg_pcr_regist_data), 
		.oINFO_DATA(w_sysreg_pcr_info_data)
	);
	assign		w_sysreg_pcr_regist_valid		=		iWB_VALID && !iFREE_PIPELINE_STOP && !iFREE_REGISTER_LOCK;
	assign		w_sysreg_pcr_regist_data		=		(iWB_BRANCH)? iWB_BRANCH_PC : iWB_PC;
	
	reg			b_pcr_valid;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_pcr_valid <= 1'b0;
		end
		else if(iFREE_REFRESH)begin
			b_pcr_valid <= 1'b0;
		end
		else begin
			if(!b_pcr_valid)begin
				if(iWB_VALID && !iFREE_PIPELINE_STOP)begin
					b_pcr_valid <= 1'b1;
				end
			end
		end
	end
	

	
	
	
	
	//System Register
	wire	[31:0]		w_sysreg_cpuidr_info_data;
	wire	[31:0]		w_sysreg_coreidr_info_data;
	wire				w_sysreg_tidr_regist_valid;
	wire	[31:0]		w_sysreg_tidr_regist_data;
	wire	[31:0]		w_sysreg_tidr_info_data;
	wire				w_sysreg_psr_regist_valid;
	wire	[31:0]		w_sysreg_psr_regist_data;
	wire	[31:0]		w_sysreg_psr_info_data;
	wire				w_sysreg_spr_regist_valid;
	wire	[31:0]		w_sysreg_spr_regist_data;
	wire	[31:0]		w_sysreg_spr_info_data;
	wire				w_sysreg_idtr_regist_valid;
	wire	[31:0]		w_sysreg_idtr_regist_data;
	wire	[31:0]		w_sysreg_idtr_info_data;
	wire				w_sysreg_pdtr_regist_valid;
	wire	[31:0]		w_sysreg_pdtr_regist_data;
	wire	[31:0]		w_sysreg_pdtr_info_data;
	wire				w_sysreg_tisr_regist_valid;
	wire	[31:0]		w_sysreg_tisr_regist_data;
	wire	[31:0]		w_sysreg_tisr_info_data;
	wire				w_sysreg_kpdtr_regist_valid;
	wire	[31:0]		w_sysreg_kpdtr_regist_data;
	wire	[31:0]		w_sysreg_kpdtr_info_data;
	wire	[31:0]		w_sysreg_iosr_info_data;
	wire				w_sysreg_ppcr_regist_valid;
	wire	[31:0]		w_sysreg_ppcr_regist_data;
	wire	[31:0]		w_sysreg_ppcr_info_data;
	wire				w_sysreg_ptidr_regist_valid;
	wire	[31:0]		w_sysreg_ptidr_regist_data;
	wire	[31:0]		w_sysreg_ptidr_info_data;
	wire				w_sysreg_ppdtr_regist_valid;
	wire	[31:0]		w_sysreg_ppdtr_regist_data;
	wire	[31:0]		w_sysreg_ppdtr_info_data;	
	wire				w_sysreg_ppsr_regist_valid;
	wire	[31:0]		w_sysreg_ppsr_regist_data;
	wire	[31:0]		w_sysreg_ppsr_info_data;
	wire				w_sysreg_frclr_regist_valid;
	wire	[31:0]		w_sysreg_frclr_regist_data;
	wire				w_sysreg_frchr_regist_valid;
	wire	[31:0]		w_sysreg_frchr_regist_data;
	wire	[31:0]		w_sysreg_frclr_info_data;
	wire	[31:0]		w_sysreg_frchr_info_data;
	
	
	/****************************************
	System Register
	****************************************/
	wire			writeback_source0_valid, writeback_source1_valid;
	wire	[31:0]	writeback_source0, writeback_source1;
	
	assign	{writeback_source0_valid, writeback_source0}	=	func_writeback_set(
																	iPREVIOUS_SOURCE0[4:0], 
																	iPREVIOUS_SOURCE0_SYSREG,
																	//Writeback
																	iWB_VALID,
																	iWB_DATA,
																	iWB_DESTINATION,
																	iWB_DESTINATION_SYSREG,
																	iWB_WRITEBACK,
																	iWB_SPR_WRITEBACK,
																	iWB_SPR,
																	iWB_PC
																);
	
	
	assign	{writeback_source1_valid, writeback_source1}	=	func_writeback_set_imm(
																	iPREVIOUS_SOURCE1[4:0], 
																	iPREVIOUS_SOURCE1_SYSREG,
																	iPREVIOUS_SOURCE1_IMM,
																	//Writeback
																	iWB_VALID,
																	iWB_DATA,
																	iWB_DESTINATION,
																	iWB_DESTINATION_SYSREG,
																	iWB_WRITEBACK,
																	iWB_SPR_WRITEBACK,
																	iWB_SPR,
																	iWB_PC
																);
	
	
	
	function [32:0] func_writeback_set;
		//Select
		input	[4:0]		func_register;
		input				func_sysreg;
		/*******Writeback*******/
		input				func_wb_valid;
		input	[31:0]		func_wb_data;
		input	[4:0]		func_wb_destination;
		input				func_wb_destination_sysreg;
		input				func_wb_writeback;
		input				func_wb_spr_writeback;
		input	[31:0]		func_wb_spr;
		input	[31:0]		func_wb_pc;
		begin
			if(func_wb_valid)begin
				if(func_sysreg)begin
					if(func_wb_destination_sysreg)begin
						if(func_register == `SYSREG_PCR)begin
							func_writeback_set = {1'b1, func_wb_pc};
						end
						else if(func_register == `SYSREG_SPR && func_wb_spr_writeback)begin
							func_writeback_set = {1'b1, func_wb_spr};
						end
						else if(func_register == func_wb_destination && func_wb_writeback)begin
							func_writeback_set = {1'b1, func_wb_data};
						end
						else begin
							func_writeback_set = {1'b0, 32'h0};
						end
					end
					else begin
						func_writeback_set = {1'b0, 32'h0};
					end
				end
				else begin
					if(func_register == func_wb_destination && !func_wb_destination_sysreg && func_wb_writeback)begin
						func_writeback_set = {1'b1, func_wb_data};
					end
					else begin
						func_writeback_set = {1'b0, 32'h0};
					end
				end
			end
			else begin
				func_writeback_set = {1'b0, 32'h0};
			end
		end
	endfunction
		
	
	function [32:0] func_writeback_set_imm;
		//Select
		input	[4:0]		func_register;
		input				func_sysreg;
		input				func_imm;
		/*******Writeback*******/
		input				func_wb_valid;
		input	[31:0]		func_wb_data;
		input	[4:0]		func_wb_destination;
		input				func_wb_destination_sysreg;
		input				func_wb_writeback;
		input				func_wb_spr_writeback;
		input	[31:0]		func_wb_spr;
		input	[31:0]		func_wb_pc;
		begin
			if(!func_imm)begin
				if(func_wb_valid)begin
					if(func_sysreg)begin
						if(func_wb_destination_sysreg)begin
							if(func_register == `SYSREG_PCR)begin
								func_writeback_set_imm = {1'b1, func_wb_pc};
							end
							else if(func_register == `SYSREG_SPR && func_wb_spr_writeback)begin
								func_writeback_set_imm = {1'b1, func_wb_spr};
							end
							else if(func_register == func_wb_destination && func_wb_writeback)begin
								func_writeback_set_imm = {1'b1, func_wb_data};
							end
							else begin
								func_writeback_set_imm = {1'b0, 32'h0};
							end
						end
						else begin
							func_writeback_set_imm = {1'b0, 32'h0};
						end
					end
					else begin
						if(func_register == func_wb_destination && !func_wb_destination_sysreg && func_wb_writeback)begin
							func_writeback_set_imm = {1'b1, func_wb_data};
						end
						else begin
							func_writeback_set_imm = {1'b0, 32'h0};
						end
					end
				end
				else begin
					func_writeback_set_imm = {1'b0, 32'h0};
				end
			end
			else begin
				func_writeback_set_imm = {1'b0, 32'h0};
			end
		end
	endfunction
	
	
	
	
	wire			sysreg_source0_valid, sysreg_source1_valid;
	wire	[31:0]	sysreg_source0, sysreg_source1;

	assign	{sysreg_source0_valid, sysreg_source0}	=	func_sysreg_set(
																			iPREVIOUS_SOURCE0_ACTIVE,
																			iPREVIOUS_SOURCE0[4:0], 
																			w_sysreg_cpuidr_info_data,
																			w_sysreg_coreidr_info_data,
																			w_sysreg_tidr_info_data,
																			iPREVIOUS_PC - 32'h4,
																			w_sysreg_spr_info_data,
																			w_sysreg_psr_info_data,
																			w_sysreg_idtr_info_data,
																			w_sysreg_pdtr_info_data,
																			w_sysreg_tisr_info_data,
																			w_sysreg_kpdtr_info_data,
																			w_sysreg_iosr_info_data,
																			w_sysreg_ppsr_info_data,
																			w_sysreg_ppcr_info_data,
																			w_sysreg_ppdtr_info_data,
																			w_sysreg_ptidr_info_data,
																			w_sysreg_frclr_info_data,
																			w_sysreg_frchr_info_data																									
														);
	assign	{sysreg_source1_valid, sysreg_source1}	=	func_sysreg_set(
																			iPREVIOUS_SOURCE1_ACTIVE,
																			iPREVIOUS_SOURCE1[4:0], 
																			w_sysreg_cpuidr_info_data,
																			w_sysreg_coreidr_info_data,
																			w_sysreg_tidr_info_data,
																			iPREVIOUS_PC - 32'h4,
																			w_sysreg_spr_info_data,
																			w_sysreg_psr_info_data,
																			w_sysreg_idtr_info_data,
																			w_sysreg_pdtr_info_data,
																			w_sysreg_tisr_info_data,
																			w_sysreg_kpdtr_info_data,
																			w_sysreg_iosr_info_data,
																			w_sysreg_ppsr_info_data,
																			w_sysreg_ppcr_info_data,
																			w_sysreg_ppdtr_info_data,
																			w_sysreg_ptidr_info_data,
																			w_sysreg_frclr_info_data,
																			w_sysreg_frchr_info_data
														);
	
	
	reg b_valid;	
	reg b_fault_pagefault;
	reg b_fault_privilege_error;
	reg b_fault_invalid_inst;
	reg b_destination_sysreg;
	reg [4:0] b_destination;			
	reg b_writeback;	
	reg b_flag_writeback;				
	reg [4:0] b_cmd;
	reg [3:0] b_cc_afe;
	reg [31:0] b_source0;
	reg [31:0] b_source1;	
	reg [4:0] b_source0_pointer;
	reg [4:0] b_source1_pointer;
	reg b_source0_sysreg;
	reg b_source1_sysreg;
	reg b_source1_imm;
	reg b_source0_flags;
	reg b_ex_sys_reg;
	reg b_ex_sys_ldst;
	reg b_ex_logic;
	reg b_ex_shift;
	reg b_ex_adder;
	reg b_ex_mul;
	reg b_ex_sdiv;
	reg b_ex_udiv;
	reg b_ex_ldst;
	reg b_ex_branch;
	reg [31:0] b_pc;
	
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_valid <= 1'b0;
			b_fault_pagefault <= 1'b0;
			b_fault_privilege_error <= 1'b0;
			b_fault_invalid_inst <= 1'b0;
			b_destination_sysreg <= 1'b0;
			b_destination <= 5'h0;
			b_writeback <= 1'b0;
			b_flag_writeback <= 1'b0;
			b_cmd <= 5'h0;
			b_cc_afe <= 4'h0;
			b_source0 <= 32'h0;
			b_source1 <= 32'h0;
			b_source0_pointer <= 5'h0;
			b_source1_pointer <= 5'h0;
			b_source0_sysreg <= 1'b0;
			b_source1_sysreg <= 1'b0;
			b_source1_imm <= 1'b0;
			b_source0_flags <= 1'b0;
			b_ex_sys_reg <= 1'b0;
			b_ex_sys_ldst <= 1'b0;
			b_ex_logic <= 1'b0;
			b_ex_shift <= 1'b0;
			b_ex_adder <= 1'b0;
			b_ex_mul <= 1'b0;
			b_ex_sdiv <= 1'b0;
			b_ex_udiv <= 1'b0;
			b_ex_ldst <= 1'b0;
			b_ex_branch <= 1'b0;
			b_pc <= 32'h0;
		end
		else if(iFREE_REFRESH)begin
			b_valid <= 1'b0;
			b_fault_pagefault <= 1'b0;
			b_fault_privilege_error <= 1'b0;
			b_fault_invalid_inst <= 1'b0;
			b_destination_sysreg <= 1'b0;
			b_destination <= 5'h0;
			b_writeback <= 1'b0;
			b_flag_writeback <= 1'b0;
			b_cmd <= 5'h0;
			b_cc_afe <= 4'h0;
			b_source0 <= 32'h0;
			b_source1 <= 32'h0;
			b_source0_pointer <= 5'h0;
			b_source1_pointer <= 5'h0;
			b_source0_sysreg <= 1'b0;
			b_source1_sysreg <= 1'b0;
			b_source1_imm <= 1'b0;
			b_source0_flags <= 1'b0;
			b_ex_sys_reg <= 1'b0;
			b_ex_sys_ldst <= 1'b0;
			b_ex_logic <= 1'b0;
			b_ex_shift <= 1'b0;
			b_ex_adder <= 1'b0;
			b_ex_mul <= 1'b0;
			b_ex_sdiv <= 1'b0;
			b_ex_udiv <= 1'b0;
			b_ex_ldst <= 1'b0;
			b_ex_branch <= 1'b0;
			b_pc <= 32'h0;
		end
		else begin
			if(!iNEXT_LOCK)begin
				b_valid <= iPREVIOUS_VALID;//latch_condition;
				b_fault_pagefault <= iPREVIOUS_FAULT_PAGEFAULT;
				b_fault_privilege_error <= iPREVIOUS_FAULT_PRIVILEGE_ERROR;
				b_fault_invalid_inst <= iPREVIOUS_FAULT_INVALID_INST;
				b_destination_sysreg <= iPREVIOUS_DESTINATION_SYSREG;
				b_destination <= iPREVIOUS_DESTINATION;
				b_writeback <= iPREVIOUS_WRITEBACK;
				b_flag_writeback <= iPREVIOUS_FLAGS_WRITEBACK;
				b_cmd <= iPREVIOUS_CMD;
				b_cc_afe <= iPREVIOUS_CC_AFE;
				if(writeback_source0_valid)begin
					b_source0 <= writeback_source0;
				end
				else begin
					b_source0 <= (sysreg_source0_valid && iPREVIOUS_SOURCE0_SYSREG)? sysreg_source0 : b_gr_register[iPREVIOUS_SOURCE0[4:0]];
				end
				if(writeback_source1_valid && !iPREVIOUS_SOURCE1_IMM)begin
					b_source1 <= writeback_source1;
				end
				else begin
					b_source1 <= (iPREVIOUS_SOURCE1_IMM)? iPREVIOUS_SOURCE1 : ((sysreg_source1_valid && iPREVIOUS_SOURCE1_SYSREG)? sysreg_source1 : b_gr_register[iPREVIOUS_SOURCE1[4:0]]);
				end
				b_source0_pointer <= iPREVIOUS_SOURCE0;
				b_source1_pointer <= iPREVIOUS_SOURCE1[4:0];
				b_source0_sysreg <= iPREVIOUS_SOURCE0_SYSREG;
				b_source1_sysreg <= iPREVIOUS_SOURCE1_SYSREG;
				b_source1_imm <= iPREVIOUS_SOURCE1_IMM;
				b_source0_flags <= iPREVIOUS_SOURCE0_FLAGS;
				b_ex_sys_reg <= iPREVIOUS_EX_SYS_REG;
				b_ex_sys_ldst <= iPREVIOUS_EX_SYS_LDST;
				b_ex_logic <= iPREVIOUS_EX_LOGIC;
				b_ex_shift <= iPREVIOUS_EX_SHIFT;
				b_ex_adder <= iPREVIOUS_EX_ADDER;
				b_ex_mul <= iPREVIOUS_EX_MUL;
				b_ex_sdiv <= iPREVIOUS_EX_SDIV;
				b_ex_udiv <= iPREVIOUS_EX_UDIV;
				b_ex_ldst <= iPREVIOUS_EX_LDST;
				b_ex_branch <= iPREVIOUS_EX_BRANCH;
				b_pc <= iPREVIOUS_PC;
			end
		end
	end
	

	
	function [32:0] func_sysreg_set;
		//Active
		input				func_active;
		//Select
		input	[4:0]		func_sysreg;
		//Sysreg
		input	[31:0]		func_cpuidr;
		input	[31:0]		func_coreidr;
		input	[31:0]		func_tidr;
		input	[31:0]		func_pcr;
		input	[31:0]		func_spr;
		input	[31:0]		func_psr;
		input	[31:0]		func_idtr;
		input	[31:0]		func_pdtr;
		input	[31:0]		func_tisr;
		input	[31:0]		func_kpdtr;
		input	[31:0]		func_iosr;	
		input	[31:0]		func_ppsr;	
		input	[31:0]		func_ppcr;	
		input	[31:0]		func_ppdtr;
		input	[31:0]		func_ptidr;
		input	[31:0]		func_frclr;
		input	[31:0]		func_frchr;
		begin
			if(func_active)begin
				case(func_sysreg)
					`SYSREG_CPUIDR		:	func_sysreg_set		=		{1'b1, func_cpuidr};
					`SYSREG_COREIDR		:	func_sysreg_set		=		{1'b1, func_coreidr};
					`SYSREG_TIDR		:	func_sysreg_set		=		{1'b1, func_tidr};
					//`SYSREG_FLAGR		Non Use
					`SYSREG_PCR			:	func_sysreg_set		=		{1'b1, func_pcr};
					`SYSREG_SPR			:	func_sysreg_set		=		{1'b1, func_spr};
					`SYSREG_PSR			:	func_sysreg_set		=		{1'b1, func_psr};
					`SYSREG_IDTR		:	func_sysreg_set		=		{1'b1, func_idtr};
					`SYSREG_PDTR		:	func_sysreg_set		=		{1'b1, func_pdtr};
					`SYSREG_TISR		:	func_sysreg_set		=		{1'b1, func_tisr};
					`SYSREG_KPDTR		:	func_sysreg_set		=		{1'b1, func_kpdtr};
					`SYSREG_IOSR		:	func_sysreg_set		=		{1'b1, func_iosr};
					`SYSREG_PPSR		:	func_sysreg_set		=		{1'b1, func_ppsr};
					`SYSREG_PPCR		:	func_sysreg_set		=		{1'b1, func_ppcr};
					`SYSREG_PPDTR		:	func_sysreg_set		=		{1'b1, func_ppdtr};
					`SYSREG_PTIDR		:	func_sysreg_set		=		{1'b1, func_ptidr};
					`SYSREG_FRCLR		:	func_sysreg_set		=		{1'b1, func_frclr};
					`SYSREG_FRCHR		:	func_sysreg_set		=		{1'b1, func_frchr};
					default	:
						begin
							func_sysreg_set		=		{1'b0, 32'h0};
						end
				endcase
			end
			else begin
				func_sysreg_set		=		{1'b0, 27'h0, func_sysreg};	
			end
		end
	endfunction
	
	



	/****************************************
	General Register File
	****************************************/
	reg		[31:0]		b_gr_register[0:31];
	integer i;
	
	//Write Back
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			for(i = 0; i < 32; i = i + 1)begin
				b_gr_register	[i]						<=		32'h0;
			end
		end
		else begin
			if(iWB_VALID && !iWB_DESTINATION_SYSREG && iWB_WRITEBACK && !iFREE_PIPELINE_STOP)begin
				b_gr_register	[iWB_DESTINATION]		<=		iWB_DATA;
			end
		end
	end//General Register Write Back
	
	
	
	/****************************************
	System Register File
	****************************************/
	//CPUIDR : Processor ID Register
	system_register CPUIDR (
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(1'b1), .iREGIST_DATA({`PROCESSOR_ID, `PROCESSOR_REVISION}), 
		.oINFO_DATA(w_sysreg_cpuidr_info_data)
	);
								
	//COREIDR : Core ID Register
	system_register COREIDR (
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(1'b1), .iREGIST_DATA(CORE_ID), 
		.oINFO_DATA(w_sysreg_coreidr_info_data)
	);
	
	//TIDR : Task ID Register
	system_register TIDR (
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_tidr_regist_valid), .iREGIST_DATA(w_sysreg_tidr_regist_data), 
		.oINFO_DATA(w_sysreg_tidr_info_data)
	);
	assign		w_sysreg_tidr_regist_valid		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_TIDR);
	assign		w_sysreg_tidr_regist_data		=		iWB_DATA;
	
	
	//FLAGR : Renaming System Register
	
	//PCR : Non Use Register
	
	//PSR : Program Status Register
	system_register PSR (
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_psr_regist_valid), .iREGIST_DATA(w_sysreg_psr_regist_data), 
		.oINFO_DATA(w_sysreg_psr_info_data)
	);							
	assign		w_sysreg_psr_regist_valid		=		iFREE_SYSREG_SET_IRQ_MODE || iFREE_SYSREG_CLR_IRQ_MODE || (!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PSR);
	assign		w_sysreg_psr_regist_data		=		(iFREE_SYSREG_SET_IRQ_MODE)? {w_sysreg_psr_info_data[31:7], 2'h0, w_sysreg_psr_info_data[4:3], 1'b0, w_sysreg_psr_info_data[1:0]} : (
															(iFREE_SYSREG_CLR_IRQ_MODE)? w_sysreg_ppsr_info_data : iWB_DATA
														);
														
	//SPR
	system_register SPR (
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_spr_regist_valid), .iREGIST_DATA(w_sysreg_spr_regist_data), 
		.oINFO_DATA(w_sysreg_spr_info_data)
	);
	assign		w_sysreg_spr_regist_valid		=		((!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_SPR) || !iFREE_PIPELINE_STOP && iWB_SPR_WRITEBACK && iWB_VALID);
	assign		w_sysreg_spr_regist_data		=		(!iFREE_PIPELINE_STOP && iWB_SPR_WRITEBACK && iWB_VALID)? iWB_SPR : iWB_DATA;
			
			
	//IDTR
	system_register IDTR (
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_idtr_regist_valid), .iREGIST_DATA(w_sysreg_idtr_regist_data), 
		.oINFO_DATA(w_sysreg_idtr_info_data)
	);
	assign		w_sysreg_idtr_regist_valid		=		!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_IDTR;
	assign		w_sysreg_idtr_regist_data		=		iWB_DATA;
	
	//FI0R
	system_register FI0R (
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(iFREE_FI0R_SET), .iREGIST_DATA(iFREE_FI0R), 
		.oINFO_DATA()
	);
	
	//PDTR : Page Directory Table Register
	system_register PDTR	(
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_pdtr_regist_valid), .iREGIST_DATA(w_sysreg_pdtr_regist_data), 
		.oINFO_DATA(w_sysreg_pdtr_info_data)
	);
	assign		w_sysreg_pdtr_regist_valid		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PDTR);
	assign		w_sysreg_pdtr_regist_data		=		iWB_DATA;	
	
	//TISR
	system_register TISR	(
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_tisr_regist_valid), .iREGIST_DATA(w_sysreg_tisr_regist_data), 
		.oINFO_DATA(w_sysreg_tisr_info_data)
	);
	assign		w_sysreg_tisr_regist_valid		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_TISR);
	assign		w_sysreg_tisr_regist_data		=		iWB_DATA;	
	
	//KPDTR
	system_register KPDTR	(
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_kpdtr_regist_valid), .iREGIST_DATA(w_sysreg_kpdtr_regist_data), 
		.oINFO_DATA(w_sysreg_kpdtr_info_data)
	);
	assign		w_sysreg_kpdtr_regist_valid		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_KPDTR);
	assign		w_sysreg_kpdtr_regist_data		=		iWB_DATA;	
	
	//IOSR
	system_register IOSR	(
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(iSYSREGINFO_IOSR_VALID), .iREGIST_DATA(iSYSREGINFO_IOSR), 
		.oINFO_DATA(w_sysreg_iosr_info_data)
	);
	
	
	//PPSR : Previous Program Status Register
	system_register PPSR	(
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_ppsr_regist_valid), .iREGIST_DATA(w_sysreg_ppsr_regist_data), 
		.oINFO_DATA(w_sysreg_ppsr_info_data)
	);
	assign		w_sysreg_ppsr_regist_valid		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PPSR) || iFREE_SYSREG_SET_IRQ_MODE;
	assign		w_sysreg_ppsr_regist_data		=		(iFREE_SYSREG_SET_IRQ_MODE)? w_sysreg_psr_info_data : iWB_DATA;


	//PPCR : Previous Program Counter
	system_register PPCR	(
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_ppcr_regist_valid), .iREGIST_DATA(w_sysreg_ppcr_regist_data), 
		.oINFO_DATA(w_sysreg_ppcr_info_data)
	);
	assign		w_sysreg_ppcr_regist_valid		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PPCR) || iFREE_PPCR_SET;
	assign		w_sysreg_ppcr_regist_data		=		(iFREE_PPCR_SET)? iFREE_PPCR : iWB_DATA;
	
	
	//PPDTR : Previous Page Directry Table Register
	system_register PPDTR	(
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_ppdtr_regist_valid), .iREGIST_DATA(w_sysreg_ppdtr_regist_data), 
		.oINFO_DATA(w_sysreg_ppdtr_info_data)
	);
	assign		w_sysreg_ppdtr_regist_valid		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PPDTR) || iFREE_SYSREG_SET_IRQ_MODE;
	assign		w_sysreg_ppdtr_regist_data		=		(iFREE_SYSREG_SET_IRQ_MODE)? w_sysreg_pdtr_info_data : iWB_DATA;

	
	//PTIDR : Previous Task Id Register
	system_register PTIDR	(
		.iCLOCK(iCLOCK), .inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_ptidr_regist_valid), .iREGIST_DATA(w_sysreg_ptidr_regist_data), 
		.oINFO_DATA(w_sysreg_ptidr_info_data)
	);
	assign		w_sysreg_ptidr_regist_valid		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PTIDR) || iFREE_SYSREG_SET_IRQ_MODE;
	assign		w_sysreg_ptidr_regist_data		=		(iFREE_SYSREG_SET_IRQ_MODE)? w_sysreg_tidr_info_data : iWB_DATA;


	//FRCR
	wire			frcr_64bit_write_condition;
	wire	[63:0]	frcr_64bit_timer;
	assign			frcr_64bit_write_condition		=	(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCR);

	
	frcr_timer FRCR(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iWR_ENA(frcr_64bit_write_condition),
		.iRW_COUNTER({w_sysreg_frchr_info_data, w_sysreg_frclr_info_data}),
		.oCOUNTER(frcr_64bit_timer)
	);
	
	
	//FRCLR
	system_register FRCLR	(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_frclr_regist_valid), 
		.iREGIST_DATA(w_sysreg_frclr_regist_data), 
		.oINFO_DATA(w_sysreg_frclr_info_data)
	);
	
	assign		w_sysreg_frclr_regist_valid		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCLR) || 
														(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCR2FRCXR);
	assign		w_sysreg_frclr_regist_data		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCLR)? iWB_DATA : frcr_64bit_timer[31:0];
	

	//FRCHR
	system_register FRCHR	(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET),
		.iREGIST_DATA_VALID(w_sysreg_frchr_regist_valid), 
		.iREGIST_DATA(w_sysreg_frchr_regist_data), 
		.oINFO_DATA(w_sysreg_frchr_info_data)
	);
	
	
	assign		w_sysreg_frchr_regist_valid		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCHR) || 
														(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCR2FRCXR);
	assign		w_sysreg_frchr_regist_data		=		(!iFREE_PIPELINE_STOP && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCHR)? iWB_DATA : frcr_64bit_timer[63:32];
	

	
	//Debug Modulegenerate
	generate
		//Debug Module Enable
		if(`PROCESSOR_USE_DEBUG_MODULE)begin
			assign oDEBUG_REG_OUT_GR0 = b_gr_register[0];
			assign oDEBUG_REG_OUT_GR1 = b_gr_register[1];
			assign oDEBUG_REG_OUT_GR2 = b_gr_register[2];
			assign oDEBUG_REG_OUT_GR3 = b_gr_register[3];
			assign oDEBUG_REG_OUT_GR4 = b_gr_register[4];
			assign oDEBUG_REG_OUT_GR5 = b_gr_register[5];
			assign oDEBUG_REG_OUT_GR6 = b_gr_register[6];
			assign oDEBUG_REG_OUT_GR7 = b_gr_register[7];
			assign oDEBUG_REG_OUT_GR8 = b_gr_register[8];
			assign oDEBUG_REG_OUT_GR9 = b_gr_register[9];
			assign oDEBUG_REG_OUT_GR10 = b_gr_register[10];
			assign oDEBUG_REG_OUT_GR11 = b_gr_register[11];
			assign oDEBUG_REG_OUT_GR12 = b_gr_register[12];
			assign oDEBUG_REG_OUT_GR13 = b_gr_register[13];
			assign oDEBUG_REG_OUT_GR14 = b_gr_register[14];
			assign oDEBUG_REG_OUT_GR15 = b_gr_register[15];
			assign oDEBUG_REG_OUT_GR16 = b_gr_register[16];
			assign oDEBUG_REG_OUT_GR17 = b_gr_register[17];
			assign oDEBUG_REG_OUT_GR18 = b_gr_register[18];
			assign oDEBUG_REG_OUT_GR19 = b_gr_register[19];
			assign oDEBUG_REG_OUT_GR20 = b_gr_register[20];
			assign oDEBUG_REG_OUT_GR21 = b_gr_register[21];
			assign oDEBUG_REG_OUT_GR22 = b_gr_register[22];
			assign oDEBUG_REG_OUT_GR23 = b_gr_register[23];
			assign oDEBUG_REG_OUT_GR24 = b_gr_register[24];
			assign oDEBUG_REG_OUT_GR25 = b_gr_register[25];
			assign oDEBUG_REG_OUT_GR26 = b_gr_register[26];
			assign oDEBUG_REG_OUT_GR27 = b_gr_register[27];
			assign oDEBUG_REG_OUT_GR28 = b_gr_register[28];
			assign oDEBUG_REG_OUT_GR29 = b_gr_register[29];
			assign oDEBUG_REG_OUT_GR30 = b_gr_register[30];
			assign oDEBUG_REG_OUT_GR31 = b_gr_register[31];
			assign oDEBUG_REG_OUT_SPR = w_sysreg_spr_info_data;
			assign oDEBUG_REG_OUT_PCR = w_sysreg_pcr_info_data;
			assign oDEBUG_REG_OUT_PPCR = w_sysreg_ppcr_info_data;
			assign oDEBUG_REG_OUT_PSR = w_sysreg_psr_info_data;
			assign oDEBUG_REG_OUT_PPSR = w_sysreg_ppsr_info_data;
		end
		//Disable
		else begin
			assign oDEBUG_REG_OUT_GR0 = 32'h0;
			assign oDEBUG_REG_OUT_GR1 = 32'h0;
			assign oDEBUG_REG_OUT_GR2 = 32'h0;
			assign oDEBUG_REG_OUT_GR3 = 32'h0;
			assign oDEBUG_REG_OUT_GR4 = 32'h0;
			assign oDEBUG_REG_OUT_GR5 = 32'h0;
			assign oDEBUG_REG_OUT_GR6 = 32'h0;
			assign oDEBUG_REG_OUT_GR7 = 32'h0;
			assign oDEBUG_REG_OUT_GR8 = 32'h0;
			assign oDEBUG_REG_OUT_GR9 = 32'h0;
			assign oDEBUG_REG_OUT_GR10 = 32'h0;
			assign oDEBUG_REG_OUT_GR11 = 32'h0;
			assign oDEBUG_REG_OUT_GR12 = 32'h0;
			assign oDEBUG_REG_OUT_GR13 = 32'h0;
			assign oDEBUG_REG_OUT_GR14 = 32'h0;
			assign oDEBUG_REG_OUT_GR15 = 32'h0;
			assign oDEBUG_REG_OUT_GR16 = 32'h0;
			assign oDEBUG_REG_OUT_GR17 = 32'h0;
			assign oDEBUG_REG_OUT_GR18 = 32'h0;
			assign oDEBUG_REG_OUT_GR19 = 32'h0;
			assign oDEBUG_REG_OUT_GR20 = 32'h0;
			assign oDEBUG_REG_OUT_GR21 = 32'h0;
			assign oDEBUG_REG_OUT_GR22 = 32'h0;
			assign oDEBUG_REG_OUT_GR23 = 32'h0;
			assign oDEBUG_REG_OUT_GR24 = 32'h0;
			assign oDEBUG_REG_OUT_GR25 = 32'h0;
			assign oDEBUG_REG_OUT_GR26 = 32'h0;
			assign oDEBUG_REG_OUT_GR27 = 32'h0;
			assign oDEBUG_REG_OUT_GR28 = 32'h0;
			assign oDEBUG_REG_OUT_GR29 = 32'h0;
			assign oDEBUG_REG_OUT_GR30 = 32'h0;
			assign oDEBUG_REG_OUT_GR31 = 32'h0;
			assign oDEBUG_REG_OUT_SPR = 32'h0;
			assign oDEBUG_REG_OUT_PCR = 32'h0;
			assign oDEBUG_REG_OUT_PPCR = 32'h0;
			assign oDEBUG_REG_OUT_PSR = 32'h0;
			assign oDEBUG_REG_OUT_PPSR = 32'h0;
		end
	endgenerate
	
	
	//Assign
	assign oNEXT_VALID = b_valid && !iNEXT_LOCK;
	assign oNEXT_FAULT_PAGEFAULT = b_fault_pagefault;
	assign oNEXT_FAULT_PRIVILEGE_ERROR = b_fault_privilege_error;
	assign oNEXT_FAULT_INVALID_INST = b_fault_invalid_inst;
	assign oNEXT_SYSREG_PSR = w_sysreg_psr_info_data;
	assign oNEXT_SYSREG_TIDR = w_sysreg_tidr_info_data;
	assign oNEXT_SYSREG_PDTR = w_sysreg_pdtr_info_data;
	assign oNEXT_DESTINATION_SYSREG	= b_destination_sysreg;
	assign oNEXT_DESTINATION = b_destination;
	assign oNEXT_WRITEBACK = b_writeback;
	assign oNEXT_FLAGS_WRITEBACK = b_flag_writeback;
	assign oNEXT_CMD = b_cmd;
	assign oNEXT_CC_AFE = b_cc_afe;
	assign oNEXT_SPR = w_sysreg_spr_info_data;
	assign oNEXT_SOURCE0 = b_source0;
	assign oNEXT_SOURCE1 = b_source1;
	
	assign oNEXT_SOURCE0_POINTER = b_source0_pointer;
	assign oNEXT_SOURCE1_POINTER = b_source1_pointer;
	assign oNEXT_SOURCE0_SYSREG = b_source0_sysreg;
	assign oNEXT_SOURCE1_SYSREG = b_source1_sysreg;
	assign oNEXT_SOURCE1_IMM = b_source1_imm;
	
	assign oNEXT_SOURCE0_FLAGS = b_source0_flags;
	assign oNEXT_EX_SYS_REG = b_ex_sys_reg;
	assign oNEXT_EX_SYS_LDST = b_ex_sys_ldst;
	assign oNEXT_EX_LOGIC = b_ex_logic;
	assign oNEXT_EX_SHIFT = b_ex_shift;
	assign oNEXT_EX_ADDER = b_ex_adder;
	assign oNEXT_EX_MUL = b_ex_mul;
	assign oNEXT_EX_SDIV = b_ex_sdiv;
	assign oNEXT_EX_UDIV = b_ex_udiv;
	assign oNEXT_EX_LDST = b_ex_ldst;
	assign oNEXT_EX_BRANCH = b_ex_branch;
	assign oNEXT_PC = b_pc;
	//System Register
	assign oSYSREG_IDTR = w_sysreg_idtr_info_data;
	assign oSYSREG_TISR = w_sysreg_tisr_info_data;
	assign oSYSREG_TIDR = w_sysreg_tidr_info_data;
	assign oSYSREG_PSR = w_sysreg_psr_info_data;
	assign oSYSREG_PPSR = w_sysreg_ppsr_info_data;
	assign oSYSREG_PPCR = w_sysreg_ppcr_info_data;
	assign oSYSREG_SPR = w_sysreg_spr_info_data;
	
	assign	oPREVIOUS_LOCK = iNEXT_LOCK;//this_lock;
	
endmodule


`default_nettype wire


`include "core.h"
`include "processor.h"
`include "common.h"
`default_nettype none


module dispatch #(
		parameter CORE_ID = 0
	)(
		//System
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Event Control
		input wire iEVENT_HOLD,
		input wire iEVENT_START,
		input wire iEVENT_IRQ_FRONT2BACK,
		input wire iEVENT_IRQ_BACK2FRONT,
		input wire iEVENT_END,
		//IOSR
		input wire iSYSREGINFO_IOSR_VALID,
		input wire [31:0] iSYSREGINFO_IOSR,
		//FI0R Set
		input wire iEVENT_SETREG_FI0R_SET,
		input wire iEVENT_SETREG_FI1R_SET,
		input wire iEVENT_SETREG_PPCR_SET,
		input wire iEVENT_SETREG_PCR_SET,
		input wire [31:0] iEVENT_SETREG_FI0R,
		input wire [31:0] iEVENT_SETREG_FI1R,
		input wire [31:0] iEVENT_SETREG_PPCR,
		input wire [31:0] iEVENT_SETREG_PCR,
		//System Register Input
		input wire [31:0] iSYSREG_FLAGR,
		//System Register Output
		output wire [31:0] oSYSREG_PCR,
		output wire [31:0] oSYSREG_IDTR,
		output wire [31:0] oSYSREG_TISR,
		output wire [31:0] oSYSREG_TIDR,
		output wire [31:0] oSYSREG_PSR,
		output wire [31:0] oSYSREG_PPSR,
		output wire [31:0] oSYSREG_PPCR,
		output wire [31:0] oSYSREG_SPR,
		output wire [31:0] oSYSREG_PDTR,
		output wire [31:0] oSYSREG_KPDTR,
		output wire [31:0] oSYSREG_PFLAGR,
		//Pipeline
		input wire iPREVIOUS_VALID,
		input wire iPREVIOUS_FAULT_PAGEFAULT,
		input wire iPREVIOUS_FAULT_PRIVILEGE_ERROR,
		input wire iPREVIOUS_FAULT_INVALID_INST,
		input wire iPREVIOUS_PAGING_ENA,
		input wire iPREVIOUS_KERNEL_ACCESS,
		input wire iPREVIOUS_BRANCH_PREDICT,
		input wire [31:0] iPREVIOUS_BRANCH_PREDICT_ADDR,
		input wire iPREVIOUS_SOURCE0_ACTIVE,
		input wire iPREVIOUS_SOURCE1_ACTIVE,
		input wire iPREVIOUS_SOURCE0_SYSREG,
		input wire iPREVIOUS_SOURCE1_SYSREG,
		input wire iPREVIOUS_ADV_ACTIVE,
		input wire iPREVIOUS_DESTINATION_SYSREG,
		input wire [4:0] iPREVIOUS_DESTINATION,
		input wire iPREVIOUS_WRITEBACK,
		input wire iPREVIOUS_FLAGS_WRITEBACK,
		input wire [4:0] iPREVIOUS_CMD,
		input wire [3:0] iPREVIOUS_CC_AFE,
		input wire [4:0] iPREVIOUS_SOURCE0,
		input wire [31:0] iPREVIOUS_SOURCE1,
		input wire [5:0] iPREVIOUS_ADV_DATA,
		input wire iPREVIOUS_SOURCE0_FLAGS,
		input wire iPREVIOUS_SOURCE1_IMM,
		input wire iPREVIOUS_EX_SYS_REG,
		input wire iPREVIOUS_EX_SYS_LDST,
		input wire iPREVIOUS_EX_LOGIC,
		input wire iPREVIOUS_EX_SHIFT,
		input wire iPREVIOUS_EX_ADDER,
		input wire iPREVIOUS_EX_MUL,
		input wire iPREVIOUS_EX_SDIV,
		input wire iPREVIOUS_EX_UDIV,
		input wire iPREVIOUS_EX_LDST,
		input wire iPREVIOUS_EX_BRANCH,
		input wire [31:0] iPREVIOUS_PC,
		output wire oPREVIOUS_LOCK,
		//Next
		output wire oNEXT_VALID,
		output wire oNEXT_FAULT_PAGEFAULT,
		output wire oNEXT_FAULT_PRIVILEGE_ERROR,
		output wire oNEXT_FAULT_INVALID_INST,
		output wire oNEXT_PAGING_ENA,
		output wire oNEXT_KERNEL_ACCESS,
		output wire oNEXT_BRANCH_PREDICT,
		output wire [31:0] oNEXT_BRANCH_PREDICT_ADDR,
		output wire [31:0] oNEXT_SYSREG_PSR,
		output wire [31:0] oNEXT_SYSREG_TIDR,
		output wire [31:0] oNEXT_SYSREG_PDTR,
		output wire [31:0] oNEXT_SYSREG_KPDTR,
		output wire oNEXT_DESTINATION_SYSREG,
		output wire [4:0] oNEXT_DESTINATION,
		output wire oNEXT_WRITEBACK,
		output wire oNEXT_FLAGS_WRITEBACK,
		output wire [4:0] oNEXT_CMD,
		output wire [3:0] oNEXT_CC_AFE,
		output wire [31:0] oNEXT_SPR,
		output wire [31:0] oNEXT_SOURCE0,
		output wire [31:0] oNEXT_SOURCE1,
		output wire [5:0] oNEXT_ADV_DATA,
		output wire [4:0] oNEXT_SOURCE0_POINTER,
		output wire [4:0] oNEXT_SOURCE1_POINTER,
		output wire oNEXT_SOURCE0_SYSREG,
		output wire oNEXT_SOURCE1_SYSREG,
		output wire oNEXT_SOURCE1_IMM,
		output wire oNEXT_SOURCE0_FLAGS,
		output wire oNEXT_ADV_ACTIVE,
		output wire oNEXT_EX_SYS_REG,
		output wire oNEXT_EX_SYS_LDST,
		output wire oNEXT_EX_LOGIC,
		output wire oNEXT_EX_SHIFT,
		output wire oNEXT_EX_ADDER,
		output wire oNEXT_EX_MUL,
		output wire oNEXT_EX_SDIV,
		output wire oNEXT_EX_UDIV,
		output wire oNEXT_EX_LDST,
		output wire oNEXT_EX_BRANCH,
		output wire [31:0] oNEXT_PC,
		input wire iNEXT_LOCK,
		//Write Back
		input wire iWB_VALID,
		input wire [31:0] iWB_DATA,
		input wire [4:0] iWB_DESTINATION,
		input wire iWB_DESTINATION_SYSREG,
		input wire iWB_WRITEBACK,
		input wire iWB_SPR_WRITEBACK,
		input wire [31:0] iWB_SPR,
		input wire [31:0] iWB_PC,
		input wire iWB_BRANCH,
		input wire [31:0] iWB_BRANCH_PC,
		//Debug Module
		output wire [31:0] oDEBUG_REG_OUT_GR0,
		output wire [31:0] oDEBUG_REG_OUT_GR1,
		output wire [31:0] oDEBUG_REG_OUT_GR2,
		output wire [31:0] oDEBUG_REG_OUT_GR3,
		output wire [31:0] oDEBUG_REG_OUT_GR4,
		output wire [31:0] oDEBUG_REG_OUT_GR5,
		output wire [31:0] oDEBUG_REG_OUT_GR6,
		output wire [31:0] oDEBUG_REG_OUT_GR7,
		output wire [31:0] oDEBUG_REG_OUT_GR8,
		output wire [31:0] oDEBUG_REG_OUT_GR9,
		output wire [31:0] oDEBUG_REG_OUT_GR10,
		output wire [31:0] oDEBUG_REG_OUT_GR11,
		output wire [31:0] oDEBUG_REG_OUT_GR12,
		output wire [31:0] oDEBUG_REG_OUT_GR13,
		output wire [31:0] oDEBUG_REG_OUT_GR14,
		output wire [31:0] oDEBUG_REG_OUT_GR15,
		output wire [31:0] oDEBUG_REG_OUT_GR16,
		output wire [31:0] oDEBUG_REG_OUT_GR17,
		output wire [31:0] oDEBUG_REG_OUT_GR18,
		output wire [31:0] oDEBUG_REG_OUT_GR19,
		output wire [31:0] oDEBUG_REG_OUT_GR20,
		output wire [31:0] oDEBUG_REG_OUT_GR21,
		output wire [31:0] oDEBUG_REG_OUT_GR22,
		output wire [31:0] oDEBUG_REG_OUT_GR23,
		output wire [31:0] oDEBUG_REG_OUT_GR24,
		output wire [31:0] oDEBUG_REG_OUT_GR25,
		output wire [31:0] oDEBUG_REG_OUT_GR26,
		output wire [31:0] oDEBUG_REG_OUT_GR27,
		output wire [31:0] oDEBUG_REG_OUT_GR28,
		output wire [31:0] oDEBUG_REG_OUT_GR29,
		output wire [31:0] oDEBUG_REG_OUT_GR30,
		output wire [31:0] oDEBUG_REG_OUT_GR31,
		output wire [31:0] oDEBUG_REG_OUT_SPR,
		output wire [31:0] oDEBUG_REG_OUT_PCR,
		output wire [31:0] oDEBUG_REG_OUT_PPCR,
		output wire [31:0] oDEBUG_REG_OUT_PSR,
		output wire [31:0] oDEBUG_REG_OUT_PPSR
	);

	//System Register
	wire [31:0] w_sysreg_cpuidr_info_data;
	wire [31:0] w_sysreg_coreidr_info_data;
	wire w_sysreg_tidr_register_valid;
	wire [31:0] w_sysreg_tidr_register_data;
	wire [31:0] w_sysreg_tidr_info_data;
	wire w_sysreg_pcr_register_valid;
	wire [31:0] w_sysreg_pcr_register_data;
	wire [31:0] w_sysreg_pcr_info_data;
	wire w_sysreg_psr_register_valid;
	wire [31:0] w_sysreg_psr_register_data;
	wire [31:0] w_sysreg_psr_info_data;
	wire w_sysreg_spr_register_valid;
	wire [31:0] w_sysreg_spr_register_data;
	wire [31:0] w_sysreg_spr_info_data;
	wire w_sysreg_idtr_register_valid;
	wire [31:0] w_sysreg_idtr_register_data;
	wire [31:0] w_sysreg_idtr_info_data;
	wire [31:0] w_sysreg_fi0r_info_data;
	wire [31:0] w_sysreg_fi1r_info_data;
	wire w_sysreg_pdtr_register_valid;
	wire [31:0] w_sysreg_pdtr_register_data;
	wire [31:0] w_sysreg_pdtr_info_data;
	wire w_sysreg_tisr_register_valid;
	wire [31:0] w_sysreg_tisr_register_data;
	wire [31:0] w_sysreg_tisr_info_data;
	wire w_sysreg_kpdtr_register_valid;
	wire [31:0] w_sysreg_kpdtr_register_data;
	wire [31:0] w_sysreg_kpdtr_info_data;
	wire [31:0] w_sysreg_iosr_info_data;
	wire w_sysreg_ppcr_register_valid;
	wire [31:0] w_sysreg_ppcr_register_data;
	wire [31:0] w_sysreg_ppcr_info_data;
	wire w_sysreg_ptidr_register_valid;
	wire [31:0] w_sysreg_ptidr_register_data;
	wire [31:0] w_sysreg_ptidr_info_data;
	wire w_sysreg_ppdtr_register_valid;
	wire [31:0] w_sysreg_ppdtr_register_data;
	wire [31:0] w_sysreg_ppdtr_info_data;
	wire w_sysreg_pflagr_register_valid;
	wire [31:0] w_sysreg_pflagr_register_data;
	wire [31:0] w_sysreg_pflagr_info_data;
	wire w_sysreg_ppsr_register_valid;
	wire [31:0] w_sysreg_ppsr_register_data;
	wire [31:0] w_sysreg_ppsr_info_data;
	wire w_sysreg_frclr_register_valid;
	wire [31:0] w_sysreg_frclr_register_data;
	wire w_sysreg_frchr_register_valid;
	wire [31:0] w_sysreg_frchr_register_data;
	wire [31:0] w_sysreg_frclr_info_data;
	wire [31:0] w_sysreg_frchr_info_data;

	
	/*************************************************************************************
	Current Register Assignment
	*************************************************************************************/
	wire writeback_source0_valid, writeback_source1_valid;
	wire [31:0] writeback_source0, writeback_source1;

	assign {writeback_source0_valid, writeback_source0} = func_writeback_set(
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

	assign {writeback_source1_valid, writeback_source1} = func_writeback_set(
		iPREVIOUS_SOURCE1[4:0],
		iPREVIOUS_SOURCE1_SYSREG,
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
		input [4:0] func_register;
		input func_sysreg;
		/*******Writeback*******/
		input func_wb_valid;
		input [31:0] func_wb_data;
		input [4:0] func_wb_destination;
		input func_wb_destination_sysreg;
		input func_wb_writeback;
		input func_wb_spr_writeback;
		input [31:0] func_wb_spr;
		input [31:0] func_wb_pc;
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


	wire sysreg_source0_valid, sysreg_source1_valid;
	wire [31:0] sysreg_source0, sysreg_source1;

	assign	{sysreg_source0_valid, sysreg_source0} = func_sysreg_set(
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
		w_sysreg_frchr_info_data,
		w_sysreg_fi0r_info_data,
		w_sysreg_fi1r_info_data
	);

	assign	{sysreg_source1_valid, sysreg_source1} = func_sysreg_set(
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
		w_sysreg_frchr_info_data,
		w_sysreg_fi0r_info_data,
		w_sysreg_fi1r_info_data
	);

	function [32:0] func_sysreg_set;
		//Active
		input func_active;
		//Select
		input [4:0] func_sysreg;
		//Sysreg
		input [31:0] func_cpuidr;
		input [31:0] func_coreidr;
		input [31:0] func_tidr;
		input [31:0] func_pcr;
		input [31:0] func_spr;
		input [31:0] func_psr;
		input [31:0] func_idtr;
		input [31:0] func_pdtr;
		input [31:0] func_tisr;
		input [31:0] func_kpdtr;
		input [31:0] func_iosr;
		input [31:0] func_ppsr;
		input [31:0] func_ppcr;
		input [31:0] func_ppdtr;
		input [31:0] func_ptidr;
		input [31:0] func_frclr;
		input [31:0] func_frchr;
		input [31:0] func_fi0r;
		input [31:0] func_fi1r;
		begin
			if(func_active)begin
				case(func_sysreg)
					`SYSREG_CPUIDR : func_sysreg_set = {1'b1, func_cpuidr};
					`SYSREG_COREIDR : func_sysreg_set = {1'b1, func_coreidr};
					`SYSREG_TIDR : func_sysreg_set = {1'b1, func_tidr};
					//`SYSREG_FLAGR		Non Use
					`SYSREG_PCR : func_sysreg_set = {1'b1, func_pcr};
					`SYSREG_SPR : func_sysreg_set = {1'b1, func_spr};
					`SYSREG_PSR : func_sysreg_set = {1'b1, func_psr};
					`SYSREG_IDTR : func_sysreg_set = {1'b1, func_idtr};
					`SYSREG_PDTR : func_sysreg_set = {1'b1, func_pdtr};
					`SYSREG_TISR : func_sysreg_set = {1'b1, func_tisr};
					`SYSREG_KPDTR : func_sysreg_set = {1'b1, func_kpdtr};
					`SYSREG_IOSR : func_sysreg_set = {1'b1, func_iosr};
					`SYSREG_PPSR : func_sysreg_set = {1'b1, func_ppsr};
					`SYSREG_PPCR : func_sysreg_set = {1'b1, func_ppcr};
					`SYSREG_PPDTR : func_sysreg_set = {1'b1, func_ppdtr};
					`SYSREG_PTIDR : func_sysreg_set = {1'b1, func_ptidr};
					`SYSREG_FRCLR : func_sysreg_set = {1'b1, func_frclr};
					`SYSREG_FRCHR : func_sysreg_set = {1'b1, func_frchr};
					`SYSREG_FI0R : func_sysreg_set = {1'b1, func_fi0r};
					`SYSREG_FI1R : func_sysreg_set = {1'b1, func_fi1r};
					default	:
						begin
							func_sysreg_set = {1'b0, 32'h0};
						end
				endcase
			end
			else begin
				func_sysreg_set = {1'b0, 27'h0, func_sysreg};
			end
		end
	endfunction
	
	/*************************************************************************************
	General Register File
	*************************************************************************************/
	wire [31:0] gr_r_data0;
	wire [31:0] gr_r_data1;

	dispatch_general_register GRF(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//Write Port
		.iWR_VALID(iWB_VALID && !iWB_DESTINATION_SYSREG && iWB_WRITEBACK && !iEVENT_HOLD),
		.iWR_ADDR(iWB_DESTINATION),
		.iWR_DATA(iWB_DATA),
		//Read Port0
		.iRD0_ADDR(iPREVIOUS_SOURCE0[4:0]),
		.oRD0_DATA(gr_r_data0),
		//Read Port1
		.iRD1_ADDR(iPREVIOUS_SOURCE1[4:0]),
		.oRD1_DATA(gr_r_data1),
		//Debug Module
		.oDEBUG_REG_OUT_GR0(oDEBUG_REG_OUT_GR0),
		.oDEBUG_REG_OUT_GR1(oDEBUG_REG_OUT_GR1),
		.oDEBUG_REG_OUT_GR2(oDEBUG_REG_OUT_GR2),
		.oDEBUG_REG_OUT_GR3(oDEBUG_REG_OUT_GR3),
		.oDEBUG_REG_OUT_GR4(oDEBUG_REG_OUT_GR4),
		.oDEBUG_REG_OUT_GR5(oDEBUG_REG_OUT_GR5),
		.oDEBUG_REG_OUT_GR6(oDEBUG_REG_OUT_GR6),
		.oDEBUG_REG_OUT_GR7(oDEBUG_REG_OUT_GR7),
		.oDEBUG_REG_OUT_GR8(oDEBUG_REG_OUT_GR8),
		.oDEBUG_REG_OUT_GR9(oDEBUG_REG_OUT_GR9),
		.oDEBUG_REG_OUT_GR10(oDEBUG_REG_OUT_GR10),
		.oDEBUG_REG_OUT_GR11(oDEBUG_REG_OUT_GR11),
		.oDEBUG_REG_OUT_GR12(oDEBUG_REG_OUT_GR12),
		.oDEBUG_REG_OUT_GR13(oDEBUG_REG_OUT_GR13),
		.oDEBUG_REG_OUT_GR14(oDEBUG_REG_OUT_GR14),
		.oDEBUG_REG_OUT_GR15(oDEBUG_REG_OUT_GR15),
		.oDEBUG_REG_OUT_GR16(oDEBUG_REG_OUT_GR16),
		.oDEBUG_REG_OUT_GR17(oDEBUG_REG_OUT_GR17),
		.oDEBUG_REG_OUT_GR18(oDEBUG_REG_OUT_GR18),
		.oDEBUG_REG_OUT_GR19(oDEBUG_REG_OUT_GR19),
		.oDEBUG_REG_OUT_GR20(oDEBUG_REG_OUT_GR20),
		.oDEBUG_REG_OUT_GR21(oDEBUG_REG_OUT_GR21),
		.oDEBUG_REG_OUT_GR22(oDEBUG_REG_OUT_GR22),
		.oDEBUG_REG_OUT_GR23(oDEBUG_REG_OUT_GR23),
		.oDEBUG_REG_OUT_GR24(oDEBUG_REG_OUT_GR24),
		.oDEBUG_REG_OUT_GR25(oDEBUG_REG_OUT_GR25),
		.oDEBUG_REG_OUT_GR26(oDEBUG_REG_OUT_GR26),
		.oDEBUG_REG_OUT_GR27(oDEBUG_REG_OUT_GR27),
		.oDEBUG_REG_OUT_GR28(oDEBUG_REG_OUT_GR28),
		.oDEBUG_REG_OUT_GR29(oDEBUG_REG_OUT_GR29),
		.oDEBUG_REG_OUT_GR30(oDEBUG_REG_OUT_GR30),
		.oDEBUG_REG_OUT_GR31(oDEBUG_REG_OUT_GR31)
	);

	/*************************************************************************************
	System Registers
	*************************************************************************************/
	//CPUIDR : Processor ID Register
	dispatch_system_register CPUIDR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(1'b1), 
		.iREGIST_DATA({`PROCESSOR_ID, `PROCESSOR_REVISION}),
		.oINFO_DATA(w_sysreg_cpuidr_info_data)
	);

	//COREIDR : Core ID Register
	dispatch_system_register COREIDR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(1'b1), 
		.iREGIST_DATA(CORE_ID),
		.oINFO_DATA(w_sysreg_coreidr_info_data)
	);

	//TIDR : Task ID Register
	dispatch_system_register TIDR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_tidr_register_valid), 
		.iREGIST_DATA(w_sysreg_tidr_register_data),
		.oINFO_DATA(w_sysreg_tidr_info_data)
	);
	assign w_sysreg_tidr_register_valid = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_TIDR);
	assign w_sysreg_tidr_register_data = iWB_DATA;


	//FLAGR : Renaming System Register -> Execute Stage

	//PCR
	dispatch_system_register PCR(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_pcr_register_valid),
		.iREGIST_DATA(w_sysreg_pcr_register_data),
		.oINFO_DATA(w_sysreg_pcr_info_data)
	);
	assign w_sysreg_pcr_register_valid = (iWB_VALID && !iEVENT_HOLD) || (iEVENT_SETREG_PCR_SET || iEVENT_END);
	assign w_sysreg_pcr_register_data = (iEVENT_SETREG_PCR_SET || iEVENT_END)? iEVENT_SETREG_PCR : iWB_PC;


	//PSR : Program Status Register
	dispatch_system_register PSR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_psr_register_valid), 
		.iREGIST_DATA(w_sysreg_psr_register_data),
		.oINFO_DATA(w_sysreg_psr_info_data)
	);
	assign w_sysreg_psr_register_valid = iEVENT_IRQ_FRONT2BACK || iEVENT_IRQ_BACK2FRONT || (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PSR);
	assign w_sysreg_psr_register_data = (iEVENT_IRQ_FRONT2BACK)? {w_sysreg_psr_info_data[31:7], 2'h0, w_sysreg_psr_info_data[4:3], 1'b0, w_sysreg_psr_info_data[1:0]} : (
															(iEVENT_IRQ_BACK2FRONT)? w_sysreg_ppsr_info_data : iWB_DATA
														);

	//SPR
	dispatch_system_register SPR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_spr_register_valid), 
		.iREGIST_DATA(w_sysreg_spr_register_data),
		.oINFO_DATA(w_sysreg_spr_info_data)
	);
	assign w_sysreg_spr_register_valid = ((!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_SPR) || !iEVENT_HOLD && iWB_SPR_WRITEBACK && iWB_VALID);
	assign w_sysreg_spr_register_data = (!iEVENT_HOLD && iWB_SPR_WRITEBACK && iWB_VALID)? iWB_SPR : iWB_DATA;


	//IDTR
	dispatch_system_register IDTR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_idtr_register_valid), 
		.iREGIST_DATA(w_sysreg_idtr_register_data),
		.oINFO_DATA(w_sysreg_idtr_info_data)
	);
	assign w_sysreg_idtr_register_valid = !iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_IDTR;
	assign w_sysreg_idtr_register_data = iWB_DATA;

	//FI0R
	dispatch_system_register FI0R (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(iEVENT_SETREG_FI0R_SET), 
		.iREGIST_DATA(iEVENT_SETREG_FI0R),
		.oINFO_DATA(w_sysreg_fi0r_info_data)
	);

	//FI1R
	dispatch_system_register FI1R (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(iEVENT_SETREG_FI1R_SET), 
		.iREGIST_DATA(iEVENT_SETREG_FI1R),
		.oINFO_DATA(w_sysreg_fi1r_info_data)
	);

	//PDTR : Page Directory Table Register
	dispatch_system_register PDTR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_pdtr_register_valid), 
		.iREGIST_DATA(w_sysreg_pdtr_register_data),
		.oINFO_DATA(w_sysreg_pdtr_info_data)
	);
	assign w_sysreg_pdtr_register_valid = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PDTR);
	assign w_sysreg_pdtr_register_data = iWB_DATA;

	//TISR
	dispatch_system_register TISR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_tisr_register_valid), 
		.iREGIST_DATA(w_sysreg_tisr_register_data),
		.oINFO_DATA(w_sysreg_tisr_info_data)
	);
	assign w_sysreg_tisr_register_valid = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_TISR);
	assign w_sysreg_tisr_register_data = iWB_DATA;

	//KPDTR
	dispatch_system_register KPDTR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_kpdtr_register_valid), 
		.iREGIST_DATA(w_sysreg_kpdtr_register_data),
		.oINFO_DATA(w_sysreg_kpdtr_info_data)
	);
	assign w_sysreg_kpdtr_register_valid = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_KPDTR);
	assign w_sysreg_kpdtr_register_data = iWB_DATA;

	//IOSR
	dispatch_system_register IOSR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(iSYSREGINFO_IOSR_VALID), 
		.iREGIST_DATA(iSYSREGINFO_IOSR),
		.oINFO_DATA(w_sysreg_iosr_info_data)
	);


	//PPSR : Previous Program Status Register
	dispatch_system_register PPSR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_ppsr_register_valid), 
		.iREGIST_DATA(w_sysreg_ppsr_register_data),
		.oINFO_DATA(w_sysreg_ppsr_info_data)
	);
	assign w_sysreg_ppsr_register_valid = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PPSR) || iEVENT_IRQ_FRONT2BACK;
	assign w_sysreg_ppsr_register_data = (iEVENT_IRQ_FRONT2BACK)? w_sysreg_psr_info_data : iWB_DATA;


	//PPCR : Previous Program Counter
	dispatch_system_register PPCR(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_ppcr_register_valid), 
		.iREGIST_DATA(w_sysreg_ppcr_register_data),
		.oINFO_DATA(w_sysreg_ppcr_info_data)
	);
	assign w_sysreg_ppcr_register_valid = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PPCR) || (iEVENT_SETREG_PPCR_SET && iEVENT_END);
	assign w_sysreg_ppcr_register_data = (iEVENT_SETREG_PPCR_SET && iEVENT_END)? iEVENT_SETREG_PPCR : iWB_DATA;
	


	//PPDTR : Previous Page Directry Table Register
	dispatch_system_register PPDTR(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_ppdtr_register_valid), 
		.iREGIST_DATA(w_sysreg_ppdtr_register_data),
		.oINFO_DATA(w_sysreg_ppdtr_info_data)
	);
	assign w_sysreg_ppdtr_register_valid = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PPDTR) || iEVENT_IRQ_FRONT2BACK;
	assign w_sysreg_ppdtr_register_data = (iEVENT_IRQ_FRONT2BACK)? w_sysreg_pdtr_info_data : iWB_DATA;

	//PFLAGR : Previous Flag Register
	dispatch_system_register PFLAGR(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_pflagr_register_valid),
		.iREGIST_DATA(w_sysreg_pflagr_register_data),
		.oINFO_DATA(w_sysreg_pflagr_info_data)
	);
	assign w_sysreg_pflagr_register_valid	 = iEVENT_IRQ_FRONT2BACK;		//iEVENT_IRQ_FRONT2BACK;
	assign w_sysreg_pflagr_register_data = iSYSREG_FLAGR;


	//PTIDR : Previous Task Id Register
	dispatch_system_register PTIDR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_ptidr_register_valid), 
		.iREGIST_DATA(w_sysreg_ptidr_register_data),
		.oINFO_DATA(w_sysreg_ptidr_info_data)
	);
	assign w_sysreg_ptidr_register_valid = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_PTIDR) || iEVENT_IRQ_FRONT2BACK;
	assign w_sysreg_ptidr_register_data = (iEVENT_IRQ_FRONT2BACK)? w_sysreg_tidr_info_data : iWB_DATA;


	//FRCR
	wire frcr_64bit_write_condition;
	wire [63:0] frcr_64bit_timer;
	assign frcr_64bit_write_condition = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCR);


	dispatch_frcr_timer FRCR(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		.iWR_ENA(frcr_64bit_write_condition),
		.iRW_COUNTER({w_sysreg_frchr_info_data, w_sysreg_frclr_info_data}),
		.oCOUNTER(frcr_64bit_timer)
	);

	//FRCLR
	dispatch_system_register FRCLR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_frclr_register_valid),
		.iREGIST_DATA(w_sysreg_frclr_register_data),
		.oINFO_DATA(w_sysreg_frclr_info_data)
	);

	assign w_sysreg_frclr_register_valid = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCLR) ||
														(!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCR2FRCXR);
	assign w_sysreg_frclr_register_data = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCLR)? iWB_DATA : frcr_64bit_timer[31:0];


	//FRCHR
	dispatch_system_register FRCHR (
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iRESET_SYNC(iRESET_SYNC),
		.iREGIST_DATA_VALID(w_sysreg_frchr_register_valid),
		.iREGIST_DATA(w_sysreg_frchr_register_data),
		.oINFO_DATA(w_sysreg_frchr_info_data)
	);


	assign w_sysreg_frchr_register_valid = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCHR) ||
														(!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCR2FRCXR);
	assign w_sysreg_frchr_register_data = (!iEVENT_HOLD && iWB_VALID && iWB_DESTINATION_SYSREG && iWB_WRITEBACK && iWB_DESTINATION == `SYSREG_FRCHR)? iWB_DATA : frcr_64bit_timer[63:32];


	/*************************************************************************************
	Pipline Stage
	*************************************************************************************/
	reg b_valid;
	reg b_fault_pagefault;
	reg b_fault_privilege_error;
	reg b_fault_invalid_inst;
	reg b_paging_ena;
	reg b_kernel_access;
	reg b_branch_predict;
	reg [31:0] b_branch_predict_addr;
	reg b_destination_sysreg;
	reg [4:0] b_destination;
	reg b_writeback;
	reg b_flag_writeback;
	reg [4:0] b_cmd;
	reg [3:0] b_cc_afe;
	reg [31:0] b_source0;
	reg [31:0] b_source1;
	reg [5:0] b_adv_data;
	reg [4:0] b_source0_pointer;
	reg [4:0] b_source1_pointer;
	reg b_source0_sysreg;
	reg b_source1_sysreg;
	reg b_source1_imm;
	reg b_source0_flags;
	reg b_adv_active;
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
			b_paging_ena <= 1'b0;
			b_kernel_access <= 1'b0;
			b_branch_predict <= 1'B0;
			b_branch_predict_addr <= 32'h0;
			b_destination_sysreg <= 1'b0;
			b_destination <= 5'h0;
			b_writeback <= 1'b0;
			b_flag_writeback <= 1'b0;
			b_cmd <= 5'h0;
			b_cc_afe <= 4'h0;
			b_adv_data <= 6'h0;
			b_source0_pointer <= 5'h0;
			b_source1_pointer <= 5'h0;
			b_source0_sysreg <= 1'b0;
			b_source1_sysreg <= 1'b0;
			b_source1_imm <= 1'b0;
			b_source0_flags <= 1'b0;
			b_adv_active <= 1'b0;
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
		else if(iRESET_SYNC || iEVENT_START)begin
			b_valid <= 1'b0;
			b_fault_pagefault <= 1'b0;
			b_fault_privilege_error <= 1'b0;
			b_fault_invalid_inst <= 1'b0;
			b_paging_ena <= 1'b0;
			b_kernel_access <= 1'b0;
			b_branch_predict <= 1'b0;
			b_branch_predict_addr <= 32'h0;
			b_destination_sysreg <= 1'b0;
			b_destination <= 5'h0;
			b_writeback <= 1'b0;
			b_flag_writeback <= 1'b0;
			b_cmd <= 5'h0;
			b_cc_afe <= 4'h0;
			b_adv_data <= 6'h0;
			b_source0_pointer <= 5'h0;
			b_source1_pointer <= 5'h0;
			b_source0_sysreg <= 1'b0;
			b_source1_sysreg <= 1'b0;
			b_source1_imm <= 1'b0;
			b_source0_flags <= 1'b0;
			b_adv_active <= 1'h0;
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
				b_paging_ena <= iPREVIOUS_PAGING_ENA;
				b_kernel_access <= iPREVIOUS_KERNEL_ACCESS;
				b_branch_predict <= iPREVIOUS_BRANCH_PREDICT;
				b_branch_predict_addr <= iPREVIOUS_BRANCH_PREDICT_ADDR;
				b_destination_sysreg <= iPREVIOUS_DESTINATION_SYSREG;
				b_destination <= iPREVIOUS_DESTINATION;
				b_writeback <= iPREVIOUS_WRITEBACK;
				b_flag_writeback <= iPREVIOUS_FLAGS_WRITEBACK;
				b_cmd <= iPREVIOUS_CMD;
				b_cc_afe <= iPREVIOUS_CC_AFE;
				b_adv_data <= iPREVIOUS_ADV_DATA;
				b_source0_pointer <= iPREVIOUS_SOURCE0;
				b_source1_pointer <= iPREVIOUS_SOURCE1[4:0];
				b_source0_sysreg <= iPREVIOUS_SOURCE0_SYSREG;
				b_source1_sysreg <= iPREVIOUS_SOURCE1_SYSREG;
				b_source1_imm <= iPREVIOUS_SOURCE1_IMM;
				b_source0_flags <= iPREVIOUS_SOURCE0_FLAGS;
				b_adv_active <= iPREVIOUS_ADV_ACTIVE;
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


	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_source0 <= 32'h0;
		end
		else if(iRESET_SYNC || iEVENT_START)begin
			b_source0 <= 32'h0;
		end
		else begin
			if(!iNEXT_LOCK)begin
				if(writeback_source0_valid)begin
					b_source0 <= writeback_source0;
				end
				else begin
					b_source0 <= (sysreg_source0_valid && iPREVIOUS_SOURCE0_SYSREG)? sysreg_source0 : gr_r_data0;
				end
			end
		end
	end

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_source1 <= 32'h0;
		end
		else if(iRESET_SYNC || iEVENT_START)begin
			b_source1 <= 32'h0;
		end
		else begin
			if(!iNEXT_LOCK)begin
				if(writeback_source1_valid && !iPREVIOUS_SOURCE1_IMM)begin
					b_source1 <= writeback_source1;
				end
				else begin
					if(iPREVIOUS_SOURCE1_IMM)begin
						b_source1 <= iPREVIOUS_SOURCE1;
					end
					else begin
						if(sysreg_source1_valid && iPREVIOUS_SOURCE1_SYSREG)begin
							b_source1 <= sysreg_source1;
						end
						else begin
							b_source1 <= gr_r_data1;
						end
					end
				end
			end
		end
	end

	
	
	/*************************************************************************************
	Assign
	*************************************************************************************/
	assign oNEXT_VALID = b_valid && !iNEXT_LOCK;
	assign oNEXT_FAULT_PAGEFAULT = b_fault_pagefault;
	assign oNEXT_FAULT_PRIVILEGE_ERROR = b_fault_privilege_error;
	assign oNEXT_FAULT_INVALID_INST = b_fault_invalid_inst;
	assign oNEXT_PAGING_ENA = b_paging_ena;
	assign oNEXT_KERNEL_ACCESS = b_kernel_access;
	assign oNEXT_BRANCH_PREDICT = b_branch_predict;
	assign oNEXT_BRANCH_PREDICT_ADDR = b_branch_predict_addr;
	assign oNEXT_SYSREG_PSR = w_sysreg_psr_info_data;
	assign oNEXT_SYSREG_TIDR = w_sysreg_tidr_info_data;
	assign oNEXT_SYSREG_PDTR = w_sysreg_pdtr_info_data;
	assign oNEXT_SYSREG_KPDTR = w_sysreg_kpdtr_info_data;
	assign oNEXT_DESTINATION_SYSREG	= b_destination_sysreg;
	assign oNEXT_DESTINATION = b_destination;
	assign oNEXT_WRITEBACK = b_writeback;
	assign oNEXT_FLAGS_WRITEBACK = b_flag_writeback;
	assign oNEXT_CMD = b_cmd;
	assign oNEXT_CC_AFE = b_cc_afe;
	assign oNEXT_SPR = w_sysreg_spr_info_data;
	assign oNEXT_SOURCE0 = b_source0;
	assign oNEXT_SOURCE1 = b_source1;
	assign oNEXT_ADV_DATA = b_adv_data;

	assign oNEXT_SOURCE0_POINTER = b_source0_pointer;
	assign oNEXT_SOURCE1_POINTER = b_source1_pointer;
	assign oNEXT_SOURCE0_SYSREG = b_source0_sysreg;
	assign oNEXT_SOURCE1_SYSREG = b_source1_sysreg;
	assign oNEXT_SOURCE1_IMM = b_source1_imm;

	assign oNEXT_SOURCE0_FLAGS = b_source0_flags;
	assign oNEXT_ADV_ACTIVE = b_adv_active;
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
	assign oSYSREG_PDTR = w_sysreg_pdtr_info_data;
	assign oSYSREG_KPDTR = w_sysreg_kpdtr_info_data;
	assign oSYSREG_PFLAGR = w_sysreg_pflagr_info_data;
	assign oSYSREG_PCR = w_sysreg_pcr_info_data;

	assign oPREVIOUS_LOCK = iNEXT_LOCK;//this_lock;

	/*************************************************************************************
	Debugger
	*************************************************************************************/
	//Debug Module Enable
	`ifdef MIST1032ISA_STANDARD_DEBUGGER
		assign oDEBUG_REG_OUT_SPR = w_sysreg_spr_info_data;
		assign oDEBUG_REG_OUT_PCR = w_sysreg_pcr_info_data;
		assign oDEBUG_REG_OUT_PPCR = w_sysreg_ppcr_info_data;
		assign oDEBUG_REG_OUT_PSR = w_sysreg_psr_info_data;
		assign oDEBUG_REG_OUT_PPSR = w_sysreg_ppsr_info_data;
	`else
	//Disable
		assign oDEBUG_REG_OUT_SPR = 32'h0;
		assign oDEBUG_REG_OUT_PCR = 32'h0;
		assign oDEBUG_REG_OUT_PPCR = 32'h0;
		assign oDEBUG_REG_OUT_PSR = 32'h0;
		assign oDEBUG_REG_OUT_PPSR = 32'h0;
	`endif


endmodule


`default_nettype wire

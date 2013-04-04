/****************************************
	Decode Unit
****************************************/
`include "core.h"
`default_nettype none			


module decoder(
		//System
		input iCLOCK,
		input inRESET,
		//Free
		input iFREE_DEFAULT,	
		//Previous
		input iPREVIOUS_INST_VALID,
		input iPREVIOUS_FAULT_PAGEFAULT,
		input iPREVIOUS_FAULT_PRIVILEGE_ERROR,
		input iPREVIOUS_FAULT_INVALID_INST,
		input iPREVIOUS_PAGING_ENA,
		input iPREVIOUS_KERNEL_ACCESS,
		input iPREVIOUS_BRANCH_PREDICT,
		input [31:0] iPREVIOUS_BRANCH_PREDICT_ADDR,
		input [31:0] iPREVIOUS_INST,
		input [31:0] iPREVIOUS_PC,
		output oPREVIOUS_LOCK,
		//Next-0		
		output oNEXT_VALID,
		output oNEXT_FAULT_PAGEFAULT,
		output oNEXT_FAULT_PRIVILEGE_ERROR,
		output oNEXT_FAULT_INVALID_INST,
		output oNEXT_PAGING_ENA,
		output oNEXT_KERNEL_ACCESS,
		output oNEXT_BRANCH_PREDICT,
		output [31:0] oNEXT_BRANCH_PREDICT_ADDR,
		output oNEXT_SOURCE0_ACTIVE,			
		output oNEXT_SOURCE1_ACTIVE,		
		output oNEXT_SOURCE0_SYSREG,		
		output oNEXT_SOURCE1_SYSREG,		
		output oNEXT_SOURCE0_SYSREG_RENAME,	
		output oNEXT_SOURCE1_SYSREG_RENAME,	
		output oNEXT_DESTINATION_SYSREG,	
		output oNEXT_DEST_RENAME,	
		output oNEXT_WRITEBACK,
		output oNEXT_FLAGS_WRITEBACK,
		output oNEXT_FRONT_COMMIT_WAIT,				
		output [4:0] oNEXT_CMD,
		output [3:0] oNEXT_CC_AFE,
		output [4:0] oNEXT_SOURCE0,
		output [31:0] oNEXT_SOURCE1,
		output oNEXT_SOURCE0_FLAGS,
		output oNEXT_SOURCE1_IMM,
		output [4:0] oNEXT_DESTINATION,
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
		input iNEXT_LOCK
	);
	
	//Pipeline 
	reg					b_valid;	
	reg b_fault_pagefault;
	reg b_fault_page_privilege_error;
	reg b_fault_page_invalid_inst;		
	reg b_paging_ena;
	reg b_kernel_access;
	reg b_branch_predict;
	reg [31:0] b_branch_predict_addr;
	reg [13:0] b_mmu_flags;
	reg b_destination_sysreg;			
	reg b_dest_rename;			
	reg b_writeback;	
	reg b_flag_writeback;
	reg b_commit_wait_inst;					
	reg [4:0] b_cmd;
	reg [3:0] b_cc_afe;
	reg [4:0] b_source0;
	reg [31:0] b_source1;
	reg b_source0_flags;
	reg b_source1_imm;
	reg b_source0_active;	
	reg b_source1_active;	
	reg b_source0_sysreg;				
	reg b_source1_sysreg;	
	reg b_source0_sysreg_rename;
	reg b_source1_sysreg_rename;
	reg [4:0] b_destination;	
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
	reg b_error;
	reg [31:0] b_pc;
	
	
	always@(posedge iCLOCK, negedge inRESET)begin
		if(!inRESET)begin
			b_valid <= 1'b0;	
			b_fault_pagefault <= 1'b0;
			b_fault_page_privilege_error <= 1'b0;
			b_fault_page_invalid_inst <= 1'b0;			
			b_paging_ena <= 1'b0;
			b_kernel_access <= 1'b0;	
			b_branch_predict <= 1'b0;
			b_branch_predict_addr <= 32'h0;
			b_source0_active <= 1'b0;			
			b_source1_active <= 1'b0;	
			b_source0_sysreg <= 1'b0;	
			b_source1_sysreg <= 1'b0;		
			b_source0_sysreg_rename <= 1'b0;	
			b_source1_sysreg_rename <= 1'b0;				
			b_destination_sysreg <= 1'b0;	
			b_dest_rename <= 1'b0;
			b_writeback <= 1'b0;		
			b_flag_writeback <= 1'b0;			
			b_commit_wait_inst <= 1'b0;					
			b_cmd <= {5{1'b0}};
			b_cc_afe <= {4{1'b0}};
			b_source0 <= {5{1'b0}};
			b_source1 <= {32{1'b0}};
			b_source0_flags <= 1'b0;
			b_source1_imm <= 1'b0;
			b_destination <= {5{1'b0}};
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
			b_error <= 1'b0;
			b_pc <= 32'h0;
		end
		else if(iFREE_DEFAULT)begin
			b_valid <= 1'b0;	
			b_fault_pagefault <= 1'b0;
			b_fault_page_privilege_error <= 1'b0;
			b_fault_page_invalid_inst <= 1'b0;		
			b_paging_ena <= 1'b0;
			b_kernel_access <= 1'b0;
			b_branch_predict <= 1'b0;
			b_branch_predict_addr <= 32'h0;
			b_source0_active <= 1'b0;			
			b_source1_active <= 1'b0;	
			b_source0_sysreg <= 1'b0;	
			b_source1_sysreg <= 1'b0;		
			b_source0_sysreg_rename <= 1'b0;	
			b_source1_sysreg_rename <= 1'b0;				
			b_destination_sysreg <= 1'b0;	
			b_dest_rename <= 1'b0;
			b_writeback <= 1'b0;		
			b_flag_writeback <= 1'b0;			
			b_commit_wait_inst <= 1'b0;					
			b_cmd <= {5{1'b0}};
			b_cc_afe <= {4{1'b0}};
			b_source0 <= {5{1'b0}};
			b_source1 <= {32{1'b0}};
			b_source0_flags <= 1'b0;
			b_source1_imm <= 1'b0;
			b_destination <= {5{1'b0}};
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
			b_error <= 1'b0;
			b_pc <= 32'h0;
		end
		else begin
			if(!iNEXT_LOCK)begin
				//Pipeline 1
				b_valid <= iPREVIOUS_INST_VALID;
				//Flag
				b_fault_pagefault <= iPREVIOUS_FAULT_PAGEFAULT;
				b_fault_page_privilege_error <= iPREVIOUS_FAULT_PRIVILEGE_ERROR;
				b_fault_page_invalid_inst <= iPREVIOUS_FAULT_INVALID_INST;
				b_paging_ena <= iPREVIOUS_PAGING_ENA;
				b_kernel_access <= iPREVIOUS_KERNEL_ACCESS;
				b_branch_predict <= iPREVIOUS_BRANCH_PREDICT;
				b_branch_predict_addr <= iPREVIOUS_BRANCH_PREDICT_ADDR;
				//Inst
				{
					b_error, b_commit_wait_inst, b_cc_afe,
					b_source0, b_source1, b_source0_flags, b_source1_imm,
					b_source0_active, b_source1_active, 
					b_source0_sysreg, b_source1_sysreg,
					b_source0_sysreg_rename, b_source1_sysreg_rename,
					b_destination, b_writeback, b_flag_writeback, 
					b_destination_sysreg, b_dest_rename, b_cmd, b_ex_sys_reg, b_ex_sys_ldst,  
					b_ex_logic, b_ex_shift, b_ex_adder, b_ex_sdiv, 
					b_ex_udiv, b_ex_mul, b_ex_ldst, b_ex_branch
				} <= f_decode(iPREVIOUS_INST);
				//Program Counter
				b_pc <= iPREVIOUS_PC;
			end
		end
	end //always
			
	
	

	
	function [74:0]	f_decode;
		input	[31:0]			f_decode_inst;
		begin
			case(f_decode_inst[30 : 21])
				/*******************
				Integer
				*******************/
				`OC_ADD :
					begin	
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_ADDER_ADD,
								/* Execute Module */					`EXE_SELECT_ADDER
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{f_decode_inst[15]}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_ADDER_ADD,
								/* Execute Module */					`EXE_SELECT_ADDER
							};
						end
					end
				`OC_SUB :
					begin	
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_ADDER_SUB,
								/* Execute Module */					`EXE_SELECT_ADDER
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{f_decode_inst[15]}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_ADDER_SUB,
								/* Execute Module */					`EXE_SELECT_ADDER
							};
						end
					end
				`OC_MULL : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_MUL_MULL,
								/* Execute Module */					`EXE_SELECT_MUL
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{f_decode_inst[15]}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_MUL_MULL,
								/* Execute Module */					`EXE_SELECT_MUL
							};
						end
					end
				`OC_MULH : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_MUL_MULH,
								/* Execute Module */					`EXE_SELECT_MUL
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{f_decode_inst[15]}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_MUL_MULH,
								/* Execute Module */					`EXE_SELECT_MUL
							};
						end
					end
				`OC_UDIV : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_DIV_UDIV,
								/* Execute Module */					`EXE_SELECT_UDIV
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_DIV_UDIV,
								/* Execute Module */					`EXE_SELECT_UDIV
							};
						end
					end
				`OC_UMOD :
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_DIV_UMOD,
								/* Execute Module */					`EXE_SELECT_UDIV
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_DIV_UMOD,
								/* Execute Module */					`EXE_SELECT_UDIV
							};
						end
					end
				`OC_CMP : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_ADDER_SUB,
								/* Execute Module */					`EXE_SELECT_ADDER
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{f_decode_inst[15]}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_ADDER_SUB,
								/* Execute Module */					`EXE_SELECT_ADDER
							};
						end
					end
				`OC_DIV : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_DIV_DIV,
								/* Execute Module */					`EXE_SELECT_SDIV
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_DIV_DIV,
								/* Execute Module */					`EXE_SELECT_SDIV
							};
						end
					end
				`OC_MOD :
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_DIV_MOD,
								/* Execute Module */					`EXE_SELECT_SDIV
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_DIV_MOD,
								/* Execute Module */					`EXE_SELECT_SDIV
							};
						end
					end
				`OC_NEG :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_ADDER_NEG,
							/* Execute Module */					`EXE_SELECT_ADDER
							};
					end
				`OC_ADDC :
					begin	
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_ADDER_COUT,
								/* Execute Module */					`EXE_SELECT_ADDER
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{f_decode_inst[15]}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_ADDER_COUT,
								/* Execute Module */					`EXE_SELECT_ADDER
							};
						end
					end
				`OC_INC	:
					begin
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[4:0],
							/* Source1 */							32'h1,
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b1,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_ADDER_ADD,
							/* Execute Module */					`EXE_SELECT_ADDER
						};
					end
				`OC_DEC	:
					begin
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[4:0],
							/* Source1 */							32'h1,
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b1,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_ADDER_SUB,
							/* Execute Module */					`EXE_SELECT_ADDER
						};
					end
				`OC_SEXT8 :
					begin		//O2	
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_ADDER_SEXT8,
							/* Execute Module */					`EXE_SELECT_ADDER
						};
					end
				`OC_SEXT16 :
					begin		//O2	
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_ADDER_SEXT16,
							/* Execute Module */					`EXE_SELECT_ADDER
						};
					end
				/*******************
				Floating
				*******************/
				/*******************
				Shift
				*******************/
				`OC_SHL : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_SHIFT_LOGICL,
								/* Execute Module */					`EXE_SELECT_SHIFT
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_SHIFT_LOGICL,
								/* Execute Module */					`EXE_SELECT_SHIFT
							};
						end
					end
				`OC_SHR : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_SHIFT_LOGICR,
								/* Execute Module */					`EXE_SELECT_SHIFT
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_SHIFT_LOGICR,
								/* Execute Module */					`EXE_SELECT_SHIFT
							};
						end
					end
				`OC_SAR : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_SHIFT_ALITHMETICR,
								/* Execute Module */					`EXE_SELECT_SHIFT
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_SHIFT_ALITHMETICR,
								/* Execute Module */					`EXE_SELECT_SHIFT
							};
						end
					end
				`OC_ROL : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_SHIFT_ROTATEL,
								/* Execute Module */					`EXE_SELECT_SHIFT
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_SHIFT_ROTATEL,
								/* Execute Module */					`EXE_SELECT_SHIFT
							};
						end
					end
				`OC_ROR : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_SHIFT_ROTATER,
								/* Execute Module */					`EXE_SELECT_SHIFT
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b1,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_SHIFT_ROTATER,
								/* Execute Module */					`EXE_SELECT_SHIFT
							};
						end
					end
				/*******************
				Logic
				*******************/
				`OC_AND :
					begin									//O2
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b1,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_AND,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_OR :
					begin									//O2
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b1,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_OR,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_XOR :
					begin									//O2
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b1,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_XOR,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_NOT :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b1,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_NOT,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_NAND :
					begin									//O2
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b1,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_NAND,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_NOR :
					begin									//O2
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b1,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_NOR,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_XNOR :
					begin									//O2
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b1,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_XNOR,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end	
				`OC_TEST :
					begin									//O2
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b0,
							/* Make Flag Instruction */				1'b1,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_LOGIC_TEST,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end	
				`OC_WL16 :
					begin									//I16
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{16{1'b0}}, f_decode_inst[20:10], f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b1,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_WBL,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_WH16 :
					begin									//I16
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{16{1'b0}}, f_decode_inst[20:10], f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b1,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_WBH,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_CLRB :
					begin									//I11
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b1,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_CLB,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_SETB :
					begin									//I11
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b1,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_STB,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_CLR :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b1,
							/* Source0 Active */					1'b0,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_CLW,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end	
				`OC_SET :				//okasi
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b1}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b1,
							/* Source0 Active */					1'b0,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_STW,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_REVB :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_BITREV,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_REV8 :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_BYTEREV,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_GETB : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_LOGIC_GETBIT,
								/* Execute Module */					`EXE_SELECT_LOGIC
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_LOGIC_GETBIT,
								/* Execute Module */					`EXE_SELECT_LOGIC
							};
						end
					end
				`OC_GET8 : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_LOGIC_GETBYTE,
								/* Execute Module */					`EXE_SELECT_LOGIC
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_LOGIC_GETBYTE,
								/* Execute Module */					`EXE_SELECT_LOGIC
							};
						end
					end
				`OC_LIL	:	
					begin									//I16
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				4'h0,
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{16{1'b0}}, f_decode_inst[20:10], f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b1,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_LIL,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_LIH	:	
					begin									//I16
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				4'h0,
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{f_decode_inst[20:10], f_decode_inst[4:0], {16{1'b0}}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b1,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_LIH,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_ULIL	:	
					begin									//I16
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				4'h0,
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{16{1'b0}}, f_decode_inst[20:10], f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b1,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_ULIL,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				/*******************
				Load/Store
				*******************/
				`OC_LD8 : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							{5{1'b0}},
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},									//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b0,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_LDSW_LD8,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							{5{1'b0}},
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},				//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b0,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_LDSW_LD8,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
					end
				`OC_LD16 : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							{5{1'b0}},
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},									//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b0,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_LDSW_LD16,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							{5{1'b0}},
								/* Source1 */							{{20{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0], 1'b0},				//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b0,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_LDSW_LD16,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
					end
				`OC_LD32 : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							{5{1'b0}},
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},									//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b0,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_LDSW_LD32,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							{5{1'b0}},
								/* Source1 */							{{19{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0], 2'b00},				//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b0,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_LDSW_LD32,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
					end
				`OC_ST8 : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],						//Rd
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},		//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						5'h00,		//Memory
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_LDSW_ST8,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],											//Rd
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},		//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						5'h00,		//Memory
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_LDSW_ST8,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
					end
				`OC_ST16 : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],						//Rd
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},		//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						5'h00,		//Memory
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_LDSW_ST16,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],											//Rd
								/* Source1 */							{{20{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0], 1'b0},		//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						5'h00,		//Memory
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_LDSW_ST16,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
					end
				`OC_ST32 : 
					begin
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],						//Rd
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},		//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						5'h00,		//Memory
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_LDSW_ST32,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],											//Rd
								/* Source1 */							{{19{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0], 2'b00},		//Rs
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						5'h00,		//Memory
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_LDSW_ST32,
								/* Execute Module */					`EXE_SELECT_LDST
							};
						end
					end
				`OC_PUSH :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],						//Rs
							/* Source1 */							{{27{1'b0}}, `SYSREG_SPR},				//SPR
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b1,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						5'h00,		//Memory
							/* Write Back Enable */					1'b0,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_LDSW_PUSH,
							/* Execute Module */					`EXE_SELECT_LDST
						};
					end
				`OC_PUSHPC :
					begin									//C
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_PCR,								//PC
							/* Source1 */							{{27{1'b0}}, `SYSREG_SPR},				//SPR
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b1,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						5'h00,		//Memory
							/* Write Back Enable */					1'b0,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_LDSW_PPUSH,
							/* Execute Module */					`EXE_SELECT_LDST
						};
					end
				`OC_POP :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							5'h00,
							/* Source1 */							{{27{1'b0}}, `SYSREG_SPR},				//SPR
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b0,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b1,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LDSW_POP,
							/* Execute Module */					`EXE_SELECT_LDST
						};
					end
				/*******************
				Branch
				*******************/
				`OC_BUR :
					begin	
						if(!f_decode_inst[20])begin			//JO1
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],//	/* Source0 */							`SYSREG_PC,							//PC
								/* Source1 */							{{27{1'b0}}, f_decode_inst[9:5]},	//Rd
								/* Source0 Use Flags*/					1'b1,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,		//Flag
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,//1'b0,//	/* Source0 System Register */			1'b1,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PCR,
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_BRANCH_BUR,
								/* Execute Module */					`EXE_SELECT_BRANCH
							};
						end
						else begin							//JI16
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],//	/* Source0 */							`SYSREG_PC,							//PC
								/* Source1 */							{{14{1'b0}}, f_decode_inst[15:0], 2'h0},	//Rd
								/* Source0 Use Flags*/					1'b1,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,		//Flag
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,//1'b0,//	/* Source0 System Register */			1'b1,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PCR,
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_BRANCH_BUR,
								/* Execute Module */					`EXE_SELECT_BRANCH
							};
						end
					end
				`OC_BR :
					begin	
						if(!f_decode_inst[20])begin			//JO1
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],//	/* Source0 */							`SYSREG_PC,							//PC
								/* Source1 */							{{27{1'b0}}, f_decode_inst[9:5]},	//Rd
								/* Source0 Use Flags*/					1'b1,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,		//Flag
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,//1'b0,//	/* Source0 System Register */			1'b1,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PCR,
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_BRANCH_BR,
								/* Execute Module */					`EXE_SELECT_BRANCH
							};
						end
						else begin							//JI16
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							f_decode_inst[9:5],//	/* Source0 */							`SYSREG_PC,							//PC
								/* Source1 */							{{14{f_decode_inst[15]}}, f_decode_inst[15:0], 2'h0}, //{{16{1'b0}}, f_decode_inst[15:0]},	//Rd
								/* Source0 Use Flags*/					1'b1,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,		//Flag
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,//1'b0,//	/* Source0 System Register */			1'b1,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PCR,
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_BRANCH_BR,
								/* Execute Module */					`EXE_SELECT_BRANCH
							};
						end
					end
				`OC_B :
					begin	
						if(!f_decode_inst[20])begin			//JO1
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							{5{1'b0}},								//none
								/* Source1 */							{{27{1'b0}}, f_decode_inst[9:5]},		//Rd
								/* Source0 Use Flags*/					1'b1,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,//1'b0,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,//1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PCR,
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_BRANCH_B,
								/* Execute Module */					`EXE_SELECT_BRANCH
							};
						end
						else begin							//JI16
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							{5{1'b0}},								//none		
								/* Source1 */							{{14{1'b0}}, f_decode_inst[15:0], 2'b0},		//Rd
								/* Source0 Use Flags*/					1'b1,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,//1'b0,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,//1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PCR,
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_BRANCH_B,
								/* Execute Module */					`EXE_SELECT_BRANCH
							};
						end
					end
				`OC_IB :
					begin	
						if(!f_decode_inst[20])begin			//JO1
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							{5{1'b0}},								//none
								/* Source1 */							{{27{1'b0}}, f_decode_inst[9:5]},		//Rd
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b0,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PCR,
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_BRANCH_INTB,
								/* Execute Module */					`EXE_SELECT_BRANCH
							};
						end
						else begin							//JI16
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							{5{1'b0}},								//none		
								/* Source1 */							{{14{1'b0}}, f_decode_inst[15:0], 2'h0},		//Rd
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b0,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b0,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PCR,
								/* Write Back Enable */					1'b0,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_BRANCH_INTB,
								/* Execute Module */					`EXE_SELECT_BRANCH
							};
						end
					end
				//`OC_BURN
				//`OC_BRN
				//`OC_BN
				/*******************
				System Read
				*******************/			
				`OC_SRSPR :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_SPR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_LDST_READ_SPR,
							/* Execute Module */					`EXE_SELECT_SYS_LDST
						};
					end
				`OC_SRPDTR :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_PDTR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end				
				`OC_SRPIDR :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_CPUIDR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRCIDR : 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_COREIDR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_MODER : 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_PSR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_SR1_CMOD_R,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRIEIR : 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_PSR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_SR1_IM_R,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRTISR : 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_TISR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRKPDTR : 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_KPDTR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRMMUR : 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_PSR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_SR1_MMUMOD_R,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRIOSR : 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_IOSR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRTIDR : 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_TIDR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRPPSR: 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_PPSR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRPPCR: 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_PPCR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRPPDTR: 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_PPDTR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRPTIDR: 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_PTIDR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRPSR: 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_PSR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRFRCR: 
					begin									//C
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							5'h0,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b0,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_FRCR2FRCXR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRFRCLR: 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_FRCLR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRFRCHR: 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_FRCHR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_PFLAGR: 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							`SYSREG_PFLAGR,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b1,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
					
				/*******************
				System Write
				*******************/
				`OC_SRSPW :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_SPR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_LDST_WRITE_SPR,
							/* Execute Module */					`EXE_SELECT_SYS_LDST
						};
					end
				`OC_SRPDTW : 
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_PDTR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_LDST
						};
					end
				`OC_SRIEIW : 
					begin
						if(!f_decode_inst[20])begin			//O1
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b1,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							`SYSREG_PSR,
								/* Source1 */							{{27{1'b0}}, f_decode_inst[9:5]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PSR,
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_SYS_REG_SR1_IM_W,
								/* Execute Module */					`EXE_SELECT_SYS_REG
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b1,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							`SYSREG_PSR,
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PSR,
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_SYS_REG_SR1_IM_W,
								/* Execute Module */					`EXE_SELECT_SYS_REG
							};
						end
					end
				`OC_SRTISW :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_TISR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRKPDTW :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_KPDTR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRMMUW : 
					begin
						if(!f_decode_inst[20])begin			//O1
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b1,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							`SYSREG_PSR,
								/* Source1 */							{{27{1'b0}}, f_decode_inst[9:5]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PSR,
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_SYS_REG_SR1_MMUMOD_W,
								/* Execute Module */					`EXE_SELECT_SYS_REG
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b1,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							`SYSREG_PSR,
								/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						`SYSREG_PSR,
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b1,
								/* Destination Rename*/					1'b0,
								/* Execute Module Command */			`EXE_SYS_REG_SR1_MMUMOD_W,
								/* Execute Module */					`EXE_SELECT_SYS_REG
							};
						end
					end
				`OC_SRPPSW :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_PPSR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRPPCW :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_PPCR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRPPDTW :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_PPDTR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRPTIDW :
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_PTIDR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRIDTW:
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_IDTR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRPSW:
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_PSR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRFRCW:
					begin									//C
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							5'h0,
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b0,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_FRCR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRFRCLR:
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_FRCLR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				`OC_SRFRCHR:
					begin									//O1
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b1,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b1,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_FRCHR,
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_SYS_REG_BUFFER0,
							/* Execute Module */					`EXE_SELECT_SYS_REG
						};
					end
				/*******************
				Other
				*******************/
				`OC_NOP :
					begin									//C
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b1,
							/* Source0 Active */					1'b0,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						{5{1'b0}},
							/* Write Back Enable */					1'b0,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_ADDER_ADD,
							/* Execute Module */					`EXE_SELECT_ADDER
						};
					end
				`OC_HALT :
					begin									//C
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b0,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						{5{1'b0}},
							/* Write Back Enable */					1'b0,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_BRANCH_HALT,
							/* Execute Module */					`EXE_SELECT_BRANCH
						};	
					end
				`OC_MOVE : 
					begin
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b0,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						f_decode_inst[9:5],
							/* Write Back Enable */					1'b1,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b1,
							/* Execute Module Command */			`EXE_LOGIC_BUFFER1,
							/* Execute Module */					`EXE_SELECT_LOGIC
						};
					end
				`OC_MOVEPC	:	
					begin	
						if(!f_decode_inst[20])begin			//O2
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							`SYSREG_PCR,
								/* Source1 */							{{27{1'b0}}, f_decode_inst[4:0]},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b0,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_ADDER_ADD,
								/* Execute Module */					`EXE_SELECT_ADDER
							};
						end
						else begin							//I11
							f_decode	=	{
								/* Decode Error */						1'b0,
								/* Commit Wait Instruction */			1'b0,
								/* Condition Code & AFE */				f_decode_inst[19:16],
								/* Source0 */							`SYSREG_PCR,
								/* Source1 */							{{19{f_decode_inst[15]}}, f_decode_inst[15:10], f_decode_inst[4:0], 2'b0},
								/* Source0 Use Flags*/					1'b0,
								/* Source1-Immediate */					1'b1,
								/* Source0 Active */					1'b1,
								/* Source1 Active */					1'b1,
								/* Source0 System Register */			1'b1,
								/* Source1 System Register */			1'b0,
								/* Source0 System Register Rename */	1'b0,
								/* Source1 System Register Rename */	1'b0,
								/* Destination */						f_decode_inst[9:5],
								/* Write Back Enable */					1'b1,
								/* Make Flag Instruction */				1'b0,
								/* Destination is System Register */	1'b0,
								/* Destination Rename*/					1'b1,
								/* Execute Module Command */			`EXE_ADDER_ADD,
								/* Execute Module */					`EXE_SELECT_ADDER
							};
						end
					end
				/*******************
				OS Support
				*******************/
				`OC_SWI	:	
					begin					//I11
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							{5{1'b0}},								//none		
							/* Source1 */							{{21{1'b0}}, f_decode_inst[15:10], f_decode_inst[4:0]},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b1,
							/* Source0 Active */					1'b0,
							/* Source1 Active */					1'b1,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						`SYSREG_PCR,
							/* Write Back Enable */					1'b0,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b1,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_BRANCH_SWI,
							/* Execute Module */					`EXE_SELECT_BRANCH
						};
					end
				`OC_IDTS :
					begin									//C
						f_decode	=	{
							/* Decode Error */						1'b0,
							/* Commit Wait Instruction */			1'b0,
							/* Condition Code & AFE */				f_decode_inst[19:16],
							/* Source0 */							f_decode_inst[9:5],
							/* Source1 */							{32{1'b0}},
							/* Source0 Use Flags*/					1'b0,
							/* Source1-Immediate */					1'b0,
							/* Source0 Active */					1'b0,
							/* Source1 Active */					1'b0,
							/* Source0 System Register */			1'b0,
							/* Source1 System Register */			1'b0,
							/* Source0 System Register Rename */	1'b0,
							/* Source1 System Register Rename */	1'b0,
							/* Destination */						{5{1'b0}},
							/* Write Back Enable */					1'b0,
							/* Make Flag Instruction */				1'b0,
							/* Destination is System Register */	1'b0,
							/* Destination Rename*/					1'b0,
							/* Execute Module Command */			`EXE_BRANCH_IDTS,
							/* Execute Module */					`EXE_SELECT_BRANCH
						};
					end	
				//Error
				default :
					begin
						f_decode				=		{1'b1, {74{1'b0}}};
						/*
						$display("Instruction Error : Decoder > Not Match Instruction(TIME:%t, Line0 Valid0:%d, Line1 Valid:%d)", $stime, iPREVIOUS_0_INST_VALID, iPREVIOUS_1_INST_VALID);
						*/
					end
			endcase
		end
	endfunction
	
	
	
	/****************************************
	This -> Previous
	****************************************/			
	assign oPREVIOUS_LOCK = iNEXT_LOCK;
				
	/****************************************
	This -> Next
	****************************************/
	//Pipeline1
	assign oNEXT_VALID = b_valid;
	assign oNEXT_FAULT_PAGEFAULT = b_fault_pagefault;
	assign oNEXT_FAULT_PRIVILEGE_ERROR = b_fault_page_privilege_error;
	assign oNEXT_FAULT_INVALID_INST = b_fault_page_invalid_inst;
	assign oNEXT_PAGING_ENA = b_paging_ena;
	assign oNEXT_KERNEL_ACCESS = b_kernel_access;
	assign oNEXT_BRANCH_PREDICT = b_branch_predict;
	assign oNEXT_BRANCH_PREDICT_ADDR = b_branch_predict_addr;
	assign oNEXT_SOURCE0_ACTIVE = b_source0_active;
	assign oNEXT_SOURCE1_ACTIVE = b_source1_active;
	assign oNEXT_SOURCE0_SYSREG = b_source0_sysreg;
	assign oNEXT_SOURCE1_SYSREG = b_source1_sysreg;
	assign oNEXT_SOURCE0_SYSREG_RENAME = b_source0_sysreg_rename;
	assign oNEXT_SOURCE1_SYSREG_RENAME = b_source1_sysreg_rename;
	assign oNEXT_DESTINATION_SYSREG = b_destination_sysreg;
	assign oNEXT_DEST_RENAME = b_dest_rename;
	assign oNEXT_WRITEBACK = b_writeback;
	assign oNEXT_FLAGS_WRITEBACK = b_flag_writeback;
	assign oNEXT_FRONT_COMMIT_WAIT = b_commit_wait_inst;
	assign oNEXT_CMD = b_cmd;
	assign oNEXT_CC_AFE = b_cc_afe;
	assign oNEXT_SOURCE0 = b_source0;
	assign oNEXT_SOURCE1 = b_source1;
	assign oNEXT_SOURCE0_FLAGS = b_source0_flags;
	assign oNEXT_SOURCE1_IMM = b_source1_imm;
	assign oNEXT_DESTINATION = b_destination;
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

	
	
endmodule


`default_nettype wire



	
`default_nettype none
`include "core.h"

module instruction_buffer(
		input iCLOCK,
		input inRESET,
		input iFREE_REFRESH,
		//Prev
		input iPREVIOUS_INST_VALID,
		input iPREVIOUS_PAGEFAULT,
		input [13:0] iPREVIOUS_MMU_FLAGS,
		input iPREVIOUS_PAGING_ENA,
		input iPREVIOUS_KERNEL_ACCESS,
		input iPREVIOUS_BRANCH_PREDICT,
		input [31:0] iPREVIOUS_BRANCH_PREDICT_ADDR,
		input [31:0] iPREVIOUS_INST,
		input [31:0] iPREVIOUS_PC,
		output oPREVIOUS_FETCH_STOP,
		output oPREVIOUS_LOCK,
		//Next
		output oNEXT_INST_VALID,
		output oNEXT_FAULT_PAGEFAULT,
		output oNEXT_FAULT_PRIVILEGE_ERROR,
		output oNEXT_FAULT_INVALID_INST,
		output oNEXT_PAGING_ENA,
		output oNEXT_KERNEL_ACCESS,
		output oNEXT_BRANCH_PREDICT,
		output [31:0] oNEXT_BRANCH_PREDICT_ADDR,
		output [31:0] oNEXT_INST,
		output [31:0] oNEXT_PC,
		input iNEXT_LOCK
	);
	
	//Fifo
	wire fifo_full;
	wire fifo_empty;
	wire [4:0] fifo_count;
	//Fault
	wire [2:0] fault = iPREVIOUS_PAGEFAULT |
						func_mmu_flags_fault_check(iPREVIOUS_PAGING_ENA, iPREVIOUS_KERNEL_ACCESS, iPREVIOUS_MMU_FLAGS[5:0]) |
						(func_instruction_fault_check(iPREVIOUS_INST, iPREVIOUS_KERNEL_ACCESS, iPREVIOUS_MMU_FLAGS[5:0]) << 1'b1);
	
	/*************************************************
	MMU Flag Check
	[0]	:	IRQ40 Invalid page.(Page fault)
	[1]	:	IRQ41 Privilege error.(Page)
	[2]	:	IRQ42 Invalid instruction.(Page)
	*************************************************/
	function [2:0] func_mmu_flags_fault_check;
		input func_paging;
		input func_kernel;				//1:kernel mode
		input [5:0] func_mmu_flags;
		begin
			if(func_paging)begin
				//Page fault check
				if(!func_mmu_flags[0])begin
					func_mmu_flags_fault_check = 3'h1;
				end
				//Invalid instruction check
				if(!func_mmu_flags[3])begin
					func_mmu_flags_fault_check = 3'h4;
				end
				//Privilege error check
				else begin
					//Page check
					if(func_kernel)begin			//Kernell Mode
						func_mmu_flags_fault_check = 3'h0;
					end
					else begin	//User Mode
						if(func_mmu_flags[5:4] != 2'h0)begin
							func_mmu_flags_fault_check = 3'h0;
						end
						else begin
							func_mmu_flags_fault_check = 3'h2;	//Privilege Error
						end
					end
				end
			end
			else begin
				func_mmu_flags_fault_check = 3'h0;
			end
		end
	endfunction
		
		
	/*************************************************
	Instruction Check
	[0]	:	IRQ41 Privilege error.(Page)
	*************************************************/
	function func_instruction_fault_check;
		input [31:0] func_instruction;
		input func_kernel;				//[1]Kernel
		input [5:0] func_mmu_flags;
		begin
			if(func_kernel)begin			//Kernell Mode
				func_instruction_fault_check = 1'b0;
			end
			else begin
				case(func_instruction[30:21])
					`FAULT_INSTRUCTION_SRTISR,
					`FAULT_INSTRUCTION_SRKPDTR,
					`FAULT_INSTRUCTION_SRPDTW,
					`FAULT_INSTRUCTION_SRIEIW,
					`FAULT_INSTRUCTION_SRTISW,
					`FAULT_INSTRUCTION_SRKPDTW,
					`FAULT_INSTRUCTION_SRMMUW,
					`FAULT_INSTRUCTION_HALT,
					`FAULT_INSTRUCTION_IDTS	:	func_instruction_fault_check = 1'b1;
					default					:	func_instruction_fault_check = 1'b0;
				endcase
			end
		end
	endfunction
	
	
	/*************************************************
	Instruction Loop Buffer
	*************************************************/
	mist1032isa_sync_fifo #(102, 32, 5) INST_LOOPBUFFER(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iREMOVE(iFREE_REFRESH), 
		.oCOUNT(fifo_count), 	
		.iWR_EN(!fifo_full && iPREVIOUS_INST_VALID), 
		.iWR_DATA({fault, iPREVIOUS_PAGING_ENA, iPREVIOUS_KERNEL_ACCESS, iPREVIOUS_BRANCH_PREDICT, iPREVIOUS_BRANCH_PREDICT_ADDR, iPREVIOUS_INST, iPREVIOUS_PC}), 
		.oWR_FULL(fifo_full),
		.iRD_EN(!fifo_empty && !iNEXT_LOCK), 
		.oRD_DATA({oNEXT_FAULT_PAGEFAULT, oNEXT_FAULT_PRIVILEGE_ERROR, oNEXT_FAULT_INVALID_INST, oNEXT_PAGING_ENA, oNEXT_KERNEL_ACCESS, oNEXT_BRANCH_PREDICT, oNEXT_BRANCH_PREDICT_ADDR, oNEXT_INST, oNEXT_PC}), 
		.oRD_EMPTY(fifo_empty)
	);

	assign oPREVIOUS_LOCK = fifo_full;	
	assign oNEXT_INST_VALID = !fifo_empty && !iNEXT_LOCK;			
	assign oPREVIOUS_FETCH_STOP = (fifo_count > 5'h1A)? 1'b1 : 1'b0;
	
endmodule
	
`default_nettype wire


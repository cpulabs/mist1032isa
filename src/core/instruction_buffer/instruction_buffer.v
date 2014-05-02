	
`default_nettype none
`include "core.h"
`include "common.h"

module instruction_buffer(
		input wire iCLOCK,
		input wire inRESET,
		input wire iFREE_REFRESH,
		//Prev
		input wire iPREVIOUS_INST_VALID,
		input wire [11:0] iPREVIOUS_MMU_FLAGS,
		input wire iPREVIOUS_PAGING_ENA,
		input wire iPREVIOUS_KERNEL_ACCESS,
		input wire iPREVIOUS_BRANCH_PREDICT,
		input wire [31:0] iPREVIOUS_BRANCH_PREDICT_ADDR,
		input wire [31:0] iPREVIOUS_INST,
		input wire [31:0] iPREVIOUS_PC,
		output wire oPREVIOUS_FETCH_STOP,
		output wire oPREVIOUS_LOCK,
		//Next
		output wire oNEXT_INST_VALID,
		output wire oNEXT_FAULT_PAGEFAULT,
		output wire oNEXT_FAULT_PRIVILEGE_ERROR,
		output wire oNEXT_FAULT_INVALID_INST,
		output wire oNEXT_PAGING_ENA,
		output wire oNEXT_KERNEL_ACCESS,
		output wire oNEXT_BRANCH_PREDICT,
		output wire [31:0] oNEXT_BRANCH_PREDICT_ADDR,
		output wire [31:0] oNEXT_INST,
		output wire [31:0] oNEXT_PC,
		input wire iNEXT_LOCK
	);
	
	//Fifo
	wire fifo_full;
	wire fifo_empty;
	wire [4:0] fifo_count;
	//Fault
	wire [2:0] fault = func_mmu_flags_fault_check(iPREVIOUS_PAGING_ENA, iPREVIOUS_KERNEL_ACCESS, iPREVIOUS_MMU_FLAGS[5:0]) |
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
	`ifdef MIST1032ISA_ALTERA_PRIMITIVE
		//FIFO Mode				: Show Ahead Synchronous FIFO Mode
		//Width					: 102bit
		//Depth					: 32Word
		//Asynchronous Reset	: Use
		//Synchronous Reset		: Use
		//Usedw					: Use
		//Full					: Use
		//Empty					: Use
		//Almost Full			: Use(Value=2)
		//Almost Empty			: Use(Value=30)
		//Overflow Checking		: Disable
		//Undesflow Checking	: Disable

		altera_primitive_sync_fifo_102in_102out_32depth INST_LOOPBUFFER(
			.aclr(!inRESET),				//Asynchronous Reset
			.clock(iCLOCK),				//Clock
			.data(
				{
					fault, 
					iPREVIOUS_PAGING_ENA, 
					iPREVIOUS_KERNEL_ACCESS, 
					iPREVIOUS_BRANCH_PREDICT, 
					iPREVIOUS_BRANCH_PREDICT_ADDR, 
					iPREVIOUS_INST, iPREVIOUS_PC
				}
			),				//Data-In
			.rdreq(!fifo_empty && !iNEXT_LOCK),				//Read Data Request
			.sclr(iFREE_REFRESH),				//Synchthronous Reset
			.wrreq(!fifo_full && iPREVIOUS_INST_VALID),				//Write Req
			.almost_empty(),		
			.almost_full(),
			.empty(fifo_empty),
			.full(fifo_full),
			.q(
				{
					oNEXT_FAULT_PAGEFAULT, 
					oNEXT_FAULT_PRIVILEGE_ERROR, 
					oNEXT_FAULT_INVALID_INST, 
					oNEXT_PAGING_ENA, 
					oNEXT_KERNEL_ACCESS, 
					oNEXT_BRANCH_PREDICT, 
					oNEXT_BRANCH_PREDICT_ADDR, 
					oNEXT_INST, oNEXT_PC
				}
			),					//Dataout
			.usedw(fifo_count)
		);
	
	`elsif MIST1032ISA_XILINX_PRIMITIVE

	`else
		mist1032isa_sync_fifo #(102, 32, 5) INST_LOOPBUFFER(
			.iCLOCK(iCLOCK), 
			.inRESET(inRESET), 
			.iREMOVE(iFREE_REFRESH), 
			.oCOUNT(fifo_count), 	
			.iWR_EN(!fifo_full && iPREVIOUS_INST_VALID), 
			.iWR_DATA(
				{
					fault, 
					iPREVIOUS_PAGING_ENA, 
					iPREVIOUS_KERNEL_ACCESS, 
					iPREVIOUS_BRANCH_PREDICT, 
					iPREVIOUS_BRANCH_PREDICT_ADDR, 
					iPREVIOUS_INST, iPREVIOUS_PC
				}
			), 
			.oWR_FULL(fifo_full),
			.iRD_EN(!fifo_empty && !iNEXT_LOCK), 
			.oRD_DATA(
				{
					oNEXT_FAULT_PAGEFAULT, 
					oNEXT_FAULT_PRIVILEGE_ERROR, 
					oNEXT_FAULT_INVALID_INST, 
					oNEXT_PAGING_ENA, 
					oNEXT_KERNEL_ACCESS, 
					oNEXT_BRANCH_PREDICT, 
					oNEXT_BRANCH_PREDICT_ADDR, 
					oNEXT_INST, oNEXT_PC
				}
			), 
			.oRD_EMPTY(fifo_empty)
		);
	`endif

	assign oPREVIOUS_LOCK = fifo_full;	
	assign oNEXT_INST_VALID = !fifo_empty && !iNEXT_LOCK;			
	assign oPREVIOUS_FETCH_STOP = (fifo_count > 5'h1A)? 1'b1 : 1'b0;
	
	
	
	/*************************************************
	Assertion - SVA
	*************************************************/
	`ifdef MIST1032ISA_SVA_ASSERTION
		property FIFO_FULL_CHECK;
			@(posedge iCLOCK) disable iff (!inRESET) (fifo_full |-> !(!fifo_full && iPREVIOUS_INST_VALID));
		endproperty
		
		assert property(FIFO_FULL_CHECK);
	`endif
	
	
endmodule
	
`default_nettype wire


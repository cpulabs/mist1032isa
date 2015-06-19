

`default_nettype none

`include "irq.h"

/****
HOLD
0 START
1 MOVE_K2U
1 MOVE_UK
2 EMD
*/

module execute_exception_check_ldst(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Event CTRL
		input wire iEVENT_HOLD,
		input wire iEVENT_START,
		input wire iEVENT_IRQ_FRONT2BACK,
		input wire iEVENT_IRQ_BACK2FRONT,
		input wire iEVENT_END,
		//Execute Module State
		input wire iPREV_STATE_NORMAL,
		input wire iPREV_STATE_LDST,
		//Previous Instruxtion
		input wire iPREV_VALID,
		input wire iPREV_KERNEL_ACCESS,
		input wire iPREV_PAGING_ENA,
		input wire iPREV_LDST_RW,
		//Load Store
		input wire iLDST_VALID,
		input wire [11:0] iLDST_MMU_FLAG,
		//Output Exception 
		output wire oEXCEPT_VALID,
		output wire [6:0] oEXCEPT_NUM
	);



	reg b_kernel_access;
	reg b_paging_ena;
	reg [31:0] b_pc;
	reg b_ldst_rw;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_kernel_access <= 1'b0;
			b_paging_ena <= 1'b0;
			b_pc <= 32'h0;
			b_ldst_rw <= 1'b0;
		end
		else if(iRESET_SYNC || iEVENT_HOLD)begin
			b_kernel_access <= 1'b0;
			b_paging_ena <= 1'b0;
			b_ldst_rw <= 1'b0;
		end
		else begin
			if(iPREV_VALID && iPREV_STATE_NORMAL)begin
				b_kernel_access <= iPREV_KERNEL_ACCESS;
				b_paging_ena <= iPREV_PAGING_ENA;
				b_ldst_rw <= iPREV_LDST_RW;
			end
		end
	end



	/**************************************************************************************************
	Load/Store Exception
	**************************************************************************************************/
	wire exception_ldst_valid;
	wire [6:0] exception_ldst_num;
	assign {exception_ldst_valid, exception_ldst_num} = func_ldst_exception_check(
		b_paging_ena,
		b_kernel_access,
		b_ldst_rw,
		iLDST_MMU_FLAG[5:0]
	);


	//MMU Flag Check
	function [7:0] func_ldst_exception_check;
		input func_paging;
		input func_kernel;				//1:kernel mode
		input func_rw;
		input [5:0] func_mmu_flags;
		begin
			if(func_paging)begin
				//Privilege error check
				if(func_kernel)begin			//Kernell Mode
					case(func_mmu_flags[5:4])
						2'h1:
							begin
								if(func_rw)begin
									func_ldst_exception_check = {1'b1, `INT_NUM_PRIVILEGE_ERRPR};
								end
								else begin
									func_ldst_exception_check = 8'h0;
								end
							end
						2'h0,
						2'h2,
						2'h3:
							begin
								func_ldst_exception_check = 8'h0;
							end
					endcase
				end
				else begin	//User Mode
					case(func_mmu_flags[5:4])
						2'h0: func_ldst_exception_check = {1'b1, `INT_NUM_PRIVILEGE_ERRPR};
						2'h1,
						2'h2:
							begin
								if(func_rw)begin
									func_ldst_exception_check = {1'b1, `INT_NUM_PRIVILEGE_ERRPR};
								end
								else begin
									func_ldst_exception_check = 8'h0;
								end
							end
						2'h3: func_ldst_exception_check = 8'h0;
					endcase
				end
			end
			else begin
				func_ldst_exception_check = 8'h0;
			end
		end
	endfunction


	assign oEXCEPT_VALID = exception_ldst_valid && iPREV_STATE_LDST; 
	assign oEXCEPT_NUM = exception_ldst_num;


endmodule

`default_nettype wire


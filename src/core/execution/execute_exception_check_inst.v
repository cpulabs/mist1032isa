

`default_nettype none

`include "irq.h"

/****
HOLD
0 START
1 MOVE_K2U
1 MOVE_UK
2 EMD
*/

module execute_exception_check_inst(
		//Execute Module State
		input wire iPREV_STATE_NORMAL,
		//Previous Instruxtion
		input wire iPREV_FAULT_PAGEFAULT,
		input wire iPREV_FAULT_PRIVILEGE_ERROR,
		input wire iPREV_FAULT_INVALID_INST,
		input wire iPREV_FAULT_DIVIDE_ZERO,
		//Output Exception 
		output wire oEXCEPT_VALID,
		output wire [6:0] oEXCEPT_NUM
	);



	/**************************************************************************************************
	General Instruction Exception
	**************************************************************************************************/
	function [7:0] func_exception_check;
		input func_pagefault;
		input func_privilege;
		input func_invalid_inst;
		input func_div_error;
		begin
			if(func_pagefault)begin
				func_exception_check = {1'b1, `INT_NUM_PAGEFAULT};
			end
			else if(func_privilege)begin
				func_exception_check = {1'b1, `INT_NUM_PRIVILEGE_ERRPR};
			end
			else if(func_invalid_inst)begin
				func_exception_check = {1'b1, `INT_NUM_INSTRUCTION_INVALID};
			end
			else if(func_div_error)begin
				func_exception_check = {1'b1, `INT_NUM_DIVIDER_ERROR};
			end
			else begin
				func_exception_check = 8'h0;
			end
		end
	endfunction


	wire exception_valid;
	wire [6:0] exception_num;
	assign {exception_valid, exception_num} = func_exception_check(
		iPREV_FAULT_PAGEFAULT,
		iPREV_FAULT_PRIVILEGE_ERROR,
		iPREV_FAULT_INVALID_INST,
		iPREV_FAULT_DIVIDE_ZERO
	);


	assign oEXCEPT_VALID = exception_valid; 
	assign oEXCEPT_NUM = exception_num;

endmodule

`default_nettype wire


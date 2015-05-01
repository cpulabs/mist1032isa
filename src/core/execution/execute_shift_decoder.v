

`default_nettype none
`include "core.h"


module execute_shift_decode(
		input wire [4:0] iPREV_INST,
		output wire [2:0] oNEXT_INST
	);


	function [2:0] func_shift_select;
		input [4:0] func_shift_select_cmd;
		begin
			case(func_shift_select_cmd)
				`EXE_SHIFT_BUFFER		:	func_shift_select = 3'h0;
				`EXE_SHIFT_LOGICL		:	func_shift_select = 3'h1;
				`EXE_SHIFT_LOGICR		:	func_shift_select = 3'h2;
				`EXE_SHIFT_ALITHMETICR	:	func_shift_select = 3'h3;
				`EXE_SHIFT_ROTATEL		:	func_shift_select = 3'h4;
				`EXE_SHIFT_ROTATER		:	func_shift_select = 3'h5;
				default					:	func_shift_select = 3'h0;
			endcase
		end
	endfunction


	assign oNEXT_INST = func_shift_select(iPREV_INST);


endmodule

`default_nettype wire 


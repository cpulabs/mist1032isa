

`default_nettype none
`include "core.h"


module execute_logic_decode(
		input wire [4:0] iPREV_INST,
		output wire [4:0] oNEXT_INST
	);



	function [4:0] func_logic_select;
		input [4:0] func_logic_select_cmd;

		begin
			case(func_logic_select_cmd)
				`EXE_LOGIC_BUFFER0	:	func_logic_select = 5'h00;
				`EXE_LOGIC_BUFFER1	:	func_logic_select = 5'h01;
				`EXE_LOGIC_AND		:	func_logic_select = 5'h04;
				`EXE_LOGIC_OR		:	func_logic_select = 5'h05;
				`EXE_LOGIC_XOR		:	func_logic_select = 5'h06;
				`EXE_LOGIC_NOT		:	func_logic_select = 5'h02;
				`EXE_LOGIC_NAND		:	func_logic_select = 5'h07;
				`EXE_LOGIC_NOR		:	func_logic_select = 5'h08;
				`EXE_LOGIC_XNOR		:	func_logic_select = 5'h09;
				`EXE_LOGIC_TEST		:	func_logic_select = 5'h04;
				`EXE_LOGIC_WBL		:	func_logic_select = 5'h10;
				`EXE_LOGIC_WBH		:	func_logic_select = 5'h11;
				`EXE_LOGIC_CLB		:	func_logic_select = 5'h0A;
				`EXE_LOGIC_STB		:	func_logic_select = 5'h0B;
				`EXE_LOGIC_CLW		:	func_logic_select = 5'h15;
				`EXE_LOGIC_STW		:	func_logic_select = 5'h16;
				`EXE_LOGIC_BITREV	:	func_logic_select = 5'h0C;
				`EXE_LOGIC_BYTEREV	:	func_logic_select = 5'h0D;
				`EXE_LOGIC_GETBIT	:	func_logic_select = 5'h0E;
				`EXE_LOGIC_GETBYTE	:	func_logic_select = 5'h0F;
				`EXE_LOGIC_LIL		:	func_logic_select = 5'h12;
				`EXE_LOGIC_LIH		:	func_logic_select = 5'h01;
				`EXE_LOGIC_ULIL		:	func_logic_select = 5'h14;
				default
					begin
						func_logic_select = 5'h00;
					end
			endcase
		end
	endfunction

	assign oNEXT_INST = func_logic_select(iPREV_INST);


endmodule

`default_nettype wire 


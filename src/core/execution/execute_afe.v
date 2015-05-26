`default_nettype none
`include "common.h"

module execute_afe(
		input wire iAFE_LDST,
		input wire [31:0] iAFE_LDST_DATA,
		input wire [31:0] iRAW_DATA,		
		output wire [31:0] oDATA
	);

	wire [31:0] result_data_with_afe;

	`ifdef MIST32_AFE_ENA
		//AFE - Output Select
		function [31:0] func_afe_select;
			input func_ldst;
			input [31:0] func_ldst_data;
			input [31:0] func_non_afe_data;
			begin
				if(func_ldst)begin
					func_afe_select = func_ldst_data;
				end
				else begin
					func_afe_select = func_non_afe_data;
				end
			end 
		endfunction

		assign result_data_with_afe = func_afe_select(iAFE_LDST, iAFE_LDST_DATA, iRAW_DATA);

	`else
		assign result_data_with_afe = iRAW_DATA;
	`endif

	assign oDATA = result_data_with_afe;
	

endmodule // execute_afe


`default_nettype wire



`default_nettype none

module core_paging_support(
		input wire [31:0] iSYSREG_PSR,
		input wire iPDTR_WRITEBACK,
		//Cache
		output wire oCACHE_FLASH
	);

	assign oCACHE_FLASH = (iSYSREG_PSR[1:0] != 2'h0)? iPDTR_WRITEBACK : 1'b0;
	
	
endmodule


`default_nettype wire 



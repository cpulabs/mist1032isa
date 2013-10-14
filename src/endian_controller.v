
`default_nettype none 


module endian_controller(
		//Source
		input wire [3:0] iSRC_MASK,
		input wire [31:0] iSRC_DATA,
		//Destnation
		output wire [3:0] oDEST_MASK,
		output wire [31:0] oDEST_DATA
	);

	
	assign oDEST_MASK = {iSRC_MASK[0], iSRC_MASK[1], iSRC_MASK[2], iSRC_MASK[3]}
	assign oDEST_DATA = {iSRC_DATA[7:0], iSRC_DATA[15:8], iSRC_DATA[23:16], iSRC_DATA[31:24]};
		
endmodule


`default_nettype wire 

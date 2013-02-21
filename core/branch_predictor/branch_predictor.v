


`default_nettype none 

module branch_predictor(
		input iCLOCK,
		input inRESET,
		input iFLUSH,
		//Flush
		output oFLUSH_PIPELINE,
		output oFLUSH_
		//Jump
		input iJUMP_STB,
		input iJUMP_VALID,
		input [31:0] iJUMP_ADDR,		
		input [31:0] iJUMP_INST_ADDR,	//Tag[31:5]| Cell Address[4:2] | Byte Order[1:0]
		//Search
		input iSEARCH_STB,
		input [31:0] iSEARCH_INST_ADDR,
		output oSEARCH_VALID,
		output oSEARCH_HIT,
		output [31:0] oSEARCH_ADDR
	);






endmodule

`default_nettype wire 






`default_nettype none 

module branch_predictor(
		input iCLOCK,
		input inRESET,
		input iFLUSH,
		//Flush
		/*
		output oFLUSH_PIPELINE,
		output oFLUSH_
		*/
		//Search
		input iSEARCH_STB,
		input [31:0] iSEARCH_INST_ADDR,
		output oSEARCH_VALID,
		output oSEARCH_HIT,
		output oSRARCH_PREDICT_BRANCH,
		output [31:0] oSEARCH_ADDR,
		//Jump
		input iJUMP_STB,
		input iJUMP_VALID,
		input [31:0] iJUMP_ADDR,		
		input [31:0] iJUMP_INST_ADDR
	);
	
	
	
	branch_cache #(8) BRANCH_CACHE(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iFLUSH(iFLUSH),
		//Search
		.iSEARCH_STB(),
		.iSEARCH_INST_ADDR(),
		.oSEARCH_VALID(),
		.oSEARCH_HIT(),
		.oSRARCH_PREDICT_BRANCH(),
		.oSEARCH_ADDR(),
		//Jump
		.iJUMP_STB(iJUMP_STB),
		.iJUMP_VALID(iJUMP_VALID),
		.iJUMP_ADDR(iJUMP_ADDR),		
		.iJUMP_INST_ADDR(iJUMP_INST_ADDR)	//Tag[31:5]| Cell Address[4:2] | Byte Order[1:0]
	);


	
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			//
		end
		else begin
			//
		end
	end

endmodule

`default_nettype wire 






`default_nettype none 

module branch_predictor(
		input iCLOCK,
		input inRESET,
		input iFLUSH,
		//Search
		input iSEARCH_STB,
		input [31:0] iSEARCH_INST_ADDR,
		output oSEARCH_VALID,
		input iSEARCH_LOCK,
		output oSRARCH_PREDICT_BRANCH,
		output [31:0] oSEARCH_ADDR,
		//Jump
		input iJUMP_STB,
		input iJUMP_HIT,
		input [31:0] iJUMP_ADDR,		
		input [31:0] iJUMP_INST_ADDR
	);
	
	
	//Branch Cache
	wire branch_cache_valid;
	wire branch_cache_hit;
	wire branch_cache_predict_branch;
	wire [31:0] branch_cache_addr;
	//Latch
	reg b_branch_cache_valid;
	reg b_branch_cache_predict_branch;
	reg [31:0] b_branch_cache_addr;
	
	branch_cache #(16) BRANCH_CACHE(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iFLUSH(iFLUSH),
		//Search
		.iSEARCH_STB(iSEARCH_STB),
		.iSEARCH_INST_ADDR(iSEARCH_INST_ADDR),
		.oSEARCH_VALID(branch_cache_valid),
		.oSEARCH_HIT(branch_cache_hit),
		.oSRARCH_PREDICT_BRANCH(branch_cache_predict_branch),
		.oSEARCH_ADDR(branch_cache_addr),
		//Jump
		.iJUMP_STB(iJUMP_STB),
		.iJUMP_HIT(iJUMP_HIT),
		.iJUMP_ADDR(iJUMP_ADDR),		
		.iJUMP_INST_ADDR(iJUMP_INST_ADDR)	//Tag[31:5]| Cell Address[4:2] | Byte Order[1:0]
	);

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_branch_cache_valid <= 1'b0;
			b_branch_cache_predict_branch <= 1'b0; 
			b_branch_cache_addr <= 32'h0;
		end
		else begin
			if(!iSEARCH_LOCK)begin
				b_branch_cache_valid <= branch_cache_valid;
				b_branch_cache_predict_branch <= branch_cache_predict_branch && branch_cache_hit;
				b_branch_cache_addr <= branch_cache_addr;
			end
		end
	end
	
	
	assign oSEARCH_VALID = b_branch_cache_valid;
	assign oSRARCH_PREDICT_BRANCH = b_branch_cache_predict_branch;
	assign oSEARCH_ADDR = b_branch_cache_addr;
	
endmodule

`default_nettype wire 




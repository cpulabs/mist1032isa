

`include "common.h"
`default_nettype none


module execute_branch_predict(
		//State
		input wire iSTATE_NORMAL,
		//Previous - PREDICT
		input wire iPREV_VALID,
		input wire iPREV_EX_BRANCH,
		input wire iPREV_BRANCH_PREDICT_ENA,
		input wire [31:0] iPREV_BRANCH_PREDICT_ADDR,
		//JUMP
		input wire iPREV_BRANCH_VALID,
		input wire iPREV_BRANCH_IB_VALID,
		input wire [31:0] iPREV_JUMP_ADDR,
		//Next
		input wire iNEXT_BUSY,
		output wire oNEXT_PREDICT_HIT
	);


	reg predict_hit;

	always @* begin
		if(iSTATE_NORMAL)begin	
			if(iPREV_VALID && iPREV_EX_BRANCH && !iNEXT_BUSY)begin
				//Jump True
				if(iPREV_BRANCH_VALID)begin
					//Branch Predict Hardware Enable / Disable
					`ifdef MIST1032ISA_BRANCH_PREDICT
						//Hit Branch Predict
						if(iPREV_BRANCH_PREDICT_ENA && iPREV_BRANCH_PREDICT_ADDR == iPREV_JUMP_ADDR)begin
							predict_hit = 1'b1;
						end
						//Un Hit
						else begin
							predict_hit = 1'b0;
						end
					`else
						predict_hit = 1'b0;
					`endif
				end
				//System Branch
				else if(iPREV_BRANCH_IB_VALID)begin
					predict_hit = 1'b0;
				end
				//Non Branch(Compiler predict instruction)
				else begin
					//Branch Predict Enable
					`ifdef MIST1032ISA_BRANCH_PREDICT
						predict_hit = 1'b0;
					`else
					//Predict Disable
						predict_hit = 1'b0;
					`endif
				end
			end
		end
		else begin
			predict_hit = 1'b0;
		end
	end


	assign oNEXT_PREDICT_HIT = predict_hit;

endmodule




`default_nettype wire


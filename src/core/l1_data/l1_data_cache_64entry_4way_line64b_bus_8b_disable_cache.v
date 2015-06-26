`default_nettype none





module l1_data_cache_64entry_4way_line64b_bus_8b_disable_cache(
		/********************************
		System
		********************************/
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Remove
		input wire iREMOVE,
		/********************************
		Search
		********************************/
		//Search Request 
		input wire iRD_REQ,
		output wire oRD_BUSY,		
		input wire [31:0] iRD_ADDR,		//Tag:22bit | Index:4bit(4Way*16Entry) | LineSize:6bit(64B)
		//Search Output Result
		output wire oRD_VALID,
		output wire oRD_HIT,
		input wire iRD_BUSY,		
		output wire [31:0] oRD_DATA,
		output wire [11:0] oRD_MMU_FLAGS,
		/********************************
		Upload
		********************************/
		input wire iUP_REQ,
		output wire oUP_BUSY,
		input wire [1:0] iUP_ORDER,
		input wire [3:0] iUP_MASK,
		input wire [31:0] iUP_ADDR,				
		input wire [31:0] iUP_DATA,
		/********************************
		Write Request
		********************************/
		input wire iWR_REQ,
		output wire oWR_BUSY,
		input wire [31:0] iWR_ADDR,	//Tag:22bit | Index:4bit(4Way*16Entry) | LineSize:6bit(64B)
		input wire [511:0] iWR_DATA,
		input wire [255:0] iWR_MMU_FLAGS
	);
			
	assign oRD_BUSY = 1'b0;
	assign oRD_MMU_FLAGS = 11'h0;
	
	reg b_req_valid;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_req_valid <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_req_valid <= 1'b0;
		end
		else if(iREMOVE)begin
			b_req_valid <= 1'b0;
		end
		else begin
			b_req_valid <= iRD_REQ;
		end
	end

	assign oRD_VALID = b_req_valid;
	assign oRD_HIT = 1'b0;
	assign oRD_DATA = 32'h0;
	assign oUP_BUSY = 1'b0;
	assign oWR_BUSY = 1'b0;
			
endmodule

`default_nettype wire

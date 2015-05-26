/*************************************************
Branch Cache
	-Branch predictor & Branch address cache
*************************************************/


`default_nettype none


module branch_cache #(
		parameter LRU_TIMER_N = 8
	)(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		input wire iFLUSH,
		//Search
		input wire iSEARCH_STB,
		input wire [31:0] iSEARCH_INST_ADDR,
		output wire oSEARCH_VALID,
		output wire oSEARCH_HIT,
		output wire oSRARCH_PREDICT_BRANCH,	//1 : Branch is valid predict
		output wire [31:0] oSEARCH_ADDR,
		//Jump
		input wire iJUMP_STB,
		input wire iJUMP_HIT,
		input wire [31:0] iJUMP_ADDR,		
		input wire [31:0] iJUMP_INST_ADDR	//Tag[31:5]| Cell Address[4:2] | Byte Order[1:0]
	);


	/*****************************************************************************
	Wire and Register
	*****************************************************************************/
	//Generate
	integer i;
	//Branch Address Buffer
	reg [1:0] b_tag0_lru[0:7];
	reg [1:0] b_tag1_lru[0:7];
	reg [28:0] b_tag0_addr[0:7];
	reg [28:0] b_tag1_addr[0:7];
	reg [1:0] b_tag0_predict[0:7];
	reg [1:0] b_tag1_predict[0:7];
	reg [31:0] b_tag0_jump_addr[0:7];
	reg [31:0] b_tag1_jump_addr[0:7];
	//LRU Timer
	reg [LRU_TIMER_N-1:0] b_lru_timer;
	wire lru_timing = (b_lru_timer == {LRU_TIMER_N{1'b1}})? 1'b1 : 1'b0;
	
	/*****************************************************************************
	Function
	*****************************************************************************/
	function func_get_write_way;
		input [1:0] func_priority_lru0;
		input [1:0] func_priority_lru1;
		begin
			if(func_priority_lru0 == 2'h0)begin
				func_get_write_way = 1'h0;
			end
			else if(func_priority_lru1 == 2'h0)begin
				func_get_write_way = 1'h1;
			end
			else if(func_priority_lru0 <= func_priority_lru1)begin
				func_get_write_way = 1'b0;
			end
			else begin
				func_get_write_way = 1'b1;
			end
		end
	endfunction
	
	//[1] : Hit valid
	//[0] : Hit Way
	function [1:0] func_get_hit_way;
		input [28:0] func_req_addr;
		input [1:0] func_tag_priority_lru0;
		input [1:0] func_tag_priority_lru1;
		input [28:0] func_tag_addr0;
		input [28:0] func_tag_addr1;
		begin
			if(func_tag_priority_lru0 != 2'h0 && func_req_addr == func_tag_addr0)begin
				func_get_hit_way = 2'b10;
			end
			else if(func_tag_priority_lru1 != 2'h0 && func_req_addr == func_tag_addr1)begin
				func_get_hit_way = 2'b11;
			end
			else begin
				func_get_hit_way = 2'b00;
			end
		end
	endfunction 
	
	function [1:0] func_predict_update;
		input func_jump_hit;
		input [1:0] func_now_predict;
		begin
			if(func_now_predict == 2'h3 && !func_jump_hit)begin
				func_predict_update = 2'h3;
			end
			else if(func_now_predict == 2'h0 && func_jump_hit)begin
				func_predict_update = 2'h0;
			end
			else begin
				func_predict_update = (!func_jump_hit)? func_now_predict + 2'h1 : func_now_predict - 2'h1;
			end
		end
	endfunction
	
	function [1:0] func_lru_update;
		input [1:0] func_lru_now;
		begin
			if(func_lru_now == 2'h0 || func_lru_now == 2'h1)begin
				func_lru_update = func_lru_now;
			end
			else begin
				func_lru_update = func_lru_now - 2'h1;
			end
		end
	endfunction
	
	/*****************************************************************************
	Main State
	*****************************************************************************/
	wire [2:0] write_tag_array_addr = iJUMP_INST_ADDR[4:2];
	wire [28:0] write_tag_addr_tag = iJUMP_INST_ADDR[31:5];
	wire [2:0] read_tag_array_addr = iSEARCH_INST_ADDR[4:2];
	wire [28:0] read_tag_addr_tag = iSEARCH_INST_ADDR[31:5];
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			for(i = 0; i < 8; i = i + 1)begin : RESET
				b_tag0_lru[i] <= 2'h0;
				b_tag1_lru[i] <= 2'h0;
				b_tag0_predict[i] <= 2'h0;
				b_tag1_predict[i] <= 2'h0;
			end
		end
		else if(iRESET_SYNC || iFLUSH)begin
			for(i = 0; i < 8; i = i + 1)begin : FLUSH
				b_tag0_lru[i] <= 2'h0;
				b_tag1_lru[i] <= 2'h0; 
				b_tag0_predict[i] <= 2'h0;
				b_tag1_predict[i] <= 2'h0;
			end
		end
		else begin
			//Tag0
			for(i = 0; i < 8; i = i + 1)begin : MAIN_ALWAYS_TAG0
				//Write
				if(iJUMP_STB && write_tag_array_addr == i && !func_get_write_way(b_tag0_lru[write_tag_array_addr], b_tag1_lru[write_tag_array_addr]))begin
					b_tag0_lru[write_tag_array_addr] <= 2'h3;
					b_tag0_addr[write_tag_array_addr] <= write_tag_addr_tag;
					b_tag0_predict[write_tag_array_addr] <= func_predict_update(iJUMP_HIT, b_tag0_predict[write_tag_array_addr]);
					b_tag0_jump_addr[write_tag_array_addr] <= iJUMP_ADDR;
				end
				//Read
				else if(iSEARCH_STB && read_tag_array_addr == i && read_tag_addr_tag == b_tag0_addr[i])begin
					b_tag0_lru[i] <= (b_tag0_lru[i] != 2'h0 && b_tag0_lru[i] != 2'h3)? b_tag0_lru[i] + 2'h1 : b_tag0_lru[i];
				end
				//LRU
				else if(lru_timing)begin
					b_tag0_lru[i] <= func_lru_update(b_tag0_lru[i]);
				end
			end
			//Tag1
			for(i = 0; i < 8; i = i + 1)begin : MAIN_ALWAYS_TAG1
				//Write
				if(iJUMP_STB && write_tag_array_addr == i && func_get_write_way(b_tag0_lru[write_tag_array_addr], b_tag1_lru[write_tag_array_addr]))begin
					b_tag1_lru[write_tag_array_addr] <= 2'h3;
					b_tag1_addr[write_tag_array_addr] <= write_tag_addr_tag;
					b_tag1_predict[write_tag_array_addr] <= func_predict_update(iJUMP_HIT, b_tag1_predict[write_tag_array_addr]);
					b_tag1_jump_addr[write_tag_array_addr] <= iJUMP_ADDR;
				end
				//Read
				else if(iSEARCH_STB && read_tag_array_addr == i && read_tag_addr_tag == b_tag1_addr[i])begin
					b_tag1_lru[i] <= (b_tag1_lru[i] != 2'h0 && b_tag1_lru[i] != 2'h3)? b_tag1_lru[i] + 2'h1 : b_tag1_lru[i];
				end
				//LRU
				else if(lru_timing)begin
					b_tag1_lru[i] <= func_lru_update(b_tag1_lru[i]);
				end
			end
		end
	end
	
	/*****************************************************************************
	LRU Timer
	*****************************************************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_lru_timer <= {LRU_TIMER_N{1'b0}};
		end
		else if(iRESET_SYNC || iFLUSH)begin
			b_lru_timer <= {LRU_TIMER_N{1'b0}};
		end
		else begin
			b_lru_timer <= b_lru_timer + {{LRU_TIMER_N-1{1'b0}}, 1'b1};
		end
	end

	/*****************************************************************************
	Assign
	*****************************************************************************/
	wire request_hit;
	wire hit_way;
	assign {request_hit, hit_way} = func_get_hit_way(read_tag_addr_tag, 
														b_tag0_lru[read_tag_array_addr],
														b_tag1_lru[read_tag_array_addr],
														b_tag0_addr[read_tag_array_addr],
														b_tag1_addr[read_tag_array_addr]
													);
	
	assign oSEARCH_VALID =  iSEARCH_STB;
	assign oSEARCH_HIT = request_hit;
	assign oSRARCH_PREDICT_BRANCH = func_check_predict(
										hit_way,
										b_tag0_predict[read_tag_array_addr],
										b_tag1_predict[read_tag_array_addr]
									);
	assign oSEARCH_ADDR = (!hit_way)? b_tag0_jump_addr[read_tag_array_addr] : b_tag1_jump_addr[read_tag_array_addr];
	

	function func_check_predict;
		input func_hit_way;
		input [1:0] func_tag0_predict;
		input [1:0] func_tag1_predict;
		begin
			case(func_hit_way)
				1'h0:
					begin
						if(func_tag0_predict == 2'h2 || func_tag0_predict == 2'h3)begin
							func_check_predict = 1'b1;
						end
						else begin
							func_check_predict = 1'b0;
						end
					end
				1'b1:
					begin
						if(func_tag1_predict == 2'h2 || func_tag1_predict == 2'h3)begin
							func_check_predict = 1'b1;
						end
						else begin
							func_check_predict = 1'b0;
						end
					end
			endcase
		end
	endfunction
	
endmodule

`default_nettype wire



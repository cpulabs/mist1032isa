/*
	Way				:	4Way Set Assicatiev
	Purging			:	Write Through Algorithm
	Line Size		:	8Byte(2Word)
*/

`include "mmu.h"
`default_nettype none	
	
	
module mmu_tlb(
		//System
		input wire iCLOCK,
		input wire inRESET,
		//TLB FLush
		input wire iREMOVE,			
		//Read
		input wire iRD_REQ,
		output wire oRD_BUSY,			//
		input wire [1:0] iRD_MOD,		//
		input wire [2:0] iRD_PS,		// 
		input wire [31:0] iRD_ADDR,		//Tag([31:15]Address Tag | [14:13]Way | [12]Line:none) | [11:0]None
		output wire oRD_VALID,
		input wire iRD_BUSY,			//
		output wire oRD_HIT,
		output wire [23:0] oRD_FLAGS,
		output wire [31:0] oRD_PHYS_ADDR,
		//Write
		input wire iWR_REQ,
		input wire [1:0] iWR_MOD,		//
		input wire [2:0] iWR_PS,		// 
		input wire [31:0] iWR_ADDR,		
		//input wire [27:0] iWR_FLAGS,			
		input wire [63:0] iWR_PHYS_ADDR
	);
				
				
	/********************************************
	Register and Wire
	********************************************/
	//Output Buffer
	reg b_rd_hit;
	reg b_rd_line;
	reg [1:0] b_rd_way;
	reg [1:0] b_rd_index;
	//Memory Control
	wire [1:0] write_index;
	wire [1:0] write_way;
	wire [1:0] read_index;
	wire read_hit;
	wire [1:0] read_way;
	wire this_read_lock;
	//Generate
	integer i;
	//Memory
	reg [1:0] b_status0[0:3]; //0:Non Valid
	reg [1:0] b_status1[0:3];
	reg [1:0] b_status2[0:3];
	reg [1:0] b_status3[0:3];
	/*
	reg [33:0] b_tag0[0:3];	//AddressTag:15bit
	reg [33:0] b_tag1[0:3];	
	reg [33:0] b_tag2[0:3];
	reg [33:0] b_tag3[0:3];
	*/
	reg [16:0] b_tag0[0:3];	//AddressTag:15bit
	reg [16:0] b_tag1[0:3];	
	reg [16:0] b_tag2[0:3];
	reg [16:0] b_tag3[0:3];
	reg [39:0] b_data0[0:3]; //Real Address Index(2Line)
	reg [39:0] b_data1[0:3];
	reg [39:0] b_data2[0:3];
	reg [39:0] b_data3[0:3];
	reg [23:0] b_flags0[0:3]; //MMU Flag 12bit(2Line)
	reg [23:0] b_flags1[0:3];
	reg [23:0] b_flags2[0:3];
	reg [23:0] b_flags3[0:3];
	//Memory Contoroll
	reg b_load_req_valid;	
	
	/********************************************
	Output Buffer
	********************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_rd_hit <= 1'h0;
			b_rd_line <= 1'b0;
			b_rd_way <= 2'h0;
			b_rd_index <= 2'h0;
		end
		else begin
			if(!this_read_lock)begin
				b_rd_hit <= read_hit;
				b_rd_line <= func_get_line(iRD_MOD, iRD_PS, iRD_ADDR);
				b_rd_way <= read_way;
				b_rd_index <= read_index;
			end
		end
	end
	
	
	/********************************************
	Controll Read
	********************************************/
	assign read_index = func_get_index(iRD_MOD, iRD_PS, iRD_ADDR);
	assign {read_hit, read_way}	= func_hit_check(
		func_get_tag(iRD_MOD, iRD_PS, iRD_ADDR),
		b_status0[read_index],
		b_status1[read_index],
		b_status2[read_index],
		b_status3[read_index],
		b_tag0[read_index],
		b_tag1[read_index],
		b_tag2[read_index],
		b_tag3[read_index]
	);
				
	assign this_read_lock = iRD_BUSY;
	
	/********************************************
	Controll Write
	********************************************/
	assign write_index = func_get_index(iWR_MOD, iWR_PS, iWR_ADDR);
	assign write_way = func_write_way_search(
		b_status0[write_index], 
		b_status1[write_index], 
		b_status2[write_index], 
		b_status3[write_index]
	);

	/********************************************
	Function
	********************************************/
	//Hit Check
	function [2:0] func_hit_check;	//[2]:Hit  |  [1:0] Hit Way
		input [16:0] func_request_tag;
		input [1:0] func_way0_status;
		input [1:0] func_way1_status;
		input [1:0] func_way2_status;
		input [1:0] func_way3_status;
		input [16:0] func_way0_tag;
		input [16:0] func_way1_tag;
		input [16:0] func_way2_tag;
		input [16:0] func_way3_tag;
		begin
			if(func_way0_status != 2'h0 && func_way0_tag == func_request_tag)begin
				func_hit_check = {1'b1, 2'h0};
			end
			else if(func_way1_status != 2'h0 && func_way1_tag == func_request_tag)begin
				func_hit_check = {1'b1, 2'h1};
			end
			else if(func_way2_status != 2'h0 && func_way2_tag == func_request_tag)begin
				func_hit_check = {1'b1, 2'h2};
			end
			else if(func_way3_status != 2'h0 && func_way3_tag == func_request_tag)begin
				func_hit_check = {1'b1, 2'h3};
			end
			else begin
				func_hit_check = 3'h0;
			end
		end
	endfunction
		
	
	//Low Pryority Line Search
	function [1:0] func_write_way_search;
		input [1:0] way0_status;
		input [1:0] way1_status;
		input [1:0] way2_status;
		input [1:0] way3_status;
		begin
			if(way0_status == 2'h0)
				func_write_way_search = 2'h0;
			else if(way1_status == 2'h0)
				func_write_way_search = 2'h1;
			else if(way2_status == 2'h0)
				func_write_way_search = 2'h2;
			else if(way3_status == 2'h0)
				func_write_way_search = 2'h3;
			else if(way0_status == 2'h1)
				func_write_way_search = 2'h0;
			else if(way1_status == 2'h1)
				func_write_way_search = 2'h1;
			else if(way2_status == 2'h1)
				func_write_way_search = 2'h2;
			else if(way3_status == 2'h1)
				func_write_way_search = 2'h3;
			else if(way0_status == 2'h2)
				func_write_way_search = 2'h0;
			else if(way1_status == 2'h2)
				func_write_way_search = 2'h1;
			else if(way2_status == 2'h2)
				func_write_way_search = 2'h2;
			else if(way3_status == 2'h2)
				func_write_way_search = 2'h3;
			else
				func_write_way_search = 2'h3;
		end
	endfunction


	function func_get_line;
		input [1:0] func_mod;
		input [2:0] func_ps;
		input [31:0] func_addr;
		begin
			if(func_mod == `MMU_PAGING_LEVEL_1)begin
				case(func_ps)
					`MMU_PAGING_LEVEL1_PAGESIZE_128K : func_get_line = func_addr[17];
					`MMU_PAGING_LEVEL1_PAGESIZE_256K : func_get_line = func_addr[18];
					`MMU_PAGING_LEVEL1_PAGESIZE_512K : func_get_line = func_addr[19];
					`MMU_PAGING_LEVEL1_PAGESIZE_1024K : func_get_line = func_addr[20];
					`MMU_PAGING_LEVEL1_PAGESIZE_2048K : func_get_line = func_addr[21];
					default : func_get_line = 1'b0;
				endcase
			end
			else begin
				case(func_ps)
					`MMU_PAGING_LEVEL2_PAGESIZE_4K : func_get_line = func_addr[12];
					`MMU_PAGING_LEVEL2_PAGESIZE_8K : func_get_line = func_addr[13];
					`MMU_PAGING_LEVEL2_PAGESIZE_16K : func_get_line = func_addr[14];
					`MMU_PAGING_LEVEL2_PAGESIZE_32K : func_get_line = func_addr[15];
					`MMU_PAGING_LEVEL2_PAGESIZE_64K : func_get_line = func_addr[16];
					default : func_get_line = 1'b0;
				endcase
			end
		end
	endfunction


	function [19:0] func_get_addr;
		input [1:0] func_mod;
		input [2:0] func_ps;
		input [31:0] func_data;
		begin
			if(func_mod == `MMU_PAGING_LEVEL_1)begin
				case(func_ps)
					`MMU_PAGING_LEVEL1_PAGESIZE_128K : func_get_addr = {func_data[31:17], 5'h0};
					`MMU_PAGING_LEVEL1_PAGESIZE_256K : func_get_addr = {func_data[31:18], 6'h0};
					`MMU_PAGING_LEVEL1_PAGESIZE_512K : func_get_addr = {func_data[31:19], 7'h0};
					`MMU_PAGING_LEVEL1_PAGESIZE_1024K : func_get_addr = {func_data[31:20], 8'h0};
					`MMU_PAGING_LEVEL1_PAGESIZE_2048K : func_get_addr = {func_data[31:21], 9'h0};
					default : func_get_addr = 32'h0;
				endcase
			end
			else begin
				case(func_ps)
					`MMU_PAGING_LEVEL2_PAGESIZE_4K : func_get_addr = func_data[31:12];
					`MMU_PAGING_LEVEL2_PAGESIZE_8K : func_get_addr = {func_data[31:13], 1'h0};
					`MMU_PAGING_LEVEL2_PAGESIZE_16K : func_get_addr = {func_data[31:14], 2'h0};
					`MMU_PAGING_LEVEL2_PAGESIZE_32K : func_get_addr = {func_data[31:15], 3'h0};
					`MMU_PAGING_LEVEL2_PAGESIZE_64K : func_get_addr = {func_data[31:16], 4'h0};
					default : func_get_addr = 32'h0;
				endcase
			end
		end
	endfunction

	function [11:0] func_get_flags;
		input [31:0] func_data;
		begin
			func_get_flags = func_data[11:0];
		end
	endfunction

	function [1:0] func_get_index;
		input [1:0] func_mod;
		input [2:0] func_ps;
		input [31:0] func_addr;
		begin
			if(func_mod == `MMU_PAGING_LEVEL_1)begin
				case(func_ps)
					`MMU_PAGING_LEVEL1_PAGESIZE_128K : func_get_index = func_addr[19:18];
					`MMU_PAGING_LEVEL1_PAGESIZE_256K : func_get_index = func_addr[20:19];
					`MMU_PAGING_LEVEL1_PAGESIZE_512K : func_get_index = func_addr[21:20];
					`MMU_PAGING_LEVEL1_PAGESIZE_1024K : func_get_index = func_addr[22:21];
					`MMU_PAGING_LEVEL1_PAGESIZE_2048K : func_get_index = func_addr[23:22];
					default : func_get_index = 2'h0;
				endcase
			end
			else begin
				case(func_ps)
					`MMU_PAGING_LEVEL2_PAGESIZE_4K : func_get_index = func_addr[14:13];
					`MMU_PAGING_LEVEL2_PAGESIZE_8K : func_get_index = func_addr[15:14];
					`MMU_PAGING_LEVEL2_PAGESIZE_16K : func_get_index = func_addr[16:15];
					`MMU_PAGING_LEVEL2_PAGESIZE_32K : func_get_index = func_addr[17:16];
					`MMU_PAGING_LEVEL2_PAGESIZE_64K : func_get_index = func_addr[18:17];
					default : func_get_index = 2'h0;
				endcase
			end
		end
	endfunction

	function [16:0] func_get_tag;
		input [1:0] func_mod;
		input [2:0] func_ps;
		input [31:0] func_addr;
		begin
			if(func_mod == `MMU_PAGING_LEVEL_1)begin
				case(func_ps)
					`MMU_PAGING_LEVEL1_PAGESIZE_128K : func_get_tag = {4'h0, func_addr[31:20]};
					`MMU_PAGING_LEVEL1_PAGESIZE_256K : func_get_tag = {5'h0, func_addr[31:21]};
					`MMU_PAGING_LEVEL1_PAGESIZE_512K : func_get_tag = {6'h0, func_addr[31:22]};
					`MMU_PAGING_LEVEL1_PAGESIZE_1024K : func_get_tag = {7'h0, func_addr[31:23]};
					`MMU_PAGING_LEVEL1_PAGESIZE_2048K : func_get_tag = {8'h0, func_addr[31:24]};
					default : func_get_tag = 17'h0;
				endcase
			end
			else begin
				case(func_ps)
					`MMU_PAGING_LEVEL2_PAGESIZE_4K : func_get_tag = func_addr[31:15];	//17bit
					`MMU_PAGING_LEVEL2_PAGESIZE_8K : func_get_tag = {1'h0, func_addr[31:16]};
					`MMU_PAGING_LEVEL2_PAGESIZE_16K : func_get_tag = {2'h0, func_addr[31:17]};
					`MMU_PAGING_LEVEL2_PAGESIZE_32K : func_get_tag = {3'h0, func_addr[31:18]};
					`MMU_PAGING_LEVEL2_PAGESIZE_64K : func_get_tag = {4'h0, func_addr[31:19]};
					default : func_get_tag = 17'h0;
				endcase
			end
		end
	endfunction
	
	
	/********************************************
	Tag Pryority & Tag Control
	********************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_load_req_valid <= 1'b0;
		end
		else if(iREMOVE)begin
			b_load_req_valid <= 1'b0;
		end
		else begin
			//Request Valid
			if(!this_read_lock)begin
				b_load_req_valid <= iRD_REQ;
			end
		end
	end

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			for(i = 0; i < 4; i = i + 1)begin
				b_status0[i] <= {2{1'b0}};
				b_status1[i] <= {2{1'b0}};
				b_status2[i] <= {2{1'b0}};
				b_status3[i] <= {2{1'b0}};
			end
		end
		else if(iREMOVE)begin
			for(i = 0; i < 4; i = i + 1)begin
				b_status0[i] <= {2{1'b0}};
				b_status1[i] <= {2{1'b0}};
				b_status2[i] <= {2{1'b0}};
				b_status3[i] <= {2{1'b0}};
			end
		end
		else begin
			//Write
			if(iWR_REQ)begin
				case(write_way)
					2'h0:	
						begin
							b_status0[write_index] <= 2'b11;
							b_tag0[write_index] <= func_get_tag(iWR_MOD, iWR_PS, iWR_ADDR);
							b_data0[write_index] <= {func_get_addr(iWR_MOD, iWR_PS, iWR_PHYS_ADDR[63:32]), func_get_addr(iWR_MOD, iWR_PS, iWR_PHYS_ADDR[31:0])};
							b_flags0[write_index] <= {func_get_flags(iWR_PHYS_ADDR[63:32]), func_get_flags(iWR_PHYS_ADDR[31:0])};
						end
					2'h1:
						begin
							b_status1[write_index] <= 2'b11;
							b_tag1[write_index] <= func_get_tag(iWR_MOD, iWR_PS, iWR_ADDR);
							b_data1[write_index] <= {func_get_addr(iWR_MOD, iWR_PS, iWR_PHYS_ADDR[63:32]), func_get_addr(iWR_MOD, iWR_PS, iWR_PHYS_ADDR[31:0])};
							b_flags1[write_index] <= {func_get_flags(iWR_PHYS_ADDR[63:32]), func_get_flags(iWR_PHYS_ADDR[31:0])};
						end
					2'h2:	
						begin
							b_status2[write_index] <= 2'b11;
							b_tag2[write_index] <= func_get_tag(iWR_MOD, iWR_PS, iWR_ADDR);
							b_data2[write_index] <= {func_get_addr(iWR_MOD, iWR_PS, iWR_PHYS_ADDR[63:32]), func_get_addr(iWR_MOD, iWR_PS, iWR_PHYS_ADDR[31:0])};
							b_flags2[write_index] <= {func_get_flags(iWR_PHYS_ADDR[63:32]), func_get_flags(iWR_PHYS_ADDR[31:0])};
						end
					2'h3:	
						begin
							b_status3[write_index] <= 2'b11;
							b_tag3[write_index] <= func_get_tag(iWR_MOD, iWR_PS, iWR_ADDR);
							b_data3[write_index] <= {func_get_addr(iWR_MOD, iWR_PS, iWR_PHYS_ADDR[63:32]), func_get_addr(iWR_MOD, iWR_PS, iWR_PHYS_ADDR[31:0])};
							b_flags3[write_index] <= {func_get_flags(iWR_PHYS_ADDR[63:32]), func_get_flags(iWR_PHYS_ADDR[31:0])};
						end
				endcase
			end
			//Read & LRU Controal
			else if(!this_read_lock)begin
				if(iRD_REQ)begin
					for(i = 0; i < 4; i = i + 1)begin
						//TAG0
						if(read_index == i[1:0] && read_way == 2'h0 && read_hit)begin
							b_status0[read_index] <= 2'b11;
						end
						else begin
							if(b_status0[i] != 2'h0 && b_status0[i] != 2'h1)begin
								b_status0[i] <= b_status0[i] - 2'h1;
							end
						end
						//TAG1
						if(read_index == i[1:0] && read_way == 2'h1 && read_hit)begin
							b_status1[read_index] <= 2'b11;
						end
						else begin
							if(b_status1[i] != 2'h0 && b_status1[i] != 2'h1)begin
								b_status1[i] <= b_status1[i] - 2'h1;
							end
						end
						//TAG2
						if(read_index == i[1:0] && read_way == 2'h2 && read_hit)begin
							b_status2[read_index] <= 2'b11;
						end
						else begin
							if(b_status2[i] != 2'h0 && b_status2[i] != 2'h1)begin
								b_status2[i] <= b_status2[i] - 2'h1;
							end
						end
						//TAG3
						if(read_index == i[1:0] && read_way == 2'h3 && read_hit)begin
							b_status3[read_index] <= 2'b11;
						end
						else begin
							if(b_status3[i] != 2'h0 && b_status3[i] != 2'h1)begin
								b_status3[i] <= b_status3[i] - 2'h1;
							end
						end
					end
				end
			end //End !Lock
		end
	end //always
	

	/********************************************
	Assign
	********************************************/
	function [31:0] func_line_data2output_data;
		input func_line_select;
		input [39:0] func_line_data;
		begin
			if(func_line_select)begin
				func_line_data2output_data = {func_line_data[39:20], 12'h0};
			end
			else begin
				func_line_data2output_data = {func_line_data[19:0], 12'h0};
			end
		end
	endfunction
	

	/*
	function [63:0] func_line_data2output_data;
		input [39:0] func_line_data;
		begin
			func_line_data2output_data = {func_line_data[39:20], 12'h0, func_line_data[19:0], 12'h0};
		end
	endfunction
	*/

	assign oRD_VALID = !this_read_lock && b_load_req_valid;
	assign oRD_HIT = !this_read_lock && b_load_req_valid && b_rd_hit;
	assign oRD_FLAGS =
						(b_load_req_valid && !this_read_lock && b_rd_hit)? (
							(b_rd_way == 2'h0)? b_flags0[b_rd_index] : (
								(b_rd_way == 2'h1)? b_flags1[b_rd_index] : (
									(b_rd_way == 2'h2)? b_flags2[b_rd_index] : b_flags3[b_rd_index]
								)
							)
						) : 24'h0;
	
	
	assign oRD_PHYS_ADDR = 
						(b_load_req_valid && !this_read_lock && b_rd_hit)? (
							(b_rd_way == 2'h0)? func_line_data2output_data(b_rd_line, b_data0[b_rd_index]) : (
								(b_rd_way == 2'h1)? func_line_data2output_data(b_rd_line, b_data1[b_rd_index]) : (
									(b_rd_way == 2'h2)? func_line_data2output_data(b_rd_line, b_data2[b_rd_index]) : func_line_data2output_data(b_rd_line, b_data3[b_rd_index])
								)
							)
						) : 32'h0;
	/*
	assign oRD_PHYS_ADDR = 
						(b_load_req_valid && !this_read_lock && b_rd_hit)? (
							(b_rd_way == 2'h0)? func_line_data2output_data(b_data0[b_rd_index]) : (
								(b_rd_way == 2'h1)? func_line_data2output_data(b_data1[b_rd_index]) : (
									(b_rd_way == 2'h2)? func_line_data2output_data(b_data2[b_rd_index]) : func_line_data2output_data(b_data3[b_rd_index])
								)
							)
						) : 64'h0;
	*/


	
	assign oRD_BUSY = this_read_lock;
	
	
endmodule


`default_nettype wire

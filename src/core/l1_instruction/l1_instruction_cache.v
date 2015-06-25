
//`include "processor.h"
`default_nettype none
`include "common.h"


module l1_instruction_cache(
		input wire iCLOCK,
		input wire inRESET,
		//Remove
		input wire iREMOVE,
		input wire iCACHE_FLASH,
		/****************************************
		Memory Port Memory
		****************************************/
		//Req
		output wire oINST_REQ,
		input wire iINST_LOCK,
		output wire [1:0] oINST_MMUMOD,
		output wire [2:0] oINST_MMUPS,
		output wire [13:0] oINST_ASID,
		output wire [31:0] oINST_PDT,
		output wire [31:0] oINST_ADDR,
		//Mem
		input wire iINST_VALID,
		output wire oINST_BUSY,
		input wire [63:0] iINST_DATA,
		input wire [23:0] iINST_MMU_FLAGS,
		/****************************************
		Fetch Module
		****************************************/
		//From Fetch
		input wire iNEXT_FETCH_REQ,
		output wire oNEXT_FETCH_LOCK,
		input wire [1:0] iNEXT_MMUMOD,
		input wire [2:0] iNEXT_MMUPS,
		input wire [13:0] iNEXT_ASID,
		input wire [31:0] iNEXT_PDT,
		input wire [31:0] iNEXT_FETCH_ADDR,
		//To Fetch
		output wire oNEXT_0_INST_VALID,
		output wire [11:0] oNEXT_0_MMU_FLAGS,
		output wire [31:0] oNEXT_0_INST,
		output wire oNEXT_1_INST_VALID,
		output wire [11:0] oNEXT_1_MMU_FLAGS,
		output wire [31:0] oNEXT_1_INST,
		input wire iNEXT_LOCK
	);


	/****************************************
	Instruction Access
	****************************************/
	localparam L_PARAM_IDLE = 2'h0;
	localparam L_PARAM_MEMREQ = 2'h1;
	localparam L_PARAM_MEMGET = 2'h2;
	localparam L_PARAM_OUTINST = 2'h3;

	//Controlor
	reg [1:0] b_req_main_state;
	reg [3:0] b_req_state;
	reg [3:0] b_get_state;
	reg [31:0] b_req_addr;
	reg [1:0] b_req_mmumod;
	reg [2:0] b_req_mmups;
	reg [31:0] b_req_pdt;
	reg [13:0] b_req_asid;
	reg b_mem_result_0_valid;
	reg b_mem_result_1_valid;
	reg [63:0] b_mem_result_data;
	reg [23:0] b_mem_result_mmu_flags;
	reg [511:0] b_cache_write_data;
	reg [255:0] b_cache_write_mmu_flags;


	wire cache_result_valid;
	wire cache_result_hit;
	wire [63:0] cache_result_data;
	wire [23:0] cache_result_mmu_flags;

	wire request_lock = iINST_LOCK && (b_req_main_state != L_PARAM_IDLE);
	wire load_lock = iINST_LOCK;
	wire out_lock = iNEXT_LOCK;

	reg next_0_inst_valid;
	reg [31:0] next_0_inst_inst;
	reg [11:0] next_0_inst_mmu_flags;
	reg next_1_inst_valid;
	reg [31:0] next_1_inst_inst;
	reg [11:0] next_1_inst_mmu_flags;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_req_main_state <= 2'b0;
			b_req_state <= 4'h0;
			b_get_state <= 4'h0;
			b_req_addr <= {32{1'b0}};
			b_req_mmumod <= 2'h0;
			b_req_mmups <= 3'h0;
			b_req_pdt <= 32'h0;
			b_req_asid <= 14'h0;
			b_mem_result_0_valid <= 1'b0;
			b_mem_result_1_valid <= 1'b0;
			b_mem_result_data <= 64'h0;
			b_mem_result_mmu_flags <= 24'h0;
			b_cache_write_data <= 512'h0;
			b_cache_write_mmu_flags <= 256'h0;
		end
		else begin
			//Buffer
			if(!request_lock && iNEXT_FETCH_REQ && (b_req_main_state == L_PARAM_IDLE) && !out_lock)begin
				b_req_addr <= iNEXT_FETCH_ADDR;
				b_req_mmumod <= iNEXT_MMUMOD;
				b_req_mmups <= iNEXT_MMUPS;
				b_req_pdt <= iNEXT_PDT;
				b_req_asid <= iNEXT_ASID;
			end
			//Memory State
			case(b_req_main_state)
				L_PARAM_IDLE:	//Idle
					begin
						if(cache_result_valid && !cache_result_hit && !out_lock)begin
							b_req_main_state <= L_PARAM_MEMREQ;
						end
					end
				L_PARAM_MEMREQ:	//Request State
					begin
						//Cache ON
						`ifdef MIST1032ISA_INST_L1_CACHE
							//Next Stage Check
							if(!load_lock && (b_req_state == 4'h7))begin
								b_req_main_state <= L_PARAM_MEMGET;
								b_req_state <= 4'h0;
							end
							//Request
							else if(!load_lock)begin
								b_req_state <= b_req_state + 4'h1;
							end
							//Get Check
							if(iINST_VALID)begin
								b_get_state <= b_get_state + 4'h1;
								b_cache_write_data <= {iINST_DATA, b_cache_write_data[511:64]};
								b_cache_write_mmu_flags <= {4'h0, iINST_MMU_FLAGS[23:12], 4'h0, iINST_MMU_FLAGS[11:0], b_cache_write_mmu_flags[255:31]};
								if(b_req_addr[5:3] == b_get_state[3:0])begin
									if(!b_req_addr[2])begin
										b_mem_result_0_valid <= 1'b1;
										b_mem_result_1_valid <= 1'b1;
										b_mem_result_data <= iINST_DATA;
										b_mem_result_mmu_flags <= iINST_MMU_FLAGS;
									end
									else begin
										b_mem_result_0_valid <= 1'b1;
										b_mem_result_1_valid <= 1'b0;
										b_mem_result_data <= {32'h0, iINST_DATA[62:32]};
										b_mem_result_mmu_flags <= {12'h0, iINST_MMU_FLAGS[23:12]};
									end
								end
							end
						//Cache OFF
						`else
							//Load Requset
							if(!load_lock)begin
								b_req_main_state <= L_PARAM_MEMGET;
								b_req_state <= 4'h0;
							end
						`endif
					end
				L_PARAM_MEMGET:	//Get Wait State
					begin
						//Cache ON
						`ifdef MIST1032ISA_INST_L1_CACHE
							if(iINST_VALID)begin
								//Data Check
								b_cache_write_data <= {iINST_DATA, b_cache_write_data[511:64]};
								b_cache_write_mmu_flags <= {4'h0, iINST_MMU_FLAGS[23:12], 4'h0, iINST_MMU_FLAGS[11:0], b_cache_write_mmu_flags[255:31]};
								if(b_req_addr[5:3] == b_get_state[3:0])begin
									if(!b_req_addr[2])begin
										b_mem_result_0_valid <= 1'b1;
										b_mem_result_1_valid <= 1'b1;
										b_mem_result_data <= iINST_DATA;
										b_mem_result_mmu_flags <= iINST_MMU_FLAGS;
									end
									else begin
										b_mem_result_0_valid <= 1'b1;
										b_mem_result_1_valid <= 1'b0;
										b_mem_result_data <= {32'h0, iINST_DATA[62:32]};
										b_mem_result_mmu_flags <= {12'h0, iINST_MMU_FLAGS[23:12]};
									end
								end
								//State Check
								if(b_get_state == 4'h7)begin
									b_get_state <= 4'h0;
									b_req_main_state <= L_PARAM_OUTINST;
								end
								else begin
									b_get_state <= b_get_state + 4'h1;
								end
							end
						`else
						//Cache OFF
							if(iINST_VALID)begin
								b_get_state <= 4'h0;
								b_req_main_state <= L_PARAM_OUTINST;
								if(!b_req_addr[2])begin
									b_mem_result_0_valid <= 1'b1;
									b_mem_result_1_valid <= 1'b1;
									b_mem_result_data <= iINST_DATA;
									b_mem_result_mmu_flags <= iINST_MMU_FLAGS;
								end
								else begin
									b_mem_result_0_valid <= 1'b1;
									b_mem_result_1_valid <= 1'b0;
									b_mem_result_data <= {32'h0, iINST_DATA[62:32]};
									b_mem_result_mmu_flags <= {12'h0, iINST_MMU_FLAGS[23:12]};
								end
							end
						`endif
					end
				L_PARAM_OUTINST:
					begin
						if(!out_lock)begin
							b_req_main_state <= L_PARAM_IDLE;
						end
					end
			endcase
		end
	end


	/*
	//Cache Hit Counter
	wire [6:0] cache_hit_counter;
	l1_instruction_cache_counter L1_CACHE_HIT_COUNTER(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Hit Infomation
		.iCACHE_VALID(cache_result_valid && !out_lock),
		.iCACHE_HIT(cache_result_hit),
		//Infomation
		.oINFO_COUNT(cache_hit_counter)
	);
	*/


	`ifdef MIST1032ISA_INST_L1_CACHE
		l1_cache_64entry_4way_line64b_bus_8b CACHE_MODULE(
			/********************************
			System
			********************************/
			.iCLOCK(iCLOCK),
			.inRESET(inRESET),
			//Remove
			.iREMOVE(iCACHE_FLASH),
			/********************************
			Search
			********************************/
			//Search Request
			.iRD_REQ((b_req_main_state == L_PARAM_IDLE) && iNEXT_FETCH_REQ),
			.oRD_BUSY(),
			.iRD_ADDR({iNEXT_FETCH_ADDR[31:3], 3'h0}),		//Tag:22bit | Index:4bit(4Way*16Entry) | LineSize:6bit(64B)
			//Search Output Result
			.oRD_VALID(cache_result_valid),
			.oRD_HIT(cache_result_hit),
			.iRD_BUSY(out_lock),
			.oRD_DATA(cache_result_data),
			.oRD_MMU_FLAGS(cache_result_mmu_flags),
			/********************************
			Write Request
			********************************/
			//.iWR_REQ(iINST_VALID),
			.iWR_REQ((b_req_main_state == L_PARAM_OUTINST) && !load_lock),
			.oWR_BUSY(),
			.iWR_ADDR({b_req_addr[31:6], 6'h0}),
			//.iWR_DATA(iINST_DATA),
			.iWR_DATA(b_cache_write_data),
			.iWR_MMU_FLAGS(b_cache_write_mmu_flags)
		);
	`else
		l1_cache_64entry_4way_line64b_bus_8b_damy CACHE_MODULE(
			/********************************
			System
			********************************/
			.iCLOCK(iCLOCK),
			.inRESET(inRESET),
			//Remove
			.iREMOVE(iCACHE_FLASH),
			/********************************
			Search
			********************************/
			//Search Request
			.iRD_REQ((b_req_main_state == L_PARAM_IDLE) && iNEXT_FETCH_REQ),
			.oRD_BUSY(),
			.iRD_ADDR({iNEXT_FETCH_ADDR[31:3], 3'h0}),		//Tag:22bit | Index:4bit(4Way*16Entry) | LineSize:6bit(64B)
			//Search Output Result
			.oRD_VALID(cache_result_valid),
			.oRD_HIT(cache_result_hit),
			.iRD_BUSY(out_lock),
			.oRD_DATA(cache_result_data),
			.oRD_MMU_FLAGS(cache_result_mmu_flags),
			/********************************
			Write Request
			********************************/
			.iWR_REQ(1'b0),
			.oWR_BUSY(),
			.iWR_ADDR(32'h0),
			.iWR_DATA(b_cache_write_data),
			.iWR_MMU_FLAGS(b_cache_write_mmu_flags)
		);
	`endif

	always @* begin
		if(b_req_main_state == L_PARAM_OUTINST)begin
			next_0_inst_valid = b_mem_result_0_valid;
			next_0_inst_inst = b_mem_result_data[31:0];
			next_0_inst_mmu_flags = b_mem_result_mmu_flags[11:0];
			next_1_inst_valid = b_mem_result_1_valid;
			next_1_inst_inst = b_mem_result_data[63:32];
			next_1_inst_mmu_flags = b_mem_result_mmu_flags[23:12];
		end
		else begin
			next_0_inst_valid = cache_result_valid && cache_result_hit;
			if(!b_req_addr[2])begin
				next_0_inst_inst = cache_result_data[31:0];
				next_0_inst_mmu_flags = cache_result_mmu_flags[11:0];
			end
			else begin
				next_0_inst_inst = cache_result_data[63:32];
				next_0_inst_mmu_flags = cache_result_mmu_flags[23:12];
			end
			next_1_inst_valid = !b_req_addr[2] && cache_result_valid && cache_result_hit;
			next_1_inst_inst = cache_result_data[63:32];
			next_1_inst_mmu_flags = cache_result_mmu_flags[23:12];
		end
	end

	/*************************
	Outpu Assign
	*************************/
	//Memory
	assign oINST_REQ = (b_req_main_state == L_PARAM_MEMREQ)? !load_lock : 1'b0;
	assign oINST_MMUMOD = b_req_mmumod;
	assign oINST_MMUPS = b_req_mmups;
	assign oINST_PDT = b_req_pdt;
	assign oINST_ASID = b_req_asid;

	`ifdef MIST1032ISA_INST_L1_CACHE
		assign oINST_ADDR = {b_req_addr[31:6], b_req_state[2:0], 3'h0};
	`else
		assign oINST_ADDR = {b_req_addr[31:3], 3'h0};
	`endif


	assign oINST_BUSY = 1'b0;

	//This -> Fetch Module
	assign oNEXT_FETCH_LOCK = (b_req_main_state != L_PARAM_IDLE) || request_lock || out_lock || (cache_result_valid && !cache_result_hit);
	assign oNEXT_0_INST_VALID = next_0_inst_valid && !out_lock;
	assign oNEXT_0_INST = next_0_inst_inst;
	assign oNEXT_0_MMU_FLAGS = next_0_inst_mmu_flags;
	assign oNEXT_1_INST_VALID = next_1_inst_valid && !out_lock;
	assign oNEXT_1_INST = next_1_inst_inst;
	assign oNEXT_1_MMU_FLAGS = next_1_inst_mmu_flags;
endmodule


`default_nettype wire


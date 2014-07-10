/********************************************************************************
Memory Management Unit Version 1
for MIST32 Processor
********************************************************************************/
`default_nettype none
//`include "processor.h"


module mmu(
		//System
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//TLB Flash
		input wire iTLB_FLUSH,
		/***********************
		Logic Addres Request
		***********************/
		input wire iLOGIC_REQ,
		output wire oLOGIC_LOCK,
		input wire iLOGIC_DATA_STORE_ACK,
		input wire [1:0] iLOGIC_MMUMOD,		//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion
		input wire [2:0] iLOGIC_MMUPS,		//MMU Page Size
		input wire [31:0] iLOGIC_PDT,		//Page Directory Table
		input wire [13:0] iLOGIC_ASID,		//Task ID 															<New Port>		//////////////////////
		input wire [1:0] iLOGIC_ORDER,
		input wire [3:0] iLOGIC_MASK,
		input wire iLOGIC_RW,				//0=Read 1=Write
		input wire [31:0] iLOGIC_ADDR,
		input wire [31:0] iLOGIC_DATA,
		/***********************
		MMU Flags Output
		***********************/
		output wire oMMUFLAGS_REQ,
		input wire iMMUFLAGS_LOCK,
		output wire [23:0] oMMUFLAGS_FLAGS,
		/***********************
		To Memory
		***********************/
		output wire oMEMORY_REQ,
		input wire iMEMORY_LOCK,
		output wire oMEMORY_DATA_STORE_ACK,
		output wire oMEMORY_MMU_USE,
		output wire [1:0] oMEMORY_ORDER,
		output wire [3:0] oMEMORY_MASK,
		output wire oMEMORY_RW,
		output wire [31:0] oMEMORY_ADDR,
		output wire [31:0] oMEMORY_DATA,
		//Data RAM -> This
		input wire iMEMORY_VALID,
		output wire oMEMORY_LOCK,
		input wire [63:0] iMEMORY_DATA
	);


	/************************************************************
	Parameter
	************************************************************/
	localparam PL_PAGING_LEVEL_OFF = 2'h0;
	localparam PL_PAGING_LEVEL_1 = 2'h1;
	localparam PL_PAGING_LEVEL_2 = 2'h2;

	localparam PL_MAIN_STT_TLB = 3'h0;
	localparam PL_MAIN_STT_PAGE1_REQ = 3'h1;
	localparam PL_MAIN_STT_PAGE1_WAIT = 3'h2;
	localparam PL_MAIN_STT_PAGE2_REQ = 3'h3;
	localparam PL_MAIN_STT_PAGE2_WAIT = 3'h4;
	localparam PL_MAIN_STT_ACCESS = 3'h5;

	/************************************************************
	Wire and Register
	************************************************************/
	//Logic Access
	reg b_logic_req;
	reg b_logic_data_store_ack;
	reg [1:0] b_logic_order;
	reg [3:0] b_logic_mask;
	reg b_logic_rw;
	reg [13:0] b_logic_asid;
	reg [1:0] b_logic_mode;
	reg [2:0] b_logic_mmups;
	reg [31:0] b_logic_pdt;
	reg [31:0] b_logic_addr;
	reg [31:0] b_logic_data;
	//State
	reg [2:0] b_main_state;
	//Table Load
	wire table_load_done_valid;
	wire [31:0] table_load_done_data;
	wire [11:0] table_load_done_flag0;
	wire [11:0] table_load_done_flag1;
	wire table_mem_req;
	wire [31:0] table_mem_addr;
	//TLB
	wire tlb_rd_busy;
	wire tlb_rd_valid;
	wire tlb_rd_hit;
	wire [23:0] tlb_rd_flags;
	wire [31:0] tlb_rd_physical_addr;
	//Reservation Table
	wire res_table_wr_full;
	wire res_table_rd_valid;
	wire res_table_rd_flag;


	/************************************************************
	Condition
	************************************************************/
	wire mmu_prev_busy = (b_main_state != PL_MAIN_STT_TLB) || iMEMORY_LOCK || tlb_rd_busy;
	wire mmu_prev_req_valid_condition = !mmu_prev_busy && iLOGIC_REQ;

	wire tlb_misshit_condition = tlb_rd_valid && !tlb_rd_hit && (b_logic_mode != PL_PAGING_LEVEL_OFF);
	wire tlb_hit_condition = tlb_rd_valid && tlb_rd_hit && (b_logic_mode != PL_PAGING_LEVEL_OFF);


	/************************************************************
	Latch
	************************************************************/
	//Request Latch
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_logic_req <= 1'b0;
			b_logic_data_store_ack <= 1'b0;
			b_logic_order <= 2'h0;
			b_logic_mask <= 4'h0;
			b_logic_rw <= 1'b0;
			b_logic_asid <= 14'h0;
			b_logic_mode <= 2'h0;
			b_logic_mmups <= 3'h0;
			b_logic_pdt <= {32{1'b0}};
			b_logic_addr <= {32{1'b0}};
			b_logic_data <= {32{1'b0}};
		end
		else if(iRESET_SYNC)begin
			b_logic_req <= 1'b0;
			b_logic_data_store_ack <= 1'b0;
			b_logic_order <= 2'h0;
			b_logic_mask <= 4'h0;
			b_logic_rw <= 1'b0;
			b_logic_asid <= 14'h0;
			b_logic_mode <= 2'h0;
			b_logic_mmups <= 3'h0;
			b_logic_pdt <= {32{1'b0}};
			b_logic_addr <= {32{1'b0}};
			b_logic_data <= {32{1'b0}};
		end
		else begin
			if(/*mmu_prev_req_valid_condition*/!mmu_prev_busy)begin
				b_logic_req <= iLOGIC_REQ;
				b_logic_data_store_ack <= iLOGIC_DATA_STORE_ACK;
				b_logic_order <= iLOGIC_ORDER;
				b_logic_mask <= iLOGIC_MASK;
				b_logic_rw <= iLOGIC_RW;
				b_logic_asid <= iLOGIC_ASID;
				b_logic_mode <= iLOGIC_MMUMOD;
				b_logic_mmups <= iLOGIC_MMUPS;
				b_logic_pdt <= iLOGIC_PDT;
				b_logic_addr <= iLOGIC_ADDR;
				b_logic_data <= iLOGIC_DATA;
			end
		end
	end


	/************************************************************
	State
	************************************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_state <= PL_MAIN_STT_TLB;
		end
		else if(iRESET_SYNC)begin
			b_main_state <= PL_MAIN_STT_TLB;
		end
		else begin
			case(b_main_state)
				PL_MAIN_STT_TLB:
					begin
						if(tlb_misshit_condition)begin
							b_main_state <= PL_MAIN_STT_PAGE1_REQ;
						end
					end
				PL_MAIN_STT_PAGE1_REQ:
					begin
						b_main_state <= PL_MAIN_STT_PAGE1_WAIT;
					end
				PL_MAIN_STT_PAGE1_WAIT:
					begin
						if(table_load_done_valid)begin
							if(b_logic_mode == PL_PAGING_LEVEL_2)begin
								b_main_state <= PL_MAIN_STT_PAGE2_REQ;
							end
							else begin
								b_main_state <= PL_MAIN_STT_ACCESS;
							end
						end
					end
				PL_MAIN_STT_PAGE2_REQ:
					begin
						b_main_state <= PL_MAIN_STT_PAGE2_WAIT;
					end
				PL_MAIN_STT_PAGE2_WAIT:
					begin
						if(table_load_done_valid)begin
							b_main_state <= PL_MAIN_STT_ACCESS;
						end
					end
				PL_MAIN_STT_ACCESS:
					begin
						if(!iMEMORY_LOCK)begin
							b_main_state <= PL_MAIN_STT_TLB;
						end
					end
			endcase
		end
	end


	/************************************************************
	TABLE Load
	************************************************************/
	reg [31:0] table_load_ld_addr;
	reg [31:0] b_table_load_buffer;
	reg [11:0] b_table_load_buffer_flags0;
	reg [11:0] b_table_load_buffer_flags1;

	/*
	always @* begin
		case(b_main_state)
			PL_MAIN_STT_TLB :
				begin
					if(b_logic_mode == PL_PAGING_LEVEL_1)begin
						table_load_ld_addr = b_logic_pdt + func_table_level1_index(b_logic_mmups, b_logic_addr);
					end
					else begin
						table_load_ld_addr = b_logic_pdt + func_table_level2_index1(b_logic_mmups, b_logic_addr);
					end
				end
			PL_MAIN_STT_PAGE1_REQ :
				begin
					table_load_ld_addr = func_table_get_addr(b_table_load_buffer) + func_table_level2_index2(b_logic_mmups, b_logic_addr);
				end
			PL_MAIN_STT_PAGE2_REQ :
				begin
					if(b_logic_mode == PL_PAGING_LEVEL_1)begin
						table_load_ld_addr = func_table_get_addr(b_table_load_buffer) + func_table_level1_offset(b_logic_mmups, b_logic_addr);
					end
					else begin
						table_load_ld_addr = func_table_get_addr(b_table_load_buffer) + func_table_level2_offset(b_logic_mmups, b_logic_addr);
					end
				end
			default :
				begin
					table_load_ld_addr = 32'h0;
				end
		endcase
	end
	*/


	always @* begin
		case(b_main_state)
			PL_MAIN_STT_PAGE1_REQ :
				begin
					if(b_logic_mode == PL_PAGING_LEVEL_1)begin
						table_load_ld_addr = b_logic_pdt + func_table_level1_index(b_logic_mmups, b_logic_addr);
					end
					else begin
						table_load_ld_addr = b_logic_pdt + func_table_level2_index1(b_logic_mmups, b_logic_addr);
					end
				end
			PL_MAIN_STT_PAGE2_REQ :
				begin
					//table_load_ld_addr = func_table_get_addr(b_table_load_buffer) + func_table_level2_index2(b_logic_mmups, b_logic_addr);
					//table_load_ld_addr = func_table_level2_index2_base(b_logic_mmups, b_table_load_buffer) + func_table_level2_index2(b_logic_mmups, b_logic_addr);
					table_load_ld_addr = b_table_load_buffer + func_table_level2_index2(b_logic_mmups, b_logic_addr);
				end
			default :
				begin
					table_load_ld_addr = 32'h0;
				end
		endcase
	end

	mmu_table_load TABLE_LOAD(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//Load Req
		.iLD_REQ(b_main_state == PL_MAIN_STT_PAGE1_REQ || b_main_state == PL_MAIN_STT_PAGE2_REQ),
		//.iLD_REQ((b_main_state == PL_MAIN_STT_TLB && tlb_misshit_condition) b_main_state == PL_MAIN_STT_PAGE1_REQ || b_main_state == PL_MAIN_STT_PAGE2_REQ),
		.iLD_ADDR(table_load_ld_addr),
		.oLD_BUSY(/*Not Use*/),
		//Memory Pipe - REQ
		.oMEM_REQ(table_mem_req),
		.iMEM_LOCK(iMEMORY_LOCK || res_table_wr_full),
		.oMEM_ADDR(table_mem_addr),
		//Memory Pipe - ACK
		.iMEM_VALID(iMEMORY_VALID),
		.iMEM_DATA(iMEMORY_DATA),
		//DONE
		.oDONE_VALID(table_load_done_valid),
		.oDONE_DATA(table_load_done_data),
		.oDONE_FLAG0(table_load_done_flag0),
		.oDONE_FLAG1(table_load_done_flag1)
	);

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_table_load_buffer <= 32'h0;
			b_table_load_buffer_flags0 <= 12'h0;
			b_table_load_buffer_flags1 <= 12'h0;
		end
		else if(iRESET_SYNC)begin
			b_table_load_buffer <= 32'h0;
			b_table_load_buffer_flags0 <= 12'h0;
			b_table_load_buffer_flags1 <= 12'h0;
		end
		else begin
			if(table_load_done_valid)begin
				b_table_load_buffer <= table_load_done_data;
				b_table_load_buffer_flags0 <= table_load_done_flag0;
				b_table_load_buffer_flags1 <= table_load_done_flag1;
			end
		end
	end

	/************************************************************
	Load Address
	************************************************************/
	function [31:0] func_table_level1_index;
		input [2:0] func_mode;
		input [31:0] func_addr;
		begin
			case(func_mode)
				3'b001 : func_table_level1_index = {17'h0, func_addr[31:17]};
				3'b010 : func_table_level1_index = {18'h0, func_addr[31:18]};
				3'b011 : func_table_level1_index = {19'h0, func_addr[31:19]};
				3'b100 : func_table_level1_index = {20'h0, func_addr[31:20]};
				3'b101 : func_table_level1_index = {21'h0, func_addr[31:21]};
				default : func_table_level1_index = 32'h0;
			endcase
		end
	endfunction

	function [31:0] func_table_level2_index1;
		input [2:0] func_mode;
		input [31:0] func_addr;
		begin
			case(func_mode)
				3'b001 : func_table_level2_index1 = {22'h0, func_addr[31:22]};
				3'b010 : func_table_level2_index1 = {24'h0, func_addr[31:24]};
				3'b011 : func_table_level2_index1 = {26'h0, func_addr[31:26]};
				3'b100 : func_table_level2_index1 = {28'h0, func_addr[31:28]};
				3'b101 : func_table_level2_index1 = {30'h0, func_addr[31:30]};
				default : func_table_level2_index1 = 32'h0;
			endcase
		end
	endfunction

	function [31:0] func_table_level2_index2;
		input [2:0] func_mode;
		input [31:0] func_addr;
		begin
			case(func_mode)
				3'b001 : func_table_level2_index2 = {22'h0, func_addr[21:12]};
				3'b010 : func_table_level2_index2 = {21'h0, func_addr[23:13]};
				3'b011 : func_table_level2_index2 = {20'h0, func_addr[25:14]};
				3'b100 : func_table_level2_index2 = {19'h0, func_addr[27:15]};
				3'b101 : func_table_level2_index2 = {18'h0, func_addr[29:16]};
				default : func_table_level2_index2 = 32'h0;
			endcase
		end
	endfunction

	function [31:0] func_table_level1_offset;
		input [2:0] func_mode;
		input [31:0] func_addr;
		begin
			case(func_mode)
				3'b001 : func_table_level1_offset = {20'h0, func_addr[11:0]};
				3'b010 : func_table_level1_offset = {19'h0, func_addr[12:0]};
				3'b011 : func_table_level1_offset = {18'h0, func_addr[13:0]};
				3'b100 : func_table_level1_offset = {17'h0, func_addr[14:0]};
				3'b101 : func_table_level1_offset = {16'h0, func_addr[15:0]};
				default : func_table_level1_offset = 32'h0;
			endcase
		end
	endfunction

	function [31:0] func_table_level2_offset;
		input [2:0] func_mode;
		input [31:0] func_addr;
		begin
			case(func_mode)
				3'b001 : func_table_level2_offset = {15'h0, func_addr[16:0]};
				3'b010 : func_table_level2_offset = {14'h0, func_addr[17:0]};
				3'b011 : func_table_level2_offset = {13'h0, func_addr[18:0]};
				3'b100 : func_table_level2_offset = {12'h0, func_addr[19:0]};
				3'b101 : func_table_level2_offset = {11'h0, func_addr[20:0]};
				default : func_table_level2_offset = 32'h0;
			endcase
		end
	endfunction

	/*
	function [31:0] func_table_get_addr;
		input [31:0] func_data;
		begin
			func_table_get_addr = {func_data[31:12], 12'h0};
		end
	endfunction
	*/

	function [31:0] func_table_level2_index2_base;
		input [2:0] func_mode;
		input [31:0] func_data;
		begin
			case(func_mode)
				3'b001 : func_table_level2_index2_base = {func_data[31:12], 12'h0};
				3'b001 : func_table_level2_index2_base = {func_data[31:13], 13'h0};
				3'b001 : func_table_level2_index2_base = {func_data[31:14], 14'h0};
				3'b001 : func_table_level2_index2_base = {func_data[31:15], 15'h0};
				default : func_table_level2_index2_base = 32'h0;
			endcase
		end
	endfunction

	function [11:0] func_table_get_flag;
		input [31:0] func_data;
		begin
			func_table_get_flag = func_data[11:0];
		end
	endfunction



	/************************************************************
	Memory Pipe
	************************************************************/
	reg mem_out_req;
	reg mem_out_data_store_ack;
	reg mem_out_mmu_use;
	reg [1:0] mem_out_order;
	reg [3:0] mem_out_mask;
	reg mem_out_rw;
	reg [31:0] mem_out_addr;
	reg [31:0] mem_out_data;

	assign oMEMORY_REQ = mem_out_req;
	assign oMEMORY_DATA_STORE_ACK = mem_out_data_store_ack;
	assign oMEMORY_MMU_USE = mem_out_mmu_use;
	assign oMEMORY_ORDER = mem_out_order;
	assign oMEMORY_MASK = mem_out_mask;
	assign oMEMORY_RW = mem_out_rw;
	assign oMEMORY_ADDR = mem_out_addr;
	assign oMEMORY_DATA = mem_out_data;
	//Data RAM -> This
	assign oMEMORY_LOCK = 1'b0;

	always @* begin
		case(b_logic_mode)
			PL_PAGING_LEVEL_OFF:
				begin
					mem_out_req = b_logic_req && !iMEMORY_LOCK;
					mem_out_data_store_ack = b_logic_data_store_ack;
					mem_out_mmu_use = 1'b0;
					mem_out_order = b_logic_order;
					mem_out_mask = b_logic_mask;
					mem_out_rw = b_logic_rw;
					mem_out_addr = b_logic_addr;
					mem_out_data = b_logic_data;
				end
			PL_PAGING_LEVEL_1,
			PL_PAGING_LEVEL_2:
				begin
					if(tlb_hit_condition)begin
						mem_out_req = 1'b1;
						mem_out_data_store_ack = b_logic_data_store_ack;
						mem_out_mmu_use = 1'b0;
						mem_out_order = b_logic_order;
						mem_out_mask = b_logic_mask;
						mem_out_rw = b_logic_rw;
						mem_out_addr = {tlb_rd_physical_addr[31:12], b_logic_addr[11:0]};//tlb_rd_physical_addr;
						mem_out_data = b_logic_data;
					end
					else if(b_main_state == PL_MAIN_STT_ACCESS)begin
						mem_out_req = 1'b1;
						mem_out_data_store_ack = b_logic_data_store_ack;
						mem_out_mmu_use = 1'b0;
						mem_out_order = b_logic_order;
						mem_out_mask = b_logic_mask;
						mem_out_rw = b_logic_rw;
						mem_out_addr = {b_table_load_buffer[31:12], b_logic_addr[11:0]};//32'hxxxxxxxx;//table_load_done_data //table_mem_addr;
						mem_out_data = b_logic_data;
					end
					else begin
						mem_out_req = table_mem_req && !res_table_wr_full && !iMEMORY_LOCK;
						mem_out_data_store_ack = 1'b0;
						mem_out_mmu_use = 1'b1;
						mem_out_order = 2'h2;
						mem_out_mask = 4'h0;
						mem_out_rw = 1'b0;
						mem_out_addr = table_mem_addr;
						mem_out_data = 32'h0;
					end
				end
			default:
				begin
					mem_out_req = 1'b0;
					mem_out_data_store_ack = 1'b0;
					mem_out_mmu_use = 1'b1;
					mem_out_order = 2'h2;
					mem_out_mask = 4'h0;
					mem_out_rw = 1'b0;
					mem_out_addr = 32'h0;
					mem_out_data = 32'h0;
				end
		endcase
	end

	assign oMMUFLAGS_REQ = (b_logic_mode == PL_PAGING_LEVEL_1 || b_logic_mode == PL_PAGING_LEVEL_2) && (tlb_hit_condition || b_main_state == PL_MAIN_STT_ACCESS);
	//input wire iMMUFLAGS_LOCK,
	assign oMMUFLAGS_FLAGS = (tlb_hit_condition)? tlb_rd_flags : {b_table_load_buffer_flags1, b_table_load_buffer_flags0};




	/************************************************************
	TLB Check
	************************************************************/
	wire tlb_write_condition = iMEMORY_VALID && res_table_rd_valid && res_table_rd_flag && (
		(b_main_state == PL_MAIN_STT_PAGE1_WAIT && b_logic_mode == PL_PAGING_LEVEL_1) ||
		(b_main_state == PL_MAIN_STT_PAGE2_WAIT && b_logic_mode == PL_PAGING_LEVEL_2)
	);

	mmu_tlb TLB(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Core Info
		.iREMOVE(iTLB_FLUSH || iRESET_SYNC), //context switch
		//Read
		.iRD_REQ(mmu_prev_req_valid_condition),
		.oRD_BUSY(tlb_rd_busy),
		.iRD_ASID(iLOGIC_ASID),
		.iRD_MOD(iLOGIC_MMUMOD),
		.iRD_PS(iLOGIC_MMUPS),
		.iRD_ADDR(iLOGIC_ADDR),
		.oRD_VALID(tlb_rd_valid),
		.iRD_BUSY(iMEMORY_LOCK),
		.oRD_HIT(tlb_rd_hit),
		.oRD_FLAGS(tlb_rd_flags),
		.oRD_PHYS_ADDR(tlb_rd_physical_addr),
		//Write
		.iWR_REQ(tlb_write_condition),
		.iWR_ASID(b_logic_asid),
		.iWR_MOD(b_logic_mode),
		.iWR_PS(b_logic_mmups),
		.iWR_ADDR({b_logic_addr[31:3], 3'h0}),
		//.iWR_FLAGS({iMEMORY_DATA[45:32], iMEMORY_DATA[13:0]}),
		.iWR_PHYS_ADDR(iMEMORY_DATA[63:0])
	);



	/************************************************************
	Reservation Table for non TLB access
	************************************************************/
	wire res_table_wr_condition = mem_out_req && (
		(b_main_state == PL_MAIN_STT_PAGE1_REQ) ||
		(b_main_state == PL_MAIN_STT_PAGE1_REQ)
	);

	wire res_table_rd_condition = iMEMORY_VALID && (
		(b_main_state == PL_MAIN_STT_PAGE1_WAIT) ||
		(b_main_state == PL_MAIN_STT_PAGE2_WAIT)
	);

	//Matching Bridge
	mist1032isa_arbiter_matching_queue #(16, 4, 1) MMU_RES_TABLE(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Flash
		.iFLASH(iTLB_FLUSH || iRESET_SYNC),	//context switch
		//Write
		//.iWR_REQ(mem_out_req),
		.iWR_REQ(res_table_wr_condition),
		//.iWR_FLAG(1'b0),
		.iWR_FLAG(mem_out_mmu_use),
		.oWR_FULL(res_table_wr_full),
		//Read
		.iRD_REQ(res_table_rd_condition),
		//.iRD_REQ(iMEMORY_VALID),
		.oRD_VALID(res_table_rd_valid),
		.oRD_FLAG(res_table_rd_flag),
		.oRD_EMPTY(/* Not Use */)
	);

	assign oLOGIC_LOCK = mmu_prev_busy;

endmodule

`default_nettype wire


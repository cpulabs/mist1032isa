/****************************************
	Memory Management Unit
	- MMU V1
	- 1page = 16KB
	
	
	Make	:	2011/03/@@
	Update	:	
****************************************/
`default_nettype none		
`include "global.h"



module mmu(			
		//System
		input iCLOCK,
		input inRESET,
		//TLB Flash
		input iTLB_FLASH,
		/***********************
		Logic Addres Request
		***********************/
		input iLOGIC_REQ,
		output oLOGIC_LOCK,
		input iLOGIC_DATA_STORE_ACK,
		input [1:0] iLOGIC_MODE,		//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion
		input [31:0] iLOGIC_PDT,		//Page Directory Table 
		input [1:0] iLOGIC_ORDER,
		input iLOGIC_RW,				//0=Read 1=Write
		input [31:0] iLOGIC_ADDR,
		input [31:0] iLOGIC_DATA,		
		/***********************
		MMU Flags Output
		***********************/
		output oMMUFLAGS_REQ,
		input iMMUFLAGS_LOCK,
		output [27:0] oMMUFLAGS_FLAGS,
		/***********************
		To Memory
		***********************/
		output oMEMORY_REQ,
		input iMEMORY_LOCK,			
		output oMEMORY_DATA_STORE_ACK,
		output oMEMORY_MMU_USE,
		output [1:0] oMEMORY_ORDER,
		output oMEMORY_RW,
		output [31:0] oMEMORY_ADDR,
		output [31:0] oMEMORY_DATA,
		//Data RAM -> This
		input iMEMORY_VALID,
		output oMEMORY_LOCK,
		input [63:0] iMEMORY_DATA
	);

	
	localparam MAIN_STT_CACHE = 2'h0;
	localparam MAIN_STT_1ST_MEM	= 2'h1;
	localparam MAIN_STT_2ST_MEM	= 2'h2;

	localparam SUB_STT_REQ = 1'h0;
	localparam SUB_STT_GET = 1'h1;

	
	/************************************************************
	Wire and Register
	************************************************************/
	reg physical_out_req;
	reg [63:0] physical_out_addr;
	//MMU Main State
	reg [1:0] b_main_state;
	reg [1:0] b_sub_state;
	reg [63:0] b_1l_mem_data;
	reg [63:0] b_2l_mem_data;
	reg b_writeback;
	//TLB Write Condition
	wire tlb_write_condition;
	//Memory Selector Line
	wire matching_bridge_full;
	wire matching_bridge_valid;
	//Busy Controll
	wire cache_request_busy;
	//TLB Check
	wire tlb_rd_valid;
	wire tlb_rd_hit;
	wire [27:0] tlb_rd_flags;
	wire [63:0] tlb_rd_physical_addr;
	//Input Buffer
	reg b_req;
	reg b_data_store_ack;
	reg [1:0] b_order;
	reg b_rw;
	reg [31:0] b_pdt;
	reg [1:0] b_mode;
	reg [31:0] b_logic_addr;
	reg [31:0] b_data;


	always@* begin
		case(b_mode)
			2'h0:	
				begin
					physical_out_req = b_req;
					physical_out_addr = b_logic_addr;
				end
			2'h1:
				begin
					physical_out_req = b_writeback;
					physical_out_addr = (b_logic_addr[14])? {b_1l_mem_data[63:31], b_logic_addr[13:0]} : {b_1l_mem_data[31:14], b_logic_addr[13:0]};
				end
			2'h2:	
				begin
					physical_out_req = b_writeback;
					physical_out_addr = (b_logic_addr[14])? {b_2l_mem_data[63:31], b_logic_addr[13:0]} : {b_2l_mem_data[31:14], b_logic_addr[13:0]};
				end
			default:	
				begin
					physical_out_req = b_req;
					physical_out_addr = b_logic_addr;
				end
		endcase
	end
	
	/************************************************************
	State
	************************************************************/	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_main_state		<=		MAIN_STT_CACHE;
			b_sub_state			<=		SUB_STT_REQ;
			b_writeback			<=		1'b0;
			if(`DATA_RESET_ENABLE)begin
				b_1l_mem_data		<=		{64{1'b0}};
				b_2l_mem_data		<=		{64{1'b0}};
			end
		end
		else begin
			case(b_main_state)
				MAIN_STT_CACHE:
					begin
						b_writeback			<=		1'b0;
						if(tlb_rd_valid && !tlb_rd_hit && b_mode != 2'h0)begin
							b_main_state		<=		MAIN_STT_1ST_MEM;
						end
					end
				MAIN_STT_1ST_MEM:
					begin
						if(b_sub_state == SUB_STT_REQ)begin	
							if(!iMEMORY_LOCK)begin
								b_sub_state			<=		SUB_STT_GET;
							end
						end
						else begin
							if(iMEMORY_VALID && !iMEMORY_LOCK)begin
								if(b_mode == 2'h1)begin
									b_main_state		<=		MAIN_STT_CACHE;
									b_sub_state			<=		SUB_STT_REQ;
									b_1l_mem_data		<=		iMEMORY_DATA;
									b_writeback			<=		1'b1;
								end
								else begin
									b_main_state		<=		MAIN_STT_2ST_MEM;
									b_sub_state			<=		SUB_STT_REQ;
									b_1l_mem_data		<=		iMEMORY_DATA;
								end
							end
						end
					end
				MAIN_STT_2ST_MEM:
					begin
						if(b_sub_state == SUB_STT_REQ)begin	
							if(!iMEMORY_LOCK)begin
								b_sub_state			<=		SUB_STT_GET;
							end
						end
						else begin
							if(iMEMORY_VALID && !iMEMORY_LOCK)begin
								b_sub_state			<=		SUB_STT_REQ;
								b_main_state		<=		MAIN_STT_CACHE;
								b_2l_mem_data		<=		iMEMORY_DATA;
								b_writeback			<=		1'b1;
							end
						end
					end
				default:	
					begin
						b_main_state		<=		MAIN_STT_CACHE;
						$display("[ERRPR] : mmu.v b_main_state Errpr");
					end
			endcase
		end
	end //always State
	
	assign		tlb_write_condition		=	iMEMORY_VALID && (b_mode == 2'h1 && b_main_state == MAIN_STT_1ST_MEM && b_sub_state == SUB_STT_GET) || (b_mode == 2'h2 && b_main_state == MAIN_STT_2ST_MEM && b_sub_state == SUB_STT_GET);	
	
	
	/************************************************************
	Matching Bridge
	************************************************************/	
	//Matching Bridge 
	arbiter_matching_bridge #(16, 4) MMU_MATCHING_BRIDGE(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Flash
		.iFLASH(iTLB_FLASH),
		//Write
		.iWR_REQ(tlb_rd_valid && !tlb_rd_hit && b_mode != 2'h0),
		.iWR_TYPE(1'b0),
		.oWR_FULL(matching_bridge_full),
		//Read
		.iRD_REQ(tlb_write_condition),
		.oRD_VALID(matching_bridge_valid),
		.oRD_TYPE(/* Not Use */),
		.oRD_EMPTY(/* Not Use */)
	);
	
	
	/************************************************************
	Busy Controll
	************************************************************/
	assign		cache_request_busy		=		(tlb_rd_valid && !tlb_rd_hit && b_mode != 2'h0) || b_main_state != MAIN_STT_CACHE;
	
	
	
	/************************************************************
	TLB Check
	************************************************************/	
	tlb #(/*LRU Timing N*/10) TLB(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Core Info
		.iREMOVE(iTLB_FLASH/* Context Switch */),			
		//Read
		.iRD_REQ(iLOGIC_REQ && !cache_request_busy),
		.iRD_ADDR(iLOGIC_ADDR),	
		.oRD_VALID(tlb_rd_valid),
		.oRD_HIT(tlb_rd_hit),
		.oRD_FLAGS(tlb_rd_flags),
		.oRD_PHYS_ADDR(tlb_rd_physical_addr),
		//Write
		.iWR_REQ(tlb_write_condition && matching_bridge_valid),
		.iWR_ADDR(b_pdt),
		.iWR_FLAGS({iMEMORY_DATA[45:32], iMEMORY_DATA[13:0]}),
		.iWR_PHYS_ADDR(iMEMORY_DATA[63:0])	
	);
	
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_req <= 1'b0;
			b_data_store_ack <= 1'b0;
			b_order <= 32'h0;
			b_rw <= 1'b0;
			b_mode <= 2'h0;
			b_pdt <= {32{1'b0}};
			b_logic_addr <= {32{1'b0}};
			b_data <= {32{1'b0}};
		end
		else begin
			if(!cache_request_busy && !iMEMORY_LOCK)begin
				b_req <= iLOGIC_REQ;
				b_data_store_ack <= iLOGIC_DATA_STORE_ACK;
				b_order <= iLOGIC_ORDER;
				b_rw <= iLOGIC_RW;
				b_mode <= iLOGIC_MODE;
				b_pdt <= iLOGIC_PDT;
				b_logic_addr <= iLOGIC_ADDR;
				b_data <= iLOGIC_DATA;
			end
		end
	end
	
	/*************************************************************
	Assign
	*************************************************************/
	assign oMEMORY_LOCK = 1'b0;

	assign oLOGIC_LOCK = iMEMORY_LOCK || iMMUFLAGS_LOCK || (b_main_state != MAIN_STT_CACHE)? 1'b1 : tlb_rd_valid && !tlb_rd_hit && b_mode != 2'h0;

	assign oMMUFLAGS_REQ = (b_mode == 2'h0)? 1'b0 : (b_main_state == MAIN_STT_1ST_MEM && b_sub_state == SUB_STT_REQ) || (b_main_state == MAIN_STT_2ST_MEM && b_sub_state == SUB_STT_REQ) && !physical_out_req;
	assign oMMUFLAGS_FLAGS = (tlb_rd_hit && tlb_rd_valid)? tlb_rd_flags : {b_2l_mem_data[45:32], b_2l_mem_data[13:0]};
	
	assign oMEMORY_REQ = physical_out_req || (b_main_state == MAIN_STT_1ST_MEM && b_sub_state == SUB_STT_REQ) || (b_main_state == MAIN_STT_2ST_MEM && b_sub_state == SUB_STT_REQ) || (tlb_rd_valid && !tlb_rd_hit && b_mode != 2'h0);
	assign oMEMORY_DATA_STORE_ACK = b_data_store_ack;
	assign oMEMORY_MMU_USE = (b_mode == 2'h0)? 1'b0 : 1'b1;
	assign oMEMORY_ORDER = b_order;
	assign oMEMORY_RW = b_rw;
	assign oMEMORY_DATA = b_data;
	
	reg [31:0] memory_addr;
	always @* begin
		if(tlb_rd_valid && !tlb_rd_hit && b_mode != 2'h0)begin
			memory_addr = (b_logic_addr[14])? tlb_rd_physical_addr[63:32] + b_logic_addr[13:0] : tlb_rd_physical_addr[31:0] + b_logic_addr[13:0];
		end
		else if(physical_out_req) begin
			memory_addr = physical_out_addr;
		end
		else begin
			memory_addr = (b_main_state == MAIN_STT_1ST_MEM)? b_pdt + b_logic_addr[13:0] : b_1l_mem_data + b_logic_addr[13:0];
		end
	end	
	assign oMEMORY_ADDR = memory_addr;
	
endmodule

`default_nettype wire


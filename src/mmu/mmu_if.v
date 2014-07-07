
`default_nettype none
`include "common.h"


module mmu_if(
		input wire iCLOCK,
		input wire inRESET,
		input wire iFREE_TLB_FLUSH,
		/*************************
		To Core
		*************************/
		//Core -> This
		input wire iCORE_REQ,
		output wire oCORE_LOCK,
		input wire iCORE_DATA_STORE_ACK,
		input wire [1:0] iCORE_MMUMOD,		//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion
		input wire [2:0] iCORE_MMUPS,
		input wire [31:0] iCORE_PDT,		//Page Table Register
		input wire [13:0] iCORE_TID,		///
		input wire [1:0] iCORE_ORDER,
		input wire [3:0] iCORE_MASK,
		input wire iCORE_RW,
		input wire [31:0] iCORE_ADDR,
		input wire [31:0] iCORE_DATA,
		//This -> Core
		output wire oCORE_REQ,
		input wire iCORE_LOCK,
		output wire oCORE_STORE_ACK,
		output wire [63:0] oCORE_DATA,
		output wire [23:0] oCORE_MMU_FLAGS,
		/************************
		To Memory
		************************/
		//This -> Memory
		output wire oMEMORY_REQ,
		input wire iMEMORY_LOCK,
		output wire [1:0] oMEMORY_ORDER,
		output wire [3:0] oMEMORY_MASK,
		output wire oMEMORY_RW,
		output wire [31:0] oMEMORY_ADDR,
		output wire [31:0] oMEMORY_DATA,
		//Memory -> This
		input wire iMEMORY_REQ,
		output wire oMEMORY_LOCK,
		input wire [63:0] iMEMORY_DATA
	);

	localparam L_PARAM_STT_PFAULT_IDLE = 2'h0;
	localparam L_PARAM_STT_PFAULT_QUEUEWAIT = 2'h1;
	localparam L_PARAM_STT_PFAULT_TOCORE = 2'h2;

	/********************************************************************************
	Wire and Register
	********************************************************************************/
	//MMU <-> Memory
	wire mmu2memory_req;
	wire mmu2memory_lock;
	wire mmu2memory_data_store_ack;
	wire mmu2memory_rw;
	//MMU <-> Matching
	wire matching2mmu_full;
	wire mmu2matching_type;
	wire matching2coreout_type;
	wire matching2mmu_empty;
	//MMU Flags
	wire mmu2mmufifo_req;
	wire mmufifo2mmu_lock;
	wire [23:0] mmu2mmufifo_flags;
	wire [23:0] mmufifo2coreout_flags;
	//Core Output Latch
	reg b_coreout_req;
	reg [63:0] b_coreout_data;
	reg [23:0] b_coreout_mmu_flags;


	//Condition
	wire mmu2core_data_write_ack_condition = mmu2memory_req && mmu2memory_data_store_ack && !iMEMORY_LOCK;
	wire mmu2memory_req_condition = mmu2memory_req && !iMEMORY_LOCK && !matching2mmu_full && !mmufifo2mmu_lock;

	wire memory2mmu_lock_condition = iMEMORY_LOCK || matching2mmu_full || mmufifo2mmu_lock;

	/********************************************************************************
	Memory Management Unit
		Dorect, 1level, 2level Address Convertion
	********************************************************************************/
	//MMU
	mmu MMU(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(1'b0),
		//TLB Flash
		.iTLB_FLUSH(iFREE_TLB_FLUSH),
		/***********************
		Logic Addres Request
		***********************/
		.iLOGIC_REQ(iCORE_REQ),
		.oLOGIC_LOCK(oCORE_LOCK),
		.iLOGIC_DATA_STORE_ACK(iCORE_DATA_STORE_ACK),
		.iLOGIC_MMUMOD(iCORE_MMUMOD),					//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion
		.iLOGIC_MMUPS(iCORE_MMUPS),
		.iLOGIC_PDT(iCORE_PDT),							//Page Directory Table
		.iLOGIC_TID(iCORE_TID),						//Task ID
		.iLOGIC_ORDER(iCORE_ORDER),
		.iLOGIC_MASK(iCORE_MASK),
		.iLOGIC_RW(iCORE_RW),							//0=Read 1=Write
		.iLOGIC_ADDR(iCORE_ADDR),
		.iLOGIC_DATA(iCORE_DATA),
		/***********************
		MMU Flags Output
		***********************/
		.oMMUFLAGS_REQ(mmu2mmufifo_req),
		.iMMUFLAGS_LOCK(mmufifo2mmu_lock),
		.oMMUFLAGS_FLAGS(mmu2mmufifo_flags),
		/***********************
		To Memory
		***********************/
		//MMU -> Memory
		.oMEMORY_REQ(mmu2memory_req),
		.iMEMORY_LOCK(memory2mmu_lock_condition),
		.oMEMORY_DATA_STORE_ACK(mmu2memory_data_store_ack),
		.oMEMORY_MMU_USE(mmu2matching_type),
		.oMEMORY_ORDER(oMEMORY_ORDER),
		.oMEMORY_MASK(oMEMORY_MASK),
		.oMEMORY_RW(mmu2memory_rw),
		.oMEMORY_ADDR(oMEMORY_ADDR),
		.oMEMORY_DATA(oMEMORY_DATA),
		//Memory -> MMU
		.iMEMORY_VALID(iMEMORY_REQ && matching2coreout_type && !iCORE_LOCK && !mmu2memory_lock && !mmu2core_data_write_ack_condition),
		.oMEMORY_LOCK(mmu2memory_lock),
		.iMEMORY_DATA(iMEMORY_DATA)
	);


	/********************************************************************************
	Memory Matching Queue
		Memory access type queue.
			Type	0	:	Core Use
					1	:	MMU Use
	********************************************************************************/
	mist1032isa_arbiter_matching_queue #(16, 4, 1) MEM_MATCHING_QUEUE(	//Queue deep : 16, Queue deep_n : 4, Flag_n : 2
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Flash
		.iFLASH(1'b0),
		//Write
		.iWR_REQ(mmu2memory_req_condition && !mmu2memory_data_store_ack),
		.iWR_FLAG(mmu2matching_type),
		.oWR_FULL(matching2mmu_full),
		//Read
		.iRD_REQ(iMEMORY_REQ && !iCORE_LOCK && !mmu2memory_lock && !mmu2core_data_write_ack_condition),
		.oRD_VALID(),
		.oRD_FLAG(matching2coreout_type),
		.oRD_EMPTY(matching2mmu_empty)
	);


	/********************************************************************************
	MMU Flags Queue
	********************************************************************************/
	`ifdef MIST1032ISA_ALTERA_PRIMITIVE
		//FIFO Mode				: Show Ahead Synchronous FIFO Mode
		//Width					: 24bit
		//Depth					: 16Word
		//Asynchronous Reset	: Use
		//Synchronous Reset		: Use
		//Usedw					: Use
		//Full					: Use
		//Empty					: Use
		//Almost Full			: Use(Value=14)
		//Almost Empty			: Use(Value=2)
		//Overflow Checking		: Disable
		//Undesflow Checking	: Disable
		altera_primitive_sync_fifo_24in_24out_16depth MMUFLAGS_QUEUE(
			.aclr(!inRESET),				//Asynchronous Reset
			.clock(iCLOCK),				//Clock
			.data(mmu2mmufifo_flags),				//Data-In
			.rdreq(iMEMORY_REQ && matching2coreout_type && !iCORE_LOCK && !mmu2memory_lock && !mmu2core_data_write_ack_condition),				//Read Data Request
			.sclr(1'b0),				//Synchthronous Reset
			.wrreq(mmu2mmufifo_req && !memory2mmu_lock_condition),				//Write Req
			.almost_empty(),
			.almost_full(),
			.empty(),
			.full(mmufifo2mmu_lock),
			.q(mmufifo2coreout_flags),					//Dataout
			.usedw()
		);
	`elsif MIST1032ISA_XILINX_PRIMITIVE

	`else
		mist1032isa_sync_fifo #(24, 16, 4) MMUFLAGS_QUEUE(
			.iCLOCK(iCLOCK),
			.inRESET(inRESET),
			.iREMOVE(1'b0),
			.oCOUNT(),
			.iWR_EN(mmu2mmufifo_req && !memory2mmu_lock_condition),
			.iWR_DATA(mmu2mmufifo_flags),
			.oWR_FULL(mmufifo2mmu_lock),
			.iRD_EN(iMEMORY_REQ && matching2coreout_type && !iCORE_LOCK && !mmu2memory_lock && !mmu2core_data_write_ack_condition),
			.oRD_DATA(mmufifo2coreout_flags),
			.oRD_EMPTY()
		);
	`endif


	/********************************************************************************
	Core Output Latch
	********************************************************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_coreout_req <= 1'b0;
			b_coreout_data <= {64{1'b0}};
			b_coreout_mmu_flags <= {24{1'b0}};
		end
		else begin
			if(!iCORE_LOCK && !mmu2memory_lock && !mmu2core_data_write_ack_condition)begin
				b_coreout_req <= iMEMORY_REQ && !matching2coreout_type;
				b_coreout_data <= iMEMORY_DATA;
				b_coreout_mmu_flags <= mmufifo2coreout_flags;
			end
		end
	end


	/********************************************************************************
	Assign
	********************************************************************************/
	assign oCORE_REQ = b_coreout_req || mmu2core_data_write_ack_condition;
	assign oCORE_STORE_ACK = mmu2core_data_write_ack_condition;
	assign oCORE_DATA = b_coreout_data;
	assign oCORE_MMU_FLAGS = b_coreout_mmu_flags;

	assign oMEMORY_REQ = mmu2memory_req_condition;
	assign oMEMORY_RW = mmu2memory_rw;

	assign oMEMORY_LOCK = iCORE_LOCK || mmu2memory_lock || mmu2core_data_write_ack_condition;

endmodule

`default_nettype wire


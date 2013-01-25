
`default_nettype none


module mmu_if(
		input iCLOCK,
		input inRESET,
		/*************************
		To Core
		*************************/
		//Core -> This
		input iCORE_REQ,
		output oCORE_LOCK,
		input iCORE_DATA_STORE_ACK,
		input [1:0] iCORE_MMU_MODE,		//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion
		input [31:0] iCORE_PDT,			//Page Table Register
		input [1:0] iCORE_ORDER,
		input iCORE_RW,
		input [31:0] iCORE_ADDR,
		input [31:0] iCORE_DATA,
		//This -> Core
		output oCORE_REQ,
		input iCORE_LOCK,
		output oCORE_STORE_ACK,
		output oCORE_PAGE_FAULT,	
		output oCORE_QUEUE_FLUSH,	
		output [63:0] oCORE_DATA,
		output [27:0] oCORE_MMU_FLAGS,
		/************************
		To Memory
		************************/
		//This -> Memory
		output oMEMORY_REQ,
		input iMEMORY_LOCK,
		output [1:0] oMEMORY_ORDER,
		output oMEMORY_RW,
		output [31:0] oMEMORY_ADDR,
		output [31:0] oMEMORY_DATA,
		//Memory -> This
		input iMEMORY_REQ,
		output oMEMORY_LOCK,
		input [63:0] iMEMORY_DATA
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
	wire [27:0] mmu2mmufifo_flags;
	wire [27:0] mmufifo2coreout_flags;
	//Page Fault
	wire mmu2core_pagefault;
	reg [1:0] b_pagefault_state;
	//Core Output Latch
	reg b_coreout_req;
	reg [63:0] b_coreout_data;
	reg [27:0] b_coreout_mmu_flags;


	//Condition
	wire mmu2core_data_write_ack_condition = mmu2memory_req && mmu2memory_data_store_ack && !iMEMORY_LOCK;
	wire mmu2memory_req_condition = mmu2memory_req && !iMEMORY_LOCK && !matching2mmu_full && !mmufifo2mmu_lock;
	
	wire memory2mmu_lock_condition = iMEMORY_LOCK || matching2mmu_full || mmufifo2mmu_lock || (b_pagefault_state == L_PARAM_STT_PFAULT_QUEUEWAIT);
	
	/********************************************************************************
	Memory Management Unit
		Dorect, 1level, 2level Address Convertion
	********************************************************************************/
	//MMU
	mmu mmu(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//TLB Flash
		.iTLB_FLASH(1'b0),
		/***********************
		Logic Addres Request
		***********************/
		.iLOGIC_REQ(iCORE_REQ),
		.oLOGIC_LOCK(oCORE_LOCK),
		.iLOGIC_DATA_STORE_ACK(iCORE_DATA_STORE_ACK),
		.iLOGIC_MODE(iCORE_MMU_MODE),					//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion
		.iLOGIC_PDT(iCORE_PDT),							//Page Directory Table 
		.iLOGIC_ORDER(iCORE_ORDER),
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
		Page Fault
		***********************/
		.oPAGEFAULT_VALID(mmu2core_pagefault),
		/***********************
		To Memory
		***********************/
		//MMU -> Memory
		.oMEMORY_REQ(mmu2memory_req),
		.iMEMORY_LOCK(memory2mmu_lock_condition),
		.oMEMORY_DATA_STORE_ACK(mmu2memory_data_store_ack),
		.oMEMORY_MMU_USE(mmu2matching_type),
		.oMEMORY_ORDER(oMEMORY_ORDER),
		.oMEMORY_RW(mmu2memory_rw),
		.oMEMORY_ADDR(oMEMORY_ADDR),
		.oMEMORY_DATA(oMEMORY_DATA),
		//Memory -> MMU
		.iMEMORY_VALID(iMEMORY_REQ && matching2coreout_type && !iCORE_LOCK && !mmu2memory_lock && !mmu2core_data_write_ack_condition),
		.oMEMORY_LOCK(mmu2memory_lock),
		.iMEMORY_DATA(iMEMORY_DATA)
	);
	
	/********************************************************************************
	Page Fault
	********************************************************************************/
	wire pagefault_condition = (b_pagefault_state == L_PARAM_STT_PFAULT_TOCORE);
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_pagefault_state <= L_PARAM_STT_PFAULT_IDLE;
		end
		else begin
			case(b_pagefault_state)
				L_PARAM_STT_PFAULT_IDLE:
					begin
						if(mmu2core_pagefault)begin
							b_pagefault_state <= L_PARAM_STT_PFAULT_QUEUEWAIT;
						end
					end
				L_PARAM_STT_PFAULT_QUEUEWAIT:
					begin
						if(matching2mmu_empty)begin
							b_pagefault_state <= L_PARAM_STT_PFAULT_TOCORE;
						end
					end
				L_PARAM_STT_PFAULT_TOCORE:
					begin
						if(!iCORE_LOCK)begin
							b_pagefault_state <= L_PARAM_STT_PFAULT_IDLE;
						end
					end
			endcase
		end
	end


	/********************************************************************************
	Memory Matching Queue
		Memory access type queue.
			Type	0	:	Core Use
					1	:	MMU Use
	********************************************************************************/
	arbiter_matching_queue #(16, 4, 1) MEM_MATCHING_QUEUE(	//Queue deep : 16, Queue deep_n : 4, Flag_n : 2
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Flash
		.iFLASH(pagefault_condition),
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
	sync_fifo #(28, 16, 4) MMUFLAGS_QUEUE(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iREMOVE(pagefault_condition), 
		.oCOUNT(), 	
		.iWR_EN(mmu2mmufifo_req && !memory2mmu_lock_condition), 
		.iWR_DATA(mmu2mmufifo_flags), 
		.oWR_FULL(mmufifo2mmu_lock),
		.iRD_EN(iMEMORY_REQ && matching2coreout_type && !iCORE_LOCK && !mmu2memory_lock && !mmu2core_data_write_ack_condition), 
		.oRD_DATA(mmufifo2coreout_flags), 
		.oRD_EMPTY()
	);
	
	/********************************************************************************
	Core Output Latch
	********************************************************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_coreout_req <= 1'b0;
			b_coreout_data <= {64{1'b0}};
			b_coreout_mmu_flags <= {28{1'b0}};
		end
		//Page Fault
		if(pagefault_condition)begin
			b_coreout_req <= 1'b0;
			b_coreout_data <= {64{1'b0}};
			b_coreout_mmu_flags <= {28{1'b0}};
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
	assign oCORE_REQ = b_coreout_req || mmu2core_data_write_ack_condition || pagefault_condition;
	assign oCORE_STORE_ACK = mmu2core_data_write_ack_condition;
	assign oCORE_PAGE_FAULT = pagefault_condition;
	assign oCORE_QUEUE_FLUSH = pagefault_condition;
	assign oCORE_DATA = b_coreout_data;
	assign oCORE_MMU_FLAGS = b_coreout_mmu_flags;
	
	assign oMEMORY_REQ = mmu2memory_req_condition;
	assign oMEMORY_RW = mmu2memory_rw;
	
	assign oMEMORY_LOCK = iCORE_LOCK || mmu2memory_lock || mmu2core_data_write_ack_condition;
	
endmodule

`default_nettype wire


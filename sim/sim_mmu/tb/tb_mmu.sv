
`default_nettype none
module tb_mmu;
	//System
	reg iCLOCK;
	reg inRESET;
	reg iRESET_SYNC;
	//TLB Flash
	reg iTLB_FLUSH;
	/***********************
	Logic Addres Request
	***********************/
	reg iLOGIC_REQ;
	wire oLOGIC_LOCK;
	reg iLOGIC_DATA_STORE_ACK;
	reg [1:0] iLOGIC_MMUMOD;		//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion		<New Name>
	reg [2:0] iLOGIC_MMUPS;		//MMU Page Size														<New Port>
	reg [31:0] iLOGIC_PDT;		//Page Directory Table
	reg [13:0] iLOGIC_TID;
	reg [1:0] iLOGIC_ORDER;
	reg [3:0] iLOGIC_MASK;
	reg iLOGIC_RW;				//0=Read 1=Write
	reg [31:0] iLOGIC_ADDR;
	reg [31:0] iLOGIC_DATA;
	/***********************
	MMU Flags Output
	***********************/
	wire oMMUFLAGS_REQ;
	reg iMMUFLAGS_LOCK;
	wire [27:0] oMMUFLAGS_FLAGS;
	/***********************
	To Memory
	***********************/
	wire oMEMORY_REQ;
	wire iMEMORY_LOCK;
	wire oMEMORY_DATA_STORE_ACK;
	wire oMEMORY_MMU_USE;
	wire [1:0] oMEMORY_ORDER;
	wire [3:0] oMEMORY_MASK;
	wire oMEMORY_RW;
	wire [31:0] oMEMORY_ADDR;
	wire [31:0] oMEMORY_DATA;
	//Data RAM -> This
	wire iMEMORY_VALID;
	wire oMEMORY_LOCK;
	wire [63:0] iMEMORY_DATA;


	/************************************************************
	Parameter
	************************************************************/
	localparam PL_CYCLE = 20;

	localparam PL_PAGING_LEVEL_OFF = 2'h0;
	localparam PL_PAGING_LEVEL_1 = 2'h1;
	localparam PL_PAGING_LEVEL_2 = 2'h2;

	localparam PL_PAGING_OFF = 3'h0;
	localparam PL_PAGING_LEVEL2_PAGESIZE_4K = 3'h1;
	localparam PL_PAGING_LEVEL2_PAGESIZE_8K = 3'h2;
	localparam PL_PAGING_LEVEL2_PAGESIZE_16K = 3'h3;
	localparam PL_PAGING_LEVEL2_PAGESIZE_32K = 3'h4;
	localparam PL_PAGING_LEVEL2_PAGESIZE_64K = 3'h5;

	localparam PL_PAGING_LEVEL1_PAGESIZE_128K = 3'h1;
	localparam PL_PAGING_LEVEL1_PAGESIZE_256K = 3'h2;
	localparam PL_PAGING_LEVEL1_PAGESIZE_512K = 3'h3;
	localparam PL_PAGING_LEVEL1_PAGESIZE_1024K = 3'h4;
	localparam PL_PAGING_LEVEL1_PAGESIZE_2048K = 3'h5;


	mmu TARGET(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//TLB Flash
		.iTLB_FLUSH(iTLB_FLUSH),
		/***********************
		Logic Addres Request
		***********************/
		.iLOGIC_REQ(iLOGIC_REQ),
		.oLOGIC_LOCK(oLOGIC_LOCK),
		.iLOGIC_DATA_STORE_ACK(iLOGIC_DATA_STORE_ACK),
		.iLOGIC_MMUMOD(iLOGIC_MMUMOD),		//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion		<New Name>
		.iLOGIC_MMUPS(iLOGIC_MMUPS),		//MMU Page Size														<New Port>
		.iLOGIC_PDT(iLOGIC_PDT),		//Page Directory Table
		.iLOGIC_TID(iLOGIC_TID),
		.iLOGIC_ORDER(iLOGIC_ORDER),
		.iLOGIC_MASK(iLOGIC_MASK),
		.iLOGIC_RW(iLOGIC_RW),				//0=Read 1=Write
		.iLOGIC_ADDR(iLOGIC_ADDR),
		.iLOGIC_DATA(iLOGIC_DATA),
		/***********************
		MMU Flags Output
		***********************/
		.oMMUFLAGS_REQ(oMMUFLAGS_REQ),
		.iMMUFLAGS_LOCK(iMMUFLAGS_LOCK),
		.oMMUFLAGS_FLAGS(oMMUFLAGS_FLAGS),
		/***********************
		To Memory
		***********************/
		.oMEMORY_REQ(oMEMORY_REQ),
		.iMEMORY_LOCK(iMEMORY_LOCK),
		.oMEMORY_DATA_STORE_ACK(oMEMORY_DATA_STORE_ACK),
		.oMEMORY_MMU_USE(oMEMORY_MMU_USE),
		.oMEMORY_ORDER(oMEMORY_ORDER),
		.oMEMORY_MASK(oMEMORY_MASK),
		.oMEMORY_RW(oMEMORY_RW),
		.oMEMORY_ADDR(oMEMORY_ADDR),
		.oMEMORY_DATA(oMEMORY_DATA),
		//Data RAM -> This
		.iMEMORY_VALID(iMEMORY_VALID),
		.oMEMORY_LOCK(oMEMORY_LOCK),
		.iMEMORY_DATA(func_endian_convert(iMEMORY_DATA))
	);

	//Sim Memory
	sim_memory_model #(11, "", 134217728/8, 2, 2) MEMORY(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//Req
		.iMEMORY_REQ(oMEMORY_REQ),
		.oMEMORY_LOCK(iMEMORY_LOCK),
		.iMEMORY_ORDER(oMEMORY_ORDER),				//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.iMEMORY_MASK(oMEMORY_MASK),
		.iMEMORY_RW(oMEMORY_RW),						//1:Write | 0:Read
		.iMEMORY_ADDR(oMEMORY_ADDR),
		//This -> Data RAM
		.iMEMORY_DATA(oMEMORY_DATA),
		//Data RAM -> This
		.oMEMORY_VALID(iMEMORY_VALID),
		.iMEMORY_LOCK(oMEMORY_LOCK),
		.oMEMORY_DATA(iMEMORY_DATA)
	);

	function [63:0] func_endian_convert;
		input [63:0] func_data;
		reg [31:0] func_tmp;
		begin
			func_tmp = func_data[63:32];
			func_endian_convert = {
				func_tmp[7:0], func_tmp[15:8], func_tmp[23:16], func_tmp[31:24],
				func_data[7:0], func_data[15:8], func_data[23:16], func_data[31:24]
			};
		end
	endfunction

	always#(PL_CYCLE/2)begin
		iCLOCK = !iCLOCK;
	end

	/*
	reg [63:0] main_ram [0:1023];
	longint i;
	initial begin
		#0 begin
			for(i = 0; i < 1024; i = i + 1)begin
				main_ram[i] = i;//{i[31:0], i[31:0]};
			end
		end
	end

	reg b_load_req;
	reg [63:0] b_load_buffer;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_load_req <= 1'h0;
			b_load_buffer <= 64'h0;
		end
	end
	*/

	initial begin
		#0 begin
			iCLOCK = 1'b0;
			inRESET = 1'b0;
			iRESET_SYNC = 1'b0;
			iTLB_FLUSH = 1'b0;
			iLOGIC_MMUMOD = PL_PAGING_LEVEL_OFF;		//Convertion Level
			iLOGIC_MMUPS = 3'h0;
			iLOGIC_PDT = 32'h100;
			iLOGIC_TID = {14{1'b0}};
			iLOGIC_REQ = 1'b0;
			iLOGIC_RW = 1'b0;
			iLOGIC_ADDR = {32{1'b0}};
		end
		#1 begin
			inRESET = 1'b1;
		end
	end

	reg [31:0] load_req_fifo_addr[$];
	reg load_req_fifo_type[$];
	always_ff@(posedge iCLOCK)begin
		if(inRESET && oMEMORY_REQ && !iMEMORY_LOCK)begin
			load_req_fifo_addr.push_back(oMEMORY_ADDR);
			load_req_fifo_type.push_back(oMEMORY_MMU_USE);
		end
	end

	task task_req_read_access_test;
		input [1:0] task_mod;
		input [2:0] task_psize;
		input [31:0] task_addr;
		input [31:0] task_expect;
		reg [31:0] result_addr;
		reg result_flag;
		begin
			//Initial
			result_flag = 0;
			//Request
			iLOGIC_REQ = 1'b1;
			iLOGIC_ADDR = task_addr;
			iLOGIC_MMUPS = task_psize;
			iLOGIC_MMUMOD = task_mod;
			while(oLOGIC_LOCK)begin
				#(PL_CYCLE);
			end
			#(PL_CYCLE);
			iLOGIC_REQ = 1'b0;
			#(PL_CYCLE);
			//Recive
			while(!result_flag)begin
				if(iMEMORY_VALID)begin
					result_addr = load_req_fifo_addr.pop_front();
					result_flag = !(load_req_fifo_type.pop_front());
				end
				#(PL_CYCLE);
			end
			//Compare
			if(task_expect != result_addr)begin
				$display("[ERR][tb_mmu.sv]Expect[%x], Result[%x]", task_expect, result_addr);
				$finish;
			end
		end
	endtask

	task task_set_pdtr;
		input [31:0] task_pdtr;
		begin
			iLOGIC_PDT = task_pdtr;
			#(PL_CYCLE);
		end
	endtask

	task task_inc_tid;
		begin
			iLOGIC_TID = iLOGIC_TID + 1;
		end
	endtask




	initial begin
		/*
		//Read LogicAddr:0x0
		#(PL_CYCLE+1) begin
			iLOGIC_REQ = 1'b1;
			iLOGIC_ADDR = {32{1'b0}};
			iLOGIC_MMUMOD = PL_PAGING_LEVEL_OFF;
			//STOP
			#(PL_CYCLE);
			iLOGIC_REQ = 1'b0;
			iLOGIC_MMUMOD = PL_PAGING_LEVEL_OFF;
		end
		//Read LogicAddr:0x8
		#(PL_CYCLE) begin
			iLOGIC_REQ = 1'b1;
			iLOGIC_ADDR = 32'h00000008;
			iLOGIC_MMUMOD = PL_PAGING_LEVEL_OFF;
			#(PL_CYCLE);
			iLOGIC_REQ = 1'b1;
			iLOGIC_ADDR = 32'h00000008;
			iLOGIC_MMUMOD = PL_PAGING_LEVEL_OFF;
		end
		*/

		#(PL_CYCLE*10+1);
		/***************************************************************************************************************
		No Paging
		***************************************************************************************************************/
		#(PL_CYCLE*10);
		task_inc_tid();			//TID Change
		task_set_pdtr(0);												//1page
		task_req_read_access_test(PL_PAGING_LEVEL_OFF, PL_PAGING_OFF, 32'h0, 32'h0);		//Index1=1, Index2=1, Offset=0 / (PDTR=4097) -> (4096) -> 4096 + 3 = 4099
		task_req_read_access_test(PL_PAGING_LEVEL_OFF, PL_PAGING_OFF, 32'h4, 32'h4);
		task_req_read_access_test(PL_PAGING_LEVEL_OFF, PL_PAGING_OFF, 32'h8, 32'h8);
		task_req_read_access_test(PL_PAGING_LEVEL_OFF, PL_PAGING_OFF, 32'h10, 32'h10);
		$display("[INF]Non-Paging Check OK");


		/***************************************************************************************************************
		1-Level Check
		***************************************************************************************************************/
		//----------------------------------------------------128KB----------------------------------------------------
		#(PL_CYCLE*10+1);
		task_inc_tid();			//TID Change
		task_set_pdtr(128*1024);												//1page
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_128K, {15'h80, 17'h0}, 32'h0004_0000);		//Index1=1, Index2=1, Offset=0 / (PDTR=4097) -> (4096) -> 4096 + 3 = 4099
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_128K, {15'h80, 17'h4}, 32'h0004_0004);
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_128K, {15'h80, 17'h8}, 32'h0004_0008);
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_128K, {15'h80, 17'hf}, 32'h0004_000f);
		$display("[INF]1-Level 128KB Check OK");

		//----------------------------------------------------256KB----------------------------------------------------
		#(PL_CYCLE*10+1);
		task_inc_tid();			//TID Change
		task_set_pdtr(256*1024);												//1page
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_256K, {14'h100, 18'h0}, 32'h0008_0000);		//Index1=1, Index2=1, Offset=0 / (PDTR=4097) -> (4096) -> 4096 + 3 = 4099
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_256K, {14'h100, 18'h4}, 32'h0008_0004);
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_256K, {14'h100, 18'h8}, 32'h0008_0008);
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_256K, {14'h100, 18'hf}, 32'h0008_000f);
		$display("[INF]1-Level 256KB Check OK");

		//----------------------------------------------------512KB----------------------------------------------------
		#(PL_CYCLE*10+1);
		task_inc_tid();			//TID Change
		task_set_pdtr(512*1024);												//1page
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_512K, {13'h200, 19'h0}, 32'h0010_0000);		//Index1=1, Index2=1, Offset=0 / (PDTR=4097) -> (4096) -> 4096 + 3 = 4099
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_512K, {13'h200, 19'h4}, 32'h0010_0004);
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_512K, {13'h200, 19'h8}, 32'h0010_0008);
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_512K, {13'h200, 19'hf}, 32'h0010_000f);
		$display("[INF]1-Level 512KB Check OK");

		//---------------------------------------------------1024KB---------------------------------------------------
		#(PL_CYCLE*10+1);
		task_inc_tid();			//TID Change
		task_set_pdtr(1024*1024);												//1page
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_1024K, {12'h200, 20'h0}, 32'h0020_0000);		//Index1=1, Index2=1, Offset=0 / (PDTR=4097) -> (4096) -> 4096 + 3 = 4099
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_1024K, {12'h200, 20'h4}, 32'h0020_0004);
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_1024K, {12'h200, 20'h8}, 32'h0020_0008);
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_1024K, {12'h200, 20'hf}, 32'h0020_000f);
		$display("[INF]1-Level 1024KB Check OK");

		//---------------------------------------------------2048KB---------------------------------------------------
		#(PL_CYCLE*10+1);
		task_inc_tid();			//TID Change
		task_set_pdtr(2048*1024);												//1page
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_2048K, {11'h200, 21'h0}, 32'h0040_0000);		//Index1=1, Index2=1, Offset=0 / (PDTR=4097) -> (4096) -> 4096 + 3 = 4099
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_2048K, {11'h200, 21'h4}, 32'h0040_0004);
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_2048K, {11'h200, 21'h8}, 32'h0040_0008);
		task_req_read_access_test(PL_PAGING_LEVEL_1, PL_PAGING_LEVEL1_PAGESIZE_2048K, {11'h200, 21'hf}, 32'h0040_000f);
		$display("[INF]1-Level 2048KB Check OK");


		/***************************************************************************************************************
		2-Level Check
		***************************************************************************************************************/
		//-----------------------------------------------------4KB-----------------------------------------------------
		#(PL_CYCLE*10+1);
		task_inc_tid();			//TID Change
		task_set_pdtr(4096);												//1page
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_4K, {10'h4, 10'h8, 12'h0}, 32'h0000_4000);		//Index1=1, Index2=1, Offset=0 / (PDTR=4097) -> (4096) -> 4096 + 3 = 4099
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_4K, {10'h4, 10'h8, 12'h4}, 32'h0000_4004);
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_4K, {10'h4, 10'h8, 12'h8}, 32'h0000_4008);
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_4K, {10'h4, 10'h8, 12'hf}, 32'h0000_400f);
		$display("[INF]2-Level 4KB Check OK");

		//-----------------------------------------------------8KB-----------------------------------------------------
		#(PL_CYCLE*10);
		task_inc_tid();			//TID Change
		task_set_pdtr(8192);												//1page
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_8K, {8'h8, 11'h10, 13'h0}, 32'h0000_8000);		//Index1=1, Index2=1, Offset=0 / (PDTR=4097) -> (4096) -> 4096 + 3 = 4099
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_8K, {8'h8, 11'h10, 13'h4}, 32'h0000_8004);
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_8K, {8'h8, 11'h10, 13'h8}, 32'h0000_8008);
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_8K, {8'h8, 11'h10, 13'hf}, 32'h0000_800f);
		$display("[INF]2-Level 8KB Check OK");

		//-----------------------------------------------------16KB-----------------------------------------------------
		#(PL_CYCLE*10);
		task_inc_tid();			//TID Change
		task_set_pdtr(16384);												//1page
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_16K, {6'h10, 12'h20, 14'h0}, 32'h0001_0000);		//Index1=1, Index2=1, Offset=0 / (PDTR=4097) -> (4096) -> 4096 + 3 = 4099
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_16K, {6'h10, 12'h20, 14'h4}, 32'h0001_0004);
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_16K, {6'h10, 12'h20, 14'h8}, 32'h0001_0008);
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_16K, {6'h10, 12'h20, 14'hf}, 32'h0001_000f);
		$display("[INF]2-Level 16KB Check OK");

		//-----------------------------------------------------32KB-----------------------------------------------------
		#(PL_CYCLE*10);
		task_inc_tid();			//TID Change
		task_set_pdtr(32768);												//1page
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_32K, {4'h20, 13'h40, 15'h0}, 32'h0002_0000);		//Index1=1, Index2=1, Offset=0 / (PDTR=4097) -> (4096) -> 4096 + 3 = 4099
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_32K, {4'h20, 13'h40, 15'h4}, 32'h0002_0004);
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_32K, {4'h20, 13'h40, 15'h8}, 32'h0002_0008);
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_32K, {4'h20, 13'h40, 15'hf}, 32'h0002_000f);
		$display("[INF]2-Level 32KB Check OK");

		//-----------------------------------------------------64KB-----------------------------------------------------
		#(PL_CYCLE*10);
		task_inc_tid();			//TID Change
		task_set_pdtr(65536);												//1page
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_64K, {2'h40, 14'h80, 16'h0}, 32'h0004_0000);		//Index1=1, Index2=1, Offset=0 / (PDTR=4097) -> (4096) -> 4096 + 3 = 4099
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_64K, {2'h40, 14'h80, 16'h4}, 32'h0004_0004);
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_64K, {2'h40, 14'h80, 16'h8}, 32'h0004_0008);
		task_req_read_access_test(PL_PAGING_LEVEL_2, PL_PAGING_LEVEL2_PAGESIZE_64K, {2'h40, 14'h80, 16'hf}, 32'h0004_000f);
		$display("[INF]2-Level 64KB Check OK");



		//STOP
		#(1000);
		$display("[INF]Simulation OK");
		$finish;


	end


endmodule

`default_nettype wire


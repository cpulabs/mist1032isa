
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
	reg [1:0] iLOGIC_MOD;		//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion		<New Name>
	reg [2:0] iLOGIC_MMUPS;		//MMU Page Size														<New Port>
	reg [31:0] iLOGIC_PDT;		//Page Directory Table 
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
	Page Fault
	***********************/
	wire oPAGEFAULT_VALID;
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
		.iLOGIC_MOD(iLOGIC_MOD),		//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion		<New Name>
		.iLOGIC_MMUPS(iLOGIC_MMUPS),		//MMU Page Size														<New Port>
		.iLOGIC_PDT(iLOGIC_PDT),		//Page Directory Table 
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
		Page Fault
		***********************/
		.oPAGEFAULT_VALID(oPAGEFAULT_VALID),
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
		.iMEMORY_DATA(iMEMORY_DATA)
	);
	
	//Sim Memory
	sim_memory_model #(2, "", 134217728/8, 1, 1) MEMORY(
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

	always#(PL_CYCLE/2)begin
		iCLOCK = !iCLOCK;
	end

	reg [63:0] main_ram [0:1023];
	integer i;
	initial begin
		#0 begin
			for(i = 0; i < 1024; i = i + 1)begin
				main_ram[i] = {i[31:0], i[31:0]};
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

	initial begin
		#0 begin
			iCLOCK = 1'b0;
			inRESET = 1'b0;
			iRESET_SYNC = 1'b0;
			iTLB_FLUSH = 1'b0;
			iLOGIC_MOD = PL_PAGING_LEVEL_OFF;		//Convertion Level
			iLOGIC_MMUPS = 3'h0;
			iLOGIC_PDT = 32'h100;
			//iLOGIC_TID = {14{1'b0}};
			iLOGIC_REQ = 1'b0;
			iLOGIC_RW = 1'b0;
			iLOGIC_ADDR = {32{1'b0}};
		end
		#1 begin
			inRESET = 1'b1;
		end
		#100000 begin
			$finish;
		end
	end

	initial begin
		//Read LogicAddr:0
		#(PL_CYCLE+1) begin
			iLOGIC_REQ = 1'b1;
			iLOGIC_ADDR = {32{1'b0}};
			iLOGIC_MOD = PL_PAGING_LEVEL_OFF;
			//STOP	
			#(PL_CYCLE);
			iLOGIC_REQ = 1'b0;
			iLOGIC_MOD = PL_PAGING_LEVEL_OFF;
		end
		

		//Read LogicAddr:1
		#(PL_CYCLE) begin
			iLOGIC_REQ = 1'b1;
			iLOGIC_ADDR = 32'h00000008;
			iLOGIC_MOD = PL_PAGING_LEVEL_OFF;
			#(PL_CYCLE);
			iLOGIC_REQ = 1'b1;
			iLOGIC_ADDR = 32'h00000008;
			iLOGIC_MOD = PL_PAGING_LEVEL_OFF;
		end

		/*

		//Read LogicAddr:3
		#(PL_CYCLE) begin
			iLOGIC_REQ = 1'b1;
			iLOGIC_ADDR = 32'h00000003;
			iLOGIC_MOD = PL_PAGING_LEVEL_OFF;
		end
		//Read LogicAddr:4
		#(PL_CYCLE) begin
			iLOGIC_REQ = 1'b1;
			iLOGIC_ADDR = 32'h00000004;
			iLOGIC_MOD = PL_PAGING_LEVEL_2;
		end
		//Read LogicAddr:16384
		#(PL_CYCLE * 10) begin
			iLOGIC_REQ = 1'b1;
			iLOGIC_ADDR = 32'h4000;
			iLOGIC_MOD = PL_PAGING_LEVEL_2;
		end
		*/

		//STOP
		#(PL_CYCLE) begin
			iLOGIC_REQ = 1'b0;
		end
	end
	
	
endmodule

`default_nettype wire


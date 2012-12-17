`timescale 10ns/1ps
`default_nettype none	
`define		CYCLE		20


module mmu_test;
				//System
				reg						iCLOCK;
				reg						inRESET;
				//TLB Flash
				reg						iTLB_FLASH;
				//Req IRQ
				wire					oINTERRUPT_VALID;
				//CORE REGISTER
				reg		[1:0]			iCOREINFO_MODE;			//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion
				reg		[31:0]			iCOREINFO_PDT;			//Page Directory Table 
				reg		[13:0]			iCOREINFO_TID;			//Task Id 
				//LOGIC Address Request
				reg						iLOGIC_REQ;
				reg						iLOGIC_RW;				//0=Read 1=Write
				reg						iLOGIC_TYPE;			//0:Data 1:Instruction	
				reg		[31:0]			iLOGIC_ADDR;
				wire					oLOGIC_LOCK;
				//Physical Output
				wire					oPHYSICAL_VALID;
				reg						iPHYSICAL_LOCK;
				wire	[31:0]			oPHYSICAL_ADDR;
				//Memory <--->
				//Req
				wire					oMEMORY_REQ;
				reg						iMEMORY_LOCK;
				wire	[31:0]			oMEMORY_ADDR;
				//Data RAM -> This
				wire					iMEMORY_VALID;
				wire					oMEMORY_LOCK;
				wire	[63:0]			iMEMORY_DATA;


	
				
	
	mmu TARGET( 
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		//TLB Flash
		.iTLB_FLASH(iTLB_FLASH),
		//Req IRQ
		.oINTERRUPT_VALID(oINTERRUPT_VALID),
		//CORE REGISTER
		.iCOREINFO_MODE(iCOREINFO_MODE),			//0=NoConvertion 1=none 2=1LevelConvertion 3=2LevelConvertion
		.iCOREINFO_PDT(iCOREINFO_PDT),			//Page Directory Table 
		.iCOREINFO_TID(iCOREINFO_TID),			//Task Id 
		//LOGIC Address Request
		.iLOGIC_REQ(iLOGIC_REQ),
		.iLOGIC_RW(iLOGIC_RW),				//0=Read 1=Write
		.iLOGIC_TYPE(iLOGIC_TYPE),			//0:Data 1:Instruction	
		.iLOGIC_ADDR(iLOGIC_ADDR),
		.oLOGIC_LOCK(oLOGIC_LOCK),
		//Physical Output
		.oPHYSICAL_VALID(oPHYSICAL_VALID),
		.iPHYSICAL_LOCK(iPHYSICAL_LOCK),
		.oPHYSICAL_ADDR(oPHYSICAL_ADDR),
		//Memory <--->
		//Req
		.oMEMORY_REQ(oMEMORY_REQ),
		.iMEMORY_LOCK(iMEMORY_LOCK),
		.oMEMORY_ADDR(oMEMORY_ADDR),
		//Data RAM -> This
		.iMEMORY_VALID(iMEMORY_VALID),
		.oMEMORY_LOCK(oMEMORY_LOCK),
		.iMEMORY_DATA(iMEMORY_DATA)
	);
	
	
	//Main - RAM
	/*
	Memory Structure
		0~16383					:	1Page
			0~2047				:	1 Level PTA - Default Point
				0~3				:	2 Level PTA Addr 
			2048~4095			:	2 Level PTA
				2048~4051		:	2 Page Addr
		16384~32768				:	2Page
	*/
	/*
	reg		[7:0]		main_ram	[0:(1024*32)-1];
	integer i;
	initial begin
		#0 begin
			for(i = 0; i  < 32768; i = i + 1)begin
				main_ram[i]		=		8'h0;
			end
		end
		#1 begin
			{main_ram[3], main_ram[2], main_ram[1], main_ram[0]}				=		32'd2048 | 8'b0000_0011;		//2Level Pointer
			{main_ram[2051], main_ram[2050], main_ram[2049], main_ram[2048]}	=		32'd16384 | 8'b0001_0011;		//Access Pointer
			//main_ram[16384]														=		8'hAA;
		end
	end
	*/
	//END
	
	
	reg		[63:0]		main_ram	[0:1023];
	integer i;
	initial begin
		#0 begin
			for(i = 0; i  < 1024; i = i + 1)begin
				main_ram[i]		=		{i[31:0], i[31:0]};
			end
		end
		#1 begin
			//main_ram[i]		=		{i[31:0], i[31:0]};
		end
	end
	
	
	
	assign	iMEMORY_VALID			=		b_latch_req;
	assign	iMEMORY_DATA			=		main_ram[oMEMORY_ADDR];//{main_ram[iTHIS_MEM_ADDR[14:0]+7], main_ram[iTHIS_MEM_ADDR[14:0]+6], main_ram[iTHIS_MEM_ADDR[14:0]+5], main_ram[iTHIS_MEM_ADDR[14:0]+4], main_ram[iTHIS_MEM_ADDR[14:0]+3], main_ram[iTHIS_MEM_ADDR[14:0]+2], main_ram[iTHIS_MEM_ADDR[14:0]+1], main_ram[iTHIS_MEM_ADDR[14:0]]};
	
	wire		b_latch_req;
	
	//Memory Request Latch
	sim_buffer #(1) REQ_LATCH(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iSOURCE(oMEMORY_REQ),
		.oOUTPUT(b_latch_req)
	);
	

				
				
	initial begin
		#0 begin
			iCLOCK				=		1'b0;
			inRESET				=		1'b0;
			iTLB_FLASH			=		1'b0;
			iCOREINFO_MODE		=		2'b0;		//Convertion Level
			iCOREINFO_PDT		=		32'h100;
			iCOREINFO_TID		=		{14{1'b0}};
			iLOGIC_REQ			=		1'b0;
			iLOGIC_RW			=		1'b0;
			iLOGIC_TYPE			=		1'b0;
			iLOGIC_ADDR			=		{32{1'b0}};
			iPHYSICAL_LOCK		=		1'b0;
			iMEMORY_LOCK		=		1'b0;
			//iMEMORY_VALID		=		1'b0;
			//iMEMORY_DATA		=		{32{1'b0}};		
		end
		#1 begin
			inRESET				=		1'b1;
		end
		#10000 begin
			$finish;
		end
	end
	
	
	initial begin
		//Read LogicAddr:0
		#(`CYCLE+1) begin
			iLOGIC_REQ			=		1'b1;
			iLOGIC_ADDR			=		{32{1'b0}};
			iCOREINFO_MODE		=		2'h0;
		end
		//STOP	
		#(`CYCLE) begin	
			iLOGIC_REQ			=		1'b0;
			iCOREINFO_MODE		=		2'h0;
		end
		#(`CYCLE) begin	
			iLOGIC_REQ			=		1'b0;
			iCOREINFO_MODE		=		2'h0;
		end
		//Read LogicAddr:1
		#(`CYCLE) begin
			iLOGIC_REQ			=		1'b1;
			iLOGIC_ADDR			=		32'h00000001;
			iCOREINFO_MODE		=		2'h0;
		end
		//Read LogicAddr:2
		#(`CYCLE) begin
			iLOGIC_REQ			=		1'b1;
			iLOGIC_ADDR			=		32'h00000002;
			iCOREINFO_MODE		=		2'h0;
		end
		//Read LogicAddr:3
		#(`CYCLE) begin
			iLOGIC_REQ			=		1'b1;
			iLOGIC_ADDR			=		32'h00000003;
			iCOREINFO_MODE		=		2'h0;
		end
		//Read LogicAddr:4
		#(`CYCLE) begin
			iLOGIC_REQ			=		1'b1;
			iLOGIC_ADDR			=		32'h00000004;
			iCOREINFO_MODE		=		2'h2;
		end
		//Read LogicAddr:16384
		#(`CYCLE * 10) begin
			iLOGIC_REQ			=		1'b1;
			iLOGIC_ADDR			=		32'h4000;
			iCOREINFO_MODE		=		2'h2;
		end
				

		
		
		/*
		#(`CYCLE) begin
			oTHIS_CORE_VALID			=		1'b1;
			oTHIS_CORE_LOGIC_ADDR		=		32'h00000002;
		end
		#(`CYCLE) begin
			oTHIS_CORE_VALID			=		1'b1;
			oTHIS_CORE_LOGIC_ADDR		=		32'h00000003;
		end
		#(`CYCLE) begin
			oTHIS_CORE_VALID			=		1'b1;
			oTHIS_CORE_LOGIC_ADDR		=		32'h00000004;
		end
		#(`CYCLE) begin
			oTHIS_CORE_VALID			=		1'b1;
			oTHIS_CORE_LOGIC_ADDR		=		32'h00000005;
		end
		#(`CYCLE) begin
			oTHIS_CORE_VALID			=		1'b1;
			oTHIS_CORE_LOGIC_ADDR		=		32'h00000006;
		end*/
		

		//STOP
		#(`CYCLE) begin
			iLOGIC_REQ			=		1'b0;
		end
	end

	
	//function func_select
	
	//function
	
	
	always#(`CYCLE/2)begin
		iCLOCK		=		~iCLOCK;
	end
		

	
	
endmodule

	
	
	
	
	
	
module sim_buffer(
					input					iCLOCK,
					input					inRESET,
					input		[N-1:0]		iSOURCE,
					output		[N-1:0]		oOUTPUT
	);
	
	parameter		N		=	1;
		
	
	assign		oOUTPUT		=		buffer;
		
		
	reg		[N-1:0]		buffer;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			buffer		<=		{N{1'b0}};
		end
		else begin
			buffer		<=		iSOURCE;
		end
	end
	
endmodule

	
	
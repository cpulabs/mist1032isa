`timescale 1ns/1ps
`default_nettype none	
`define		CYCLE		20


module test_tlb;
	//System
	reg						oCLOCK;
	reg						onRESET;
	//Remove
	reg						oREMOVE_VALID;
	//Wrote
	reg						oWRITE_VALID;
	reg		[17:0]			oWRITE_ADDR;
	reg		[63:0]			oWRITE_DATA;
	//Read
	reg						oREAD_VALID;
	reg		[17:0]			oREAD_ADDR;
	wire					iREAD_VALID;
	wire	[31:0]			iREAD_DATA;
	
	
	tlb tlb_module(
					.iCLOCK(oCLOCK), .inRESET(onRESET),
					.iREMOVE_VALID(oREMOVE_VALID), 
					.iWRITE_VALID(oWRITE_VALID), .iWRITE_ADDR(oWRITE_ADDR), .iWRITE_DATA(oWRITE_DATA),
					.iREAD_VALID(oREAD_VALID), .iREAD_ADDR(oREAD_ADDR), .oREAD_VALID(iREAD_VALID), .oREAD_DATA(iREAD_DATA));
	
	
	initial begin
		#0 begin
			oCLOCK				=		1'b0;
			onRESET				=		1'b0;
			oREMOVE_VALID		=		1'b0;
			oWRITE_VALID		=		1'b0;
			oWRITE_ADDR			=		{18{1'b0}};
			oWRITE_DATA			=		{64{1'b0}};
			oREAD_VALID			=		1'b0;
			oREAD_ADDR			=		{18{1'b0}};
		end
		#1 begin
			onRESET				=		1'b1;
		end	
	end
	
	initial begin
		#100000 begin
			$finish;
		end
	end
	
	initial begin
		//Write
		#(`CYCLE + 1) begin					//Write
			oWRITE_VALID		=		1'b1;
			oWRITE_ADDR			=		32'h0;
			oWRITE_DATA			=		64'h00000001_00000001;
		end
		#(`CYCLE) begin						//Write
			oWRITE_VALID		=		1'b1;
			oWRITE_ADDR			=		32'h1;
			oWRITE_DATA			=		64'h00000002_00000002;
		end	
		#(`CYCLE) begin						//Write
			oWRITE_VALID		=		1'b1;
			oWRITE_ADDR			=		32'h2;
			oWRITE_DATA			=		64'h00000003_00000003;
		end
		#(`CYCLE) begin						//Write
			oWRITE_VALID		=		1'b1;
			oWRITE_ADDR			=		32'h3;
			oWRITE_DATA			=		64'h00000004_00000004;
		end
		//Wait
		#(`CYCLE) begin						//Wait
			oWRITE_VALID		=		1'b0;
			oWRITE_ADDR			=		32'h0;
			oWRITE_DATA			=		64'h00000001_00000001;
			oREAD_VALID			=		1'b0;
			oREAD_ADDR			=		18'd0;
		end
		//Read
		#(`CYCLE) begin						//Read
			oREAD_VALID			=		1'b1;
			oREAD_ADDR			=		64'h00000002_00000002;
		end
		#(`CYCLE) begin						//Read
			oREAD_VALID			=		1'b1;
			oREAD_ADDR			=		64'h00000003_00000003;
		end
		#(`CYCLE) begin						//Read
			oREAD_VALID			=		1'b1;
			oREAD_ADDR			=		64'h00000004_00000004;
		end
		//Wait
		#(`CYCLE) begin						//Wait
			oWRITE_VALID		=		1'b0;
			oWRITE_ADDR			=		18'b00_0000_0000_0000;
			oWRITE_DATA			=		18'd0;
			oREAD_VALID			=		1'b0;
			oREAD_ADDR			=		64'h00000001_00000001;
		end
	end
		
	always#(`CYCLE/2)begin
		oCLOCK		=		~oCLOCK;
	end
	
endmodule

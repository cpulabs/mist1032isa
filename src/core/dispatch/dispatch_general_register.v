
`default_nettype none
`include "processor.h"

module dispatch_general_register(
		//System
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Write Port
		input wire iWR_VALID,
		input wire [4:0] iWR_ADDR,
		input wire [31:0] iWR_DATA,
		//Read Port0
		input wire [4:0] iRD0_ADDR,
		output wire [31:0] oRD0_DATA,
		//Read Port1
		input wire [4:0] iRD1_ADDR,
		output wire [31:0] oRD1_DATA,
		//Debug Module
		output wire [31:0] oDEBUG_REG_OUT_GR0,
		output wire [31:0] oDEBUG_REG_OUT_GR1,
		output wire [31:0] oDEBUG_REG_OUT_GR2,
		output wire [31:0] oDEBUG_REG_OUT_GR3,
		output wire [31:0] oDEBUG_REG_OUT_GR4,
		output wire [31:0] oDEBUG_REG_OUT_GR5,
		output wire [31:0] oDEBUG_REG_OUT_GR6,
		output wire [31:0] oDEBUG_REG_OUT_GR7,
		output wire [31:0] oDEBUG_REG_OUT_GR8,
		output wire [31:0] oDEBUG_REG_OUT_GR9,
		output wire [31:0] oDEBUG_REG_OUT_GR10,
		output wire [31:0] oDEBUG_REG_OUT_GR11,
		output wire [31:0] oDEBUG_REG_OUT_GR12,
		output wire [31:0] oDEBUG_REG_OUT_GR13,
		output wire [31:0] oDEBUG_REG_OUT_GR14,
		output wire [31:0] oDEBUG_REG_OUT_GR15,
		output wire [31:0] oDEBUG_REG_OUT_GR16,
		output wire [31:0] oDEBUG_REG_OUT_GR17,
		output wire [31:0] oDEBUG_REG_OUT_GR18,
		output wire [31:0] oDEBUG_REG_OUT_GR19,
		output wire [31:0] oDEBUG_REG_OUT_GR20,
		output wire [31:0] oDEBUG_REG_OUT_GR21,
		output wire [31:0] oDEBUG_REG_OUT_GR22,
		output wire [31:0] oDEBUG_REG_OUT_GR23,
		output wire [31:0] oDEBUG_REG_OUT_GR24,
		output wire [31:0] oDEBUG_REG_OUT_GR25,
		output wire [31:0] oDEBUG_REG_OUT_GR26,
		output wire [31:0] oDEBUG_REG_OUT_GR27,
		output wire [31:0] oDEBUG_REG_OUT_GR28,
		output wire [31:0] oDEBUG_REG_OUT_GR29,
		output wire [31:0] oDEBUG_REG_OUT_GR30,
		output wire [31:0] oDEBUG_REG_OUT_GR31
	);

	integer i;

	reg [31:0] b_ram0[0:31];
	reg [31:0] b_ram1[0:31];

	//RAM0
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			for(i = 0; i < 32; i = i + 1)begin
				b_ram0[i] <= 32'h0;
			end
		end
		else if(iRESET_SYNC)begin
			for(i = 0; i < 32; i = i + 1)begin
				b_ram0[i] <= 32'h0;
			end
		end
		else begin
			if(iWR_VALID)begin
				b_ram0[iWR_ADDR] <= iWR_DATA;
			end
		end
	end//General Register Write Back

	//RAM1
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			for(i = 0; i < 32; i = i + 1)begin
				b_ram1[i] <= 32'h0;
			end
		end
		else if(iRESET_SYNC)begin
			for(i = 0; i < 32; i = i + 1)begin
				b_ram1[i] <= 32'h0;
			end
		end
		else begin
			if(iWR_VALID)begin
				b_ram1[iWR_ADDR] <= iWR_DATA;
			end
		end
	end//General Register Write Back


	assign oRD0_DATA = b_ram0[iRD0_ADDR];
	assign oRD1_DATA = b_ram1[iRD1_ADDR];


	//Debug Module Enable
	`ifdef MIST1032ISA_STANDARD_DEBUGGER
		assign oDEBUG_REG_OUT_GR0 = b_ram0[0];
		assign oDEBUG_REG_OUT_GR1 = b_ram0[1];
		assign oDEBUG_REG_OUT_GR2 = b_ram0[2];
		assign oDEBUG_REG_OUT_GR3 = b_ram0[3];
		assign oDEBUG_REG_OUT_GR4 = b_ram0[4];
		assign oDEBUG_REG_OUT_GR5 = b_ram0[5];
		assign oDEBUG_REG_OUT_GR6 = b_ram0[6];
		assign oDEBUG_REG_OUT_GR7 = b_ram0[7];
		assign oDEBUG_REG_OUT_GR8 = b_ram0[8];
		assign oDEBUG_REG_OUT_GR9 = b_ram0[9];
		assign oDEBUG_REG_OUT_GR10 = b_ram0[10];
		assign oDEBUG_REG_OUT_GR11 = b_ram0[11];
		assign oDEBUG_REG_OUT_GR12 = b_ram0[12];
		assign oDEBUG_REG_OUT_GR13 = b_ram0[13];
		assign oDEBUG_REG_OUT_GR14 = b_ram0[14];
		assign oDEBUG_REG_OUT_GR15 = b_ram0[15];
		assign oDEBUG_REG_OUT_GR16 = b_ram0[16];
		assign oDEBUG_REG_OUT_GR17 = b_ram0[17];
		assign oDEBUG_REG_OUT_GR18 = b_ram0[18];
		assign oDEBUG_REG_OUT_GR19 = b_ram0[19];
		assign oDEBUG_REG_OUT_GR20 = b_ram0[20];
		assign oDEBUG_REG_OUT_GR21 = b_ram0[21];
		assign oDEBUG_REG_OUT_GR22 = b_ram0[22];
		assign oDEBUG_REG_OUT_GR23 = b_ram0[23];
		assign oDEBUG_REG_OUT_GR24 = b_ram0[24];
		assign oDEBUG_REG_OUT_GR25 = b_ram0[25];
		assign oDEBUG_REG_OUT_GR26 = b_ram0[26];
		assign oDEBUG_REG_OUT_GR27 = b_ram0[27];
		assign oDEBUG_REG_OUT_GR28 = b_ram0[28];
		assign oDEBUG_REG_OUT_GR29 = b_ram0[29];
		assign oDEBUG_REG_OUT_GR30 = b_ram0[30];
		assign oDEBUG_REG_OUT_GR31 = b_ram0[31];
	`else
	//Disable
		assign oDEBUG_REG_OUT_GR0 = 32'h0;
		assign oDEBUG_REG_OUT_GR1 = 32'h0;
		assign oDEBUG_REG_OUT_GR2 = 32'h0;
		assign oDEBUG_REG_OUT_GR3 = 32'h0;
		assign oDEBUG_REG_OUT_GR4 = 32'h0;
		assign oDEBUG_REG_OUT_GR5 = 32'h0;
		assign oDEBUG_REG_OUT_GR6 = 32'h0;
		assign oDEBUG_REG_OUT_GR7 = 32'h0;
		assign oDEBUG_REG_OUT_GR8 = 32'h0;
		assign oDEBUG_REG_OUT_GR9 = 32'h0;
		assign oDEBUG_REG_OUT_GR10 = 32'h0;
		assign oDEBUG_REG_OUT_GR11 = 32'h0;
		assign oDEBUG_REG_OUT_GR12 = 32'h0;
		assign oDEBUG_REG_OUT_GR13 = 32'h0;
		assign oDEBUG_REG_OUT_GR14 = 32'h0;
		assign oDEBUG_REG_OUT_GR15 = 32'h0;
		assign oDEBUG_REG_OUT_GR16 = 32'h0;
		assign oDEBUG_REG_OUT_GR17 = 32'h0;
		assign oDEBUG_REG_OUT_GR18 = 32'h0;
		assign oDEBUG_REG_OUT_GR19 = 32'h0;
		assign oDEBUG_REG_OUT_GR20 = 32'h0;
		assign oDEBUG_REG_OUT_GR21 = 32'h0;
		assign oDEBUG_REG_OUT_GR22 = 32'h0;
		assign oDEBUG_REG_OUT_GR23 = 32'h0;
		assign oDEBUG_REG_OUT_GR24 = 32'h0;
		assign oDEBUG_REG_OUT_GR25 = 32'h0;
		assign oDEBUG_REG_OUT_GR26 = 32'h0;
		assign oDEBUG_REG_OUT_GR27 = 32'h0;
		assign oDEBUG_REG_OUT_GR28 = 32'h0;
		assign oDEBUG_REG_OUT_GR29 = 32'h0;
		assign oDEBUG_REG_OUT_GR30 = 32'h0;
		assign oDEBUG_REG_OUT_GR31 = 32'h0;
	`endif

endmodule // dispatch_general_register

`default_nettype wire

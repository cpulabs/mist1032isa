

`default_nettype none
`include "core.h"

module load_store(
					//Prev
					input	[4:0]			iCMD,
					input					iLOADSTORE_MODE,		//0:SYS_LDST | 1:LDST
					input	[31:0]			iSOURCE0,
					input	[31:0]			iSOURCE1,
					input	[31:0]			iSPR,
					input	[31:0]			iPC,
					//Output - Writeback
					output					oOUT_SPR_VALID,
					output	[31:0]			oOUT_SPR,
					output	[31:0]			oOUT_DATA,
					//Output - LDST Pipe
					output					oLDST_RW,
					output	[31:0]			oLDST_ADDR,
					output	[31:0]			oLDST_DATA,
					output	[1:0]			oLDST_ORDER,
					output	[1:0]			oLOAD_SHIFT,
					output	[1:0]			oLOAD_MASK
	);

	reg					spr_valid;
	reg		[31:0]		spr;
	reg		[31:0]		data;
	reg		[31:0]		ldst_addr;
	reg		[31:0]		ldst_data;
	reg					ldst_rw;
	reg		[1:0]		ldst_order;
	reg		[1:0]		ldst_load_mask;
	reg		[1:0]		ldst_load_shift;
	always @* begin
		if(iLOADSTORE_MODE)begin
			case(iCMD)
				`EXE_LDSW_LD8:
					begin
						spr_valid = 1'b0;
						spr		=	iSPR;	
						data	=	32'h0;
						ldst_addr	=	iSOURCE1;
						ldst_data	=	iSOURCE0;
						ldst_rw		=	1'b0;
						ldst_order	=	2'h0;
						ldst_load_mask = 2'h0;
						ldst_load_shift = iSOURCE1[1:0];
					end
				`EXE_LDSW_LD16:
					begin
						spr_valid = 1'b0;
						spr		=	iSPR;		
						data	=	32'h0;
						ldst_addr	=	iSOURCE1;
						ldst_data	=	iSOURCE0;
						ldst_rw		=	1'b0;
						ldst_order	=	2'h1;
						ldst_load_mask = 2'h1;
						ldst_load_shift = iSOURCE1[1:0];
					end
				`EXE_LDSW_LD32:
					begin
						spr_valid = 1'b0;
						spr		=	iSPR;		
						data	=	32'h0;
						ldst_addr	=	iSOURCE1;
						ldst_data	=	iSOURCE0;
						ldst_rw		=	1'b0;
						ldst_order	=	2'h2;
						ldst_load_mask = 2'h3;
						ldst_load_shift = 2'h0;
					end
				`EXE_LDSW_ST8:
					begin
						spr_valid = 1'b0;
						spr		=	iSPR;		
						data	=	32'h0;
						ldst_addr	=	iSOURCE1;
						ldst_data	=	iSOURCE0;
						ldst_rw		=	1'b1;
						ldst_order	=	2'h0;
						ldst_load_mask = 2'h0;
						ldst_load_shift = 2'h0;
					end
				`EXE_LDSW_ST16:
					begin
						spr_valid = 1'b0;
						spr		=	iSPR;		
						data	=	32'h0;
						ldst_addr	=	iSOURCE1;
						ldst_data	=	iSOURCE0;
						ldst_rw		=	1'b1;
						ldst_order	=	2'h1;
						ldst_load_mask = 2'h0;
						ldst_load_shift = 2'h0;
					end
				`EXE_LDSW_ST32:
					begin
						spr_valid = 1'b0;
						spr		=	iSPR;		
						data	=	32'h0;
						ldst_addr	=	iSOURCE1;
						ldst_data	=	iSOURCE0;
						ldst_rw		=	1'b1;
						ldst_order	=	2'h2;
						ldst_load_mask = 2'h0;
						ldst_load_shift = 2'h0;
					end
				`EXE_LDSW_PUSH:
					begin
						spr_valid = 1'b1;
						spr		=	iSPR - 32'h4;		
						data	=	32'h0;
						ldst_addr	=	iSPR - 32'h4;
						ldst_data	=	iSOURCE0;
						ldst_rw		=	1'b1;
						ldst_order	=	2'h2;
						ldst_load_mask = 2'h0;
						ldst_load_shift = 2'h0;
					end
				`EXE_LDSW_PPUSH:
					begin
						spr_valid = 1'b1;
						spr		=	iSPR - 32'h4;		
						data	=	32'h0;
						ldst_addr	=	iSPR - 32'h4;
						ldst_data	=	iPC;
						ldst_rw		=	1'b1;
						ldst_order	=	2'h2;
						ldst_load_mask = 2'h0;
						ldst_load_shift = 2'h0;
					end
				`EXE_LDSW_POP:
					begin
						spr_valid = 1'b1;
						spr		=	iSPR + 32'h4;	
						data	=	32'h0;	
						ldst_addr	=	iSPR;
						ldst_data	=	32'h0;
						ldst_rw		=	1'b0;
						ldst_order	=	2'h2;
						ldst_load_mask = 2'h3;
						ldst_load_shift = 2'h0;
					end
				default:
					begin
						spr_valid = 1'b0;
						spr		=	iSPR;		
						data	=	32'h0;
						ldst_addr	=	iSOURCE1;
						ldst_data	=	32'h0;
						ldst_rw		=	1'b0;
						ldst_order	=	2'h0;
						ldst_load_mask = 2'h0;
						ldst_load_shift = 2'h0;
					end
			endcase
		end
		else begin
			if(iCMD == `EXE_SYS_LDST_READ_SPR)begin
				spr_valid = 1'b1;
				spr		=	iSPR;		
				data	=	iSPR;
				ldst_addr	=	iSOURCE1;
				ldst_data	=	iSPR;
				ldst_rw		=	1'b0;
				ldst_order	=	2'h2;
				ldst_load_mask = 2'h0;
				ldst_load_shift = 2'h0;
			end
			else begin
				spr_valid = 1'b1;
				spr		=	iSOURCE0;			
				data	=	32'h0;
				ldst_addr	=	iSOURCE0;
				ldst_data	=	iSOURCE0;
				ldst_rw		=	1'b1;
				ldst_order	=	2'h2;
				ldst_load_mask = 2'h0;
				ldst_load_shift = 2'h0;
			end
		end
	end
	
	
	assign		oOUT_SPR_VALID = spr_valid;
	assign		oOUT_SPR = spr;
	assign		oOUT_DATA = data;
	//Output - LDST Pipe
	assign		oLDST_RW = ldst_rw;
	assign		oLDST_ADDR = ldst_addr;
	assign		oLDST_DATA = ldst_data;
	assign		oLDST_ORDER = ldst_order;
	assign		oLOAD_SHIFT = ldst_load_shift;
	assign		oLOAD_MASK = ldst_load_mask;
endmodule


`default_nettype wire


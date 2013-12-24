
`include "core.h"
`default_nettype none

module execute_forwarding(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Writeback - General Register
		input wire iWB_GR_VALID,
		input wire [31:0] iWB_GR_DATA,
		input wire [4:0] iWB_GR_DEST,
		input wire iWB_GR_DEST_SYSREG,
		//Writeback - Stack Point Register
		input wire iWB_SPR_VALID,
		input wire [31:0] iWB_SPR_DATA,
		//Previous Writeback - General Register
		input wire iPREV_WB_GR_VALID,
		input wire [31:0] iPREV_WB_GR_DATA,
		input wire [4:0] iPREV_WB_GR_DEST,
		input wire iPREV_WB_GR_DEST_SYSREG,
		//Previous Writeback - Stack Point Register
		input wire iPREV_WB_SPR_VALID,
		input wire [31:0] iPREV_WB_SPR_DATA,
		//Source
		input wire iPREVIOUS_SOURCE_SYSREG,
		input wire [4:0] iPREVIOUS_SOURCE_POINTER,
		input wire iPREVIOUS_SOURCE_IMM,
		input wire [31:0] iPREVIOUS_SOURCE_DATA,
		//Output
		output wire [31:0] oNEXT_SOURCE_DATA,
		output wire [31:0] oNEXT_SOURCE_SPR
	);
	

		
	/************************************************************************
	Fowarding Function
	************************************************************************/
	//[31:0]	: Data	
	function [31:0] func_forwarding_rewrite;
		input func_src_settle; //No forwarding
		input [4:0] func_src_pointer;
		input func_src_sysreg;
		input [31:0] func_src_data;
		//Previous
		input func_prev_valid;
		input func_prev_sysreg;
		input func_prev_spr_writeback;
		input [4:0] func_prev_dest_pointer;
		//input [31:0] func_prev_pcr;
		input [31:0] func_prev_spr;
		input [31:0] func_prev_gr_data;
		begin
			//Forwarding Valid
			if(func_prev_valid && !func_src_settle)begin
				//SPR Forwarding
				//Source Sysreg -> Valid, Source Pointer -> SPR, Previous Data -> Valid, Previous SPR Writeback -> Valid
				if(func_src_sysreg && func_src_pointer == `SYSREG_SPR && (func_prev_spr_writeback || func_prev_dest_pointer == `SYSREG_SPR))begin
					func_forwarding_rewrite = func_prev_spr;
				end
				//General Register Fowerding
				else if(!func_src_sysreg && !func_prev_sysreg && func_src_pointer == func_prev_dest_pointer)begin
					func_forwarding_rewrite = func_prev_gr_data;
				end
				//No Forwarding
				else begin
					func_forwarding_rewrite = func_src_data;
				end
			end
			//No Forwarding
			else begin
				func_forwarding_rewrite = func_src_data;
			end
		end
	endfunction
	
	function [31:0] func_forwarding_reqrite_spr;
		input [31:0] func_prev_data;
		input func_cuur_valid;
		input [31:0] func_cuur_data;
		begin
			if(func_cuur_valid)begin
				func_forwarding_reqrite_spr = func_cuur_data;
			end
			else begin
				func_forwarding_reqrite_spr = func_prev_data;
			end
		end
	endfunction
	
		
		
	/************************************************************************
	Assign
	************************************************************************/
	wire [31:0] prev_forwarding_data = func_forwarding_rewrite(
		iPREVIOUS_SOURCE_IMM,
		iPREVIOUS_SOURCE_POINTER,
		iPREVIOUS_SOURCE_SYSREG,
		iPREVIOUS_SOURCE_DATA,
		iPREV_WB_GR_VALID,
		iPREV_WB_GR_DEST_SYSREG,
		iPREV_WB_SPR_VALID,
		iPREV_WB_GR_DEST,
		iPREV_WB_SPR_DATA,
		iPREV_WB_GR_DATA
	);

	wire [31:0] cuur_forwarding_data = func_forwarding_rewrite(
		iPREVIOUS_SOURCE_IMM,
		iPREVIOUS_SOURCE_POINTER,
		iPREVIOUS_SOURCE_SYSREG,
		prev_forwarding_data,
		iWB_GR_VALID,
		iWB_GR_DEST_SYSREG,
		iWB_SPR_VALID,
		iWB_GR_DEST,
		iWB_SPR_DATA,
		iWB_GR_DATA
	);
	
	wire [31:0] cuur_forwarding_spr = func_forwarding_reqrite_spr(
		iPREV_WB_SPR_DATA,
		iWB_SPR_VALID,
		iWB_SPR_DATA
	);


	assign oNEXT_SOURCE_DATA = cuur_forwarding_data;
	assign oNEXT_SOURCE_SPR = cuur_forwarding_spr;

endmodule

`default_nettype wire 


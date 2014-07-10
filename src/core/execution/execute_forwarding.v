
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
		input wire [31:0] iPREVIOUS_SOURCE_PDTR,
		input wire [31:0] iPREVIOUS_SOURCE_KPDTR,
		input wire [31:0] iPREVIOUS_SOURCE_TIDR,
		input wire [31:0] iPREVIOUS_SOURCE_PSR,
		//Output
		output wire [31:0] oNEXT_SOURCE_DATA,
		output wire [31:0] oNEXT_SOURCE_SPR,
		output wire [31:0] oNEXT_SOURCE_PDTR,
		output wire [31:0] oNEXT_SOURCE_KPDTR,
		output wire [31:0] oNEXT_SOURCE_TIDR,
		output wire [31:0] oNEXT_SOURCE_PSR
	);



	/************************************************************************
	Fowarding Function
	************************************************************************/
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

	function [31:0] func_forwarding_rewrite_sysreg;
		input [4:0] func_target_sysreg;
		//Current
		input [31:0] func_src_data;
		//Previous
		input func_prev_valid;
		input func_prev_sysreg;
		input [4:0] func_prev_dest_pointer;
		input [31:0] func_prev_data;
		begin
			//Forwarding Valid
			if(func_prev_valid && func_prev_sysreg && func_prev_dest_pointer == func_target_sysreg)begin
				//Forwarding
				func_forwarding_rewrite_sysreg = func_prev_data;
			end
			//No Forwarding
			else begin
				func_forwarding_rewrite_sysreg = func_src_data;
			end
		end
	endfunction



	/************************************************************************
	Assign
	************************************************************************/
	//GR
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

	//SPR
	wire [31:0] cuur_forwarding_spr = func_forwarding_reqrite_spr(
		iPREV_WB_SPR_DATA,
		iWB_SPR_VALID,
		iWB_SPR_DATA
	);

	//PDTR
	wire [31:0] prev_forwarding_pdtr = func_forwarding_rewrite_sysreg(
		`SYSREG_PDTR,
		iPREVIOUS_SOURCE_PDTR,
		iWB_GR_VALID,
		iWB_GR_DEST_SYSREG,
		iWB_GR_DEST,
		iWB_GR_DATA
	);

	wire [31:0] cuur_forwarding_pdtr = func_forwarding_rewrite_sysreg(
		`SYSREG_PDTR,
		prev_forwarding_pdtr,
		iWB_GR_VALID,
		iWB_GR_DEST_SYSREG,
		iWB_GR_DEST,
		iWB_GR_DATA
	);

	//KPDTR
	wire [31:0] prev_forwarding_kpdtr = func_forwarding_rewrite_sysreg(
		`SYSREG_KPDTR,
		iPREVIOUS_SOURCE_KPDTR,
		iWB_GR_VALID,
		iWB_GR_DEST_SYSREG,
		iWB_GR_DEST,
		iWB_GR_DATA
	);

	wire [31:0] cuur_forwarding_kpdtr = func_forwarding_rewrite_sysreg(
		`SYSREG_KPDTR,
		prev_forwarding_kpdtr,
		iWB_GR_VALID,
		iWB_GR_DEST_SYSREG,
		iWB_GR_DEST,
		iWB_GR_DATA
	);

	//TIDR
	wire [31:0] prev_forwarding_tidr = func_forwarding_rewrite_sysreg(
		`SYSREG_TIDR,
		iPREVIOUS_SOURCE_PDTR,
		iWB_GR_VALID,
		iWB_GR_DEST_SYSREG,
		iWB_GR_DEST,
		iWB_GR_DATA
	);

	wire [31:0] cuur_forwarding_tidr = func_forwarding_rewrite_sysreg(
		`SYSREG_TIDR,
		prev_forwarding_tidr,
		iWB_GR_VALID,
		iWB_GR_DEST_SYSREG,
		iWB_GR_DEST,
		iWB_GR_DATA
	);

	//PSR
	wire [31:0] prev_forwarding_psr = func_forwarding_rewrite_sysreg(
		`SYSREG_PSR,
		iPREVIOUS_SOURCE_PDTR,
		iWB_GR_VALID,
		iWB_GR_DEST_SYSREG,
		iWB_GR_DEST,
		iWB_GR_DATA
	);

	wire [31:0] cuur_forwarding_psr = func_forwarding_rewrite_sysreg(
		`SYSREG_PSR,
		prev_forwarding_psr,
		iWB_GR_VALID,
		iWB_GR_DEST_SYSREG,
		iWB_GR_DEST,
		iWB_GR_DATA
	);




	assign oNEXT_SOURCE_DATA = cuur_forwarding_data;
	assign oNEXT_SOURCE_SPR = cuur_forwarding_spr;

	assign oNEXT_SOURCE_PDTR = cuur_forwarding_pdtr;
	assign oNEXT_SOURCE_KPDTR = cuur_forwarding_kpdtr;
	assign oNEXT_SOURCE_TIDR = cuur_forwarding_tidr;
	assign oNEXT_SOURCE_PSR = cuur_forwarding_psr;

endmodule

`default_nettype wire


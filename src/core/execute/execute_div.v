

`default_nettype none
`include "core.h"

module execute_div(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//FLAG
		output wire oFLAG_WAITING_DIV,
		//Prev
		input wire iPREV_VALID,
		input wire iPREV_UDIV,
		input wire iPREV_SDIV,
		input wire [4:0] iCMD,
		//iDATA
		input wire [31:0] iDATA_0,
		input wire [31:0] iDATA_1,
		//oDATA
		input wire iBUSY,
		output wire oDATA_VALID,
		output wire [31:0] oDATA
	);

	wire divider_condition = iPREV_VALID && (iPREV_UDIV || iPREV_SDIV) && !iBUSY;

	wire divider_out_valid;
	wire [31:0] divider_out_q;
	wire [31:0] divider_out_r;

	pipelined_div_radix2 EXE_DIV(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(iRESET_SYNC),
		//Source
		.oSOURCE_BUSY(/* Not Use*/),
		.iSOURCE_VALID(divider_condition),
		.iSOURCE_SIGN(iPREV_SDIV),
		.iSOURCE_DIVIDEND(iDATA_0),
		.iSOURCE_DIVISOR(iDATA_1),
		//Output
		.iOUT_BUSY(1'b0),
		.oOUT_VALID(divider_out_valid),
		.oOUT_DATA_Q(divider_out_q),
		.oOUT_DATA_R(divider_out_r)
	);

	reg b_div_wait;

	localparam PL_IDLE = 1'b0;
	localparam PL_WAIT = 1'b1;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_div_wait <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_div_wait <= PL_IDLE;
		end
		else begin
			case(b_div_wait)
				PL_IDLE:
					begin
						if(divider_condition)begin
							b_div_wait <= PL_WAIT;
						end
					end
				PL_WAIT:
					begin
						if(divider_out_valid)begin
							b_div_wait <= PL_IDLE;
						end
					end
			endcase
		end
	end

	reg b_div_q_r_condition;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_div_q_r_condition <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_div_q_r_condition <= 1'b0;
		end
		else begin
			if(b_div_wait == PL_IDLE)begin
				if(divider_condition)begin
					b_div_q_r_condition <= ((iPREV_UDIV && iCMD == `EXE_DIV_UMOD || iPREV_SDIV && iCMD == `EXE_DIV_MOD))? 1'b0 : 1'b1;	//0:R 1:Q
				end
			end
		end
	end


	assign oDATA_VALID = divider_out_valid;
	assign oDATA = (b_div_q_r_condition)? divider_out_q : divider_out_r;
	assign oFLAG_WAITING_DIV = b_div_wait;

endmodule

`default_nettype wire 



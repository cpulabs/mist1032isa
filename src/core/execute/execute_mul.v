

`default_nettype none
`include "core.h"

module execute_mul(
		input wire [4:0] iCMD,
		//iDATA
		input wire [31:0] iDATA_0,
		input wire [31:0] iDATA_1,
		//oDATA
		output wire [31:0] oDATA,
		output wire [4:0] oFLAGS
	);

	wire [63:0]	mul_tmp;
	wire mul_sf_l;
	wire mul_cf_l;
	wire mul_of_l;
	wire mul_pf_l;
	wire mul_zf_l;
	wire mul_sf_h;
	wire mul_cf_h;
	wire mul_of_h;
	wire mul_pf_h;
	wire mul_zf_h;


	assign mul_tmp = iDATA_0 * iDATA_1;
	assign mul_sf_l = mul_tmp[31];
	assign mul_cf_l = mul_tmp[32];
	assign mul_of_l = mul_tmp[31] ^ mul_tmp[32];
	assign mul_pf_l = mul_tmp[0];
	assign mul_zf_l = (mul_tmp == {64{1'b0}})? 1'b1 : 1'b0;
	assign mul_sf_h = mul_tmp[63];
	assign mul_cf_h = 1'b0;
	assign mul_of_h = 1'b0;
	assign mul_pf_h = mul_tmp[32];
	assign mul_zf_h = (mul_tmp == {64{1'b0}})? 1'b1 : 1'b0;

	assign oFLAGS = (iCMD == `EXE_MUL_MULH || iCMD == `EXE_MUL_UMULH)? {mul_sf_h, mul_of_h, mul_cf_h, mul_pf_h, mul_zf_h} : {mul_sf_l, mul_of_l, mul_cf_l, mul_pf_l, mul_zf_l};
	assign oDATA = (iCMD == `EXE_MUL_MULH || iCMD == `EXE_MUL_UMULH)? mul_tmp[63:32] : mul_tmp[31:0];



endmodule

`default_nettype wire 



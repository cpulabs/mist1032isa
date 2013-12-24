
`default_nettype none
`include "core.h"
`include "irq.h"
`include "common.h"

`define MIST32_AFE_ENA


module execute(
		input wire iCLOCK,
		input wire inRESET,
		input wire iFREE_REGISTER_LOCK,
		input wire iFREE_PIPELINE_STOP,
		input wire iFREE_REFRESH,
		//Lock
		output wire oEXCEPTION_LOCK,
		output wire oEXCEPTION_LDST_LOCK,
		//System Register
		output wire [31:0] oSYSREG_FLAGR,
		//Pipeline 
		input wire iPREVIOUS_VALID,	
		input wire iPREVIOUS_FAULT_PAGEFAULT,
		input wire iPREVIOUS_FAULT_PRIVILEGE_ERROR,
		input wire iPREVIOUS_FAULT_INVALID_INST,
		input wire iPREVIOUS_PAGING_ENA,
		input wire iPREVIOUS_KERNEL_ACCESS,
		input wire iPREVIOUS_BRANCH_PREDICT,
		input wire [31:0] iPREVIOUS_BRANCH_PREDICT_ADDR,	
		input wire [31:0] iPREVIOUS_SYSREG_PSR,
		input wire [31:0] iPREVIOUS_SYSREG_TIDR,
		input wire [31:0] iPREVIOUS_SYSREG_PDTR,
		input wire iPREVIOUS_DESTINATION_SYSREG,
		input wire [4:0] iPREVIOUS_DESTINATION,			
		input wire iPREVIOUS_WRITEBACK,	
		input wire iPREVIOUS_FLAGS_WRITEBACK,	
		input wire [4:0] iPREVIOUS_CMD,
		input wire [3:0] iPREVIOUS_CC_AFE,	
		input wire [31:0] iPREVIOUS_SPR,
		input wire [31:0] iPREVIOUS_SOURCE0,
		input wire [31:0] iPREVIOUS_SOURCE1,
		input wire [5:0] iPREVIOUS_ADV_DATA,	
		input wire [4:0] iPREVIOUS_SOURCE0_POINTER,
		input wire [4:0] iPREVIOUS_SOURCE1_POINTER,
		input wire iPREVIOUS_SOURCE0_SYSREG,
		input wire iPREVIOUS_SOURCE1_SYSREG,
		input wire iPREVIOUS_SOURCE1_IMM,
		input wire iPREVIOUS_SOURCE0_FLAGS,
		input wire iPREVIOUS_ADV_ACTIVE,
		input wire iPREVIOUS_EX_SYS_REG,		
		input wire iPREVIOUS_EX_SYS_LDST,		
		input wire iPREVIOUS_EX_LOGIC,
		input wire iPREVIOUS_EX_SHIFT,
		input wire iPREVIOUS_EX_ADDER,
		input wire iPREVIOUS_EX_MUL,
		input wire iPREVIOUS_EX_SDIV,
		input wire iPREVIOUS_EX_UDIV,
		input wire iPREVIOUS_EX_LDST,
		input wire iPREVIOUS_EX_BRANCH,
		input wire [31:0] iPREVIOUS_PC,
		output wire oPREVIOUS_LOCK,
		//Load Store Pipe
		output wire oDATAIO_REQ,
		input wire iDATAIO_BUSY,
		output wire [1:0] oDATAIO_ORDER,	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		output wire [3:0] oDATAIO_MASK,		//[0]=Byte0, [1]=Byte1... 
		output wire oDATAIO_RW,				//0=Read 1=Write
		output wire [13:0] oDATAIO_TID,
		output wire [1:0] oDATAIO_MMUMOD,
		output wire [31:0] oDATAIO_PDT,
		output wire [31:0] oDATAIO_ADDR,
		output wire [31:0] oDATAIO_DATA,
		input wire iDATAIO_REQ,
		input wire iDATAIO_PAGEFAULT,
		input wire [13:0] iDATAIO_MMU_FLAGS,
		input wire [31:0] iDATAIO_DATA,
		//Writeback
		output wire oNEXT_VALID,
		output wire [31:0] oNEXT_DATA,
		output wire [4:0] oNEXT_DESTINATION,
		output wire oNEXT_DESTINATION_SYSREG,
		output wire oNEXT_WRITEBACK,
		output wire oNEXT_SPR_WRITEBACK,
		output wire [31:0] oNEXT_SPR, 
		output wire [31:0] oNEXT_PC,
		output wire oNEXT_BRANCH,
		output wire [31:0] oNEXT_BRANCH_PC,
		//System Register Write
		output wire oPDTR_WRITEBACK,
		//Branch
		output wire [31:0] oBRANCH_ADDR,
		output wire oJUMP_VALID,
		output wire oINTR_VALID,
		output wire oIDTSET_VALID,
		output wire oPDTSET_VALID,
		output wire oFAULT_VALID,
		output wire [6:0] oFAULT_NUM,	
		output wire [31:0] oFAULT_FI0R,
		//Branch Predictor			
		output wire oBPREDICT_PREDICT,				//Branch Guess
		output wire oBPREDICT_HIT,					//Guess Hit!
		output wire oBPREDICT_JUMP,					//Branch Active
		output wire [31:0] oBPREDICT_JUMP_ADDR,		//Branch Address
		output wire [31:0] oBPREDICT_INST_ADDR,		//Branch Instruction Memory Address
		//Debug
		input wire iDEBUG_CTRL_REQ,
		input wire iDEBUG_CTRL_STOP,
		input wire iDEBUG_CTRL_START,
		output wire oDEBUG_CTRL_ACK,
		output wire [31:0] oDEBUG_REG_OUT_FLAGR
	);

	localparam L_PARAM_STT_NORMAL =  3'h0;
	localparam L_PARAM_STT_DIV_WAIT = 3'h1;
	localparam L_PARAM_STT_LOAD = 3'h2;
	localparam L_PARAM_STT_STORE = 3'h3;
	localparam L_PARAM_STT_BRANCH = 3'h4;
	localparam L_PARAM_STT_EXCEPTION = 3'h5;
	localparam L_PARAM_STT_HALT = 3'h6;
	
	//Debugger
	reg [1:0] b_debug_state;
	reg b_debug_stop;
	reg b_debug_cmd_ack;

	reg b_valid;
	reg b_paging_ena;
	reg b_kernel_access;
	reg [31:0] b_sysreg_psr;
	reg [31:0] b_sysreg_tidr;
	reg [31:0] b_sysreg_pdtr;
	reg [2:0] b_state;
	reg b_load_store;
	reg b_writeback;
	reg b_destination_sysreg;
	reg [4:0] b_destination;
	reg [3:0] b_afe;
	reg [31:0] b_r_data;
	reg b_spr_writeback;
	reg [31:0] b_r_spr;
	reg b_ldst_pipe_valid;
	reg [1:0] b_ldst_pipe_order;
	reg [31:0] b_ldst_pipe_addr;
	reg [31:0] b_ldst_pipe_data;
	reg [3:0] b_ldst_pipe_mask;
	reg [1:0] b_load_pipe_shift;
	reg [1:0] b_load_pipe_mask;
	reg b_exception_valid;
	reg [6:0] b_exception_num;
	reg [31:0] b_exception_fi0r;
	reg b_jump;
	reg b_idts;
	reg b_pdts;
	reg b_ib;
	reg [31:0] b_branch_addr;
	reg b_branch_predict;	
	reg b_branch_predict_hit;
	reg [31:0] b_branch_predict_addr;
	reg [31:0] b_pc;

	reg b_ex_kind_adder;
	reg b_ex_kind_logic;
	reg b_ex_kind_mul;
	reg b_ex_kind_sdiv;
	reg b_ex_kind_udiv;
	reg b_ex_kind_ldst;
	reg b_ex_kind_shift;
	reg b_ex_kind_branch;
	reg b_ex_kind_sys_reg;
	reg b_ex_kind_sys_ldst;


	reg b_div_wait;
	reg b_div_q_r_condition;


	
	wire lock_condition = (b_state != L_PARAM_STT_NORMAL) || b_div_wait || b_debug_stop;// || iDATAIO_BUSY;
	wire io_lock_condition = iDATAIO_BUSY;
	assign oPREVIOUS_LOCK = lock_condition || iFREE_PIPELINE_STOP;


	wire [31:0] ex_module_source0;
	wire [31:0] ex_module_source1;


	wire forwarding_reg_gr_valid;
	wire [31:0] forwarding_reg_gr_data;
	wire [4:0] forwarding_reg_gr_dest;
	wire forwarding_reg_gr_dest_sysreg;
	wire forwarding_reg_spr_valid;
	wire [31:0] forwarding_reg_spr_data;
	wire [31:0] ex_module_spr;// = forwarding_reg_spr_data;

	//System Register
	wire sys_reg_sf = 1'b0;
	wire sys_reg_of = 1'b0;
	wire sys_reg_cf = 1'b0;
	wire sys_reg_pf = 1'b0;
	wire sys_reg_zf = 1'b0;
	wire [4:0] sys_reg_flags = {sys_reg_sf, sys_reg_of, sys_reg_cf, sys_reg_pf, sys_reg_zf};
	wire [31:0] sys_reg_data;	
	//Logic
	wire logic_sf;
	wire logic_of;
	wire logic_cf;
	wire logic_pf;
	wire logic_zf;
	wire [31:0] logic_data;
	wire [4:0] logic_flags = {logic_sf, logic_of, logic_cf, logic_pf, logic_zf};
	//Shift
	wire shift_sf, shift_of, shift_cf, shift_pf, shift_zf;
	wire [31:0] shift_data;
	wire [4:0] shift_flags = {shift_sf, shift_of, shift_cf, shift_pf, shift_zf};
	//Adder
	wire [31:0] adder_data;
	wire adder_sf, adder_of, adder_cf, adder_pf, adder_zf;
	wire [4:0] adder_flags = {adder_sf, adder_of, adder_cf, adder_pf, adder_zf};
	//MUL
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
	wire [4:0] mul_flags;
	wire [31:0] mul_data;
	//Div
	wire [31:0] divider_out_q;
	wire [31:0] divider_out_r;
	wire divider_condition;
	wire divider_out_valid;
	//Load Store
	wire ldst_spr_valid;
	wire [31:0] ldst_spr;
	wire [31:0] ldst_data;
	wire ldst_pipe_rw;
	wire [31:0] ldst_pipe_addr;
	wire [31:0] ldst_pipe_data;
	wire [1:0] ldst_pipe_order;	
	wire [1:0] load_pipe_shift;
	wire [3:0] load_pipe_mask;
	//Branch
	wire [31:0] branch_branch_addr;
	wire branch_jump_valid;
	wire branch_not_jump_valid;
	wire branch_ib_valid;
	wire branch_idts_valid;
	wire branch_halt_valid;

	//AFE
	wire [31:0] result_data_with_afe;	

	execute_forwarding_register FORWARDING_REGISTER(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iFREE_REFRESH || iFREE_REGISTER_LOCK),
		//Writeback - General Register
		.iWB_GR_VALID(b_valid && b_writeback),
		.iWB_GR_DATA(result_data_with_afe),
		.iWB_GR_DEST(b_destination),
		.iWB_GR_DEST_SYSREG(b_destination_sysreg),
		//Writeback - Stack Point Register
		.iWB_SPR_VALID(b_valid && b_spr_writeback),
		.iWB_SPR_DATA(b_r_spr),
		//Writeback Auto - Stack Point Register
		.iWB_AUTO_SPR_VALID(b_valid && b_destination_sysreg && b_writeback && b_destination == `SYSREG_SPR),
		.iWB_AUTO_SPR_DATA(result_data_with_afe),
		//Current -Stak Point Register
		.iCUUR_SPR_DATA(iPREVIOUS_SPR),					//NEW
		//Fowerding Register Output
		.oFDR_GR_VALID(forwarding_reg_gr_valid),
		.oFDR_GR_DATA(forwarding_reg_gr_data),
		.oFDR_GR_DEST(forwarding_reg_gr_dest),
		.oFDR_GR_DEST_SYSREG(forwarding_reg_gr_dest_sysreg),
		//Fowerding Register Output
		.oFDR_SPR_VALID(forwarding_reg_spr_valid),
		.oFDR_SPR_DATA(forwarding_reg_spr_data)
	);



	execute_forwarding FORWARDING_RS0(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iFREE_REFRESH || iFREE_REGISTER_LOCK),
		//Writeback - General Register
		.iWB_GR_VALID(b_valid && b_writeback),
		.iWB_GR_DATA(result_data_with_afe),
		.iWB_GR_DEST(b_destination),
		.iWB_GR_DEST_SYSREG(b_destination_sysreg),
		//Writeback - Stack Point Register
		.iWB_SPR_VALID(b_valid && b_spr_writeback),
		.iWB_SPR_DATA(b_r_spr),
		//Previous Writeback - General Register
		.iPREV_WB_GR_VALID(forwarding_reg_gr_valid),
		.iPREV_WB_GR_DATA(forwarding_reg_gr_data),
		.iPREV_WB_GR_DEST(forwarding_reg_gr_dest),
		.iPREV_WB_GR_DEST_SYSREG(forwarding_reg_gr_dest_sysreg),
		//Previous Writeback - Stack Point Register
		.iPREV_WB_SPR_VALID(forwarding_reg_spr_valid),
		.iPREV_WB_SPR_DATA(forwarding_reg_spr_data),
		//Source
		.iPREVIOUS_SOURCE_SYSREG(iPREVIOUS_SOURCE0_SYSREG),
		.iPREVIOUS_SOURCE_POINTER(iPREVIOUS_SOURCE0_POINTER),
		.iPREVIOUS_SOURCE_IMM(1'b0/*iPREVIOUS_SOURCE0_IMM*/),
		.iPREVIOUS_SOURCE_DATA(iPREVIOUS_SOURCE0),
		//Output
		.oNEXT_SOURCE_DATA(ex_module_source0),
		.oNEXT_SOURCE_SPR(ex_module_spr)
	);

	execute_forwarding FORWARDING_RS1(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iFREE_REFRESH || iFREE_REGISTER_LOCK),
		//Writeback - General Register
		.iWB_GR_VALID(b_valid && b_writeback),
		.iWB_GR_DATA(result_data_with_afe),
		.iWB_GR_DEST(b_destination),
		.iWB_GR_DEST_SYSREG(b_destination_sysreg),
		//Writeback - Stack Point Register
		.iWB_SPR_VALID(b_valid && b_spr_writeback),
		.iWB_SPR_DATA(b_r_spr),
		//Previous Writeback - General Register
		.iPREV_WB_GR_VALID(forwarding_reg_gr_valid),
		.iPREV_WB_GR_DATA(forwarding_reg_gr_data),
		.iPREV_WB_GR_DEST(forwarding_reg_gr_dest),
		.iPREV_WB_GR_DEST_SYSREG(forwarding_reg_gr_dest_sysreg),
		//Previous Writeback - Stack Point Register
		.iPREV_WB_SPR_VALID(forwarding_reg_spr_valid),
		.iPREV_WB_SPR_DATA(forwarding_reg_spr_data),
		//Source
		.iPREVIOUS_SOURCE_SYSREG(iPREVIOUS_SOURCE1_SYSREG),
		.iPREVIOUS_SOURCE_POINTER(iPREVIOUS_SOURCE1_POINTER),
		.iPREVIOUS_SOURCE_IMM(iPREVIOUS_SOURCE1_IMM),
		.iPREVIOUS_SOURCE_DATA(iPREVIOUS_SOURCE1),
		//Output
		.oNEXT_SOURCE_DATA(ex_module_source1),
		.oNEXT_SOURCE_SPR()
	);


	//Flags Register
	reg [31:0] b_sysreg_flags;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_sysreg_flags <= 32'h0;
		end
		else if(iFREE_PIPELINE_STOP || iFREE_REFRESH || iFREE_REGISTER_LOCK)begin
			b_sysreg_flags <= b_sysreg_flags;
		end
		else begin
			if(!lock_condition && iPREVIOUS_VALID)begin
				//Flag
				if(iPREVIOUS_FLAGS_WRITEBACK)begin
					if(iPREVIOUS_EX_SHIFT)begin
						b_sysreg_flags <= shift_flags;
					end
					else if(iPREVIOUS_EX_ADDER)begin
						b_sysreg_flags <= adder_flags;
					end
					else if(iPREVIOUS_EX_MUL)begin
						b_sysreg_flags <= mul_flags;
					end
					else if(iPREVIOUS_EX_LOGIC)begin	
						b_sysreg_flags <= logic_flags;
					end
				end
			end
		end
	end//General Register Write Back
	


	

	/****************************************
	System Register
	****************************************/	
	execute_sys_reg EXE_SYS_REG(
		.iCMD(iPREVIOUS_CMD),
		.iSOURCE0(ex_module_source0),
		.iSOURCE1(ex_module_source1),
		.oOUT(sys_reg_data)
	);
	
	/****************************************
	Logic
	****************************************/
	wire [4:0] logic_cmd = func_logic_select(iPREVIOUS_CMD);
	
	function [4:0] func_logic_select;
		input [4:0] func_logic_select_cmd;
		
		begin
			case(func_logic_select_cmd)
				`EXE_LOGIC_BUFFER0	:	func_logic_select = 5'h00;	
				`EXE_LOGIC_BUFFER1	:	func_logic_select = 5'h01;
				`EXE_LOGIC_AND		:	func_logic_select = 5'h04;										
				`EXE_LOGIC_OR		:	func_logic_select = 5'h05;								
				`EXE_LOGIC_XOR		:	func_logic_select = 5'h06;							
				`EXE_LOGIC_NOT		:	func_logic_select = 5'h02;										
				`EXE_LOGIC_NAND		:	func_logic_select = 5'h07;									
				`EXE_LOGIC_NOR		:	func_logic_select = 5'h08;								
				`EXE_LOGIC_XNOR		:	func_logic_select = 5'h09;	
				`EXE_LOGIC_TEST		:	func_logic_select = 5'h04;
				`EXE_LOGIC_WBL		:	func_logic_select = 5'h10;													
				`EXE_LOGIC_WBH		:	func_logic_select = 5'h11;
				`EXE_LOGIC_CLB		:	func_logic_select = 5'h0A;
				`EXE_LOGIC_STB		:	func_logic_select = 5'h0B;
				`EXE_LOGIC_CLW		:	func_logic_select = 5'h15;
				`EXE_LOGIC_STW		:	func_logic_select = 5'h16;
				`EXE_LOGIC_BITREV	:	func_logic_select = 5'h0C;
				`EXE_LOGIC_BYTEREV	:	func_logic_select = 5'h0D;
				`EXE_LOGIC_GETBIT	:	func_logic_select = 5'h0E;
				`EXE_LOGIC_GETBYTE	:	func_logic_select = 5'h0F;
				`EXE_LOGIC_LIL		:	func_logic_select = 5'h12;
				`EXE_LOGIC_LIH		:	func_logic_select = 5'h01;
				`EXE_LOGIC_ULIL		:	func_logic_select = 5'h14;	
				default
					begin
						func_logic_select = 5'h00;	
					end
			endcase
		end
	endfunction
				
	
	execute_logic #(32) EXE_LOGIC(	
		.iCONTROL_CMD(logic_cmd),
		.iDATA_0(ex_module_source0), 
		.iDATA_1(ex_module_source1),
		.oDATA(logic_data), 
		.oSF(logic_sf), 
		.oOF(logic_of), 
		.oCF(logic_cf), 
		.oPF(logic_pf), 
		.oZF(logic_zf)
	);
	
	/****************************************
	Shift
	****************************************/	
	execute_shift #(32) EXE_SHIFT(	
		.iCONTROL_MODE(func_shift_select(iPREVIOUS_CMD)),
		.iDATA_0(ex_module_source0), 
		.iDATA_1(ex_module_source1),
		.oDATA(shift_data), 
		.oSF(shift_sf), 
		.oOF(shift_of), 
		.oCF(shift_cf), 
		.oPF(shift_pf), 
		.oZF(shift_zf)
	);


	function [2:0] func_shift_select;
		input [4:0] func_shift_select_cmd;
		begin
			case(func_shift_select_cmd)
				`EXE_SHIFT_BUFFER		:	func_shift_select = 3'h0;
				`EXE_SHIFT_LOGICL		:	func_shift_select = 3'h1;
				`EXE_SHIFT_LOGICR		:	func_shift_select = 3'h2;
				`EXE_SHIFT_ALITHMETICR	:	func_shift_select = 3'h3;
				`EXE_SHIFT_ROTATEL		:	func_shift_select = 3'h4;
				`EXE_SHIFT_ROTATER		:	func_shift_select = 3'h5;
				default					:	func_shift_select = 3'h0;
			endcase
		end
	endfunction


	/****************************************
	Adder
	****************************************/	
	execute_adder	#(32) EXE_ADDER(
		.iDATA_0(ex_module_source0), 
		.iDATA_1(ex_module_source1), 
		.iADDER_CMD(iPREVIOUS_CMD),
		.oDATA(adder_data), 
		.oSF(adder_sf), 
		.oOF(adder_of), 
		.oCF(adder_cf), 
		.oPF(adder_pf), 
		.oZF(adder_zf)
	);

	
	/****************************************
	Mul 
	****************************************/	
	
	assign mul_tmp = ex_module_source0 * ex_module_source1;
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
	
	assign mul_flags = (iPREVIOUS_CMD == `EXE_MUL_MULH || iPREVIOUS_CMD == `EXE_MUL_UMULH)? {mul_sf_h, mul_of_h, mul_cf_h, mul_pf_h, mul_zf_h} : {mul_sf_l, mul_of_l, mul_cf_l, mul_pf_l, mul_zf_l};
	assign mul_data = (iPREVIOUS_CMD == `EXE_MUL_MULH || iPREVIOUS_CMD == `EXE_MUL_UMULH)? mul_tmp[63:32] : mul_tmp[31:0];

	
	
	/*
	wire [4:0] mul_flags = (iPREVIOUS_CMD == `EXE_MUL_MULH)? {mul_sf_h, mul_of_h, mul_cf_h, mul_pf_h, mul_zf_h} : {mul_sf_l, mul_of_l, mul_cf_l, mul_pf_l, mul_zf_l};
	wire [31:0] mul_data = (iPREVIOUS_CMD == `EXE_MUL_MULH)? mul_tmp[63:32] : mul_tmp[31:0];
	
	
	execute_mul_booth32 EXE_MUL_BOOTH(
		//iDATA
		.iDATA_0(ex_module_source0),
		.iDATA_1(ex_module_source1),
		//oDATA
		.oDATA(mul_tmp),
		.oHSF(mul_sf_h),				
		.oHCF(mul_cf_h),
		.oHOF(mul_of_h),
		.oHPF(mul_pf_h),
		.oHZF(mul_zf_h),
		.oLSF(mul_sf_l),				
		.oLCF(mul_cf_l),
		.oLOF(mul_of_l),
		.oLPF(mul_pf_l),
		.oLZF(mul_zf_l)
	);
	*/
	
	/****************************************
	Div
	****************************************/
	assign divider_condition = iPREVIOUS_VALID && (iPREVIOUS_EX_UDIV || iPREVIOUS_EX_SDIV) && !lock_condition;
	
	pipelined_div_radix2 EXE_DIV(
		//System
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iREMOVE(iFREE_REFRESH),
		//Source
		.oSOURCE_BUSY(/* Not Use*/),
		.iSOURCE_VALID(divider_condition),
		.iSOURCE_SIGN(iPREVIOUS_EX_SDIV),
		.iSOURCE_DIVIDEND(ex_module_source0),
		.iSOURCE_DIVISOR(ex_module_source1),
		//Output
		.iOUT_BUSY(1'b0),
		.oOUT_VALID(divider_out_valid),
		.oOUT_DATA_Q(divider_out_q),
		.oOUT_DATA_R(divider_out_r)
	);

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_div_wait <= 1'b0;
			b_div_q_r_condition <= 1'b0;
		end
		else begin
			if(!b_div_wait)begin
				if(divider_condition)begin
					b_div_wait <= 1'b1;
					b_div_q_r_condition <= ((iPREVIOUS_EX_UDIV && iPREVIOUS_CMD == `EXE_DIV_UMOD || iPREVIOUS_EX_SDIV && iPREVIOUS_CMD == `EXE_DIV_MOD))? 1'b0 : 1'b1;	//0:R 1:Q
				end
			end
			else begin
				if(divider_out_valid)begin
					b_div_wait <= 1'b0;
				end
			end
		end
	end

	
	
	/****************************************
	Load Store(Addr calculation)
	****************************************/	
	execute_load_store LDST(
		//Prev
		.iCMD(iPREVIOUS_CMD),
		.iLOADSTORE_MODE(iPREVIOUS_EX_LDST),
		.iSOURCE0(ex_module_source0),
		.iSOURCE1(ex_module_source1),
		.iADV_ACTIVE(iPREVIOUS_ADV_ACTIVE),
		.iADV_DATA(iPREVIOUS_ADV_DATA),
		.iSPR(ex_module_spr),
		.iPC(iPREVIOUS_PC - 32'h4),
		//Output - Writeback
		.oOUT_SPR_VALID(ldst_spr_valid),
		.oOUT_SPR(ldst_spr),
		.oOUT_DATA(ldst_data),
		//Output - LDST Pipe
		.oLDST_RW(ldst_pipe_rw),
		.oLDST_ADDR(ldst_pipe_addr),
		.oLDST_DATA(ldst_pipe_data),
		.oLDST_ORDER(ldst_pipe_order),
		.oLOAD_SHIFT(load_pipe_shift),
		.oLOAD_MASK(load_pipe_mask)
	);
	
	/****************************************
	Branch
	****************************************/
	execute_branch EXE_BRANCH(
		.iDATA_0(ex_module_source0),
		.iDATA_1(ex_module_source1),		
		.iPC(iPREVIOUS_PC - 32'h4),
		.iFLAG(b_sysreg_flags[4:0]),
		.iCC(iPREVIOUS_CC_AFE),
		.iCMD(iPREVIOUS_CMD),
		.oBRANCH_ADDR(branch_branch_addr),
		.oJUMP_VALID(branch_jump_valid),
		.oNOT_JUMP_VALID(branch_not_jump_valid),
		.oIB_VALID(branch_ib_valid),
		.oIDTS_VALID(branch_idts_valid),
		.oHALT_VALID(branch_halt_valid)
	);
	

	/****************************************
	Current Execute Kind
	****************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ex_kind_adder <= 1'b0;
			b_ex_kind_logic <= 1'b0;
			b_ex_kind_mul <= 1'b0;
			b_ex_kind_sdiv <= 1'b0;
			b_ex_kind_udiv <= 1'b0;
			b_ex_kind_ldst <= 1'b0;
			b_ex_kind_shift <= 1'b0;
			b_ex_kind_branch <= 1'b0;
			b_ex_kind_sys_reg <= 1'b0;
			b_ex_kind_sys_ldst <= 1'b0;
		end
		else if(iFREE_REFRESH || iFREE_REGISTER_LOCK)begin
			b_ex_kind_adder <= 1'b0;
			b_ex_kind_logic <= 1'b0;
			b_ex_kind_mul <= 1'b0;
			b_ex_kind_sdiv <= 1'b0;
			b_ex_kind_udiv <= 1'b0;
			b_ex_kind_ldst <= 1'b0;
			b_ex_kind_shift <= 1'b0;
			b_ex_kind_branch <= 1'b0;
			b_ex_kind_sys_reg <= 1'b0;
			b_ex_kind_sys_ldst <= 1'b0;
		end
		else begin
			if(b_state == L_PARAM_STT_NORMAL && iPREVIOUS_VALID && !lock_condition)begin
				b_ex_kind_adder <= iPREVIOUS_EX_ADDER;
				b_ex_kind_logic <= iPREVIOUS_EX_LOGIC;
				b_ex_kind_mul <= iPREVIOUS_EX_MUL;
				b_ex_kind_sdiv <= iPREVIOUS_EX_SDIV;
				b_ex_kind_udiv <= iPREVIOUS_EX_UDIV;
				b_ex_kind_ldst <= iPREVIOUS_EX_LDST;
				b_ex_kind_shift <= iPREVIOUS_EX_SHIFT;
				b_ex_kind_branch <= iPREVIOUS_EX_BRANCH;
				b_ex_kind_sys_reg <= iPREVIOUS_EX_SYS_REG;
				b_ex_kind_sys_ldst <= iPREVIOUS_EX_SYS_LDST;
			end
		end
	end


	/****************************************
	Execution Module Select
	****************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_valid <= 1'b0;
			b_paging_ena <= 1'b0;
			b_kernel_access <= 1'b0;
			b_sysreg_psr <= 32'h0;
			b_sysreg_tidr <= 32'h0;
			b_sysreg_pdtr <= 32'h0;
			b_state <= L_PARAM_STT_NORMAL;
			b_load_store <= 1'b0;
			b_writeback <= 1'b0;
			b_destination_sysreg  <= 1'b0;
			b_destination <= 5'h0;
			b_afe <= 4'h0;
			b_r_data <= 32'h0;
			b_spr_writeback <= 1'b0;
			b_r_spr <= 32'h0;
			b_ldst_pipe_valid <= 1'b0;
			b_ldst_pipe_order <= 2'h0;
			b_ldst_pipe_addr <= 32'h0;
			b_ldst_pipe_data <= 32'h0;
			b_ldst_pipe_mask <= 4'h0;
			b_load_pipe_shift <= 2'h0;
			b_load_pipe_mask <= 2'h0;
			b_exception_valid <= 1'b0;
			b_exception_num <= 7'h0;
			b_exception_fi0r <= 32'h0;
			b_jump <= 1'b0;
			b_idts <= 1'b0;
			b_pdts <= 1'b0;
			b_ib <= 1'b0;
			b_branch_addr <= 32'h0;
			b_branch_predict <= 1'b0;
			b_branch_predict_hit <= 1'b0;
			b_branch_predict_addr <= 32'h0;
			b_pc <= 32'h0;
		end
		else if(iFREE_REFRESH || iFREE_REGISTER_LOCK)begin
			b_valid <= 1'b0;
			b_paging_ena <= 1'b0;
			b_kernel_access <= 1'b0;
			b_sysreg_psr <= 32'h0;
			b_sysreg_tidr <= 32'h0;
			b_sysreg_pdtr <= 32'h0;
			b_state <= L_PARAM_STT_NORMAL;
			b_load_store <= 1'b0;
			b_writeback <= 1'b0;
			b_destination_sysreg  <= 1'b0;
			b_destination <= 5'h0;
			b_afe <= 4'h0;
			b_r_data <= 32'h0;
			b_spr_writeback <= 1'b0;
			b_r_spr <= 32'h0;
			b_ldst_pipe_valid <= 1'b0;
			b_ldst_pipe_order <= 2'h0;
			b_ldst_pipe_addr <= 32'h0;
			b_ldst_pipe_data <= 32'h0;
			b_ldst_pipe_mask <= 4'h0;
			b_load_pipe_shift <= 2'h0;
			b_load_pipe_mask <= 2'h0;
			b_exception_valid <= 1'b0;
			b_exception_num <= 7'h0;
			b_exception_fi0r <= 32'h0;
			b_jump <= 1'b0;
			b_idts <= 1'b0;
			b_pdts <= 1'b0;
			b_ib <= 1'b0;
			b_branch_addr <= 32'h0;
			b_branch_predict <= 1'b0;
			b_branch_predict_hit <= 1'b0;
			b_branch_predict_addr <= 32'h0;
			b_pc <= 32'h0;
		end
		else begin
			case(b_state)
				L_PARAM_STT_NORMAL:
					begin
						b_load_store <= 1'b0;
						if(iPREVIOUS_VALID && !lock_condition)begin
							b_paging_ena <= iPREVIOUS_PAGING_ENA;
							b_kernel_access <= iPREVIOUS_KERNEL_ACCESS;
							b_pc <= iPREVIOUS_PC;
						end
						b_valid <= iPREVIOUS_VALID && !lock_condition;
						if(iPREVIOUS_VALID && !lock_condition)begin
							//Exception Check(Instruction)
							if(iPREVIOUS_FAULT_PAGEFAULT)begin
								b_state <= L_PARAM_STT_EXCEPTION;
								b_exception_valid <= 1'b1;
								b_exception_num <= `INT_NUM_PAGEFAULT;
								b_exception_fi0r <= iPREVIOUS_PC - 32'h4;
								b_branch_predict <= 1'b0;
								b_branch_predict_hit <= 1'b0;
							end
							else if(iPREVIOUS_FAULT_PRIVILEGE_ERROR)begin
								b_state <= L_PARAM_STT_EXCEPTION;
								b_exception_valid <= 1'b1;
								b_exception_num <= `INT_NUM_PRIVILEGE_ERRPR;
								b_exception_fi0r <= iPREVIOUS_PC - 32'h4;
								b_branch_predict <= 1'b0;
								b_branch_predict_hit <= 1'b0;
							end
							else if(iPREVIOUS_FAULT_INVALID_INST)begin
								b_state <= L_PARAM_STT_EXCEPTION;
								b_exception_valid <= 1'b1;
								b_exception_num <= `INT_NUM_INSTRUCTION_INVALID;
								b_exception_fi0r <= iPREVIOUS_PC - 32'h4;
								b_branch_predict <= 1'b0;
								b_branch_predict_hit <= 1'b0;
							end
							else if((iPREVIOUS_EX_SDIV || iPREVIOUS_EX_UDIV) && (ex_module_source1 == 32'h0))begin
								b_state <= L_PARAM_STT_EXCEPTION;
								b_exception_valid <= 1'b1;
								b_exception_num <= `INT_NUM_DIVIDER_ERROR;
								b_exception_fi0r <= iPREVIOUS_PC - 32'h4;
								b_branch_predict <= 1'b0;
								b_branch_predict_hit <= 1'b0;
							end
							//Execute latch
							else begin
								if(iPREVIOUS_EX_SDIV || iPREVIOUS_EX_UDIV)begin
									b_valid <= 1'b0;
									b_state <= L_PARAM_STT_DIV_WAIT;
									b_writeback <= iPREVIOUS_WRITEBACK;
									b_destination_sysreg  <= 1'b0;
									b_destination <= iPREVIOUS_DESTINATION;
									b_afe <= iPREVIOUS_CC_AFE;
									b_spr_writeback <= 1'b0;
									b_r_spr <= 32'h0;
									b_ldst_pipe_valid <= 1'b0;
									b_jump <= 1'b0;
									b_idts <= 1'b0;
									b_pdts <= 1'b0;
									b_ib <= 1'b0;
									b_branch_addr <= 32'h0;	
									b_branch_predict <= 1'b0;
									b_branch_predict_hit <= 1'b0;
								end		
								//Load Store
								else if(iPREVIOUS_EX_LDST)begin 								
									b_load_store <= 1'b1;
									if(!ldst_pipe_rw)begin
										//Load
										b_valid <= 1'b0;
										b_sysreg_psr <= iPREVIOUS_SYSREG_PSR;
										b_sysreg_tidr <= iPREVIOUS_SYSREG_TIDR;
										b_sysreg_pdtr <= iPREVIOUS_SYSREG_PDTR;
										b_writeback <= iPREVIOUS_WRITEBACK;
										b_destination_sysreg  <= iPREVIOUS_DESTINATION_SYSREG;
										b_destination <= iPREVIOUS_DESTINATION;
										b_afe <= iPREVIOUS_CC_AFE;
										b_spr_writeback <= ldst_spr_valid;
										b_r_spr <= ldst_spr;
										b_ldst_pipe_valid <= 1'b1;
										b_ldst_pipe_order <= ldst_pipe_order;
										b_ldst_pipe_addr <= ldst_pipe_addr;
										b_ldst_pipe_mask <= load_pipe_mask;
										b_load_pipe_shift <= load_pipe_shift;
										b_load_pipe_mask <= load_pipe_mask;
										b_state <= L_PARAM_STT_LOAD;
										b_branch_predict <= 1'b0;
										b_branch_predict_hit <= 1'b0;
									end
									else begin
										//Store 
										b_sysreg_psr <= iPREVIOUS_SYSREG_PSR;
										b_sysreg_tidr <= iPREVIOUS_SYSREG_TIDR;
										b_sysreg_pdtr <= iPREVIOUS_SYSREG_PDTR;
										b_writeback <= iPREVIOUS_WRITEBACK;
										b_destination_sysreg  <= iPREVIOUS_DESTINATION_SYSREG;
										b_destination <= 5'h0;
										b_afe <= iPREVIOUS_CC_AFE;
										b_r_data <= ldst_spr;
										b_spr_writeback <= ldst_spr_valid;
										b_r_spr <= ldst_spr;
										b_ldst_pipe_valid <= 1'b1;
										b_ldst_pipe_order <= ldst_pipe_order;
										b_ldst_pipe_addr <= ldst_pipe_addr;
										b_ldst_pipe_data <= ldst_pipe_data;
										b_ldst_pipe_mask <= load_pipe_mask;
										b_jump <= 1'b0;
										b_idts <= 1'b0;
										b_pdts <= 1'b0;
										b_ib <= 1'b0;
										b_branch_addr <= 32'h0;
										b_state <= L_PARAM_STT_STORE;
										b_branch_predict <= 1'b0;
										b_branch_predict_hit <= 1'b0;
									end
								end
								else if(iPREVIOUS_EX_SYS_LDST)begin
									//SPR Store
									if(!ldst_pipe_rw)begin
										b_writeback <= iPREVIOUS_WRITEBACK;
										b_destination_sysreg  <= iPREVIOUS_DESTINATION_SYSREG;
										b_destination <= iPREVIOUS_DESTINATION;
										b_afe <= iPREVIOUS_CC_AFE;
										b_r_data <= ldst_spr;
										b_spr_writeback <= ldst_spr_valid;
										b_r_spr <= ldst_spr;
										b_ldst_pipe_valid <= 1'b0;
										b_jump <= 1'b0;
										b_idts <= 1'b0;
										b_pdts <= 1'b0;
										b_ib <= 1'b0;
										b_branch_addr <= 32'h0;
										b_branch_predict <= 1'b0;
										b_branch_predict_hit <= 1'b0;
									end
									//SPR Read
									else begin
										b_writeback <= iPREVIOUS_WRITEBACK;
										b_destination_sysreg  <= iPREVIOUS_DESTINATION_SYSREG;
										b_destination <= iPREVIOUS_DESTINATION;
										b_afe <= iPREVIOUS_CC_AFE;
										b_r_data <= ldst_spr;
										b_spr_writeback <= ldst_spr_valid;
										b_r_spr <= ldst_spr;
										b_ldst_pipe_valid <= 1'b0;
										b_jump <= 1'b0;
										b_idts <= 1'b0;
										b_pdts <= 1'b0;
										b_ib <= 1'b0;
										b_branch_addr <= 32'h0;
										b_branch_predict <= 1'b0;
										b_branch_predict_hit <= 1'b0;
									end
								end
								//System Register
								else if(iPREVIOUS_EX_SYS_REG)begin
									b_writeback <= iPREVIOUS_WRITEBACK;
									b_destination_sysreg  <= iPREVIOUS_DESTINATION_SYSREG;
									b_destination <= iPREVIOUS_DESTINATION;
									b_afe <= iPREVIOUS_CC_AFE;
									b_r_data <= sys_reg_data;
									b_spr_writeback <= 1'b0;
									b_r_spr <= 32'h0;
									b_ldst_pipe_valid <= 1'b0;
									b_jump <= 1'b0;
									b_idts <= 1'b0;
									b_pdts <= iPREVIOUS_WRITEBACK && (iPREVIOUS_DESTINATION_SYSREG == `SYSREG_PDTR);
									b_ib <= 1'b0;
									b_branch_addr <= iPREVIOUS_PC;
									b_branch_predict <= 1'b0;
									b_branch_predict_hit <= 1'b0;
								end
								//Logic
								else if(iPREVIOUS_EX_LOGIC)begin
									b_writeback <= iPREVIOUS_WRITEBACK;
									b_destination_sysreg  <= 1'b0;
									b_destination <= iPREVIOUS_DESTINATION;
									b_afe <= iPREVIOUS_CC_AFE;
									b_r_data <= logic_data;
									b_spr_writeback <= 1'b0;
									b_r_spr <= 32'h0;
									b_ldst_pipe_valid <= 1'b0;
									b_jump <= 1'b0;
									b_idts <= 1'b0;
									b_pdts <= 1'b0;
									b_ib <= 1'b0;
									b_branch_addr <= 32'h0;
									b_branch_predict <= 1'b0;
									b_branch_predict_hit <= 1'b0;
								end
								//SGHIFT
								else if(iPREVIOUS_EX_SHIFT)begin
									b_writeback <= iPREVIOUS_WRITEBACK;
									b_destination_sysreg  <= 1'b0;
									b_destination <= iPREVIOUS_DESTINATION;
									b_afe <= iPREVIOUS_CC_AFE;
									b_r_data <= shift_data;
									b_spr_writeback <= 1'b0;
									b_r_spr <= 32'h0;
									b_ldst_pipe_valid <= 1'b0;
									b_jump <= 1'b0;
									b_idts <= 1'b0;
									b_pdts <= 1'b0;
									b_ib <= 1'b0;
									b_branch_addr <= 32'h0;
									b_branch_predict <= 1'b0;
									b_branch_predict_hit <= 1'b0;
								end
								//ADDER
								else if(iPREVIOUS_EX_ADDER)begin
									b_writeback <= iPREVIOUS_WRITEBACK;
									b_destination_sysreg  <= 1'b0;
									b_destination <= iPREVIOUS_DESTINATION;
									b_afe <= iPREVIOUS_CC_AFE;
									b_r_data <= adder_data;
									b_spr_writeback <= 1'b0;
									b_r_spr <= 32'h0;
									b_ldst_pipe_valid <= 1'b0;
									b_jump <= 1'b0;
									b_idts <= 1'b0;
									b_pdts <= 1'b0;
									b_ib <= 1'b0;
									b_branch_addr <= 32'h0;
									b_branch_predict <= 1'b0;
									b_branch_predict_hit <= 1'b0;
								end
								//MUL
								else if(iPREVIOUS_EX_MUL)begin
									b_writeback <= iPREVIOUS_WRITEBACK;
									b_destination_sysreg  <= 1'b0;
									b_destination <= iPREVIOUS_DESTINATION;
									b_afe <= iPREVIOUS_CC_AFE;
									b_r_data <= mul_data;
									b_spr_writeback <= 1'b0;
									b_r_spr <= 32'h0;
									b_ldst_pipe_valid <= 1'b0;
									b_jump <= 1'b0;
									b_idts <= 1'b0;
									b_pdts <= 1'b0;
									b_ib <= 1'b0;
									b_branch_addr <= 32'h0;
									b_branch_predict <= 1'b0;
									b_branch_predict_hit <= 1'b0;
								end
								//Branch
								else if(iPREVIOUS_EX_BRANCH)begin
									//Halt
									if(branch_halt_valid)begin
										b_state <= L_PARAM_STT_HALT;
									end
									else if(branch_jump_valid)begin
										//Branch Predict Hardware Enable / Disable
										`ifdef MIST1032ISA_BRANCH_PREDICT
											//Hit Branch Predict
											if(iPREVIOUS_BRANCH_PREDICT && iPREVIOUS_BRANCH_PREDICT_ADDR == branch_branch_addr)begin
												b_writeback <= 1'b0;
												b_destination_sysreg  <= 1'b0;
												b_destination <= 5'h0;
												b_afe <= 4'h0;
												b_r_data <= 32'h0;
												b_spr_writeback <= 1'b0;
												b_r_spr <= 32'h0;
												b_ldst_pipe_valid <= 1'b0;
												b_jump <= 1'b0;
												b_idts <= 1'b0;
												b_pdts <= 1'b0;
												b_ib <= 1'b0;
												b_branch_addr <= branch_branch_addr;
												b_branch_predict <= iPREVIOUS_BRANCH_PREDICT;
												b_branch_predict_hit <= 1'b1;
												b_branch_predict_addr <= iPREVIOUS_BRANCH_PREDICT_ADDR;
											end
											//Un Hit
											else begin
												b_valid <= 1'b0;
												b_state <= L_PARAM_STT_BRANCH;
												b_writeback <= 1'b0;
												b_destination_sysreg  <= 1'b0;
												b_destination <= 5'h0;
												b_afe <= 4'h0;
												b_r_data <= 32'h0;
												b_spr_writeback <= 1'b0;
												b_r_spr <= 32'h0;
												b_ldst_pipe_valid <= 1'b0;
												b_jump <= branch_jump_valid;
												b_idts <= branch_idts_valid;
												b_pdts <= 1'b0;
												b_ib <= branch_ib_valid;
												b_branch_addr <= branch_branch_addr;
												b_branch_predict <= iPREVIOUS_BRANCH_PREDICT;
												b_branch_predict_hit <= 1'b0;
												b_branch_predict_addr <= iPREVIOUS_BRANCH_PREDICT_ADDR;
											end
										`else
											b_valid <= 1'b0;
											b_state <= L_PARAM_STT_BRANCH;
											b_writeback <= 1'b0;
											b_destination_sysreg  <= 1'b0;
											b_destination <= 5'h0;
											b_afe <= 4'h0;
											b_r_data <= 32'h0;
											b_spr_writeback <= 1'b0;
											b_r_spr <= 32'h0;
											b_ldst_pipe_valid <= 1'b0;
											b_jump <= branch_jump_valid;
											b_idts <= branch_idts_valid;
											b_pdts <= 1'b0;
											b_ib <= branch_ib_valid;
											b_branch_addr <= branch_branch_addr;
											b_branch_predict <= iPREVIOUS_BRANCH_PREDICT;
											b_branch_predict_hit <= 1'b0;
											b_branch_predict_addr <= iPREVIOUS_BRANCH_PREDICT_ADDR;
										`endif
									end
									//Other Branch
									else if(branch_idts_valid || branch_ib_valid)begin
										b_valid <= 1'b0;
										b_state <= L_PARAM_STT_BRANCH;
										b_writeback <= 1'b0;
										b_destination_sysreg  <= 1'b0;
										b_destination <= 5'h0;
										b_afe <= 4'h0;
										b_r_data <= 32'h0;
										b_spr_writeback <= 1'b0;
										b_r_spr <= 32'h0;
										b_ldst_pipe_valid <= 1'b0;
										b_jump <= branch_jump_valid;
										b_idts <= branch_idts_valid;
										b_pdts <= 1'b0;
										b_ib <= branch_ib_valid;
										b_branch_addr <= branch_branch_addr;
										b_branch_predict <= iPREVIOUS_BRANCH_PREDICT;
										b_branch_predict_hit <= 1'b0;
										b_branch_predict_addr <= iPREVIOUS_BRANCH_PREDICT_ADDR;
									end
									//Non Branch(Compiler predict instruction)
									else begin
										//Branch Predict Enable
										`ifdef MIST1032ISA_BRANCH_PREDICT
											//Branch Predict Mis hit
											if(branch_not_jump_valid && iPREVIOUS_BRANCH_PREDICT)begin
												b_valid <= 1'b0;
												b_state <= L_PARAM_STT_BRANCH;
												b_writeback <= 1'b0;
												b_destination_sysreg  <= 1'b0;
												b_destination <= 5'h0;
												b_afe <= 4'h0;
												b_r_data <= 32'h0;
												b_spr_writeback <= 1'b0;
												b_r_spr <= 32'h0;
												b_ldst_pipe_valid <= 1'b0;
												b_jump <= branch_not_jump_valid;	//
												b_idts <= branch_idts_valid;
												b_pdts <= 1'b0;
												b_ib <= branch_ib_valid;
												b_branch_addr <= iPREVIOUS_PC;		//Re Fetch
												b_branch_predict <= iPREVIOUS_BRANCH_PREDICT;
												b_branch_predict_hit <= 1'b0;
												b_branch_predict_addr <= iPREVIOUS_BRANCH_PREDICT_ADDR;
											end
											//Other Branch
											else begin
												//b_valid <= 1'b1;/////////////////////////////////// koko kesiteita
												b_writeback <= 1'b0;
												b_destination_sysreg  <= 1'b0;
												b_destination <= 5'h0;
												b_afe <= 4'h0;
												b_r_data <= 32'h0;
												b_spr_writeback <= 1'b0;
												b_r_spr <= 32'h0;
												b_ldst_pipe_valid <= 1'b0;
												b_jump <= branch_jump_valid;
												b_idts <= branch_idts_valid;
												b_pdts <= 1'b0;
												b_ib <= branch_ib_valid;
												b_branch_addr <= branch_branch_addr;
												b_branch_predict <= iPREVIOUS_BRANCH_PREDICT;
												b_branch_predict_hit <= 1'b0;
												b_branch_predict_addr <= iPREVIOUS_BRANCH_PREDICT_ADDR;
											end
										`else
										//Predict Disable
											//b_valid <= 1'b1;////////////////////////////////// koko kesiteita
											b_writeback <= 1'b0;
											b_destination_sysreg  <= 1'b0;
											b_destination <= 5'h0;
											b_afe <= 4'h0;
											b_r_data <= 32'h0;
											b_spr_writeback <= 1'b0;
											b_r_spr <= 32'h0;
											b_ldst_pipe_valid <= 1'b0;
											b_jump <= branch_jump_valid;
											b_idts <= branch_idts_valid;
											b_pdts <= 1'b0;
											b_ib <= branch_ib_valid;
											b_branch_addr <= branch_branch_addr;
											b_branch_predict <= iPREVIOUS_BRANCH_PREDICT;
											b_branch_predict_hit <= 1'b0;
											b_branch_predict_addr <= iPREVIOUS_BRANCH_PREDICT_ADDR;
										`endif
									end
								end
							end
						end
						else begin
							b_ldst_pipe_valid <= 1'b0;
						end
					end
				L_PARAM_STT_DIV_WAIT:
					begin
						b_ldst_pipe_valid <= 1'b0;
						if(divider_out_valid)begin
							b_valid <= 1'b1;
							b_state <= L_PARAM_STT_NORMAL;
							b_r_data <= (b_div_q_r_condition)? divider_out_q : divider_out_r;
						end
						else begin
							b_valid <= 1'b0;
						end
					end
				L_PARAM_STT_LOAD:
					begin
						if(!io_lock_condition)begin
							b_ldst_pipe_valid <= 1'b0;
						end
						
						if(iDATAIO_REQ)begin
							//Pagefault
							if(iDATAIO_PAGEFAULT)begin
								b_state <= L_PARAM_STT_EXCEPTION;
								b_exception_valid <= 1'b1;
								b_exception_num <= `INT_NUM_PAGEFAULT;
								b_exception_fi0r <= b_pc - 32'h4;
							end
							//Exception Check(Load)
							else if(func_mmu_flags_fault_check(b_paging_ena, b_kernel_access, 1'b0, iDATAIO_MMU_FLAGS))begin
								b_state <= L_PARAM_STT_EXCEPTION;
								b_exception_valid <= 1'b1;
								b_exception_num <= `INT_NUM_PRIVILEGE_ERRPR;
								b_exception_fi0r <= iPREVIOUS_PC - 32'h4;
							end
							//Non Error
							else begin
								b_valid <= 1'b1;
								b_state <= L_PARAM_STT_NORMAL;
								b_r_data <= func_load_fairing(b_ldst_pipe_mask, b_load_pipe_shift, iDATAIO_DATA);
								b_spr_writeback <= 1'b1;//1'b0;
								b_r_spr <= b_r_spr;//ldst_spr;
							end
						end
						else begin
							b_valid <= 1'b0;
						end
					end
				L_PARAM_STT_STORE:
					begin
						if(!io_lock_condition)begin
							b_ldst_pipe_valid <= 1'b0;
						end
						
						if(iDATAIO_REQ)begin
							//Pagefault
							if(iDATAIO_PAGEFAULT)begin
								b_state <= L_PARAM_STT_EXCEPTION;
								b_exception_valid <= 1'b1;
								b_exception_num <= `INT_NUM_PAGEFAULT;
								b_exception_fi0r <= b_pc - 32'h4;
							end
							//Exception Check(Load)
							else if(func_mmu_flags_fault_check(b_paging_ena, b_kernel_access, 1'b1, iDATAIO_MMU_FLAGS))begin
								b_state <= L_PARAM_STT_EXCEPTION;
								b_exception_valid <= 1'b1;
								b_exception_num <= `INT_NUM_PRIVILEGE_ERRPR;
								b_exception_fi0r <= iPREVIOUS_PC - 32'h4;
							end
							//Non Error
							else begin
								b_state <= L_PARAM_STT_NORMAL;
							end
						end
					end
				L_PARAM_STT_BRANCH:
					begin
						//Branch Wait
						b_valid <= 1'b0;
						b_jump <= 1'b0;
						b_ldst_pipe_valid <= 1'b0;
						b_state <= L_PARAM_STT_BRANCH;
					end
				L_PARAM_STT_EXCEPTION:
					begin	
						b_exception_valid <= 1'b0;
					end
				L_PARAM_STT_HALT:
					begin
						b_state <= L_PARAM_STT_HALT;
					end
			endcase
		end
	end //state always
	
	/*****************************************************
	MMU Flag Check
	[0]	:	IRQ41 Privilege error.(Page)
	*****************************************************/
	function func_mmu_flags_fault_check;
		input func_paging;
		input func_kernel;				//1:kernel mode
		input func_rw;
		input [5:0] func_mmu_flags;
		begin
			if(func_paging)begin
				//Privilege error check
				if(func_kernel)begin			//Kernell Mode
					case(func_mmu_flags[5:4])
						2'h1:
							begin
								if(func_rw)begin
									func_mmu_flags_fault_check = 1'b1;
								end
								else begin
									func_mmu_flags_fault_check = 1'b0;
								end
							end
						2'h0,
						2'h2,
						2'h3:
							begin
								func_mmu_flags_fault_check = 1'b0;
							end
					endcase
				end
				else begin	//User Mode
					case(func_mmu_flags[5:4])
						2'h0: func_mmu_flags_fault_check = 1'b1;
						2'h1,
						2'h2:
							begin
								if(func_rw)begin
									func_mmu_flags_fault_check = 1'b1;
								end
								else begin
									func_mmu_flags_fault_check = 1'b0;
								end
							end
						2'h3: func_mmu_flags_fault_check = 1'b0;
					endcase
				end
			end
			else begin
				func_mmu_flags_fault_check = 1'h0;
			end
		end
	endfunction
	
	
	/*****************************************************
	Debug Module
	*****************************************************/
	localparam L_PARAM_DEBUG_IDLE = 2'h0;
	localparam L_PARAM_DEBUG_START_REQ = 2'h1;
	localparam L_PARAM_DEBUG_STOP_REQ = 2'h2;
	
	//Debug Module Enable
	`ifdef MIST1032ISA_STANDARD_DEBUGGER
		always@(posedge iCLOCK or negedge inRESET)begin
			if(!inRESET)begin
				b_debug_state <= L_PARAM_DEBUG_IDLE;
				b_debug_stop <= 1'b0;
				b_debug_cmd_ack <= 1'b0;
			end
			else begin
				case(b_debug_state)
					L_PARAM_DEBUG_IDLE:
						begin
							b_debug_cmd_ack <= 1'b0;
							if(iDEBUG_CTRL_REQ && iDEBUG_CTRL_STOP)begin
								b_debug_state <= L_PARAM_DEBUG_START_REQ;
							end
							else if(iDEBUG_CTRL_REQ && iDEBUG_CTRL_START)begin
								b_debug_state <= L_PARAM_DEBUG_STOP_REQ;
							end
						end
					L_PARAM_DEBUG_START_REQ:
						begin
							b_debug_stop <= 1'b0;
							b_debug_cmd_ack <= 1'b1;
							b_debug_state <= L_PARAM_DEBUG_IDLE;
						end
					L_PARAM_DEBUG_STOP_REQ:
						begin
							if(!lock_condition)begin
								b_debug_stop <= 1'b1;
								b_debug_cmd_ack <= 1'b1;
								b_debug_state <= L_PARAM_DEBUG_IDLE;
							end
						end
				endcase
			end
		end
	`else
		always@(posedge iCLOCK or negedge inRESET)begin
			if(!inRESET)begin
				b_debug_state <= L_PARAM_DEBUG_IDLE;
				b_debug_stop <= 1'b0;
				b_debug_cmd_ack <= 1'b0;
			end
			else begin
				b_debug_state <= b_debug_state;
				b_debug_stop <= b_debug_stop;
				b_debug_cmd_ack <= b_debug_cmd_ack;
			end
		end
	`endif
	
	//Debug Module Enable
	`ifdef MIST1032ISA_STANDARD_DEBUGGER
		assign oDEBUG_CTRL_ACK = b_debug_cmd_ack;
		assign oDEBUG_REG_OUT_FLAGR = b_sysreg_flags;
	`else
	//Disable
		assign oDEBUG_CTRL_ACK = 32'h0;
		assign oDEBUG_REG_OUT_FLAGR = 32'h0;
	`endif
	
	
	/*****************************************************
	b_read_shift and b_read_mask comment
	*****************************************************/
	/*
	Memory--->---Shifter---Mask--->---Register
	
	Shifter(b_read_shift)
		0	:	None Shift
		1	:	>>1
		2	:	>>2
		3	:	>>3
		
	Mask(b_read_mask)
		0	:	Data & 0x000000FF
		1	:	Data & 0x0000FFFF
		2	:	Data & 0x00FFFFFF
		3	:	Data & 0xFFFFFFFF
	*/
	/****************************************************/
	
	function [31:0] func_load_mask;	
		input [1:0] func_mask;
		input [31:0] func_data;
		begin
			//Altera Worning Option
			case(func_mask)//synthesis parallel_case full_case
				2'h0: func_load_mask = func_data & 32'h000000FF;
				2'h1: func_load_mask = func_data & 32'h0000FFFF;
				2'h2: func_load_mask = func_data & 32'h00FFFFFF;
				2'h3: func_load_mask = func_data & 32'hFFFFFFFF;
			endcase
		end
	endfunction
	
	function [31:0] func_load_fairing;	
		input [3:0] func_mask;
		input [1:0] func_shift;
		input [31:0] func_data;
		reg [7:0] func_tmp0, func_tmp1, func_tmp2, func_tmp3;
		begin
			if(func_mask == 4'hf)begin
				func_load_fairing = func_data;
			end
			else if(func_mask == 4'b0001)begin
				func_load_fairing = {24'h0, func_data[31:24]};
			end
			else if(func_mask == 4'b0010)begin
				func_load_fairing = {24'h0, func_data[23:16]};
			end
			else if(func_mask == 4'b0100)begin
				func_load_fairing = {24'h0, func_data[15:8]};
			end
			else if(func_mask == 4'b1000)begin
				func_load_fairing = {24'h0, func_data[7:0]};
			end
			else if(func_mask == 4'b0011)begin
				func_load_fairing = {24'h0, func_data[31:16]};
			end
			else begin
			//else if(func_mask == 4'b1100)begin
				func_load_fairing = {24'h0, func_data[15:0]};
			end
			
			/*
			func_tmp0 = (func_mask[0])? func_data[7:0] : 8'h0;
			func_tmp1 = (func_mask[1])? func_data[15:8] : 8'h0;
			func_tmp2 = (func_mask[2])? func_data[23:16] : 8'h0;
			func_tmp3 = (func_mask[3])? func_data[31:24] : 8'h0;
			case(func_shift)
				2'h0 : func_load_fairing = {func_tmp3, func_tmp2, func_tmp1, func_tmp0}; 
				2'h1 : func_load_fairing = {8'h0, func_tmp3, func_tmp2, func_tmp1}; 
				2'h2 : func_load_fairing = {16'h0, func_tmp3, func_tmp2}; 
				2'h3 : func_load_fairing = {24'h0, func_tmp3}; 
			endcase
			*/
		end
	endfunction
	

	/****************************************
	AFE
	****************************************/
	`ifdef MIST32_AFE_ENA


		//AFE - Load / Store
		wire  [31:0] afe_ldst_data_result;
		//Load Store
		execute_afe_load_store AFE_LDST(
			//AFE-Conrtol
			.iAFE_CODE(b_afe),
			//Data-In/Out
			.iDATA(b_r_data),
			.oDATA(afe_ldst_data_result)
		);

		//AFE - Output Select
		function [31:0] func_afe_select;
			input func_ldst;
			input [31:0] func_ldst_data;
			input [31:0] func_non_afe_data;
			begin
				if(func_ldst)begin
					func_afe_select = func_ldst_data;
				end
				else begin
					func_afe_select = func_non_afe_data;
				end
			end
		endfunction

		assign result_data_with_afe = func_afe_select(b_ex_kind_ldst, afe_ldst_data_result, b_r_data);

	`else 
		assign result_data_with_afe = b_r_data;
	`endif
	
	
	//Writeback
	assign oNEXT_VALID = b_valid && !iFREE_PIPELINE_STOP && !iFREE_REGISTER_LOCK;
	assign oNEXT_DATA = result_data_with_afe;
	assign oNEXT_DESTINATION = b_destination;
	assign oNEXT_DESTINATION_SYSREG = b_destination_sysreg;
	assign oNEXT_WRITEBACK = b_writeback;
	assign oNEXT_SPR_WRITEBACK = b_spr_writeback;
	assign oNEXT_SPR = b_r_spr;
	
	//Load Store Pipe
	assign oDATAIO_REQ = (b_state == L_PARAM_STT_LOAD || b_state == L_PARAM_STT_STORE)? b_ldst_pipe_valid && !iFREE_PIPELINE_STOP && !iFREE_REGISTER_LOCK && !io_lock_condition : 1'b0;
	assign oDATAIO_ORDER = b_ldst_pipe_order;
	assign oDATAIO_MASK = b_ldst_pipe_mask;
	assign oDATAIO_RW = (b_state == L_PARAM_STT_STORE)? 1'b1 : 1'b0;
	assign oDATAIO_TID = b_sysreg_tidr[13:0];
	assign oDATAIO_MMUMOD = b_sysreg_psr[1:0];
	assign oDATAIO_PDT = b_sysreg_pdtr;
	assign oDATAIO_ADDR = b_ldst_pipe_addr;
	assign oDATAIO_DATA = b_ldst_pipe_data;
	
	
	//Exception
	assign oBRANCH_ADDR = b_branch_addr;
	assign oJUMP_VALID = b_jump;
	assign oIDTSET_VALID = b_idts;
	assign oPDTSET_VALID = b_pdts;
	assign oINTR_VALID = b_ib;
	
	//System Register Writeback
	assign oPDTR_WRITEBACK = b_destination_sysreg && b_writeback && (b_destination == `SYSREG_PDTR);
	
	assign oEXCEPTION_LOCK = b_load_store || (b_state != L_PARAM_STT_NORMAL)? 1'b1 : 1'b0;	
	assign oEXCEPTION_LDST_LOCK = b_load_store;
	
	assign oNEXT_PC = b_pc;
	assign oNEXT_BRANCH = b_jump || b_idts || b_ib;
	assign oNEXT_BRANCH_PC = b_branch_addr;
		
	assign oFAULT_VALID = b_exception_valid;
	assign oFAULT_NUM = b_exception_num;
	assign oFAULT_FI0R = b_exception_fi0r;
	
	assign oSYSREG_FLAGR = b_sysreg_flags;
	
	wire test_predict = b_branch_predict && b_valid;
	wire test_hit = b_branch_predict_hit && b_valid;
	wire test_miss_hit = b_jump && b_valid;
	
	
	
	assign oBPREDICT_PREDICT = b_branch_predict && b_valid;
	assign oBPREDICT_HIT = (b_branch_predict_hit && b_valid/* && b_branch_predict && (b_branch_addr == b_branch_predict_addr)*/) || (!b_jump && !b_branch_predict && b_valid);
	assign oBPREDICT_JUMP = b_jump;
	assign oBPREDICT_JUMP_ADDR = b_branch_addr;
	assign oBPREDICT_INST_ADDR = b_pc - 32'h00000004;
	
	
	/*************************************************
	Assertion - SVA
	*************************************************/
	//synthesis translate_off
	`ifdef MIST1032ISA_SVA_ASSERTION
	
		property PRO_DATAPIPE_REQ_ACK;
			@(posedge iCLOCK) disable iff (!inRESET || iFREE_REFRESH) (oDATAIO_REQ |-> ##[1:50] iDATAIO_REQ);
		endproperty
		
		assert property(PRO_DATAPIPE_REQ_ACK);
	`endif
	//synthesis translate_on
	
	/*************************************************
	Verilog Assertion
	*************************************************/
	//synthesis translate_off
	function [31:0] func_assert_write_data;
		input [4:0] func_mask;
		input [31:0] func_data;
		begin  
			if(func_mask == 4'hf)begin
				func_assert_write_data = func_data;
			end
			else if(func_mask == 4'b0011)begin
				func_assert_write_data = {16'h0, func_data[15:0]};
			end
			else if(func_mask == 4'b1100)begin
				func_assert_write_data = {16'h0, func_data[31:16]};
			end
			else if(func_mask == 4'b1000)begin
				func_assert_write_data = {24'h0, func_data[31:24]};
			end
			else if(func_mask == 4'b0100)begin
				func_assert_write_data = {24'h0, func_data[23:16]};
			end
			else if(func_mask == 4'b0010)begin
				func_assert_write_data = {24'h0, func_data[15:8]};
			end
			else if(func_mask == 4'b0001)begin
				func_assert_write_data = {24'h0, func_data[7:0]};
			end
			else begin
				func_assert_write_data = 32'h0;
			end
		end
	endfunction
	
	//`ifdef MIST1032ISA_VLG_ASSERTION
	localparam time_ena = 0;
	/*
	integer F_HANDLE;
	initial F_HANDLE = $fopen("ldst_time_dump.log");
	*/
	
	always@(posedge iCLOCK)begin


		//Load
		if(inRESET)begin
			if(iDATAIO_REQ && !oDATAIO_RW && b_state == L_PARAM_STT_LOAD)begin
				if(time_ena == 1)begin
					$display("%d, [L], %x, %x, %x, %x", $time, b_pc-32'h4, b_r_spr,  b_ldst_pipe_addr, func_load_fairing(b_ldst_pipe_mask, b_load_pipe_shift, iDATAIO_DATA));
				end
				else begin
					$display("[L], %x, %x, %x, %x", b_pc-32'h4, b_r_spr,  b_ldst_pipe_addr, func_load_fairing(b_ldst_pipe_mask, b_load_pipe_shift, iDATAIO_DATA));
				end
				//$fdisplay(F_HANDLE, "%d, [L], %x, %x, %x, %x", $time, b_pc-32'h4, b_r_spr,  b_ldst_pipe_addr, func_load_fairing(b_ldst_pipe_mask, b_load_pipe_shift, iDATAIO_DATA));
			end
		end
		//Store
		if(inRESET)begin
			if(oDATAIO_REQ && oDATAIO_RW)begin
				if(time_ena == 1)begin
					$display("%d, [S], %x, %x, %x, %x", $time, b_pc-32'h4, b_r_spr, b_ldst_pipe_addr, func_assert_write_data(b_ldst_pipe_mask, oDATAIO_DATA));
				end
				else begin
					$display("[S], %x, %x, %x, %x", b_pc-32'h4, b_r_spr, b_ldst_pipe_addr, func_assert_write_data(b_ldst_pipe_mask, oDATAIO_DATA));
				end
				//$fdisplay(F_HANDLE, "%d, [S], %x, %x, %x, %x", $time, b_pc-32'h4, b_r_spr, b_ldst_pipe_addr, func_assert_write_data(b_ldst_pipe_mask, oDATAIO_DATA));
			end
		end



		
/*
--------------------------------
[S], "PC", "spr", "addr", "data"
[L], "PC", "spr", "addr", "data"
--------------------------------
*/
		
		
	end
	//`endif
	//synthesis translate_on
endmodule


`default_nettype wire

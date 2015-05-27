
`default_nettype none
`include "core.h"
`include "irq.h"
`include "common.h"

`define MIST32_AFE_ENA


module execute(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Event CTRL
		input wire iEVENT_HOLD,
		input wire iEVENT_START,
		input wire iEVENT_IRQ_FRONT2BACK,
		input wire iEVENT_IRQ_BACK2FRONT,
		input wire iEVENT_END,
		//Legacy
		input wire iFREE_REGISTER_LOCK,
		input wire iFREE_PIPELINE_STOP,
		input wire iFREE_REFRESH,
		//Lock
		output wire oEXCEPTION_LOCK,
		output wire oEXCEPTION_LDST_LOCK,
		//System Register
		input wire [31:0] iSYSREG_PFLAGR,
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
		input wire [31:0] iPREVIOUS_SYSREG_KPDTR,
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
		output wire [13:0] oDATAIO_ASID,
		output wire [1:0] oDATAIO_MMUMOD,
		output wire [2:0] oDATAIO_MMUPS,
		output wire [31:0] oDATAIO_PDT,
		output wire [31:0] oDATAIO_ADDR,
		output wire [31:0] oDATAIO_DATA,
		input wire iDATAIO_REQ,
		input wire [11:0] iDATAIO_MMU_FLAGS,
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
		output wire oPSRSET_VALID,
		output wire oFAULT_VALID,
		output wire [6:0] oFAULT_NUM,
		output wire [31:0] oFAULT_FI0R,
		output wire [31:0] oFAULT_FI1R,
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







	/*********************************************************************************************************
	Wire
	*********************************************************************************************************/
	localparam L_PARAM_STT_NORMAL =  3'h0;
	localparam L_PARAM_STT_DIV_WAIT = 3'h1;
	localparam L_PARAM_STT_LOAD = 3'h2;
	localparam L_PARAM_STT_STORE = 3'h3;
	localparam L_PARAM_STT_BRANCH = 3'h4;
	localparam L_PARAM_STT_RELOAD = 3'h5;
	localparam L_PARAM_STT_EXCEPTION = 3'h6;
	localparam L_PARAM_STT_HALT = 3'h7;



	reg b_valid;
	reg [31:0] b_sysreg_psr;
	reg [31:0] b_sysreg_tidr;
	reg [31:0] b_sysreg_pdt;
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
	reg [31:0] b_exception_fi1r;
	reg b_jump;
	reg b_idts;
	reg b_pdts;
	reg b_psr;
	reg b_ib;
	reg [31:0] b_branch_addr;
	reg b_branch_predict;
	reg b_branch_predict_hit;
	reg [31:0] b_branch_predict_addr;
	reg [31:0] b_pc;



	wire div_wait;
	wire debugger_pipeline_stop;

	wire lock_condition = (b_state != L_PARAM_STT_NORMAL) || div_wait || debugger_pipeline_stop;// || iDATAIO_BUSY;
	wire io_lock_condition = iDATAIO_BUSY;
	assign oPREVIOUS_LOCK = lock_condition || iEVENT_HOLD || iFREE_PIPELINE_STOP;


	wire [31:0] ex_module_source0;
	wire [31:0] ex_module_source1;


	wire forwarding_reg_gr_valid;
	wire [31:0] forwarding_reg_gr_data;
	wire [4:0] forwarding_reg_gr_dest;
	wire forwarding_reg_gr_dest_sysreg;
	wire forwarding_reg_spr_valid;
	wire [31:0] forwarding_reg_spr_data;
	wire [31:0] ex_module_spr;// = forwarding_reg_spr_data;
	wire [31:0] ex_module_pdtr;
	wire [31:0] ex_module_kpdtr;
	wire [31:0] ex_module_tidr;
	wire [31:0] ex_module_psr;

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
	//Mul
	wire [4:0] mul_flags;
	wire [31:0] mul_data;
	//Div
	wire [31:0] div_out_data;
	wire div_out_valid;
	/*
	//Load Store
	wire ldst_spr_valid;
	wire [31:0] ldst_spr;
	wire ldst_pipe_rw;
	wire [31:0] ldst_pipe_addr;
	wire [31:0] ldst_pipe_pdt;
	wire [31:0] ldst_pipe_data;
	wire [1:0] ldst_pipe_order;
	wire [1:0] load_pipe_shift;
	wire [3:0] ldst_pipe_mask;
	*/
	//Branch
	wire [31:0] branch_branch_addr;
	wire branch_jump_valid;
	wire branch_not_jump_valid;
	wire branch_ib_valid;
	wire branch_halt_valid;

	//AFE
	wire [31:0] result_data_with_afe;

	//Flag
	wire [4:0] sysreg_flags_register;


	/*********************************************************************************************************
	Debug Module
	*********************************************************************************************************/
	execute_debugger DEBUGGER(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//Debugger Port
		.iDEBUG_CTRL_REQ(iDEBUG_CTRL_REQ),
		.iDEBUG_CTRL_STOP(iDEBUG_CTRL_STOP),
		.iDEBUG_CTRL_START(iDEBUG_CTRL_START),
		.oDEBUG_CTRL_ACK(oDEBUG_CTRL_ACK),
		.oDEBUG_REG_OUT_FLAGR(oDEBUG_REG_OUT_FLAGR),
		//Pipeline
		.oPIPELINE_STOP(debugger_pipeline_stop),
		//Registers
		.iREGISTER_FLAGR(sysreg_flags_register),
		//Busy
		.iBUSY(lock_condition)
	);

	/*********************************************************************************************************
	Forwarding
	*********************************************************************************************************/
	execute_forwarding_register FORWARDING_REGISTER(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iEVENT_HOLD || iFREE_REFRESH || iFREE_REGISTER_LOCK || iRESET_SYNC),
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
		.iCUUR_SPR_DATA(iPREVIOUS_SPR),
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
		.iRESET_SYNC(iEVENT_HOLD || iFREE_REFRESH || iFREE_REGISTER_LOCK || iRESET_SYNC),
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
		.iPREVIOUS_SOURCE_PDTR(iPREVIOUS_SYSREG_PDTR),
		.iPREVIOUS_SOURCE_KPDTR(iPREVIOUS_SYSREG_KPDTR),
		.iPREVIOUS_SOURCE_TIDR(iPREVIOUS_SYSREG_TIDR),
		.iPREVIOUS_SOURCE_PSR(iPREVIOUS_SYSREG_PSR),
		//Output
		.oNEXT_SOURCE_DATA(ex_module_source0),
		.oNEXT_SOURCE_SPR(ex_module_spr),
		.oNEXT_SOURCE_PDTR(ex_module_pdtr),
		.oNEXT_SOURCE_KPDTR(ex_module_kpdtr),
		.oNEXT_SOURCE_TIDR(ex_module_tidr),
		.oNEXT_SOURCE_PSR(ex_module_psr)
	);

	/*
	assign ex_module_pdtr = iPREVIOUS_SYSREG_PDTR;
	assign ex_module_tidr = iPREVIOUS_SYSREG_TIDR;
	assign ex_module_psr = iPREVIOUS_SYSREG_PSR;
	*/

	execute_forwarding FORWARDING_RS1(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iEVENT_HOLD || iFREE_REFRESH || iFREE_REGISTER_LOCK || iRESET_SYNC),
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
		.iPREVIOUS_SOURCE_PDTR(iPREVIOUS_SYSREG_PDTR),
		.iPREVIOUS_SOURCE_KPDTR(iPREVIOUS_SYSREG_KPDTR),
		.iPREVIOUS_SOURCE_TIDR(iPREVIOUS_SYSREG_TIDR),
		.iPREVIOUS_SOURCE_PSR(iPREVIOUS_SYSREG_PSR),
		//Output
		.oNEXT_SOURCE_DATA(ex_module_source1),
		.oNEXT_SOURCE_SPR(),
		.oNEXT_SOURCE_PDTR(),
		.oNEXT_SOURCE_KPDTR(),
		.oNEXT_SOURCE_TIDR(),
		.oNEXT_SOURCE_PSR()
	);


	/****************************************
	Flag Register
	****************************************/
	execute_flag_register REG_FLAG(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//Control
		.iCTRL_HOLD(iEVENT_HOLD || iFREE_PIPELINE_STOP || iFREE_REFRESH || iFREE_REGISTER_LOCK),
		//PFLAGR
		.iPFLAGR_VALID(iEVENT_IRQ_BACK2FRONT),
		.iPFLAGR(iSYSREG_PFLAGR[4:0]),
		//Prev
		.iPREV_INST_VALID(iPREVIOUS_VALID),
		.iPREV_BUSY(lock_condition),
		.iPREV_FLAG_WRITE(iPREVIOUS_FLAGS_WRITEBACK),
		//Shift
		.iSHIFT_VALID(iPREVIOUS_EX_SHIFT),
		.iSHIFT_FLAG(shift_flags),
		//Adder
		.iADDER_VALID(iPREVIOUS_EX_ADDER),
		.iADDER_FLAG(adder_flags),
		//Mul
		.iMUL_VALID(iPREVIOUS_EX_MUL),
		.iMUL_FLAG(mul_flags),
		//Logic
		.iLOGIC_VALID(iPREVIOUS_EX_LOGIC),
		.iLOGIC_FLAG(logic_flags),
		//oUTPUT
		.oFLAG(sysreg_flags_register)
	);




	/*********************************************************************************************************
	Execute
	*********************************************************************************************************/
	/****************************************
	Logic
	****************************************/
	wire [4:0] logic_cmd;

	execute_logic_decode EXE_LOGIC_DECODER(
		.iPREV_INST(iPREVIOUS_CMD),
		.oNEXT_INST(logic_cmd)
	);

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
	wire [4:0] shift_cmd;

	execute_shift_decode EXE_SHIFT_DECODER(
		.iPREV_INST(iPREVIOUS_CMD),
		.oNEXT_INST(shift_cmd)
	);

	execute_shift #(32) EXE_SHIFT(
		.iCONTROL_MODE(shift_cmd),
		.iDATA_0(ex_module_source0),
		.iDATA_1(ex_module_source1),
		.oDATA(shift_data),
		.oSF(shift_sf),
		.oOF(shift_of),
		.oCF(shift_cf),
		.oPF(shift_pf),
		.oZF(shift_zf)
	);

	/****************************************
	Adder
	****************************************/
	execute_adder #(32) EXE_ADDER(
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
	execute_mul EXE_MUL(
		.iCMD(iPREVIOUS_CMD),
		.iDATA_0(ex_module_source0),
		.iDATA_1(ex_module_source1),
		.oDATA(mul_data),
		.oFLAGS(mul_flags)
	);


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
	execute_div EXE_DIV(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iEVENT_HOLD || iFREE_REFRESH || iRESET_SYNC),
		//FLAG
		.oFLAG_WAITING_DIV(div_wait),
		//Prev
		.iPREV_VALID(iPREVIOUS_VALID),
		.iPREV_UDIV(iPREVIOUS_EX_UDIV),
		.iPREV_SDIV(iPREVIOUS_EX_SDIV),
		.iCMD(iPREVIOUS_CMD),
		//iDATA
		.iDATA_0(ex_module_source0),
		.iDATA_1(ex_module_source1),
		//oDATA
		.iBUSY(lock_condition),
		.oDATA_VALID(div_out_valid),
		.oDATA(div_out_data)
	);


	/****************************************
	Address calculate(Load Store)
	****************************************/
	//Load Store
	wire ldst_spr_valid;
	wire [31:0] ldst_spr;
	wire ldst_pipe_rw;
	wire [31:0] ldst_pipe_pdt;
	wire [31:0] ldst_pipe_addr;
	wire [31:0] ldst_pipe_data;
	wire [1:0] ldst_pipe_order;
	wire [1:0] load_pipe_shift;
	wire [3:0] ldst_pipe_mask;

	execute_adder_calc LDST_CALC_ADDR(
		//Prev
		.iCMD(iPREVIOUS_CMD),
		.iLOADSTORE_MODE(iPREVIOUS_EX_LDST),
		.iSOURCE0(ex_module_source0),
		.iSOURCE1(ex_module_source1),
		.iADV_ACTIVE(iPREVIOUS_ADV_ACTIVE),
		//.iADV_DATA({26'h0, iPREVIOUS_ADV_DATA}),
		.iADV_DATA({{26{iPREVIOUS_ADV_DATA[5]}}, iPREVIOUS_ADV_DATA}),
		.iSPR(ex_module_spr),
		.iPSR(ex_module_psr),
		.iPDTR(ex_module_pdtr),
		.iKPDTR(ex_module_kpdtr),
		.iPC(iPREVIOUS_PC - 32'h4),
		//Output - Writeback
		.oOUT_SPR_VALID(ldst_spr_valid),
		.oOUT_SPR(ldst_spr),
		.oOUT_DATA(),
		//Output - LDST Pipe
		.oLDST_RW(ldst_pipe_rw),
		.oLDST_PDT(ldst_pipe_pdt),
		.oLDST_ADDR(ldst_pipe_addr),
		.oLDST_DATA(ldst_pipe_data),
		.oLDST_ORDER(ldst_pipe_order),
		.oLDST_MASK(ldst_pipe_mask),
		.oLOAD_SHIFT(load_pipe_shift)
	);

	//Load Store
	wire [1:0] load_shift;
	wire [3:0] load_mask;
	execute_load_store STAGE_LDST(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//Event CTRL
		.iEVENT_HOLD(iEVENT_HOLD),
		.iEVENT_START(iEVENT_START),
		.iEVENT_IRQ_FRONT2BACK(iEVENT_IRQ_FRONT2BACK),
		.iEVENT_IRQ_BACK2FRONT(iEVENT_IRQ_BACK2FRONT),
		.iEVENT_END(iEVENT_END),
		//State
		.iSTATE_NORMAL(b_state == L_PARAM_STT_NORMAL),
		.iSTATE_LOAD(b_state == L_PARAM_STT_LOAD),
		.iSTATE_STORE(b_state == L_PARAM_STT_STORE),
		/*************************************
		Previous
		*************************************/
		//Previous - PREDICT
		.iPREV_VALID(iPREVIOUS_VALID),
		.iPREV_EX_LDST(iPREVIOUS_EX_LDST),
		//System Register
		.iPREV_PSR(ex_module_psr),
		.iPREV_TIDR(ex_module_tidr),
		//Writeback
		.iPREV_SPR_VALID(ldst_spr_valid),
		.iPREV_SPR(ldst_spr),
		//Output - LDST Pipe
		.iPREV_LDST_RW(ldst_pipe_rw),
		.iPREV_LDST_PDT(ldst_pipe_pdt),
		.iPREV_LDST_ADDR(ldst_pipe_addr),
		.iPREV_LDST_DATA(ldst_pipe_data),
		.iPREV_LDST_ORDER(ldst_pipe_order),
		.iPREV_LDST_MASK(ldst_pipe_mask),
		.iPREV_LOAD_SHIFT(load_pipe_shift),
		/*************************************
		MA
		*************************************/
		//Output - LDST Pipe
		.oLDST_REQ(oDATAIO_REQ),
		.iLDST_BUSY(iFREE_PIPELINE_STOP || iFREE_REGISTER_LOCK || io_lock_condition),
		.oLDST_RW(oDATAIO_RW),
		.oLDST_PDT(oDATAIO_PDT),
		.oLDST_ADDR(oDATAIO_ADDR),
		.oLDST_DATA(oDATAIO_DATA),
		.oLDST_ORDER(oDATAIO_ORDER),
		.oLDST_MASK(oDATAIO_MASK),
		.oLDST_ASID(oDATAIO_ASID),
		.oLDST_MMUMOD(oDATAIO_MMUMOD),
		.oLDST_MMUPS(oDATAIO_MMUPS),
		.iLDST_VALID(iDATAIO_REQ),
		/*************************************
		Next
		*************************************/
		//Next
		.iNEXT_BUSY(lock_condition),
		.oNEXT_VALID(),
		.oNEXT_SPR_VALID(),
		.oNEXT_SPR(),
		.oNEXT_SHIFT(load_shift),							//It's for after load data sigals
		.oNEXT_MASK(load_mask)								//It's for after load data sigals
	);
	

	//Load Data Mask and Shft
	wire [31:0] load_data;
	execute_load_data LOAD_MASK(
		.iMASK(load_mask),
		.iSHIFT(load_shift),
		.iDATA(iDATAIO_DATA),
		.oDATA(load_data)
	);

	/****************************************
	System Register
	****************************************/
	wire sysreg_ctrl_idt_valid;
	wire sysreg_ctrl_pdt_valid;
	wire sysreg_ctrl_psr_valid;
	wire [31:0] sysreg_reload_addr;

	execute_sys_reg EXE_SYS_REG(
		.iCMD(iPREVIOUS_CMD),
		.iPC(iPREVIOUS_PC),
		.iSOURCE0(ex_module_source0),
		.iSOURCE1(ex_module_source1),
		.oOUT(sys_reg_data),
		.oCTRL_IDT_VALID(sysreg_ctrl_idt_valid),
		.oCTRL_PDT_VALID(sysreg_ctrl_pdt_valid),
		.oCTRL_PSR_VALID(sysreg_ctrl_psr_valid),
		.oCTRL_RELOAD_ADDR(sysreg_reload_addr)
	);

	/****************************************
	Jump
	****************************************/
	//Branch
	execute_branch EXE_BRANCH(
		.iDATA_0(ex_module_source0),
		.iDATA_1(ex_module_source1),
		.iPC(iPREVIOUS_PC - 32'h4),
		.iFLAG(sysreg_flags_register),
		.iCC(iPREVIOUS_CC_AFE),
		.iCMD(iPREVIOUS_CMD),
		.oBRANCH_ADDR(branch_branch_addr),
		.oJUMP_VALID(branch_jump_valid),
		.oNOT_JUMP_VALID(branch_not_jump_valid),
		.oIB_VALID(branch_ib_valid),
		//.oIDTS_VALID(branch_idts_valid),
		.oHALT_VALID(branch_halt_valid)
	);

	//Branch Predict
	wire branch_with_predict_predict_ena;
	wire branch_with_predict_predict_hit;
	wire branch_with_predict_branch_valid;
	wire branch_with_predict_ib_valid;
	wire [31:0] branch_with_predict_jump_addr;

	//Branch Predicter
	execute_branch_predict EXE_BRANCH_PREDICT(
		//State
		.iSTATE_NORMAL(b_state == L_PARAM_STT_NORMAL),
		//Previous - PREDICT
		.iPREV_VALID(iPREVIOUS_VALID),
		.iPREV_EX_BRANCH(iPREVIOUS_EX_BRANCH),
		.iPREV_BRANCH_PREDICT_ENA(iPREVIOUS_BRANCH_PREDICT),
		.iPREV_BRANCH_PREDICT_ADDR(iPREVIOUS_BRANCH_PREDICT_ADDR),
		//BRANCH
		.iPREV_BRANCH_VALID(branch_jump_valid),
		.iPREV_BRANCH_IB_VALID(branch_ib_valid),
		.iPREV_JUMP_ADDR(branch_branch_addr),
		//Next
		.iNEXT_BUSY(lock_condition),
		.oNEXT_PREDICT_HIT(branch_with_predict_predict_hit)
	);

	wire branch_valid_with_predict_miss = branch_not_jump_valid && iPREVIOUS_BRANCH_PREDICT;											//not need jump, but predict jump
	wire branch_valid_with_predict_addr_miss = branch_jump_valid && !(iPREVIOUS_BRANCH_PREDICT && branch_with_predict_predict_hit);		//need jump, but predict addr is diffelent (predict address diffelent)

	wire branch_valid_with_predict = branch_valid_with_predict_miss || branch_valid_with_predict_addr_miss;

	//Jump
	wire jump_stage_predict_ena;
	wire jump_stage_predict_hit;
	wire jump_stage_jump_valid;
	wire [31:0] jump_stage_jump_addr;
	
	wire jump_stage_branch_valid;
	wire jump_stage_branch_ib_valid;
	wire jump_stage_sysreg_idt_valid;
	wire jump_stage_sysreg_pdt_valid;
	wire jump_stage_sysreg_psr_valid;
	execute_jump STAGE_JUMP(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//Event CTRL
		.iEVENT_HOLD(iEVENT_HOLD),
		.iEVENT_START(iEVENT_START),
		.iEVENT_IRQ_FRONT2BACK(iEVENT_IRQ_FRONT2BACK),
		.iEVENT_IRQ_BACK2FRONT(iEVENT_IRQ_BACK2FRONT),
		.iEVENT_END(iEVENT_END),
		//State
		.iSTATE_NORMAL(b_state == L_PARAM_STT_NORMAL),
		//Previous - PREDICT
		.iPREV_VALID(iPREVIOUS_VALID),
		.iPREV_EX_BRANCH(iPREVIOUS_EX_BRANCH),
		.iPREV_EX_SYS_REG(iPREVIOUS_EX_SYS_REG),
		.iPREV_PC(iPREVIOUS_PC),
		.iPREV_BRANCH_PREDICT_ENA(iPREVIOUS_BRANCH_PREDICT),
		.iPREV_BRANCH_PREDICT_HIT(branch_with_predict_predict_hit),
		//BRANCH
		.iPREV_BRANCH_PREDICT_MISS_VALID(branch_valid_with_predict_miss),
		.iPREV_BRANCH_PREDICT_ADDR_MISS_VALID(branch_valid_with_predict_addr_miss),
		.iPREV_BRANCH_IB_VALID(branch_ib_valid),
		.iPREV_BRANCH_ADDR(branch_branch_addr),
		//SYSREG JUMP
		.iPREV_SYSREG_IDT_VALID(sysreg_ctrl_idt_valid),
		.iPREV_SYSREG_PDT_VALID(sysreg_ctrl_pdt_valid),
		.iPREV_SYSREG_PSR_VALID(sysreg_ctrl_psr_valid),
		.iPREV_SYSREG_ADDR(sysreg_reload_addr),
		/*************************************
		Next
		*************************************/
		//Next
		.iNEXT_BUSY(lock_condition),
		.oNEXT_PREDICT_ENA(jump_stage_predict_ena),
		.oNEXT_PREDICT_HIT(jump_stage_predict_hit),
		.oNEXT_JUMP_VALID(jump_stage_jump_valid),
		.oNEXT_JUMP_ADDR(jump_stage_jump_addr),
		//Kaind of Jump
		.oNEXT_TYPE_BRANCH_VALID(jump_stage_branch_valid),
		.oNEXT_TYPE_BRANCH_IB_VALID(jump_stage_branch_ib_valid),
		.oNEXT_TYPE_SYSREG_IDT_VALID(jump_stage_sysreg_idt_valid),
		.oNEXT_TYPE_SYSREG_PDT_VALID(jump_stage_sysreg_pdt_valid),
		.oNEXT_TYPE_SYSREG_PSR_VALID(jump_stage_sysreg_psr_valid)
	);


	/*********************************************************************************************************
	Exception
	*********************************************************************************************************/
	wire except_inst_valid;
	wire [6:0] except_inst_num;

	wire except_ldst_valid;
	wire [6:0] except_ldst_num;

	execute_exception_check_inst EXE_EXCEPTION_INST(
		//Execute Module State
		.iPREV_STATE_NORMAL(b_state == L_PARAM_STT_NORMAL),
		//Previous Instruxtion
		.iPREV_FAULT_PAGEFAULT(iPREVIOUS_FAULT_PAGEFAULT),
		.iPREV_FAULT_PRIVILEGE_ERROR(iPREVIOUS_FAULT_PRIVILEGE_ERROR),
		.iPREV_FAULT_INVALID_INST(iPREVIOUS_FAULT_INVALID_INST),
		.iPREV_FAULT_DIVIDE_ZERO((iPREVIOUS_EX_SDIV || iPREVIOUS_EX_UDIV) && (ex_module_source1 == 32'h0)),
		//Output Exception 
		.oEXCEPT_VALID(except_inst_valid),
		.oEXCEPT_NUM(except_inst_num)
	);

	execute_exception_check_ldst EXE_EXCEPTION_LDST(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//Event CTRL
		.iEVENT_HOLD(iEVENT_HOLD),
		.iEVENT_START(iEVENT_START),
		.iEVENT_IRQ_FRONT2BACK(iEVENT_IRQ_FRONT2BACK),
		.iEVENT_IRQ_BACK2FRONT(iEVENT_IRQ_BACK2FRONT),
		.iEVENT_END(iEVENT_END),
		//Execute Module State
		.iPREV_STATE_NORMAL(b_state == L_PARAM_STT_NORMAL),
		.iPREV_STATE_LDST(b_state == L_PARAM_STT_LOAD),
		//Previous Instruxtion
		.iPREV_VALID(b_state == L_PARAM_STT_NORMAL && iPREVIOUS_VALID && !lock_condition),
		.iPREV_KERNEL_ACCESS(iPREVIOUS_KERNEL_ACCESS),
		.iPREV_PAGING_ENA(iPREVIOUS_PAGING_ENA),
		.iPREV_LDST_RW(ldst_pipe_rw),
		//Load Store
		.iLDST_VALID(iDATAIO_REQ),
		.iLDST_MMU_FLAG(iDATAIO_MMU_FLAGS),
		//Output Exception 
		.oEXCEPT_VALID(except_ldst_valid),
		.oEXCEPT_NUM(except_ldst_num)
	);

	wire exception_valid;
	wire [6:0] exception_num;
	wire [31:0] exception_fi0r;
	wire [31:0] exception_fi1r;

	execute_exception STAGE_EXCEPTION(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//Event CTRL
		.iEVENT_HOLD(iEVENT_HOLD),
		.iEVENT_START(iEVENT_START),
		.iEVENT_IRQ_FRONT2BACK(iEVENT_IRQ_FRONT2BACK),
		.iEVENT_IRQ_BACK2FRONT(iEVENT_IRQ_BACK2FRONT),
		.iEVENT_END(iEVENT_END),
		//Execute Module State
		.iPREV_STATE_NORMAL(b_state == L_PARAM_STT_NORMAL),
		.iPREV_STATE_LDST(b_state == L_PARAM_STT_LOAD),
		//Previous Instruxtion
		.iPREV_VALID(b_state == L_PARAM_STT_NORMAL && iPREVIOUS_VALID && !lock_condition),
		.iPREV_KERNEL_ACCESS(iPREVIOUS_KERNEL_ACCESS),
		.iPREV_PC(iPREVIOUS_PC),
		//Instruction Exception
		.iEXCEPT_INST_VALID(except_inst_valid),
		.iEXCEPT_INST_NUM(except_inst_num),
		//Load Store Exception
		.iEXCEPT_LDST_VALID(except_ldst_valid),
		.iEXCEPT_LDST_NUM(except_ldst_num),
		//Output Exception 
		.oEXCEPT_VALID(exception_valid),
		.oEXCEPT_NUM(exception_num),
		.oEXCEPT_FI0R(exception_fi0r),
		.oEXCEPT_FI1R(exception_fi1r)
	);

	/*********************************************************************************************************
	Pipelined Register
	*********************************************************************************************************/
	/****************************************
	State
	****************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_state <= L_PARAM_STT_NORMAL;
		end
		else if(iEVENT_HOLD || iFREE_REFRESH || iFREE_REGISTER_LOCK || iRESET_SYNC)begin
			b_state <= L_PARAM_STT_NORMAL;
		end
		else begin
			case(b_state)
				L_PARAM_STT_NORMAL:
					begin
						if(iPREVIOUS_VALID && !lock_condition)begin
							//Fault Check
							if(except_inst_valid)begin
								b_state <= L_PARAM_STT_EXCEPTION;
							end
							//Execute 
							else begin
								//Div instruction
								if(iPREVIOUS_EX_SDIV || iPREVIOUS_EX_UDIV)begin
									b_state <= L_PARAM_STT_DIV_WAIT;
								end
								//Load Store
								else if(iPREVIOUS_EX_LDST)begin
									if(!ldst_pipe_rw)begin
										b_state <= L_PARAM_STT_LOAD;
									end
									else begin
										b_state <= L_PARAM_STT_STORE;
									end
								end
								//Branch
								else if(iPREVIOUS_EX_BRANCH)begin
									//Halt
									if(branch_halt_valid)begin
										b_state <= L_PARAM_STT_HALT;
									end
									//Interrupt Return Branch
									else if(branch_ib_valid)begin
										b_state <= L_PARAM_STT_BRANCH;
									end
									//Branch(with Branch predict)
									else if(branch_valid_with_predict)begin
										b_state <= L_PARAM_STT_BRANCH;
									end
								end
								//System Register(for need re-load instructions)
								if(iPREVIOUS_EX_SYS_REG)begin
									if(sysreg_ctrl_idt_valid || sysreg_ctrl_pdt_valid || sysreg_ctrl_psr_valid)begin
										b_state <= L_PARAM_STT_RELOAD;
									end
								end
							end
						end
					end
				L_PARAM_STT_DIV_WAIT:
					begin
						if(div_out_valid)begin
							b_state <= L_PARAM_STT_NORMAL;
						end
					end
				L_PARAM_STT_LOAD:
					begin
						if(iDATAIO_REQ)begin
							//Pagefault || Exception Check(Load)
							if(except_ldst_valid)begin
								b_state <= L_PARAM_STT_EXCEPTION;
							end
							//Non Error
							else begin
								b_state <= L_PARAM_STT_NORMAL;
							end
						end
					end
				L_PARAM_STT_STORE:
					begin
						if(iDATAIO_REQ)begin
							//Pagefault
							//Exception Check(Load)
							if(except_ldst_valid)begin
								b_state <= L_PARAM_STT_EXCEPTION;
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
						b_state <= L_PARAM_STT_BRANCH;
					end
				L_PARAM_STT_RELOAD:
					begin
						//Branch Wait
						b_state <= L_PARAM_STT_RELOAD;
					end
				L_PARAM_STT_EXCEPTION:
					begin
						b_state <= L_PARAM_STT_EXCEPTION;
					end
				L_PARAM_STT_HALT:
					begin
						b_state <= L_PARAM_STT_HALT;
					end
			endcase
		end
	end //state always

	/****************************************
	For PC
	****************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_pc <= 32'h0;
		end
		else if(iEVENT_HOLD || iFREE_REFRESH || iFREE_REGISTER_LOCK || iRESET_SYNC)begin
			b_pc <= 32'h0;
		end
		else begin
			case(b_state)
				L_PARAM_STT_NORMAL:
					begin
						if(iPREVIOUS_VALID && !lock_condition)begin
							b_pc <= iPREVIOUS_PC;
						end
					end
				default:
					begin
						b_pc <= b_pc;
					end
			endcase
		end
	end

	/****************************************
	Result Data
	****************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_r_data <= 32'h0;
		end
		else if(iEVENT_HOLD || iFREE_REFRESH || iFREE_REGISTER_LOCK || iRESET_SYNC)begin
			b_r_data <= 32'h0;
		end
		else begin
			case(b_state)
				L_PARAM_STT_NORMAL:
					begin
						if(iPREVIOUS_VALID && !lock_condition)begin
							//SPR Read Store
							if(iPREVIOUS_EX_SYS_LDST)begin
								b_r_data <= ldst_spr;
							end
							//System Register
							else if(iPREVIOUS_EX_SYS_REG)begin
								b_r_data <= sys_reg_data;
							end
							//Logic
							else if(iPREVIOUS_EX_LOGIC)begin
								b_r_data <= logic_data;
							end
							//SHIFT
							else if(iPREVIOUS_EX_SHIFT)begin
								b_r_data <= shift_data;
							end
							//ADDER
							else if(iPREVIOUS_EX_ADDER)begin
								b_r_data <= adder_data;
							end
							//MUL
							else if(iPREVIOUS_EX_MUL)begin
								b_r_data <= mul_data;
							end
							//Error
							else begin
								b_r_data <= 32'h0;
							end
						end
					end
				L_PARAM_STT_DIV_WAIT:
					begin
						if(div_out_valid)begin
							b_r_data <= div_out_data;
						end
						else begin
							b_r_data <= 32'h0;
						end
					end
				L_PARAM_STT_LOAD:
					begin
						if(iDATAIO_REQ)begin
							b_r_data <= load_data;
						end
					end
				default:
					begin
						b_r_data <= 32'h0;
					end
			endcase
		end
	end

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_r_spr <= 32'h0;
		end
		else if(iEVENT_HOLD || iFREE_REFRESH || iFREE_REGISTER_LOCK || iRESET_SYNC)begin
			b_r_spr <= 32'h0;
		end
		else begin
			case(b_state)
				L_PARAM_STT_NORMAL:
					begin
						if(iPREVIOUS_EX_LDST || iPREVIOUS_EX_SYS_LDST)begin
							b_r_spr <= ldst_spr;
						end
					end
				default:
					begin
						b_r_spr <= b_r_spr;
					end
			endcase
		end
	end

	/****************************************
	Execute Category
	****************************************/
	reg b_ex_category_ldst;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ex_category_ldst <= 1'b0;
		end
		else if(iEVENT_HOLD || iFREE_REFRESH || iFREE_REGISTER_LOCK || iRESET_SYNC)begin
			b_ex_category_ldst <= 1'b0;
		end
		else begin
			if(b_state == L_PARAM_STT_NORMAL && iPREVIOUS_VALID && !lock_condition)begin
				b_ex_category_ldst <= iPREVIOUS_EX_LDST;
			end
		end
	end


	/****************************************
	Pass Line
	****************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_writeback <= 1'b0;
			b_destination_sysreg  <= 1'b0;
			b_destination <= 5'h0;
			b_afe <= 4'h0;
			b_spr_writeback <= 1'b0;
		end
		else if(iEVENT_HOLD || iRESET_SYNC || iFREE_REFRESH || iFREE_REGISTER_LOCK)begin
			b_writeback <= 1'b0;
			b_destination_sysreg  <= 1'b0;
			b_destination <= 5'h0;
			b_afe <= 4'h0;
			b_spr_writeback <= 1'b0;
		end
		else if(b_state == L_PARAM_STT_NORMAL)begin
			if(iPREVIOUS_VALID && !lock_condition)begin
				if(iPREVIOUS_EX_SDIV || iPREVIOUS_EX_UDIV || iPREVIOUS_EX_LDST || iPREVIOUS_EX_SYS_LDST || iPREVIOUS_EX_SYS_REG || iPREVIOUS_EX_LOGIC || iPREVIOUS_EX_SHIFT || iPREVIOUS_EX_ADDER || iPREVIOUS_EX_MUL)begin
					b_writeback <= iPREVIOUS_WRITEBACK && (!except_inst_valid);
					b_destination_sysreg  <= iPREVIOUS_DESTINATION_SYSREG;
					b_destination <= iPREVIOUS_DESTINATION;
					b_afe <= iPREVIOUS_CC_AFE;
					b_spr_writeback <= (iPREVIOUS_EX_LDST || iPREVIOUS_EX_SYS_LDST) && ldst_spr_valid;
				end
				else if(iPREVIOUS_EX_BRANCH)begin
					b_writeback <= 1'b0;
					b_destination_sysreg  <= iPREVIOUS_DESTINATION_SYSREG;
					b_destination <= iPREVIOUS_DESTINATION;
					b_afe <= iPREVIOUS_CC_AFE;
					b_spr_writeback <= 1'b0;
				end
			end
		end
	end


	/****************************************
	Valid
	****************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_valid <= 1'b0;
		end
		else if(iEVENT_HOLD || iFREE_REFRESH || iFREE_REGISTER_LOCK || iRESET_SYNC)begin
			b_valid <= 1'b0;
		end
		else begin
			case(b_state)
				L_PARAM_STT_NORMAL:
					begin
						//Fault Check
						if(iPREVIOUS_VALID && !lock_condition && except_inst_valid)begin
							b_valid <= 1'b1;
						end
						else if(iPREVIOUS_VALID && !lock_condition && (iPREVIOUS_EX_SDIV || iPREVIOUS_EX_UDIV || (iPREVIOUS_EX_LDST && !ldst_pipe_rw)))begin
							b_valid <= 1'b0;
						end
						else if(iPREVIOUS_VALID && !lock_condition && iPREVIOUS_EX_BRANCH)begin
							//Halt
							if(branch_halt_valid)begin
								b_valid <= 1'b1;
							end
							//Interrupt Return Branch
							else if(branch_ib_valid)begin
								b_valid <= 1'b1;
							end
							//Branch(with Branch predict) - True
							else if(branch_valid_with_predict)begin
								b_valid <= 1'b1;
							end
							else if(branch_with_predict_predict_hit)begin
								b_valid <= 1'b1;
							end
							else begin
								b_valid <= 1'b0;
							end
						end
						else begin
							b_valid <= iPREVIOUS_VALID && !lock_condition;
						end
					end
				L_PARAM_STT_DIV_WAIT:
					begin
						if(div_out_valid)begin
							b_valid <= 1'b1;
						end
					end
				L_PARAM_STT_LOAD:
					begin
						if(iDATAIO_REQ)begin
							//not error
							if(!except_ldst_valid)begin
								b_valid <= 1'b1;
							end
						end
					end
				L_PARAM_STT_STORE:
					begin
						if(iDATAIO_REQ)begin
							//not error
							if(!except_ldst_valid)begin
								b_valid <= 1'b1;
							end
						end
					end
				default:
					begin
						b_valid <= 1'b0;
					end
			endcase
		end
	end


	/*********************************************************************************************************
	AFE
	*********************************************************************************************************/
	/****************************************
	AFE - for Load Store
	****************************************/
	wire [31:0] afe_ldst_data_result;
	execute_afe_load_store AFE_LDST(
		//AFE-Conrtol
		.iAFE_CODE(b_afe),
		//Data-In/Out
		.iDATA(b_r_data),
		.oDATA(afe_ldst_data_result)
	);


	/****************************************
	AFE - Select
	****************************************/
	execute_afe AFE_SELECT(
		.iAFE_LDST(b_ex_category_ldst),
		.iAFE_LDST_DATA(afe_ldst_data_result),
		.iRAW_DATA(b_r_data),		
		.oDATA(result_data_with_afe)
	);


	/*********************************************************************************************************
	Assign
	*********************************************************************************************************/
	//Fault
	assign oFAULT_VALID = exception_valid;
	assign oFAULT_NUM = exception_num;
	assign oFAULT_FI0R = exception_fi0r;
	assign oFAULT_FI1R = exception_fi1r;

	//Branch Predict
	assign oBPREDICT_PREDICT = jump_stage_predict_ena;
	assign oBPREDICT_HIT = jump_stage_predict_hit || (!jump_stage_jump_valid && !jump_stage_predict_ena && b_valid);
	assign oBPREDICT_JUMP = jump_stage_jump_valid;
	assign oBPREDICT_JUMP_ADDR = jump_stage_jump_addr;
	assign oBPREDICT_INST_ADDR = b_pc - 32'h00000004;

	//Branch - Next
	assign oNEXT_PC = b_pc;
	assign oNEXT_BRANCH = jump_stage_jump_valid;
	assign oNEXT_BRANCH_PC = jump_stage_jump_addr;

	//Branch - Controller
	assign oBRANCH_ADDR = jump_stage_jump_addr;
	assign oJUMP_VALID = jump_stage_jump_valid;
	assign oINTR_VALID = jump_stage_branch_ib_valid;
	assign oIDTSET_VALID = jump_stage_sysreg_idt_valid;
	assign oPDTSET_VALID = jump_stage_sysreg_pdt_valid;
	assign oPSRSET_VALID = jump_stage_sysreg_psr_valid;

	//Writeback
	/*
	assign oNEXT_VALID = b_valid && !iFREE_PIPELINE_STOP && !iFREE_REGISTER_LOCK;
	assign oNEXT_DATA = result_data_with_afe;
	assign oNEXT_DESTINATION = b_destination;
	assign oNEXT_DESTINATION_SYSREG = b_destination_sysreg;
	assign oNEXT_WRITEBACK = b_writeback && !except_ldst_valid;
	assign oNEXT_SPR_WRITEBACK = b_spr_writeback && !except_ldst_valid;
	assign oNEXT_SPR = b_r_spr;
	*/
	assign oNEXT_VALID = b_valid && !iFREE_PIPELINE_STOP && !iFREE_REGISTER_LOCK;
	assign oNEXT_DATA = result_data_with_afe;
	assign oNEXT_DESTINATION = b_destination;
	assign oNEXT_DESTINATION_SYSREG = b_destination_sysreg;
	assign oNEXT_WRITEBACK = b_writeback && !except_ldst_valid && (b_state != L_PARAM_STT_BRANCH);
	assign oNEXT_SPR_WRITEBACK = b_spr_writeback && !except_ldst_valid && (b_state != L_PARAM_STT_BRANCH);
	assign oNEXT_SPR = b_r_spr;



	//System Register Writeback
	assign oPDTR_WRITEBACK = b_destination_sysreg && b_writeback && (b_destination == `SYSREG_PDTR);

	//assign oEXCEPTION_LOCK = b_ex_category_ldst || (b_state != L_PARAM_STT_NORMAL)? 1'b1 : 1'b0;
	

	assign oEXCEPTION_LOCK = (b_state == L_PARAM_STT_DIV_WAIT) ||  (b_state == L_PARAM_STT_LOAD) ||  (b_state == L_PARAM_STT_STORE) ||  (b_state == L_PARAM_STT_RELOAD); //new 20150526
	


/*
	localparam L_PARAM_STT_NORMAL =  3'h0;
	localparam L_PARAM_STT_DIV_WAIT = 3'h1;
	localparam L_PARAM_STT_LOAD = 3'h2;
	localparam L_PARAM_STT_STORE = 3'h3;
	localparam L_PARAM_STT_BRANCH = 3'h4;
	localparam L_PARAM_STT_RELOAD = 3'h5;
	localparam L_PARAM_STT_EXCEPTION = 3'h6;
	localparam L_PARAM_STT_HALT = 3'h7;
*/






	assign oEXCEPTION_LDST_LOCK = b_ex_category_ldst;

	assign oSYSREG_FLAGR = {27'h0, sysreg_flags_register};

	/*********************************************************************************************************
	Assertion
	*********************************************************************************************************/
	/*************************************************
	Assertion - SVA
	*************************************************/
	//synthesis translate_off
	`ifdef MIST1032ISA_SVA_ASSERTION
		property PRO_DATAPIPE_REQ_ACK;
			@(posedge iCLOCK) disable iff (!inRESET || iFREE_REFRESH || iRESET_SYNC) (oDATAIO_REQ |-> ##[1:50] iDATAIO_REQ);
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

	wire [31:0] for_assertion_store_real_data = func_assert_write_data(b_ldst_pipe_mask, oDATAIO_DATA);

	//synthesis translate_on



/*
--------------------------------
[S], "PC", "spr", "addr", "data"
[L], "PC", "spr", "addr", "data"
--------------------------------
*/


endmodule


`default_nettype wire
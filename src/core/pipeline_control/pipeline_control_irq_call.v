

`default_nettype none
`include "core.h"

module pipeline_control_irq_call(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//System Register
		input wire [31:0] iSYSREG_IDTR,
		input wire [31:0] iSYSREG_PSR,
		input wire [31:0] iSYSREG_SPR,
		input wire [31:0] iSYSREG_TISR,
		input wire [31:0] iSYSREG_TIDR,
		//Request
		input wire iIRQ_START,
		input wire [6:0] iIRQ_NUM,
		//Finish
		output wire oFINISH,
		output wire [31:0] oFINISH_HUNDLER,
		output wire oFINISH_SPR_VALID,
		output wire [31:0] oFINISH_SPR,
		//Load Store
		output wire oLDST_USE,
		output wire oLDST_REQ,
		input wire iLDST_BUSY,
		output wire [1:0] oLDST_ORDER,	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		output wire oLDST_RW,		//0=Read 1=Write
		output wire [13:0] oLDST_ASID,
		output wire [1:0] oLDST_MMUMOD,
		output wire [31:0] oLDST_PDT,
		output wire [31:0] oLDST_ADDR,
		output wire [31:0] oLDST_DATA,
		input wire iLDST_REQ,
		input wire [31:0] iLDST_DATA
	);

	
	//Hundler Load
	wire hundler_load_finish;
	wire [31:0] hundler_load_hundler;

	//SPR Exchange
	wire spr_exchange_finish;
	wire [31:0] spr_exchange_spr;

	/*****************************************************
	State
	*****************************************************/
	localparam PL_STT_IDLE = 2'h0;
	localparam PL_STT_HUNDLER_GET = 2'h1;
	localparam PL_STT_SPR_EXCHANGE = 2'h2;
	localparam PL_STT_DONE = 2'h3;

	wire spr_exchange_condition = iSYSREG_PSR[6:5] == `CORE_MODE_USER;

	reg [1:0] state;
	reg [1:0] b_state;
	always@*begin
		case(b_state)
			PL_STT_IDLE:
				begin
					if(iIRQ_START)begin
						state = PL_STT_HUNDLER_GET;
					end
					else begin
						state = b_state;
					end
				end
			PL_STT_HUNDLER_GET:
				begin
					if(hundler_load_finish)begin
						if(spr_exchange_condition)begin						//if User -> kernel, do need load Kernel-SPR, so do exchange SPR
							state = PL_STT_SPR_EXCHANGE;
						end
						else begin											//if kernel -> kernel, do not need load Kernel-SPR, so do not exchange SPR
							state = PL_STT_DONE;
						end
					end
					else begin
						state = b_state;
					end
				end
			PL_STT_SPR_EXCHANGE:
				begin
					if(spr_exchange_finish)begin
						state = PL_STT_DONE;
					end
					else begin
						state = b_state;
					end
				end
			PL_STT_DONE:
				begin
					state = PL_STT_IDLE;
				end
		endcase // b_state
	end

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_state <= PL_STT_IDLE;
		end
		else if(iRESET_SYNC)begin
			b_state <= PL_STT_IDLE;
		end
		else begin
			b_state <= state;
		end
	end

	reg b_finish;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_finish <= PL_STT_IDLE;
		end
		else if(iRESET_SYNC)begin
			b_finish <= PL_STT_IDLE;
		end
		else begin
			b_finish <= state == PL_STT_DONE;
		end
	end

	reg [1:0] b_state_delay;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_state_delay <= PL_STT_IDLE;
		end
		else if(iRESET_SYNC)begin
			b_state_delay <= PL_STT_IDLE;
		end
		else begin
			b_state_delay <= b_state;
		end
	end



	/*****************************************************
	Hundler Load
	*****************************************************/
	wire hundler_read_ldst_use;
	wire hundler_read_ldst_req;
	wire [1:0] hundler_read_ldst_order;
	wire hundler_read_ldst_rw;
	wire [13:0] hundler_read_ldst_asid;
	wire [1:0] hundler_read_ldst_mmumod;
	wire [31:0] hundler_read_ldst_pdt;
	wire [31:0] hundler_read_ldst_addr;
	wire [31:0] hundler_read_ldst_data;

	pipeline_control_hundler_read HUNDLER_READ(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//System Register
		.iSYSREG_IDTR(iSYSREG_IDTR),
		//Request
		.iRD_START(b_state == PL_STT_IDLE && iIRQ_START),
		.iRD_IRQ_NUM(iIRQ_NUM),
		.oRD_FINISH(hundler_load_finish),
		.oRD_HUNDLER(hundler_load_hundler),
		//Load Store
		.oLDST_USE(hundler_read_ldst_use),
		.oLDST_REQ(hundler_read_ldst_req),
		.iLDST_BUSY(iLDST_BUSY),
		.oLDST_ORDER(hundler_read_ldst_order),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oLDST_RW(hundler_read_ldst_rw),		//0=Read 1=Write
		.oLDST_ASID(hundler_read_ldst_asid),
		.oLDST_MMUMOD(hundler_read_ldst_mmumod),
		.oLDST_PDT(hundler_read_ldst_pdt),
		.oLDST_ADDR(hundler_read_ldst_addr),
		.oLDST_DATA(hundler_read_ldst_data),
		.iLDST_REQ(iLDST_REQ),
		.iLDST_DATA(iLDST_DATA)
	);

	reg [31:0] b_hundler;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_hundler <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_hundler <= 32'h0;
		end
		else begin
			if(b_state == PL_STT_HUNDLER_GET && hundler_load_finish)begin
				b_hundler <= hundler_load_hundler;
			end
		end
	end


	/*****************************************************
	SPR Exchange
	*****************************************************/
	wire spr_excg_ldst_use;
	wire spr_excg_ldst_req;
	wire [1:0] spr_excg_ldst_order;
	wire spr_excg_ldst_rw;
	wire [13:0] spr_excg_ldst_asid;
	wire [1:0] spr_excg_ldst_mmumod;
	wire [31:0] spr_excg_ldst_pdt;
	wire [31:0] spr_excg_ldst_addr;
	wire [31:0] spr_excg_ldst_data;

	pipeline_control_spr_exchange SPR_EXCHANGE(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iRESET_SYNC(iRESET_SYNC),
		//System Register
		.iSYSREG_SPR(iSYSREG_SPR),
		.iSYSREG_TISR(iSYSREG_TISR),
		.iSYSREG_TIDR(iSYSREG_TIDR),
		//Request
		.iRD_START(b_state == PL_STT_HUNDLER_GET && hundler_load_finish && spr_exchange_condition),
		.iRD_KERNEL(1'b1),				//0:User Mode(Kernel -> User) | 1 : Kernel Mode(User -> Kernel)
		//FInish
		.oFINISH(spr_exchange_finish),
		.oFINISH_SPR(spr_exchange_spr),
		//Load Store
		.oLDST_USE(spr_excg_ldst_use),
		.oLDST_REQ(spr_excg_ldst_req),
		.iLDST_BUSY(iLDST_BUSY),
		.oLDST_ORDER(spr_excg_ldst_order),	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
		.oLDST_RW(spr_excg_ldst_rw),		//0=Read 1=Write
		.oLDST_ASID(spr_excg_ldst_asid),
		.oLDST_MMUMOD(spr_excg_ldst_mmumod),
		.oLDST_PDT(spr_excg_ldst_pdt),
		.oLDST_ADDR(spr_excg_ldst_addr),
		.oLDST_DATA(spr_excg_ldst_data),
		.iLDST_REQ(iLDST_REQ),
		.iLDST_DATA(iLDST_DATA)
	);

	reg [31:0] b_spr;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_spr <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_spr <= 32'h0;
		end
		else begin
			if(b_state == PL_STT_SPR_EXCHANGE && spr_exchange_finish)begin
				b_spr <= spr_exchange_spr;
			end
			else if(b_state == PL_STT_IDLE && iIRQ_START)begin
				b_spr <= iSYSREG_SPR;
			end
		end
	end


	/*****************************************************
	Load Store Pipe
	*****************************************************/
	reg [1:0] ldst_pipe_order;
	reg ldst_pipe_rw;
	reg [13:0] ldst_pipe_asid;
	reg [1:0] ldst_pipe_mmumod;
	reg [31:0] ldst_pipe_pdt;
	reg [31:0] ldst_pipe_addr;
	reg [31:0] ldst_pipe_data;

	always@*begin
		if(hundler_read_ldst_use)begin
			ldst_pipe_order = hundler_read_ldst_order;
			ldst_pipe_rw = hundler_read_ldst_rw;
			ldst_pipe_asid = hundler_read_ldst_asid;
			ldst_pipe_mmumod = hundler_read_ldst_mmumod;
			ldst_pipe_pdt = hundler_read_ldst_pdt;
			ldst_pipe_addr = hundler_read_ldst_addr;
			ldst_pipe_data = hundler_read_ldst_data;
		end
		else if(spr_excg_ldst_use)begin
			ldst_pipe_order = spr_excg_ldst_order;
			ldst_pipe_rw = spr_excg_ldst_rw;
			ldst_pipe_asid = spr_excg_ldst_asid;
			ldst_pipe_mmumod = spr_excg_ldst_mmumod;
			ldst_pipe_pdt = spr_excg_ldst_pdt;
			ldst_pipe_addr = spr_excg_ldst_addr;
			ldst_pipe_data = spr_excg_ldst_addr;
		end
		else begin
			ldst_pipe_order = 2'h0;
			ldst_pipe_rw = 1'b0;
			ldst_pipe_asid = 14'h0;
			ldst_pipe_mmumod = 2'h0;
			ldst_pipe_pdt = 32'h0;
			ldst_pipe_addr = 32'h0;
			ldst_pipe_data = 32'h0;
		end
	end

	assign oLDST_USE = hundler_read_ldst_use || spr_excg_ldst_use;
	assign oLDST_REQ = hundler_read_ldst_req || spr_excg_ldst_req;
	assign oLDST_ORDER = ldst_pipe_order;
	assign oLDST_RW = ldst_pipe_rw;
	assign oLDST_ASID = ldst_pipe_asid;
	assign oLDST_MMUMOD = ldst_pipe_mmumod;
	assign oLDST_PDT = ldst_pipe_pdt;
	assign oLDST_ADDR = ldst_pipe_addr;
	assign oLDST_DATA = ldst_pipe_data;



	/*****************************************************
	Assign
	*****************************************************/
	/*
	//Out for 1-Latency
	assign oFINISH = b_finish;
	assign oFINISH_HUNDLER = b_hundler;
	assign oFINISH_SPR = b_spr;
	*/
	
	//Out for none-Latency
	assign oFINISH = state == PL_STT_DONE;
	assign oFINISH_HUNDLER = hundler_load_hundler;
	assign oFINISH_SPR_VALID = (b_state_delay == PL_STT_SPR_EXCHANGE);
	assign oFINISH_SPR = (b_state_delay == PL_STT_SPR_EXCHANGE)? b_spr : iSYSREG_SPR;




endmodule // pipeline_control_irq_call

`default_nettype wire 


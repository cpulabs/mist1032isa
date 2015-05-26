

`default_nettype none

module execute_load_store(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Event CTRL
		input wire iEVENT_HOLD,
		input wire iEVENT_START,
		input wire iEVENT_IRQ_FRONT2BACK,
		input wire iEVENT_IRQ_BACK2FRONT,
		input wire iEVENT_END,
		//State
		input wire iSTATE_NORMAL,
		input wire iSTATE_LOAD,
		input wire iSTATE_STORE,
		/*************************************
		Previous
		*************************************/
		//Previous - PREDICT
		input wire iPREV_VALID,
		input wire iPREV_EX_LDST,
		//System Register
		input wire [31:0] iPREV_PSR,
		input wire [31:0] iPREV_TIDR,
		//Writeback
		input wire iPREV_SPR_VALID,
		input wire [31:0] iPREV_SPR,
		//Output - LDST Pipe
		input wire iPREV_LDST_RW,
		input wire [31:0] iPREV_LDST_PDT,
		input wire [31:0] iPREV_LDST_ADDR,
		input wire [31:0] iPREV_LDST_DATA,
		input wire [1:0] iPREV_LDST_ORDER,
		input wire [3:0] iPREV_LDST_MASK,
		input wire [1:0] iPREV_LOAD_SHIFT,
		/*************************************
		MA
		*************************************/
		//Output - LDST Pipe
		output wire oLDST_REQ,
		input wire iLDST_BUSY,
		output wire oLDST_RW,
		output wire [31:0] oLDST_PDT,
		output wire [31:0] oLDST_ADDR,
		output wire [31:0] oLDST_DATA,
		output wire [1:0] oLDST_ORDER,
		output wire [3:0] oLDST_MASK,
		output wire [13:0] oLDST_ASID,
		output wire [1:0] oLDST_MMUMOD,
		output wire [2:0] oLDST_MMUPS,
		input wire iLDST_VALID,
		/*************************************
		Next
		*************************************/
		//Next
		input wire iNEXT_BUSY,
		output wire oNEXT_VALID,
		output wire oNEXT_SPR_VALID,
		output wire [31:0] oNEXT_SPR,
		output wire [1:0] oNEXT_SHIFT,
		output wire [3:0] oNEXT_MASK
	);




	/*************************************
	State
	*************************************/
	reg [1:0] b_state;

	localparam PL_STT_IDLE = 2'h0;
	localparam PL_STT_REQ = 2'h1;
	localparam PL_STT_WAIT = 2'h2;
	
	wire condition_start_load_store = iPREV_VALID && iPREV_EX_LDST && iSTATE_NORMAL && !iNEXT_BUSY;
	wire condition_req_load_store = ((b_state == PL_STT_IDLE) && condition_start_load_store) || (b_state == PL_STT_REQ);

	/*
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_state <= PL_STT_IDLE;
		end
		else if(iRESET_SYNC || iEVENT_HOLD || iEVENT_END)begin
			b_state <= PL_STT_IDLE;
		end
		else begin
			case(b_state)
				PL_STT_IDLE:
					begin
						if(condition_start_load_store)begin
							if(!iLDST_BUSY)begin
								b_state <= PL_STT_WAIT;
							end
							else begin
								b_state <= PL_STT_REQ;
							end
						end
					end
				PL_STT_REQ:
					begin
						if(!iLDST_BUSY)begin
							b_state <= PL_STT_WAIT;
						end
					end
				PL_STT_WAIT:
					begin
						if(iLDST_VALID)begin
							b_state <= PL_STT_IDLE;
						end
					end
				default:
					begin
						b_state <= PL_STT_IDLE;
					end
			endcase
		end
	end
	*/

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_state <= PL_STT_IDLE;
		end
		else if(iRESET_SYNC || iEVENT_HOLD || iEVENT_END)begin
			b_state <= PL_STT_IDLE;
		end
		else begin
			case(b_state)
				PL_STT_IDLE:
					begin
						if(condition_start_load_store)begin
							b_state <= PL_STT_REQ;
						end
					end
				PL_STT_REQ:
					begin
						if(!iLDST_BUSY)begin
							b_state <= PL_STT_WAIT;
						end
					end
				PL_STT_WAIT:
					begin
						if(iLDST_VALID)begin
							b_state <= PL_STT_IDLE;
						end
					end
				default:
					begin
						b_state <= PL_STT_IDLE;
					end
			endcase
		end
	end

	/*************************************
	Next
	*************************************/
	reg b_spr_valid;
	reg [31:0] b_spr;
	reg [1:0] b_shift;
	reg [3:0] b_mask;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_spr_valid <= 1'b0;
			b_spr <= 32'h0;
			b_shift <= 2'h0;
			b_mask <= 4'h0;
		end
		else if(iRESET_SYNC || iEVENT_HOLD || iEVENT_END)begin
			b_spr_valid <= 1'b0;
			b_spr <= 32'h0;
			b_shift <= 2'h0;
			b_mask <= 4'h0;
		end
		else begin
			if(condition_start_load_store)begin	
				b_spr_valid <= iPREV_SPR_VALID;
				b_spr <= iPREV_SPR;
				b_shift <= iPREV_LOAD_SHIFT;
				b_mask <= iPREV_LDST_MASK;
			end
		end
	end

	assign oNEXT_VALID = (b_state == PL_STT_WAIT) && iLDST_VALID;

	assign oNEXT_SPR_VALID = b_spr_valid;
	assign oNEXT_SPR = b_spr;
	assign oNEXT_SHIFT = b_shift;
	assign oNEXT_MASK = b_mask;

	/*************************************
	LDST
	*************************************/
	reg b_ldst_rw;
	reg [31:0] b_ldst_pdt;
	reg [31:0] b_ldst_addr;
	reg [31:0] b_ldst_data;
	reg [1:0] b_ldst_order;
	reg [3:0] b_ldst_mask;
	reg [13:0] b_ldst_asid;
	reg [1:0] b_ldst_mmumod;
	reg [2:0] b_ldst_mmups;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ldst_rw <= 1'b0;
			b_ldst_pdt <= 32'h0;
			b_ldst_addr <= 32'h0;
			b_ldst_data <= 32'h0;
			b_ldst_order <= 2'h0;
			b_ldst_mask <= 4'h0;
			b_ldst_asid <= 14'h0;
			b_ldst_mmumod <= 2'h0;
			b_ldst_mmups <= 3'h0;
		end
		else if(iRESET_SYNC || iEVENT_HOLD || iEVENT_END)begin
			b_ldst_rw <= 1'b0;
			b_ldst_pdt <= 32'h0;
			b_ldst_addr <= 32'h0;
			b_ldst_data <= 32'h0;
			b_ldst_order <= 2'h0;
			b_ldst_mask <= 4'h0;
			b_ldst_asid <= 14'h0;
			b_ldst_mmumod <= 2'h0;
			b_ldst_mmups <= 3'h0;
		end
		else begin
			if(iSTATE_NORMAL)begin	
				if(!iNEXT_BUSY)begin
					if(iPREV_VALID && iPREV_EX_LDST)begin
						b_ldst_rw <= iPREV_LDST_RW;
						b_ldst_pdt <= iPREV_LDST_PDT;
						b_ldst_addr <= iPREV_LDST_ADDR;
						b_ldst_data <= iPREV_LDST_DATA;
						b_ldst_order <= iPREV_LDST_ORDER;
						b_ldst_mask <= iPREV_LDST_MASK;
						b_ldst_asid <= iPREV_TIDR[31:18];
						b_ldst_mmumod <= iPREV_PSR[1:0];
						b_ldst_mmups <= iPREV_PSR[9:7];
					end
				end
			end
		end
	end

	assign oLDST_REQ = (b_state == PL_STT_REQ) && !iLDST_BUSY;
	assign oLDST_RW = b_ldst_rw;
	assign oLDST_PDT = b_ldst_pdt;
	assign oLDST_ADDR = b_ldst_addr;
	assign oLDST_DATA = b_ldst_data;
	assign oLDST_ORDER = b_ldst_order;
	assign oLDST_MASK = b_ldst_mask;
	assign oLDST_ASID = b_ldst_asid;
	assign oLDST_MMUMOD = b_ldst_mmumod;
	assign oLDST_MMUPS = b_ldst_mmups;


endmodule // execute_jump


`default_nettype wire




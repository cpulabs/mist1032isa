


`include "core.h"
`default_nettype none

module pipeline_control_spr_exchange(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//System Register
		input wire [31:0] iSYSREG_SPR,
		input wire [31:0] iSYSREG_TISR,
		input wire [31:0] iSYSREG_TIDR,
		//Request
		input wire iRD_START,
		input wire iRD_KERNEL,				//0:User Mode(Kernel -> User) | 1 : Kernel Mode(User -> Kernel)
		//FInish
		output wire oFINISH,
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



	/***************************************************************************
	State
	***************************************************************************/
	localparam L_PARAM_IDLE = 3'h0;
	localparam L_PARAM_LOAD_REQ = 3'h1;
	localparam L_PARAM_LOAD_ACK = 3'h2;
	localparam L_PARAM_STORE_REQ = 3'h3;
	localparam L_PARAM_STORE_ACK = 3'h4;

	reg [2:0] state;
	reg [2:0] b_state;
	
	always@*begin
		case(b_state)
			L_PARAM_IDLE:
				begin
					if(iRD_START)begin
						state = L_PARAM_LOAD_REQ;
					end
					else begin
						state = L_PARAM_IDLE;
					end
				end
			L_PARAM_LOAD_REQ:
				begin
					if(!iLDST_BUSY)begin
						state = L_PARAM_LOAD_ACK;
					end
					else begin
						state = L_PARAM_LOAD_REQ;
					end
				end
			L_PARAM_LOAD_ACK:
				begin
					//Get Check
					if(iLDST_REQ)begin
						state = L_PARAM_STORE_REQ;
					end
					else begin
						state = L_PARAM_LOAD_ACK;
					end
				end
			L_PARAM_STORE_REQ:
				begin
					if(!iLDST_BUSY)begin
						state = L_PARAM_STORE_ACK;
					end
					else begin
						state = L_PARAM_STORE_REQ;
					end
				end
			L_PARAM_STORE_ACK:
				begin
					//Get Check
					if(iLDST_REQ)begin
						state = L_PARAM_IDLE;
					end
					else begin
						state = L_PARAM_STORE_ACK;
					end
				end
			default:
				begin
					state = L_PARAM_IDLE;
				end
		endcase
	end


	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_state <= L_PARAM_IDLE;
		end
		else if(iRESET_SYNC)begin
			b_state <= L_PARAM_IDLE;
		end
		else begin
			b_state <= state;
		end
	end

	reg b_finish;
	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_finish <= 1'b0;
		end
		else if(iRESET_SYNC)begin
			b_finish <= 1'b0;
		end
		else begin
			b_finish <= (state == L_PARAM_STORE_ACK) && iLDST_REQ;
		end
	end

	/***************************************************************************
	Load Data Buffer
	***************************************************************************/
	reg [31:0] b_load_data;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_load_data <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_load_data <= 32'h0;
		end
		else begin
			if((state == L_PARAM_LOAD_ACK) && iLDST_REQ)begin
				b_load_data <= iLDST_DATA;
			end
		end
	end



	/***************************************************************************
	Load Store Pipe
	***************************************************************************/
	reg b_ldst_use;
	reg b_ldst_req;
	reg [31:0] b_ldst_data;

	wire [31:0] uspr_addr = iSYSREG_TISR + {iSYSREG_TIDR[13:0], 8'h0} + `TST_USPR;
	wire [31:0] kspr_addr = iSYSREG_TISR + {iSYSREG_TIDR[13:0], 8'h0} + `TST_KSPR;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ldst_use <= 1'b0;
			b_ldst_req <= 1'b0;
			b_ldst_data <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_ldst_use <= 1'b0;
			b_ldst_req <= 1'b0;
			b_ldst_data <= 32'h0;
		end
		else begin
			b_ldst_use <= state != L_PARAM_IDLE;
			b_ldst_req <= state == L_PARAM_STORE_REQ || state == L_PARAM_LOAD_REQ;
			b_ldst_data <= iSYSREG_SPR;
		end
	end

	reg [31:0] b_ldst_addr;
		always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ldst_addr <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_ldst_addr <= 32'h0;
		end
		else begin
			if(iRD_KERNEL)begin
				if(state == L_PARAM_STORE_REQ)begin
					b_ldst_addr <= uspr_addr;
				end
				else begin
					b_ldst_addr <= kspr_addr;
				end
			end
			else begin
				if(state == L_PARAM_STORE_REQ)begin
					b_ldst_addr <= kspr_addr;
				end
				else begin
					b_ldst_addr <= uspr_addr;
				end
			end
		end
	end


	/***************************************************************************
	Assign
	***************************************************************************/
	assign oFINISH = b_finish;
	assign oFINISH_SPR = b_load_data;

	assign oLDST_USE = b_ldst_use;
	assign oLDST_REQ = b_ldst_req;
	assign oLDST_ORDER = 2'h2;	//00=Byte Order 01=2Byte Order 10= Word Order 11= None
	assign oLDST_RW = 1'b0;		//0=Read 1=Write
	assign oLDST_ASID = 14'h0;
	assign oLDST_MMUMOD = 2'h0;
	assign oLDST_PDT = 32'h0;
	assign oLDST_ADDR = b_ldst_addr;
	assign oLDST_DATA = b_ldst_data;




endmodule




`default_nettype wire 
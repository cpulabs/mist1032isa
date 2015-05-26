

`default_nettype none


/****
HOLD
0 START
1 MOVE_K2U
1 MOVE_UK
2 EMD

****/


module execute_exception(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Event CTRL
		input wire iEVENT_HOLD,
		input wire iEVENT_START,
		input wire iEVENT_IRQ_FRONT2BACK,
		input wire iEVENT_IRQ_BACK2FRONT,
		input wire iEVENT_END,
		//Execute Module State
		input wire iPREV_STATE_NORMAL,
		input wire iPREV_STATE_LDST,
		//Previous Instruxtion
		input wire iPREV_VALID,
		input wire iPREV_KERNEL_ACCESS,
		input wire [31:0] iPREV_PC,
		//Instruction Exception
		input wire iEXCEPT_INST_VALID,
		input wire [6:0] iEXCEPT_INST_NUM,
		//Load Store Exception
		input wire iEXCEPT_LDST_VALID,
		input wire [6:0] iEXCEPT_LDST_NUM,
		//Output Exception 
		output wire oEXCEPT_VALID,
		output wire [6:0] oEXCEPT_NUM,
		output wire [31:0] oEXCEPT_FI0R,
		output wire [31:0] oEXCEPT_FI1R
	);


	reg [31:0] b_pc;
	reg b_kernel_access;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_pc <= 32'h0;
			b_kernel_access <= 1'b0;
		end
		else if(iRESET_SYNC || iEVENT_HOLD)begin
			b_pc <= 32'h0;
			b_kernel_access <= 1'b0;
		end
		else begin
			if(iPREV_VALID && iPREV_STATE_NORMAL)begin
				b_pc <= iPREV_PC;
				b_kernel_access <= iPREV_KERNEL_ACCESS;
			end
		end
	end

	/**************************************************************************************************
	General Instruction Exception
	**************************************************************************************************/
	function [31:0] func_exception_fi0r;
		input [6:0] func_error_code;
		input [31:0] func_pc;
		begin
			if(func_error_code == `INT_NUM_PAGEFAULT || func_error_code == `INT_NUM_PRIVILEGE_ERRPR || 
			func_error_code == `INT_NUM_INSTRUCTION_INVALID || func_error_code == `INT_NUM_DIVIDER_ERROR)begin
				func_exception_fi0r = func_pc - 32'h4;
			end
			else begin
				func_exception_fi0r = 32'h0;
			end
		end
	endfunction




	function [31:0] func_exception_fi1r;
		input [6:0] func_error_code;
		input [31:0] func_pc;
		input func_kernel_access;
		begin
			if(func_error_code == `INT_NUM_PAGEFAULT)begin
				func_exception_fi1r = {28'h0, 1'b1, !func_kernel_access, 1'b0, 1'b1};
			end
			else if(func_error_code == `INT_NUM_PRIVILEGE_ERRPR)begin
				func_exception_fi1r = 32'h0;
			end
			else if(func_error_code == `INT_NUM_INSTRUCTION_INVALID)begin
				func_exception_fi1r = func_pc - 32'h4;
			end
			else if(func_error_code == `INT_NUM_DIVIDER_ERROR)begin
				func_exception_fi1r = func_pc - 32'h4;
			end
			else begin
				func_exception_fi1r = 32'h0;
			end
		end
	endfunction





	/**************************************************************************************************
	Exception D-FF
	**************************************************************************************************/
	wire instruction_enable_condition = iPREV_STATE_NORMAL && iPREV_VALID && iEXCEPT_INST_VALID;
	wire ldst_enable_condition = iPREV_STATE_LDST && iEXCEPT_LDST_VALID;

	reg b_state;

	localparam PL_STT_IDLE = 1'b0;
	localparam PL_STT_HOLD = 1'b1;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_state <= PL_STT_IDLE;
		end
		else if(iRESET_SYNC || iEVENT_HOLD)begin
			b_state <= PL_STT_IDLE;
		end
		else begin
			case(b_state)
				PL_STT_IDLE:
					begin
						if(instruction_enable_condition || ldst_enable_condition)begin
							b_state <= PL_STT_HOLD;
						end
					end
				PL_STT_HOLD:
					begin
						b_state <= b_state;
					end
			endcase			
		end
	end



	reg b_exception_valid;
	reg [6:0] b_exception_num;
	reg [31:0] b_fi0r;
	reg [31:0] b_fi1r;

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_exception_valid <= 1'b0;
		end
		else if(iRESET_SYNC || iEVENT_HOLD)begin
			b_exception_valid <= 1'b0;
		end
		else begin
			if(instruction_enable_condition)begin
				b_exception_valid <= 1'b1;
			end
			else if(ldst_enable_condition)begin
				b_exception_valid <= 1'b1;
			end
			else begin
				b_exception_valid <= 1'b0;
			end
		end
	end

	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_exception_num <= 7'h0;
			b_fi0r <= 32'h0;
			b_fi0r <= 32'h1;
		end
		else if(iRESET_SYNC || iEVENT_HOLD)begin
			b_exception_num <= 7'h0;
			b_fi0r <= 32'h0;
			b_fi0r <= 32'h1;
		end
		else begin
			if(instruction_enable_condition)begin
				b_exception_num <= iEXCEPT_INST_NUM;
				b_fi0r <= func_exception_fi0r(iEXCEPT_INST_NUM, iPREV_PC);
				b_fi1r <= func_exception_fi1r(iEXCEPT_INST_NUM, iPREV_PC, iPREV_KERNEL_ACCESS);
			end
			else if(ldst_enable_condition)begin
				b_exception_num <= iEXCEPT_LDST_NUM;
				b_fi0r <= b_pc - 32'h4;
				b_fi1r <= {28'h0, 1'b0, !b_kernel_access, 1'b0, 1'b0};
			end
		end
	end


	assign oEXCEPT_VALID = b_exception_valid; 
	assign oEXCEPT_NUM = b_exception_num;
	assign oEXCEPT_FI0R = b_fi0r;
	assign oEXCEPT_FI1R = b_fi1r;


endmodule

`default_nettype wire


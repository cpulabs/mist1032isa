
`default_nettype none

module core_register_hazard_controller(
		//System
		input				iCLOCK,
		input				inRESET,
		input				iREFRESH,
		//Hazard Control
		input				iHAZ_REGISTER_VALID,
		input				iHAZ_SYSREG,
		input	[4:0]		iHAZ_REGISTER,
		input	[31:0]		iHAZ_PC,
		output				oHAZ_REGISTER_VALID,
		output				oHAZ_SYSREG,
		output	[4:0]		oHAZ_REGISTER,
		//Writeback
		input				iWB_VALID
	);	

	//Local Parameter
	parameter			L_PARAM_STT_IDLE		=	1'h0;
	parameter			L_PARAM_STT_WAIT		=	1'h1;	
	
	
	reg				b_state;
	reg				b_sysreg;
	reg		[4:0]	b_register;
	reg		[31:0]	b_pc;


	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_state		<=		1'h0;
			b_sysreg	<=		1'b0;
			b_register	<=		5'h0;
			b_pc		<=		32'h0;
		end
		else if(iREFRESH)begin
			b_state		<=		1'h0;
			b_sysreg	<=		1'b0;
			b_register	<=		5'h0;
			b_pc		<=		32'h0;
		end		
		else begin
			case(b_state)
				L_PARAM_STT_IDLE:
					begin
						if(iHAZ_REGISTER_VALID)begin
							b_state		<=		L_PARAM_STT_WAIT;
							b_sysreg	<=		iHAZ_SYSREG;
							b_register	<=		iHAZ_REGISTER;
							b_pc		<=		iHAZ_PC;
						end
					end
				L_PARAM_STT_WAIT:
					begin
						if(iWB_VALID)begin
							b_state		<=		L_PARAM_STT_IDLE;
						end
					end
			endcase
		end
	end

		
	assign		oHAZ_REGISTER_VALID		=		(b_state == L_PARAM_STT_WAIT)? 1'b1 : 1'b0;
	assign		oHAZ_SYSREG				=		b_sysreg;
	assign		oHAZ_REGISTER			=		b_register;
		
endmodule


`default_nettype wire


		
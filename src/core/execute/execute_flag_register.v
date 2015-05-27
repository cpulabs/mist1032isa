
`default_nettype none

module execute_flag_register(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Control
		input wire iCTRL_HOLD,
		//PFLAGR
		input wire iPFLAGR_VALID,
		input wire [4:0] iPFLAGR,
		//Prev
		input wire iPREV_INST_VALID,
		input wire iPREV_BUSY,
		input wire iPREV_FLAG_WRITE,
		//Shift
		input wire iSHIFT_VALID,
		input wire [4:0] iSHIFT_FLAG,
		//Adder
		input wire iADDER_VALID,
		input wire [4:0] iADDER_FLAG,
		//Mul
		input wire iMUL_VALID,
		input wire [4:0] iMUL_FLAG,
		//Logic
		input wire iLOGIC_VALID,
		input wire [4:0] iLOGIC_FLAG,
		//Output Flag
		output wire [4:0] oFLAG
	);

		//Flags Register
	reg [4:0] b_sysreg_flags;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_sysreg_flags <= 5'h0;
		end
		else if(iRESET_SYNC)begin
			b_sysreg_flags <= 5'h0;
		end
		//Copy of PFLAGR
		else if(iPFLAGR_VALID)begin
			b_sysreg_flags <= iPFLAGR;
		end
		//HOLD
		else if(iCTRL_HOLD)begin
			b_sysreg_flags <= b_sysreg_flags;
		end
		else begin
			if(!iPREV_BUSY && iPREV_INST_VALID)begin
				//Flag
				if(iPREV_FLAG_WRITE)begin
					if(iSHIFT_VALID)begin
						b_sysreg_flags <= iSHIFT_FLAG;
					end
					else if(iADDER_VALID)begin
						b_sysreg_flags <= iADDER_FLAG;
					end
					else if(iMUL_VALID)begin
						b_sysreg_flags <= iMUL_FLAG;
					end
					else if(iLOGIC_VALID)begin
						b_sysreg_flags <= iLOGIC_FLAG;
					end
				end
			end
		end
	end//General Register Write Back

	assign oFLAG = b_sysreg_flags;

endmodule

`default_nettype wire 


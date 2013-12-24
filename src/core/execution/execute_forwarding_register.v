
`default_nettype none

module execute_forwarding_register(
		input wire iCLOCK,
		input wire inRESET,
		input wire iRESET_SYNC,
		//Writeback - General Register
		input wire iWB_GR_VALID,
		input wire [31:0] iWB_GR_DATA,
		input wire [4:0] iWB_GR_DEST,
		input wire iWB_GR_DEST_SYSREG,
		//Writeback - Stack Point Register
		input wire iWB_SPR_VALID,
		input wire [31:0] iWB_SPR_DATA,
		//Writeback[AUTO] - Stack Point Register
		input wire iWB_AUTO_SPR_VALID,			
		input wire [31:0] iWB_AUTO_SPR_DATA, 	
		//Current - Stack Point Register
		input wire [31:0] iCUUR_SPR_DATA,		
		//Fowerding Register Output
		output wire oFDR_GR_VALID,
		output wire [31:0] oFDR_GR_DATA,
		output wire [4:0] oFDR_GR_DEST,
		output wire oFDR_GR_DEST_SYSREG,
		//Fowerding Register Output
		output wire oFDR_SPR_VALID,
		output wire [31:0] oFDR_SPR_DATA
	);

	//Fowarding General Register
	reg b_ex_history_valid;
	reg [31:0] b_ex_history_data;
	reg [4:0] b_ex_history_destination;
	reg b_ex_history_destination_sysreg;
	//reg [31:0] b_ex_history_pc;

	//Fowarding Stack Point Register
	reg b_fwdng_spr_valid;
	reg [31:0] b_fwdng_spr;


	/************************************************************************
	Fowarding Register
	************************************************************************/
	//General Register
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_ex_history_valid <= 1'h0;
			b_ex_history_data <= 32'h0;
			b_ex_history_destination <= 5'h0;
			b_ex_history_destination_sysreg <= 1'h0;
			//b_ex_history_pc <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_ex_history_valid <= 1'h0;
			b_ex_history_data <= 32'h0;
			b_ex_history_destination <= 5'h0;
			b_ex_history_destination_sysreg <= 1'h0;
			//b_ex_history_pc <= 32'h0;
		end
		else begin
			if(iWB_GR_VALID)begin
				b_ex_history_valid <= iWB_GR_VALID;
				b_ex_history_data <= iWB_GR_DATA;
				b_ex_history_destination <= iWB_GR_DEST;
				b_ex_history_destination_sysreg <= iWB_GR_DEST_SYSREG;
				//b_ex_history_pc <= iWB_PCR - 32'h00000004;
			end
		end
	end		

	//Stack Point Register
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_fwdng_spr_valid <= 1'h0;
			b_fwdng_spr <= 32'h0;
		end
		else if(iRESET_SYNC)begin
			b_fwdng_spr_valid <= 1'h0;
			b_fwdng_spr <= 32'h0;
		end
		else begin
			if(iWB_SPR_VALID)begin
				b_fwdng_spr_valid <= iWB_SPR_VALID;
				b_fwdng_spr <= iWB_SPR_DATA;
			end
			else if(iWB_AUTO_SPR_VALID)begin
				b_fwdng_spr_valid <= iWB_SPR_VALID;
				b_fwdng_spr <= iWB_AUTO_SPR_DATA;
			end
			else begin
				b_fwdng_spr_valid <= 1'b1;
				b_fwdng_spr <= iCUUR_SPR_DATA;
			end
		end
	end		

	/************************************************************************
	Assign
	************************************************************************/
	//GR Out
	assign oFDR_GR_VALID = b_ex_history_valid;
	assign oFDR_GR_DATA = b_ex_history_data;
	assign oFDR_GR_DEST = b_ex_history_destination;
	assign oFDR_GR_DEST_SYSREG = b_ex_history_destination_sysreg;
	//SPR Out
	assign oFDR_SPR_VALID = b_fwdng_spr_valid;
	assign oFDR_SPR_DATA = b_fwdng_spr;


endmodule

`default_nettype wire

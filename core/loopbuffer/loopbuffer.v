	
`default_nettype none



module loopbuffer(
				input					iCLOCK,
				input					inRESET,
				input					iFREE_REFRESH,
				//Prev
				input					iPREVIOUS_INST_VALID,
				input	[5:0]			iPREVIOUS_MMU_FLAGS,
				input	[31:0]			iPREVIOUS_INST,
				input	[31:0]			iPREVIOUS_PC,
				output					oPREVIOUS_FETCH_STOP,
				output					oPREVIOUS_LOCK,
				//Next
				output					oNEXT_INST_VALID,
				output	[5:0]			oNEXT_MMU_FLAGS,
				output	[31:0]			oNEXT_INST,
				output	[31:0]			oNEXT_PC,
				input					iNEXT_LOCK
		);
				
				
				
	wire			fifo_full;
	wire			fifo_empty;
	wire	[3:0]	fifo_count;
	
	sync_fifo #(70, 16, 4) INST_LOOPBUFFER(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iREMOVE(iFREE_REFRESH), 
		.oCOUNT(fifo_count), 	
		.iWR_EN(!fifo_full && iPREVIOUS_INST_VALID), 
		.iWR_DATA({iPREVIOUS_MMU_FLAGS, iPREVIOUS_INST, iPREVIOUS_PC}), 
		.oWR_FULL(fifo_full),
		.iRD_EN(!fifo_empty && !iNEXT_LOCK), 
		.oRD_DATA({oNEXT_MMU_FLAGS, oNEXT_INST, oNEXT_PC}), 
		.oRD_EMPTY(fifo_empty)
	);
	
	assign	oPREVIOUS_LOCK			=		fifo_full;	
	assign	oNEXT_INST_VALID		=		!fifo_empty && !iNEXT_LOCK;
				
	assign	oPREVIOUS_FETCH_STOP	=		(fifo_count > 4'hA)? 1'b1 : 1'b0;
	
	
		/*
	reg		b_end_program;
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_end_program	<=	1'b0;
		end
		else begin
			if(!b_end_program && !fifo_empty && !iNEXT_LOCK && oNEXT_INST == 32'h)
			b_end_program	<=	1'b0;
		end
	end
		*/		
endmodule
	
`default_nettype wire


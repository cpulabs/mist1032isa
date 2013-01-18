	
`default_nettype none

module loopbuffer(
		input iCLOCK,
		input inRESET,
		input iFREE_REFRESH,
		//Prev
		input iPREVIOUS_INST_VALID,
		input [13:0] iPREVIOUS_MMU_FLAGS,
		input iPREVIOUS_PAGING_ENA,
		input iPREVIOUS_KERNEL_ACCESS,
		input [31:0] iPREVIOUS_INST,
		input [31:0] iPREVIOUS_PC,
		output oPREVIOUS_FETCH_STOP,
		output oPREVIOUS_LOCK,
		//Next
		output oNEXT_INST_VALID,
		output [13:0] oNEXT_MMU_FLAGS,
		output oNEXT_PAGING_ENA,
		output oNEXT_KERNEL_ACCESS,
		output [31:0] oNEXT_INST,
		output [31:0] oNEXT_PC,
		input iNEXT_LOCK
	);
			
	wire fifo_full;
	wire fifo_empty;
	wire [4:0] fifo_count;
	
	sync_fifo #(80, 32, 5) INST_LOOPBUFFER(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iREMOVE(iFREE_REFRESH), 
		.oCOUNT(fifo_count), 	
		.iWR_EN(!fifo_full && iPREVIOUS_INST_VALID), 
		.iWR_DATA({iPREVIOUS_KERNEL_ACCESS, iPREVIOUS_PAGING_ENA, iPREVIOUS_MMU_FLAGS, iPREVIOUS_INST, iPREVIOUS_PC}), 
		.oWR_FULL(fifo_full),
		.iRD_EN(!fifo_empty && !iNEXT_LOCK), 
		.oRD_DATA({oNEXT_KERNEL_ACCESS, oNEXT_PAGING_ENA, oNEXT_MMU_FLAGS, oNEXT_INST, oNEXT_PC}), 
		.oRD_EMPTY(fifo_empty)
	);
	
	assign oPREVIOUS_LOCK = fifo_full;	
	assign oNEXT_INST_VALID = !fifo_empty && !iNEXT_LOCK;
				
	assign oPREVIOUS_FETCH_STOP = (fifo_count > 5'h1A)? 1'b1 : 1'b0;
	
endmodule
	
`default_nettype wire


/****************************************
	Fetch Unit
	- 2 instruction multi fetch
	
	
	Make	:	2010/09/23
	Update	:	2010/10/03
****************************************/
`default_nettype none

module fetch(
				//System
				input					iCLOCK,
				input					inRESET,
				//Exception
				input					iEXCEPTION_EVENT,
				input					iEXCEPTION_ADDR_SET,
				input	[31:0]			iEXCEPTION_ADDR,
				input					iEXCEPTION_RESTART,
				//Previous
				input					iPREVIOUS_INST_VALID,
				input	[5:0]			iPREVIOUS_MMU_FLAGS,
				input	[31:0]			iPREVIOUS_INST,
				output					oPREVIOUS_LOCK,
				//Fetch
				output					oPREVIOUS_FETCH_REQ,
				output	[31:0]			oPREVIOUS_FETCH_ADDR,
				input					iPREVIOUS_FETCH_LOCK,
				//Next
				output					oNEXT_INST_VALID,
				output	[5:0]			oNEXT_MMU_FLAGS,
				output	[31:0]			oNEXT_INST,
				output	[31:0]			oNEXT_PC,
				input					iNEXT_FETCH_STOP,
				input					iNEXT_LOCK,
				output	[31:0]			oDEBUG_PC
			);
			
	assign	oDEBUG_PC	=		b_pc;

	/****************************************
	Register and Wire
	****************************************/
	//Fetch Address Queue
	wire				fetch_addr_queue_full;
	wire	[31:0]		fetch_addr_queue_addr;
	//PC Request
	reg		[31:0]		b_pc;
	reg					b_fetch_valid;
	reg		[1:0]		b_fetch_state;
	//Next Output Buffer
	reg		[31:0]		b_next_inst;
	reg					b_next_inst_valid;
	reg		[5:0]		b_next_mmu_flags;
	reg		[31:0]		b_pc_out;
	
	
	/****************************************
	Fetch Address Queue
	****************************************/
	sync_fifo #(32, 8, 3) FETCH_REQ_ADDR_QUEUE(
		.iCLOCK(iCLOCK), .inRESET(inRESET), 
		.iREMOVE(iEXCEPTION_EVENT), 
		.oCOUNT(/* Not Use */), 	
		.iWR_EN(/*!this_lock*/!iEXCEPTION_EVENT && b_fetch_valid && !fetch_addr_queue_full && !iPREVIOUS_FETCH_LOCK && !iNEXT_FETCH_STOP), 
		.iWR_DATA(b_pc), 
		.oWR_FULL(fetch_addr_queue_full),
		.iRD_EN(/*oNEXT_INST_VALID*/iPREVIOUS_INST_VALID), 
		.oRD_DATA(fetch_addr_queue_addr), 
		.oRD_EMPTY(/* Not Use */)
	);
	
	/****************************************
	This -> Previous
	****************************************/
	wire		this_lock				=		iNEXT_LOCK || fetch_addr_queue_full || iPREVIOUS_FETCH_LOCK;		//iPREVIOUS_FETCH_LOCK ga lock site naitoki nimo fetch ga tomatte simau
	assign		oPREVIOUS_LOCK			=		iNEXT_LOCK;

	assign		oPREVIOUS_FETCH_REQ		=		!iEXCEPTION_EVENT && b_fetch_valid && !fetch_addr_queue_full && !iPREVIOUS_FETCH_LOCK && !iNEXT_FETCH_STOP; 
	assign		oPREVIOUS_FETCH_ADDR	=		b_pc;

	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_pc			<=		{32{1'b0}};
			b_fetch_valid	<=		1'b0;
			b_fetch_state	<=		2'b00;
		end
		else if(iEXCEPTION_ADDR_SET)begin		//Jump
			b_pc			<=		{iEXCEPTION_ADDR[31:1], 1'b0};
			b_fetch_valid	<=		1'b1;
			b_fetch_state	<=		2'h1;
		end
		else if(iEXCEPTION_EVENT)begin
			b_fetch_valid	<=		1'b0;
			b_fetch_state	<=		2'h2;
		end
		else begin
			case(b_fetch_state)
				2'h0 :		//Reset Start
					begin
						b_fetch_valid	<=		1'b1;
						b_fetch_state	<=		2'h1;
						b_pc			<=		32'h00000000;
					end
				2'h1 : 		//Fetch State
					begin
						if(!iEXCEPTION_EVENT && !fetch_addr_queue_full && !iPREVIOUS_FETCH_LOCK && !iNEXT_FETCH_STOP)begin	
							b_pc			<=		b_pc + 32'h4;		//Single Pipeline
							b_fetch_valid	<=		1'b1;
						end
					end
				2'h2:
					begin
						if(iEXCEPTION_ADDR_SET)begin		//Jump
							b_pc			<=		{iEXCEPTION_ADDR[31:1], 1'b0};
							b_fetch_valid	<=		1'b1;
							b_fetch_state	<=		2'h1;
						end
					end
				default :
					begin
						b_pc			<=		b_pc;
					end	
			endcase
		end
	end //always
	
	/****************************************
	Previous -> Next
	****************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_next_inst			<=		{32{1'b0}};
			b_next_inst_valid		<=		1'b0;
			b_next_mmu_flags		<=		6'h0;
			b_pc_out				<=		{32{1'b0}};
		end
		else if(iEXCEPTION_EVENT)begin
			b_next_inst			<=		{32{1'b0}};
			b_next_inst_valid		<=		1'b0;
			b_next_mmu_flags		<=		6'h0;
			b_pc_out				<=		{32{1'b0}};
		end
		else begin
			if(!iNEXT_LOCK)begin
				b_next_inst			<=		iPREVIOUS_INST;
				b_next_inst_valid		<=		iPREVIOUS_INST_VALID;
				b_next_mmu_flags		<=		iPREVIOUS_MMU_FLAGS;
				b_pc_out				<=		fetch_addr_queue_addr + 32'h4;
			end
		end
	end	//always
	

	
	
	assign		oNEXT_INST			=		b_next_inst;
	assign		oNEXT_INST_VALID	=		b_next_inst_valid;
	assign		oNEXT_MMU_FLAGS		=		b_next_mmu_flags;
	assign		oNEXT_PC			=		b_pc_out;

	
endmodule



`default_nettype wire



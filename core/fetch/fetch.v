/****************************************
	Fetch Unit
	- 2 instruction multi fetch
	
	
	Make	:	2010/09/23
	Update	:	2010/10/03
****************************************/
`default_nettype none
`include "core.h"
`include "processor.h"

module fetch(
		//System
		input iCLOCK,
		input inRESET,
		//System Register
		input [31:0] iSYSREG_PSR,
		//Exception
		input iEXCEPTION_EVENT,
		input iEXCEPTION_ADDR_SET,
		input [31:0] iEXCEPTION_ADDR,
		input iEXCEPTION_RESTART,
		//Branch Predict
		output oBRANCH_PREDICT_FETCH_FLUSH,
		input iBRANCH_PREDICT_RESULT_PREDICT,
		input iBRANCH_PREDICT_RESULT_HIT,
		input iBRANCH_PREDICT_RESULT_JUMP,
		input [31:0] iBRANCH_PREDICT_RESULT_JUMP_ADDR,
		input [31:0] iBRANCH_PREDICT_RESULT_INST_ADDR,
		//Previous
		input iPREVIOUS_INST_VALID,
		input iPREVIOUS_PAGEFAULT,
		input [13:0] iPREVIOUS_MMU_FLAGS,
		input [31:0] iPREVIOUS_INST,
		output oPREVIOUS_LOCK,
		//Fetch
		output oPREVIOUS_FETCH_REQ,
		input iPREVIOUS_FETCH_LOCK,
		output [1:0] oPREVIOUS_MMUMOD,
		output [31:0] oPREVIOUS_FETCH_ADDR,
		//Next
		output oNEXT_INST_VALID,
		output oNEXT_PAGEFAULT,
		output [13:0] oNEXT_MMU_FLAGS,
		output oNEXT_PAGING_ENA,
		output oNEXT_KERNEL_ACCESS,
		output oNEXT_BRANCH_PREDICT,			
		output [31:0] oNEXT_BRANCH_PREDICT_ADDR,
		output [31:0] oNEXT_INST,
		output [31:0] oNEXT_PC,
		input iNEXT_FETCH_STOP,
		input iNEXT_LOCK
	);
			

	/****************************************
	Register and Wire
	****************************************/
	//Fetch Address Queue
	wire fetch_queue_full;
	wire [31:0] fetch_queue_addr;
	wire fetch_queue_paging_ena;
	wire fetch_queue_kernel_access;
	//PC Request
	reg [31:0] b_pc;
	reg b_fetch_valid;
	reg [1:0] b_fetch_state;
	//Next Output Buffer
	reg [31:0] b_next_inst;
	reg b_next_inst_valid;
	reg b_next_pagefault;
	reg [13:0] b_next_mmu_flags;
	reg b_next_paging_ena;
	reg b_next_kernel_access;
	reg [31:0] b_pc_out;
	
	/****************************************
	Branch Predictor
	****************************************/
	//Branch pick up
	function func_branch_inst_check;
		input [31:0] func_inst;
		begin
			case(func_inst[30:21])
				`OC_BUR,
				`OC_BR,
				`OC_B : func_branch_inst_check = 1'b1;
				default : func_branch_inst_check = 1'b0;
			endcase
		end
	endfunction
	
	wire branch_predictor_valid;
	wire branch_predictor_predict_branch;
	wire [31:0] branch_predictor_addr;
	wire branch_predictor_flush;
	generate
		if(`BRANCH_PREDICTOR)begin
			assign branch_predictor_flush = !iNEXT_LOCK && branch_predictor_valid && branch_predictor_predict_branch;		//Test
		end
		else begin
			assign branch_predictor_flush = 1'b0;
		end
	endgenerate
	
	branch_predictor BRANCH_PREDICTOR(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iFLUSH(1'b0),
		//Flush
		//.oFLUSH_PIPELINE(),
		//.oFLUSH_
		//Search
		.iSEARCH_STB(func_branch_inst_check(iPREVIOUS_INST) && iPREVIOUS_INST_VALID),
		.iSEARCH_INST_ADDR(fetch_queue_addr),
		.oSEARCH_VALID(branch_predictor_valid),
		.iSEARCH_LOCK(iNEXT_LOCK),
		.oSRARCH_PREDICT_BRANCH(branch_predictor_predict_branch),
		.oSEARCH_ADDR(branch_predictor_addr),
		//Jump
		.iJUMP_STB(iBRANCH_PREDICT_RESULT_JUMP),
		.iJUMP_HIT(iBRANCH_PREDICT_RESULT_HIT/* && iBRANCH_PREDICT_RESULT_PREDICT*/),
		.iJUMP_ADDR(iBRANCH_PREDICT_RESULT_JUMP_ADDR),		
		.iJUMP_INST_ADDR(iBRANCH_PREDICT_RESULT_INST_ADDR)	//Tag[31:5]| Cell Address[4:2] | Byte Order[1:0]
	);
	
	/****************************************
	Fetch Address & Flag Queue
	****************************************/
	mist1032isa_sync_fifo #(34, 8, 3) FETCH_REQ_ADDR_QUEUE(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iREMOVE(iEXCEPTION_EVENT || branch_predictor_flush), 
		.oCOUNT(/* Not Use */), 	
		.iWR_EN(!iEXCEPTION_EVENT && !branch_predictor_flush && b_fetch_valid && !fetch_queue_full && !iPREVIOUS_FETCH_LOCK && !iNEXT_FETCH_STOP), 
		.iWR_DATA({!(iSYSREG_PSR[6] || iSYSREG_PSR[5])/*User mode Test 1'b1*/, (iSYSREG_PSR[1] || iSYSREG_PSR[0]), b_pc}), 
		.oWR_FULL(fetch_queue_full),
		.iRD_EN(iPREVIOUS_INST_VALID), 
		.oRD_DATA({fetch_queue_kernel_access, fetch_queue_paging_ena, fetch_queue_addr}), 
		.oRD_EMPTY(/* Not Use */)
	);
	
	
	/****************************************
	This -> Previous
	****************************************/
	wire this_lock = iNEXT_LOCK || fetch_queue_full || iPREVIOUS_FETCH_LOCK;		//iPREVIOUS_FETCH_LOCK ga lock site naitoki nimo fetch ga tomatte simau
	assign oBRANCH_PREDICT_FETCH_FLUSH = branch_predictor_flush;
	assign oPREVIOUS_LOCK = iNEXT_LOCK;

	assign oPREVIOUS_FETCH_REQ = !iEXCEPTION_EVENT && !branch_predictor_flush && b_fetch_valid && !fetch_queue_full && !iPREVIOUS_FETCH_LOCK && !iNEXT_FETCH_STOP; 
	assign oPREVIOUS_MMUMOD = iSYSREG_PSR[1:0];
	assign oPREVIOUS_FETCH_ADDR	= b_pc;

	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_pc <= {32{1'b0}};
			b_fetch_valid <= 1'b0;
			b_fetch_state <= 2'b00;
		end
		else if(iEXCEPTION_ADDR_SET)begin		//Jump
			b_pc <= {iEXCEPTION_ADDR[31:1], 1'b0};
			b_fetch_valid <= 1'b1;
			b_fetch_state <= 2'h1;
		end
		else if(iEXCEPTION_EVENT)begin
			b_fetch_valid <= 1'b0;
			b_fetch_state <= 2'h2;
		end
		else if(branch_predictor_flush)begin
			b_pc <= branch_predictor_addr;
			b_fetch_valid <= 1'b1;
			b_fetch_state <= 2'h1;
		end
		else begin
			case(b_fetch_state)
				2'h0 :		//Reset Start
					begin
						b_fetch_valid <= 1'b1;
						b_fetch_state <= 2'h1;
						b_pc <= 32'h00000000;
					end
				2'h1 : 		//Fetch State
					begin
						if(!iEXCEPTION_EVENT && !branch_predictor_flush && !fetch_queue_full && !iPREVIOUS_FETCH_LOCK && !iNEXT_FETCH_STOP)begin	
							b_pc <= b_pc + 32'h4;		//Single Pipeline
							b_fetch_valid <= 1'b1;
						end
					end
				2'h2:
					begin
						if(iEXCEPTION_ADDR_SET)begin		//Jump
							b_pc <= {iEXCEPTION_ADDR[31:1], 1'b0};
							b_fetch_valid <= 1'b1;
							b_fetch_state <= 2'h1;
						end
					end
				default :
					begin
						b_pc <= b_pc;
					end	
			endcase
		end
	end //always
	
	/****************************************
	Previous -> Next
	****************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_next_inst <= {32{1'b0}};
			b_next_inst_valid <= 1'b0;
			b_next_pagefault <= 1'b0;
			b_next_mmu_flags <= 14'h0;
			b_next_paging_ena <= 1'b0;
			b_next_kernel_access <= 1'b0;
			b_pc_out <= {32{1'b0}};
		end
		else if(iEXCEPTION_EVENT || branch_predictor_flush)begin
			b_next_inst <= {32{1'b0}};
			b_next_inst_valid <= 1'b0;
			b_next_pagefault <= 1'b0;
			b_next_mmu_flags <= 14'h0;
			b_next_paging_ena <= 1'b0;
			b_next_kernel_access <= 1'b0;
			b_pc_out <= {32{1'b0}};
		end
		else begin
			if(!iNEXT_LOCK)begin
				b_next_inst <= iPREVIOUS_INST;
				b_next_inst_valid <= iPREVIOUS_INST_VALID;
				b_next_pagefault <= iPREVIOUS_PAGEFAULT;
				b_next_mmu_flags <= iPREVIOUS_MMU_FLAGS;
				b_next_paging_ena <= fetch_queue_paging_ena;
				b_next_kernel_access <= fetch_queue_kernel_access;
				b_pc_out <= fetch_queue_addr + 32'h4;
			end
		end
	end	//always
	
	assign oNEXT_INST = b_next_inst;
	assign oNEXT_INST_VALID = b_next_inst_valid;
	assign oNEXT_PAGEFAULT = b_next_pagefault;
	assign oNEXT_MMU_FLAGS = b_next_mmu_flags;
	assign oNEXT_PAGING_ENA = b_next_paging_ena;
	assign oNEXT_KERNEL_ACCESS = b_next_kernel_access;
	generate
		if(`BRANCH_PREDICTOR)begin
			assign oNEXT_BRANCH_PREDICT = branch_predictor_valid && branch_predictor_predict_branch;
			assign oNEXT_BRANCH_PREDICT_ADDR = branch_predictor_addr;
		end
		else begin
			assign oNEXT_BRANCH_PREDICT = 1'b0;
			assign oNEXT_BRANCH_PREDICT_ADDR = 32'h0;
		end
	endgenerate
	assign oNEXT_PC = b_pc_out;

	
endmodule




module fetch_________(
		//System
		input iCLOCK,
		input inRESET,
		//System Register
		input [31:0] iSYSREG_PSR,
		//Exception
		input iEXCEPTION_EVENT,
		input iEXCEPTION_ADDR_SET,
		input [31:0] iEXCEPTION_ADDR,
		input iEXCEPTION_RESTART,
		//Branch Predict
		input iBRANCH_PREDICT_RESULT_PREDICT,
		input iBRANCH_PREDICT_RESULT_HIT,
		input iBRANCH_PREDICT_RESULT_JUMP,
		input [31:0] iBRANCH_PREDICT_RESULT_JUMP_ADDR,
		input [31:0] iBRANCH_PREDICT_RESULT_INST_ADDR,
		//Previous
		input iPREVIOUS_INST_VALID,
		input iPREVIOUS_PAGEFAULT,
		input [13:0] iPREVIOUS_MMU_FLAGS,
		input [31:0] iPREVIOUS_INST,
		output oPREVIOUS_LOCK,
		//Fetch
		output oPREVIOUS_FETCH_REQ,
		input iPREVIOUS_FETCH_LOCK,
		output [1:0] oPREVIOUS_MMUMOD,
		output [31:0] oPREVIOUS_FETCH_ADDR,
		//Next
		output oNEXT_INST_VALID,
		output oNEXT_PAGEFAULT,
		output [13:0] oNEXT_MMU_FLAGS,
		output oNEXT_PAGING_ENA,
		output oNEXT_KERNEL_ACCESS,
		output oNEXT_BRANCH_PREDICT,			
		output [31:0] oNEXT_BRANCH_PREDICT_ADDR,
		output [31:0] oNEXT_INST,
		output [31:0] oNEXT_PC,
		input iNEXT_FETCH_STOP,
		input iNEXT_LOCK
	);
			

	/****************************************
	Register and Wire
	****************************************/
	//Fetch Address Queue
	wire fetch_queue_full;
	wire [31:0] fetch_queue_addr;
	wire fetch_queue_paging_ena;
	wire fetch_queue_kernel_access;
	//PC Request
	reg [31:0] b_pc;
	reg b_fetch_valid;
	reg [1:0] b_fetch_state;
	//Next Output Buffer
	reg [31:0] b_next_inst;
	reg b_next_inst_valid;
	reg b_next_pagefault;
	reg [13:0] b_next_mmu_flags;
	reg b_next_paging_ena;
	reg b_next_kernel_access;
	reg [31:0] b_pc_out;
	
	
	/****************************************
	Fetch Address & Flag Queue
	****************************************/
	mist1032isa_sync_fifo #(34, 8, 3) FETCH_REQ_ADDR_QUEUE(
		.iCLOCK(iCLOCK), 
		.inRESET(inRESET), 
		.iREMOVE(iEXCEPTION_EVENT), 
		.oCOUNT(/* Not Use */), 	
		.iWR_EN(!iEXCEPTION_EVENT && b_fetch_valid && !fetch_queue_full && !iPREVIOUS_FETCH_LOCK && !iNEXT_FETCH_STOP), 
		.iWR_DATA({!(iSYSREG_PSR[6] || iSYSREG_PSR[5])/*User mode Test 1'b1*/, (iSYSREG_PSR[1] || iSYSREG_PSR[0]), b_pc}), 
		.oWR_FULL(fetch_queue_full),
		.iRD_EN(iPREVIOUS_INST_VALID), 
		.oRD_DATA({fetch_queue_kernel_access, fetch_queue_paging_ena, fetch_queue_addr}), 
		.oRD_EMPTY(/* Not Use */)
	);

	
	/****************************************
	Branch Predictor
	****************************************/
	//Branch pick up
	function func_branch_inst_check;
		input [31:0] func_inst;
		begin
			case(func_inst[30:21])
				`OC_BUR,
				`OC_BR,
				`OC_B : func_branch_inst_check = 1'b1;
				default : func_branch_inst_check = 1'b0;
			endcase
		end
	endfunction
	
	wire branch_predictor_valid;
	wire branch_predictor_predict_branch;
	wire [31:0] branch_predictor_addr;
	
	branch_predictor BRANCH_PREDICTOR(
		.iCLOCK(iCLOCK),
		.inRESET(inRESET),
		.iFLUSH(1'b0),
		//Flush
		//.oFLUSH_PIPELINE(),
		//.oFLUSH_
		//Search
		.iSEARCH_STB(func_branch_inst_check(iPREVIOUS_INST) && iPREVIOUS_INST_VALID),
		.iSEARCH_INST_ADDR(fetch_queue_addr),
		.oSEARCH_VALID(branch_predictor_valid),
		.iSEARCH_LOCK(iNEXT_LOCK),
		.oSRARCH_PREDICT_BRANCH(branch_predictor_predict_branch),
		.oSEARCH_ADDR(branch_predictor_addr),
		//Jump
		.iJUMP_STB(iBRANCH_PREDICT_RESULT_JUMP),
		.iJUMP_HIT(iBRANCH_PREDICT_RESULT_HIT/* && iBRANCH_PREDICT_RESULT_PREDICT*/),
		.iJUMP_ADDR(iBRANCH_PREDICT_RESULT_JUMP_ADDR),		
		.iJUMP_INST_ADDR(iBRANCH_PREDICT_RESULT_INST_ADDR)	//Tag[31:5]| Cell Address[4:2] | Byte Order[1:0]
	);
	
	

	
	
	/****************************************
	This -> Previous
	****************************************/
	wire this_lock = iNEXT_LOCK || fetch_queue_full || iPREVIOUS_FETCH_LOCK;		//iPREVIOUS_FETCH_LOCK ga lock site naitoki nimo fetch ga tomatte simau
	assign oPREVIOUS_LOCK = iNEXT_LOCK;

	assign oPREVIOUS_FETCH_REQ = !iEXCEPTION_EVENT && b_fetch_valid && !fetch_queue_full && !iPREVIOUS_FETCH_LOCK && !iNEXT_FETCH_STOP; 
	assign oPREVIOUS_MMUMOD = iSYSREG_PSR[1:0];
	assign oPREVIOUS_FETCH_ADDR	= b_pc;

	
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_pc <= {32{1'b0}};
			b_fetch_valid <= 1'b0;
			b_fetch_state <= 2'b00;
		end
		else if(iEXCEPTION_ADDR_SET)begin		//Jump
			b_pc <= {iEXCEPTION_ADDR[31:1], 1'b0};
			b_fetch_valid <= 1'b1;
			b_fetch_state <= 2'h1;
		end
		else if(iEXCEPTION_EVENT)begin
			b_fetch_valid <= 1'b0;
			b_fetch_state <= 2'h2;
		end
		else begin
			case(b_fetch_state)
				2'h0 :		//Reset Start
					begin
						b_fetch_valid <= 1'b1;
						b_fetch_state <= 2'h1;
						b_pc <= 32'h00000000;
					end
				2'h1 : 		//Fetch State
					begin
						if(!iEXCEPTION_EVENT && !fetch_queue_full && !iPREVIOUS_FETCH_LOCK && !iNEXT_FETCH_STOP)begin	
							b_pc <= b_pc + 32'h4;		//Single Pipeline
							b_fetch_valid <= 1'b1;
						end
					end
				2'h2:
					begin
						if(iEXCEPTION_ADDR_SET)begin		//Jump
							b_pc <= {iEXCEPTION_ADDR[31:1], 1'b0};
							b_fetch_valid <= 1'b1;
							b_fetch_state <= 2'h1;
						end
					end
				default :
					begin
						b_pc <= b_pc;
					end	
			endcase
		end
	end //always
	
	/****************************************
	Previous -> Next
	****************************************/
	always@(posedge iCLOCK or negedge inRESET)begin
		if(!inRESET)begin
			b_next_inst <= {32{1'b0}};
			b_next_inst_valid <= 1'b0;
			b_next_pagefault <= 1'b0;
			b_next_mmu_flags <= 14'h0;
			b_next_paging_ena <= 1'b0;
			b_next_kernel_access <= 1'b0;
			b_pc_out <= {32{1'b0}};
		end
		else if(iEXCEPTION_EVENT)begin
			b_next_inst <= {32{1'b0}};
			b_next_inst_valid <= 1'b0;
			b_next_pagefault <= 1'b0;
			b_next_mmu_flags <= 14'h0;
			b_next_paging_ena <= 1'b0;
			b_next_kernel_access <= 1'b0;
			b_pc_out <= {32{1'b0}};
		end
		else begin
			if(!iNEXT_LOCK)begin
				b_next_inst <= iPREVIOUS_INST;
				b_next_inst_valid <= iPREVIOUS_INST_VALID;
				b_next_pagefault <= iPREVIOUS_PAGEFAULT;
				b_next_mmu_flags <= iPREVIOUS_MMU_FLAGS;
				b_next_paging_ena <= fetch_queue_paging_ena;
				b_next_kernel_access <= fetch_queue_kernel_access;
				b_pc_out <= fetch_queue_addr + 32'h4;
			end
		end
	end	//always
	
	assign oNEXT_INST = b_next_inst;
	assign oNEXT_INST_VALID = b_next_inst_valid;
	assign oNEXT_PAGEFAULT = b_next_pagefault;
	assign oNEXT_MMU_FLAGS = b_next_mmu_flags;
	assign oNEXT_PAGING_ENA = b_next_paging_ena;
	assign oNEXT_KERNEL_ACCESS = b_next_kernel_access;
	assign oNEXT_BRANCH_PREDICT = branch_predictor_valid && branch_predictor_predict_branch;
	assign oNEXT_BRANCH_PREDICT_ADDR = branch_predictor_addr;
	assign oNEXT_PC = b_pc_out;

	
endmodule



`default_nettype wire



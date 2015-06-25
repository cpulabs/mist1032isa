/********************************************************
MIST1032ISA Common Settings Header

If you do instruction-level or function-level check, 
you will need to select the Normal-Simulation Mode.

Open Design Computer Project
  Takahiro Ito
  http://open-arch.org
********************************************************/

`ifdef MIST1032ISA_SYNTH

	//Synthesize Mode
	`define MIST1032ISA_INST_L1_CACHE
	`define MIST1032ISA_DATA_L1_CACHE
	//`define MIST1032ISA_BRANCH_PREDICT
	`define MIST1032ISA_STANDARD_DEBUGGER
	//`define MIST1032ISA_ALTERA_PRIMITIVE 		it have bug?


`else

	//Normal Simulation Mode
	`define MIST1032ISA_INST_L1_CACHE
	`define MIST1032ISA_DATA_L1_CACHE
	`define MIST1032ISA_BRANCH_PREDICT
	`define MIST1032ISA_STANDARD_DEBUGGER
	//`define MIST1032ISA_ALTERA_PRIMITIVE

`endif



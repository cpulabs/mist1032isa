MIST32 - Open Source 32bit Processor
==================

Open Design Computer Project - [http://open-arch.org/](http://open-arch.org/)

MIST1032ISA
---
In order execution processor for MIST32 arcitecture.

If you need high performance. We offers a MIST1032SA out of order execute processor.

[MIST1032SA](https://github.com/cpulabs/mist1032sa)

License
---
BSD 2-Clause License

See ./LICENSE

Directory
---
  com		:	Common file. Source path, Include path...
  
  src		:	Source
  
  sim		:	Simulation


Include
---
  ./include/processor.h				:	Processor Infomation
  
  ./include/irq.h						:	Interrupt Infomation
  
  ./core/include/core.h				:	Instruction and Internal format

Macro Option(Synth/Sim)
---
  MIST1032ISA_INST_L1_CACHE			:	1-Level Instruction Cache Enable 
  
  MIST1032ISA_DATA_L1_CACHE			:	1-Level Data Cache Enable
  
  MIST1032ISA_BRANCH_PREDICT		:	Branch Predictor Enable
  
  MIST1032ISA_STANDARD_DEBUGGER		:	SDI Enable

  MIST1032ISA_ALTERA_PRIMITIVE  : Use altera promitive block(Farst. But altera only).
  


Macro Option(Synth-Only)
  MIST1032ISA_SYNTH					:	Synthesize Mode(Always Simulation Macro Disable)
  
  
Macro Option(Sim-only)
---
  MIST1032ISA_SVA_ASSERTION			:	Simulation Only, System Verilog Assertion Enable
  
  MIST1032ISA_FIRST_SIM				:	Simulation Only, Use Function ROM. First Simulate.

  
Tool
---
We have validated the correctness of this design in the following tools.

Simulator
--
Riviera-Pro(Aldec)
 
Lint
--
ALINT(Aldec)

Synthesis
--
Quartus II(Altera)



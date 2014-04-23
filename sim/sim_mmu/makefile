default : compile sim


compile:
	vlib work
	vmap work work
	vlog ./tb/*.v
	vlog ../model/sim_memory_model/*.v
	vlog ../../src/mmu/mmu.v
	vlog ../../src/mmu/mmu_table_load.v
	vlog ../../src/mmu/mmu_tlb.v
	vlog ../../src/lib/*.v

sim:
	vsim -gui tb_mmu -do "run -all"
default : compile sim


compile:
	vlib work
	vlog -sv -work work ./tb/*.sv
	vlog -work work ../model/sim_memory_model/*.v
	vlog -work work +incdir+../../src/mmu/include ../../src/mmu/mmu.v
	vlog -work work +incdir+../../src/mmu/include ../../src/mmu/mmu_table_load.v
	vlog -work work +incdir+../../src/mmu/include ../../src/mmu/mmu_tlb.v
	vlog -work work ../../src/lib/*.v

sim:
	vsim -c -voptargs="+acc" tb_mmu -do "log -r /*; run -all"
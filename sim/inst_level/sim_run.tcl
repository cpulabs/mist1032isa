transcript file sim/mulh.result

vlib work
vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ./tb/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../model/sim_memory_model/sim_memory_model.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../model/altera/altera_mf.v
vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/primitive/altera/sync_fifo_8in_8out_16depth/altera_primitive_sync_fifo_8in_8out_16depth.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/primitive/altera/sync_fifo_24in_24out_16depth/altera_primitive_sync_fifo_24in_24out_16depth.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/primitive/altera/sync_fifo_34in_34out_8depth/altera_primitive_sync_fifo_34in_34out_8depth.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/primitive/altera/sync_fifo_102in_102out_32depth/altera_primitive_sync_fifo_102in_102out_32depth.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/primitive/altera/ram_256bit_16word/ram_256bit_16word.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/primitive/altera/ram_512bit_16word/ram_512bit_16word.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/debugger/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/dps/mimsr/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/dps/sci/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/dps/utim64/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/dps/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/pic/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/mmu/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/lib/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/branch_predictor/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/core_debug/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/decode/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/dispatch/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/execute/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/execute/divider/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/fetch/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/instruction_buffer/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/l1_data/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/l1_instruction/*.v

vlog -work work +incdir+../../src/include +incdir+../../src/mmu/include +incdir+../../src/core/include ../../src/core/pipeline_control/*.v
run -all
quit

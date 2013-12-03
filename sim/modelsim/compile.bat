transcript file code_check.log

vlib work
vmap work work
vlog +incdir+../../src/include +incdir+../../src/core/include ./tb/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../model/sim_memory_model/sim_memory_model.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../model/altera/altera_mf.v

vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/primitive/altera/sync_fifo_8in_8out_16depth/altera_primitive_sync_fifo_8in_8out_16depth.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/primitive/altera/sync_fifo_28in_28out_16depth/altera_primitive_sync_fifo_28in_28out_16depth.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/primitive/altera/sync_fifo_34in_34out_8depth/altera_primitive_sync_fifo_34in_34out_8depth.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/primitive/altera/sync_fifo_102in_102out_32depth/altera_primitive_sync_fifo_102in_102out_32depth.v

vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/debugger/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/dps_device/mimsr/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/dps_device/sci/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/dps_device/utim64/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/dps_main/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/mmu/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/lib/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/branch_predictor/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/core_debug/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/decode/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/dispatch/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/execution/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/execution/divider/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/fetch/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/instruction_buffer/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/l1_data/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/l1_instruction/*.v
vlog +incdir+../../src/include +incdir+../../src/core/include ../../src/core/pipeline_control/*.v


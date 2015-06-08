onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iEVENT_HOLD
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iEVENT_START
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_VALID
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_PC
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/b_state
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/iEXCEPT_IRQ_REQ
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/iEXCEPT_IRQ_NUM
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/iEXCEPT_IRQ_FI0R
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/iEXCEPT_IRQ_FI1R
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/oEXCEPT_IRQ_ACK
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/oEXCEPT_IRQ_BUSY
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/alu_jump_irq_call_start_condition
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/irq_call_start_condition
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/irq_call_finished
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/irq_call_hundler
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/b_sysreg_set_pcr_valid
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/b_sysreg_set_pcr
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/irq_return_start_condition
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/IRQ_RETURN/iRETURN_START
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/IRQ_RETURN/oFINISH
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/oEVENT_SETREG_PPCR_SET
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/oEVENT_SETREG_PPCR
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/iEXE_JUMP_ADDR
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/PPCR/b_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {364530000 ps} 0}
configure wave -namecolwidth 192
configure wave -valuecolwidth 144
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {363192649 ps} {366238555 ps}

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
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/alu_jump_start_condition
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/irq_call_start_condition
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/irq_return_start_condition
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/idt_set_start_condition
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/reload_start_condition
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/oEVENT_SETREG_PPCR_SET
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/oEVENT_SETREG_PPCR
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/iEXE_JUMP_ADDR
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/PPCR/b_data
add wave -noupdate -radix decimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/test0
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/iSYSREG_PCR
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/iSYSREG_PPCR
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/oEVENT_IRQ_FRONT2BACK
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/PIPELINE_CTRL/oEVENT_IRQ_BACK2FRONT
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/iREQ_VALID
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/iREQ_RW
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/DPS/DPS_UTIM64/iREQ_ADDR
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/DPS/DPS_UTIM64/iREQ_DATA
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_REQ
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_RW
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_ADDR
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_DATA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {419450000 ps} 0}
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
WaveRestoreZoom {415218 ns} {423921424 ps}

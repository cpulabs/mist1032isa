onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oPREVIOUS_LOCK
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_VALID
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_PC
add wave -noupdate -radix unsigned /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/EXE_ADDER/iDATA_0
add wave -noupdate -radix unsigned /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/EXE_ADDER/iDATA_1
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/CORE_INT_M/iEXT_ACTIVE
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_REQ
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_VALID
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_DATA
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/iPREVIOUS_SOURCE0_SYSREG
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/iWB_VALID
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/sysreg_source0
add wave -noupdate -group {New Group} /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/REG_FLAG/iPFLAGR_VALID
add wave -noupdate -group {New Group} /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/REG_FLAG/iPFLAGR
add wave -noupdate -group {New Group} /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/iEVENT_IRQ_FRONT2BACK
add wave -noupdate -group {New Group} /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/iEVENT_IRQ_BACK2FRONT
add wave -noupdate -group {New Group} /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iEVENT_HOLD
add wave -noupdate -group {New Group} /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iEVENT_START
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/PPCR/b_data
add wave -noupdate -radix unsigned /tb_func_level/TARGET/CORE/CORE_PIPELINE/CORE_IM/b_branch_addr
add wave -noupdate /tb_func_level/TARGET/io2cpu_valid
add wave -noupdate /tb_func_level/TARGET/PIC/b_iosize_state
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/iREQ_RW
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/oREQ_VALID
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/UTIM64A/iREQ_VALID
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/UTIM64A/iREQ_RW
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/UTIM64A/oREQ_VALID
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/UTIM64A/out_fifo_read_condition
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/UTIM64A/out_fifo_empty
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/UTIM64A/req_fifo_read_condition
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/UTIM64A/req_fifo_empty
add wave -noupdate /tb_func_level/TARGET/DPS/DPS_UTIM64/UTIM64A/req_fifo_rw
add wave -noupdate /tb_func_level/TARGET/CORE/oIO_REQ
add wave -noupdate /tb_func_level/TARGET/CORE/iIO_VALID
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {159463246 ps} 0} {{Cursor 3} {345676264 ps} 0}
configure wave -namecolwidth 248
configure wave -valuecolwidth 100
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
WaveRestoreZoom {343883955 ps} {348337041 ps}

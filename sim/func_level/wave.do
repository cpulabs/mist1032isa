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
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_DESTINATION
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_WRITEBACK
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/ex_module_source0
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE0
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/b_source0
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/writeback_source0_valid
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/sysreg_source0_valid
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/iPREVIOUS_SOURCE0_SYSREG
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/iWB_VALID
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/sysreg_source0
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/sysreg_source0_valid
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/iPREVIOUS_SOURCE0_SYSREG
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/iPREVIOUS_SOURCE0
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/iWB_VALID
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/iWB_DESTINATION
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/CORE_INT_M/iEXT_ACTIVE
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/CORE_INT_M/oEXT_ACK
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {399149532 ps} 0} {{Cursor 2} {373094542 ps} 0}
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
WaveRestoreZoom {394683449 ps} {403902193 ps}

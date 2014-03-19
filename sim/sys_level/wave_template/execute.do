onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iCLOCK
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_VALID
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION_SYSREG
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_WRITEBACK
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE0
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE1
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE0_POINTER
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE1_POINTER
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_PC
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oPREVIOUS_LOCK
add wave -noupdate -expand -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_VALID
add wave -noupdate -expand -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_DATA
add wave -noupdate -expand -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_DESTINATION
add wave -noupdate -expand -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_DESTINATION_SYSREG
add wave -noupdate -expand -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_WRITEBACK
add wave -noupdate -expand -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_SPR_WRITEBACK
add wave -noupdate -expand -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_SPR
add wave -noupdate -expand -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_PC
add wave -noupdate -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/LDST/iSOURCE0
add wave -noupdate -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/LDST/iSOURCE1
add wave -noupdate -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/LDST/oOUT_DATA
add wave -noupdate -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/LDST/oLDST_DATA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30682637834 ps} 0}
configure wave -namecolwidth 239
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
WaveRestoreZoom {30681683453 ps} {30683566488 ps}

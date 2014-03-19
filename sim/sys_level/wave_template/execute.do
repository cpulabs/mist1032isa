onerror {resume}
quietly WaveActivateNextPane {} 0
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
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iCLOCK
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_VALID
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_DATA
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_DESTINATION
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_DESTINATION_SYSREG
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_WRITEBACK
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_SPR_WRITEBACK
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_SPR
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_PC
add wave -noupdate -expand -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_REQ
add wave -noupdate -expand -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iDATAIO_BUSY
add wave -noupdate -expand -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_ORDER
add wave -noupdate -expand -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_MASK
add wave -noupdate -expand -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_RW
add wave -noupdate -expand -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_ADDR
add wave -noupdate -expand -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_DATA
add wave -noupdate -expand -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iDATAIO_REQ
add wave -noupdate -expand -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iDATAIO_DATA
add wave -noupdate -radix hexadecimal /tb_sys_level/MEMORY_MODEL/iMEMORY_REQ
add wave -noupdate -radix hexadecimal /tb_sys_level/MEMORY_MODEL/oMEMORY_LOCK
add wave -noupdate /tb_sys_level/MEMORY_MODEL/iMEMORY_ORDER
add wave -noupdate /tb_sys_level/MEMORY_MODEL/iMEMORY_MASK
add wave -noupdate -radix hexadecimal /tb_sys_level/MEMORY_MODEL/iMEMORY_RW
add wave -noupdate -radix hexadecimal -childformat {{{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[31]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[30]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[29]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[28]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[27]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[26]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[25]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[24]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[23]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[22]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[21]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[20]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[19]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[18]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[17]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[16]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[15]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[14]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[13]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[12]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[11]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[10]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[9]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[8]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[7]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[6]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[5]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[4]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[3]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[2]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[1]} -radix hexadecimal} {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[0]} -radix hexadecimal}} -subitemconfig {{/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[31]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[30]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[29]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[28]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[27]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[26]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[25]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[24]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[23]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[22]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[21]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[20]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[19]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[18]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[17]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[16]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[15]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[14]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[13]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[12]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[11]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[10]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[9]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[8]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[7]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[6]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[5]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[4]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[3]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[2]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[1]} {-height 15 -radix hexadecimal} {/tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR[0]} {-height 15 -radix hexadecimal}} /tb_sys_level/MEMORY_MODEL/iMEMORY_ADDR
add wave -noupdate -radix hexadecimal /tb_sys_level/MEMORY_MODEL/iMEMORY_DATA
add wave -noupdate /tb_sys_level/MEMORY_MODEL/system_write_condition
add wave -noupdate /tb_sys_level/MEMORY_MODEL/system_read_condition
add wave -noupdate /tb_sys_level/MEMORY_MODEL/oMEMORY_VALID
add wave -noupdate /tb_sys_level/MEMORY_MODEL/oMEMORY_DATA
add wave -noupdate /tb_sys_level/MEMORY_MODEL/test_1_
add wave -noupdate /tb_sys_level/MEMORY_MODEL/test_2_
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {31052461435 ps} 0}
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
WaveRestoreZoom {31051736147 ps} {31053210707 ps}

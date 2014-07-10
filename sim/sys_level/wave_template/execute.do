onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oJUMP_VALID
add wave -noupdate -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oBRANCH_ADDR
add wave -noupdate -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_VALID
add wave -noupdate -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION_SYSREG
add wave -noupdate -group {Execute - Port Prev} -radix hexadecimal -childformat {{{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[4]} -radix hexadecimal} {{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[3]} -radix hexadecimal} {{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[2]} -radix hexadecimal} {{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[1]} -radix hexadecimal} {{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[0]} -radix hexadecimal}} -subitemconfig {{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[4]} {-height 15 -radix hexadecimal} {/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[3]} {-height 15 -radix hexadecimal} {/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[2]} {-height 15 -radix hexadecimal} {/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[1]} {-height 15 -radix hexadecimal} {/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[0]} {-height 15 -radix hexadecimal}} /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION
add wave -noupdate -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_WRITEBACK
add wave -noupdate -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE0
add wave -noupdate -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE1
add wave -noupdate -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE0_POINTER
add wave -noupdate -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE1_POINTER
add wave -noupdate -group {Execute - Port Prev} /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_ADV_DATA
add wave -noupdate -group {Execute - Port Prev} /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_ADV_ACTIVE
add wave -noupdate -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_PC
add wave -noupdate -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oPREVIOUS_LOCK
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iCLOCK
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_VALID
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_DATA
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_DESTINATION
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_DESTINATION_SYSREG
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_WRITEBACK
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_SPR_WRITEBACK
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_SPR
add wave -noupdate -group {Execute - Port Next} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oNEXT_PC
add wave -noupdate -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_REQ
add wave -noupdate -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iDATAIO_BUSY
add wave -noupdate -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_ORDER
add wave -noupdate -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_MASK
add wave -noupdate -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_RW
add wave -noupdate -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_ADDR
add wave -noupdate -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_DATA
add wave -noupdate -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iDATAIO_REQ
add wave -noupdate -group {Execute - DataIo} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iDATAIO_DATA
add wave -noupdate -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/oDEBUG_REG_OUT_GR30
add wave -noupdate -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/b_r_spr
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_IM/iSYSREG_PSR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SYSREG_PDTR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/w_sysreg_pdtr_info_data
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SYSREG_PDTR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/oNEXT_SYSREG_PDTR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_MMUMOD
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_MMUPS
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/oSYSREG_PSR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SYSREG_PSR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oPDTSET_VALID
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oPSRSET_VALID
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iFREE_REGISTER_LOCK
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iFREE_PIPELINE_STOP
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iFREE_REFRESH
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/FETCH/oPREVIOUS_FETCH_REQ
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/FETCH/oPREVIOUS_MMUMOD
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/FETCH/oPREVIOUS_MMUPS
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/FETCH/oPREVIOUS_FETCH_ADDR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/FETCH/iPREVIOUS_INST_VALID
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/FETCH/iPREVIOUS_MMU_FLAGS
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/FETCH/iPREVIOUS_INST
add wave -noupdate -expand -group MMU -radix hexadecimal /tb_sys_level/TARGET/MMU_IF/MMU/iLOGIC_REQ
add wave -noupdate -expand -group MMU -radix hexadecimal /tb_sys_level/TARGET/MMU_IF/MMU/iLOGIC_PDT
add wave -noupdate -expand -group MMU -radix hexadecimal /tb_sys_level/TARGET/MMU_IF/MMU/iLOGIC_MMUMOD
add wave -noupdate -expand -group MMU -radix hexadecimal /tb_sys_level/TARGET/MMU_IF/MMU/iLOGIC_MMUPS
add wave -noupdate -expand -group MMU -radix hexadecimal /tb_sys_level/TARGET/MMU_IF/MMU/oMEMORY_REQ
add wave -noupdate -expand -group MMU -radix hexadecimal /tb_sys_level/TARGET/MMU_IF/MMU/oMEMORY_MMU_USE
add wave -noupdate -expand -group MMU -radix hexadecimal /tb_sys_level/TARGET/MMU_IF/MMU/oMEMORY_ADDR
add wave -noupdate -expand -group MMU -radix hexadecimal /tb_sys_level/TARGET/MMU_IF/MMU/iMEMORY_VALID
add wave -noupdate -expand -group MMU -radix hexadecimal /tb_sys_level/TARGET/MMU_IF/MMU/iMEMORY_DATA
add wave -noupdate -radix unsigned /tb_sys_level/TARGET/MMU_IF/MMU/b_table_load_buffer
add wave -noupdate -radix hexadecimal /tb_sys_level/TARGET/MMU_IF/MMU/b_logic_addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5640819204 ps} 0}
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
WaveRestoreZoom {5640619966 ps} {5641218070 ps}

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oJUMP_VALID
add wave -noupdate -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oBRANCH_ADDR
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_VALID
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION_SYSREG
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal -childformat {{{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[4]} -radix hexadecimal} {{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[3]} -radix hexadecimal} {{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[2]} -radix hexadecimal} {{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[1]} -radix hexadecimal} {{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[0]} -radix hexadecimal}} -subitemconfig {{/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[4]} {-height 15 -radix hexadecimal} {/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[3]} {-height 15 -radix hexadecimal} {/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[2]} {-height 15 -radix hexadecimal} {/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[1]} {-height 15 -radix hexadecimal} {/tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION[0]} {-height 15 -radix hexadecimal}} /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_DESTINATION
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_WRITEBACK
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE0
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE1
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE0_POINTER
add wave -noupdate -expand -group {Execute - Port Prev} -radix hexadecimal /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SOURCE1_POINTER
add wave -noupdate -expand -group {Execute - Port Prev} /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_ADV_DATA
add wave -noupdate -expand -group {Execute - Port Prev} /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_ADV_ACTIVE
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
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oBRANCH_ADDR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oFAULT_VALID
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oFAULT_NUM
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oFAULT_FI0R
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oFAULT_FI1R
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_INT_M/iFAULT_ACTIVE
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_INT_M/iFAULT_NUM
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_INT_M/iFAULT_FI0R
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_INT_M/oEXCEPTION_ACTIVE
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_INT_M/oEXCEPTION_IRQ_NUM
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_INT_M/oEXCEPTION_IRQ_FI0R
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_INT_M/iEXCEPTION_LOCK
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_IM/b_main_state
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_IM/iEXCEPT_IRQ_REQ
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_IM/iEXCEPT_IRQ_NUM
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_IM/iEXCEPT_IRQ_FI0R
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_IM/oEXCEPT_IRQ_ACK
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_IM/oEXCEPT_IRQ_BUSY
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/CORE_IM/iSYSREG_PSR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SYSREG_PDTR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/w_sysreg_pdtr_info_data
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SYSREG_PDTR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/oNEXT_SYSREG_PDTR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_MMUMOD
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oDATAIO_MMUPS
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/DISPATCH/oSYSREG_PSR
add wave -noupdate /tb_sys_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iPREVIOUS_SYSREG_PSR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5640458069 ps} 0}
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
WaveRestoreZoom {5639082989 ps} {5642669313 ps}

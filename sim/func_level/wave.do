onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iEVENT_HOLD
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iFREE_PIPELINE_STOP
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/iFREE_REFRESH
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/CORE_IM/b_main_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {398390000 ps} 0}
configure wave -namecolwidth 192
configure wave -valuecolwidth 62
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
WaveRestoreZoom {396916606 ps} {399191312 ps}

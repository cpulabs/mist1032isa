onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oJUMP_VALID
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oINTR_VALID
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oIDTSET_VALID
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oPDTSET_VALID
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/EXECUTE/oPSRSET_VALID
add wave -noupdate -expand -group {New Group} -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/iBRANCH_PREDICT_RESULT_JUMP_INST
add wave -noupdate -expand -group {New Group} -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/iBRANCH_PREDICT_RESULT_JUMP
add wave -noupdate -expand -group {New Group} -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/iBRANCH_PREDICT_RESULT_JUMP_ADDR
add wave -noupdate -expand -group {New Group} -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/iBRANCH_PREDICT_RESULT_INST_ADDR
add wave -noupdate -expand -group {New Group} /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/iBRANCH_PREDICT_RESULT_PREDICT
add wave -noupdate -expand -group {New Group} /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/iBRANCH_PREDICT_RESULT_HIT
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/BRANCH_PREDICTOR/BRANCH_CACHE/iJUMP_STB
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/BRANCH_PREDICTOR/BRANCH_CACHE/iJUMP_HIT
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/BRANCH_PREDICTOR/BRANCH_CACHE/iJUMP_ADDR
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/BRANCH_PREDICTOR/BRANCH_CACHE/iJUMP_INST_ADDR
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/BRANCH_PREDICTOR/BRANCH_CACHE/test_lru0_4
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/BRANCH_PREDICTOR/BRANCH_CACHE/test_lru1_4
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/BRANCH_PREDICTOR/BRANCH_CACHE/test_predict0_4
add wave -noupdate -radix hexadecimal /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/BRANCH_PREDICTOR/BRANCH_CACHE/test_predict1_4
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/BRANCH_PREDICTOR/BRANCH_CACHE/request_hit
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/BRANCH_PREDICTOR/BRANCH_CACHE/hit_way
add wave -noupdate /tb_func_level/TARGET/CORE/CORE_PIPELINE/FETCH/BRANCH_PREDICTOR/BRANCH_CACHE/oSRARCH_PREDICT_BRANCH
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15790 ns} 0} {{Cursor 2} {2187 ns} 0} {{Cursor 3} {19570 ns} 0}
configure wave -namecolwidth 275
configure wave -valuecolwidth 121
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
configure wave -timelineunits ns
update
WaveRestoreZoom {13014 ns} {23792 ns}

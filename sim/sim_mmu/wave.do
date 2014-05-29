onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {From Core} -radix hexadecimal /tb_mmu/iCLOCK
add wave -noupdate -expand -group {From Core} -radix hexadecimal /tb_mmu/TARGET/inRESET
add wave -noupdate -expand -group {From Core} -radix hexadecimal /tb_mmu/TARGET/iRESET_SYNC
add wave -noupdate -expand -group {From Core} -radix hexadecimal /tb_mmu/TARGET/iTLB_FLUSH
add wave -noupdate -expand -group {From Core} -radix hexadecimal /tb_mmu/TARGET/iLOGIC_REQ
add wave -noupdate -expand -group {From Core} -radix hexadecimal /tb_mmu/TARGET/oLOGIC_LOCK
add wave -noupdate -expand -group {From Core} -radix hexadecimal /tb_mmu/TARGET/iLOGIC_ADDR
add wave -noupdate -expand -group {To Memory} -radix hexadecimal /tb_mmu/TARGET/oMEMORY_REQ
add wave -noupdate -expand -group {To Memory} /tb_mmu/TARGET/oMEMORY_MMU_USE
add wave -noupdate -expand -group {To Memory} -radix hexadecimal /tb_mmu/TARGET/iMEMORY_LOCK
add wave -noupdate -expand -group {To Memory} -radix hexadecimal /tb_mmu/TARGET/oMEMORY_ADDR
add wave -noupdate -expand -group {From Memory} -radix hexadecimal /tb_mmu/TARGET/iMEMORY_VALID
add wave -noupdate -expand -group {From Memory} -radix hexadecimal /tb_mmu/TARGET/oMEMORY_LOCK
add wave -noupdate -expand -group {From Memory} -radix hexadecimal /tb_mmu/TARGET/iMEMORY_DATA
add wave -noupdate -radix hexadecimal /tb_mmu/TARGET/b_main_state
add wave -noupdate /tb_mmu/TARGET/tlb_misshit_condition
add wave -noupdate /tb_mmu/TARGET/tlb_rd_valid
add wave -noupdate /tb_mmu/TARGET/tlb_rd_hit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {390 ns} 0}
configure wave -namecolwidth 150
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {979 ns}
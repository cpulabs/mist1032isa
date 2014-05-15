####################################################################
# Simulator Target
####################################################################
#Riviera-Pro
default: riviera_code_check riviera_sim_run sim_summary
riviera: riviera_code_check riviera_sim_run sim_summary
riviera_wave: riviera_code_check riviera_sim_run_wave sim_summary

#Model-sim
modelsim: modelsim_code_check modelsim_sim_run sim_summary
modelsim_wave: modelsim_code_check modelsim_sim_run_wave sim_summary

####################################################################



########## Modelsim ##########
modelsim_code_check:
	python gen_tcl.py 0 modelsim 0 tb_inst_level ./sim_list.txt ../../com/src_list.txt ../../com/inc_list.txt code_check.log code_check.tcl
	echo ----------------------------------------------------------------------------------------
	echo Start Code Check

	vsim -do code_check.tcl
	python code_check_summary.py code_check.log

modelsim_sim_run:
	python sim_run.py code_check.log modelsim 0 tb_inst_level tb_inst_test.hex ./sim_list.txt ../../com/src_list.txt ../../com/inc_list.txt bin/
modelsim_sim_run_wave:
	python sim_run.py code_check.log modelsim 1 tb_inst_level tb_inst_test.hex ./sim_list.txt ../../com/src_list.txt ../../com/inc_list.txt bin/


########## Riviera ##########
riviera_code_check:
	python gen_tcl.py 0 riviera 0 tb_inst_level ./sim_list.txt ../../com/src_list.txt ../../com/inc_list.txt code_check.log code_check.tcl
	echo ----------------------------------------------------------------------------------------
	echo Start Code Check

	vsimsa -do code_check.tcl
	python code_check_summary.py code_check.log

riviera_sim_run:
	python sim_run.py code_check.log riviera 0 tb_inst_level tb_inst_test.hex ./sim_list.txt ../../com/src_list.txt ../../com/inc_list.txt bin/
riviera_sim_run_wave:
	python sim_run.py code_check.log riviera 1 tb_inst_level tb_inst_test.hex ./sim_list.txt ../../com/src_list.txt ../../com/inc_list.txt bin/


########## Simulation Summary ##########
sim_summary:
	python sim_summary.py sim/
	

####################################################################
# Simulator Target
####################################################################

#Model-sim
default: modelsim_code_check modelsim_sim_run sim_summary

#Riviera-Pro
#default: riviera_code_check riviera_sim_run sim_summary
####################################################################



########## Modelsim ##########
modelsim_code_check:
	python gen_tcl.py 0 modelsim ./sim_list.txt ../../com/src_list.txt ../../com/inc_list.txt code_check.log code_check.tcl
	echo ----------------------------------------------------------------------------------------
	echo Start Code Check

	vsim -do code_check.tcl
	python code_check_result.py code_check.log

modelsim_sim_run:
	python sim_run.py code_check.log modelsim ./sim_list.txt ../../com/src_list.txt ../../com/inc_list.txt bin/


########## Riviera ##########
riviera_code_check:
	python gen_tcl.py 0 riviera ./sim_list.txt ../../com/src_list.txt ../../com/inc_list.txt code_check.log code_check.tcl
	echo ----------------------------------------------------------------------------------------
	echo Start Code Check

	vsimsa -do code_check.tcl
	python code_check_result.py code_check.log

riviera_sim_run:
	python sim_run.py code_check.log riviera ./sim_list.txt ../../com/src_list.txt ../../com/inc_list.txt bin/







########## Old ##########
riviera_code_check__:
	python code_check_set.py compile_list.txt code_check.tcl
	
	vsimsa -do code_check.tcl
	python code_check_result.py code_check.log


riviera_sim_run__:
	python sim.py code_check.log compile_list.txt bin/





sim_summary:
	python sim_summary.py sim/
	

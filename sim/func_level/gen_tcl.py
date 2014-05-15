import subprocess;
import sys;


def generate_tcl(run, simulator, wave_ena, top_name, tb_model_list, srclist, inclist, log_name, tcl):
	wr_string = "transcript file " + log_name + "\n";

	#Init & Command
	if(simulator == "modelsim"):
		cmd = "vlog -work work "
		wr_string = wr_string + "vlib work\n";
	elif(simulator == "riviera"):
		cmd = "alog -work work -dbg "
		wr_string = wr_string + "alib work\nset work work\n";
	else:
		print("Error, Simulator Parameter");
		sys.exit();

	#Include
	incdir = "";
	fh = open(inclist, 'r');
	for line in fh:
		incdir = incdir + "+incdir+../" + line.rstrip() + " ";
	fh.close();

	#Make-TB Mode
	fh = open(tb_model_list, 'r');
	for line in fh:
		wr_string = wr_string + cmd + incdir + "" + line + "\n";
	fh.close();

	#Make-Src
	fh = open(srclist, 'r');
	for line in fh:
		wr_string = wr_string + cmd + incdir + "" + line + "\n";
	fh.close();

	#Simulation
	if(run == 1):
		if(simulator == "riviera"):
			wr_string = wr_string + "asim -coverage " + top_name + "\n";
			if(wave_ena == 1 or wave_ena == '1'):
				wr_string = wr_string + "wave -rec /*\n";
			wr_string = wr_string + "run -all\n";

		elif(simulator == "modelsim"):
			#For Wave save
			if(wave_ena == 1 or wave_ena == '1'):
				wr_string = wr_string + "radix -hexadecimal\n";
				wr_string = wr_string + "log -r /*\n";
			wr_string = wr_string + "run -all\n";

	#Quit
	wr_string = wr_string + "quit\n"

	#Save
	fh = open(tcl, "w");
	fh.write(wr_string);
	fh.close();


if __name__ == "__main__":
	if(len(sys.argv) != 10):	
		print("Error : Parameter missing");
		sys.exit();	
	generate_tcl(int(sys.argv[1]), sys.argv[2], int(sys.argv[3]), sys.argv[4], sys.argv[5], sys.argv[6], sys.argv[7], sys.argv[8], sys.argv[9]);


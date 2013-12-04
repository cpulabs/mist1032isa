import subprocess;
import sys;
import glob;
import datetime;
import locale;
import shutil;
import os;
import os.path;
import binascii;
import gen_tcl;


error_cnt = 0;
check_list = [];

def bin2hex(bin_prog):
	hex_prog = "";
	j = 0;
	for i in range(int(len(bin_prog)/8)):
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(i*8)+4]));
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(i*8)+5]));
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(i*8)+6]));
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(i*8)+7]));
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(i*8)+0]));
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(i*8)+1]));
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(i*8)+2]));
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(i*8)+3]));
		hex_prog = hex_prog + "\n";
		j = j + 1;
	if((len(bin_prog)%8 != 0)):
		hex_prog = hex_prog + "00";
		hex_prog = hex_prog + "00";
		hex_prog = hex_prog + "00";
		hex_prog = hex_prog + "00";
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(j*8)+0]));
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(j*8)+1]));
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(j*8)+2]));
		hex_prog = hex_prog + (binascii.b2a_hex(bin_prog[(j*8)+3]));
		hex_prog = hex_prog + "\n";
	return hex_prog;


def error_check(line_text):
	global error_cnt;
	line_list = line_text.split(' ');
	if(len(line_list) > 2):
			if(line_list[2] == "Error:"):
					error_cnt = error_cnt + 1;
						

						
def check_listup(f_dir):
	global check_list;

	for line in glob.glob(f_dir + '*.bin'):
		line = line.replace(f_dir, "");
		line = line.replace(".bin", "");
		check_list.append(line);



def sim_start(simulator, tb_model_list, srclist, inclist):
#def sim_start(sourcelist):
	global check_list;
	cnt = 0;
	#Message
	message = "Check Instruction : ";
	for instlist in check_list:
		message = message + instlist + ", ";
	print(message);
	
	if(os.path.exists("sim") != True):
		subprocess.call("mkdir sim", shell=True);
	
	#Simulation Loop
	for line in check_list:
		#Start Time
		date = datetime.datetime.today();
		print("-[" + str(cnt) + "]Start : [" + line + "] : " + date.strftime("%Y-%m-%d %H:%M:%S"));

		#Generate TCL
		gen_tcl.generate_tcl(1, simulator, tb_model_list, srclist, inclist, "sim/" + line + ".result\n", "sim_run.tcl");

		#Binary 2 Hex
		fr = open("./bin/" + line + ".bin", "rb");
		read_data = fr.read();
		result_hex = bin2hex(read_data);
		fw = open("func_level_test_tmp.hex", 'w');
		fw.write(result_hex);
		fr.close();
		fw.close();

		#Start Sim
		if(simulator == "modelsim"):
			subprocess.call("vsim -c tb_mist1032isa_func_level_test -do sim_run.tcl", shell=True);
		elif(simulator == "riviera"):
			subprocess.call("vsimsa -do sim_run.tcl", shell=True);
		else:
			print("Simulation Error");
			sys.exit();

		#End Time
		date = datetime.datetime.today();
		print("-[" + str(cnt) + "]Finish : [" + line + "] : " + date.strftime("%Y-%m-%d %H:%M:%S"));
		cnt = cnt + 1;

		#sys.exit();

		#Tempfile Remove
		os.remove("sim_run.tcl");
		os.remove("func_level_test_tmp.hex");




#args[1]=code_check.log, srgv[2]=sourcelist.txt args[3]=bin/	
if __name__ == "__main__":	
	print("\n\n----------------------------------------------------------------------------------------\nSimulation Start\n");
	if(len(sys.argv) != 7):
		print("Error : Command missing");
		sys.exit();
	
	fh = open(sys.argv[1], 'r');
	for line in fh:
		error_check(line);
		
	#subprocess.call("dir", shell=True);

		"""
		if(error_cnt != 0):
				print("Code Error, Stop");
				sys.exit();
		"""

	print("Do Check");
	
	#if(error_cnt == 0):
	check_listup(sys.argv[6]);
	if(len(check_list) != 0):
		#sim_start(sys.argv[2]);
		#sim_start();
		sim_start(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]);
		print("Simulation Finished");
	else:
		print("Simulation Error.\nNot found binary file.");


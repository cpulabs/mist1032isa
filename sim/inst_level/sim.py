import subprocess;
import sys;
import glob;
import datetime;
import locale;
import shutil:
import os;

error_cnt = 0;
check_list = [];

def error_check(line_text):
	global error_cnt;
	line_list = line_text.split(' ');
        if(len(line_list) > 2):
                if(line_list[2] == "Error:"):
                        error_cnt = error_cnt + 1;
                        

                        
def check_listup(f_dir):
        cnt = 0;
        instlist = glob.glob(f_dir + "*.bin");
        for fname in instlist:
                fname = fname.replace(f_dir, "");
                fname = fname.replace(".bin", "");
                check_list.append(fname);


def sim_start(sourcelist):
	global check_list;
        cnt = 0;
        #Message
        message = "Check Instruction : ";
        for instlist in check_list:
                message = message + instlist + ", ";
        print(message);

        #Simulation Loop
	for line in check_list:
                #Start Time
                date = datetime.datetime.today();
                print("-[" + str(cnt) + "]Start : [" + line + "] : " + date.strftime("%Y-%m-%d %H:%M:%S"));
                
                #Make TCL File
                newtext = "transcript file sim/" + line + ".result\n";
                fh = open(sourcelist, 'r');
                for codelist in fh:
                        newtext = newtext + codelist + "\n";
                newtext = newtext + "asim -coverage TOP_MODULE\n";
                newtext = newtext + "coverage save sim/" + line + ".ucdb\n";
                newtext = newtext + "run -all";
                
                fh = open("sim_run.tcl", "w");
                fh.write(newtext);
                fh.close();  

                #Copy Binary File
                shutil.copyfile("./bin/" + line + ".hex", "./inst_level_test_tmp.hex");

                #Start Sim
                subprocess.call("vsimsa -do sim_run.tcl", shell=True);

                #End Time
                date = datetime.datetime.today();
                print("-[" + str(cnt) + "]Finish : [" + line + "] : " + date.strftime("%Y-%m-%d %H:%M:%S"));
                cnt = cnt + 1;
	
                #Tempfile Remove
                os.remove("sim_run.tcl");
                os.remove("inst_level_test_tmp.hex");



#args[1]=code_check.log, srgv[2]=sourcelist.txt args[3]=bin/	
if __name__ == "__main__":	
        print("\n\n----------------------------------------------------------------------------------------\nSimulation Start\n");
	if(len(sys.argv) != 4):
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
	check_listup(sys.argv[3]);
        if(len(check_list) != 0):
                sim_start(sys.argv[2]);

        print("Simulation Finished");

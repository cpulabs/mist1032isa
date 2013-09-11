import subprocess;
import sys;


def save_file(save_addr, save_text):
	fh = open(save_addr, "w");
        fh.write(save_text);
        fh.close();


#args[1]=CodeListFileAddr, #args[2]=SaveFileAddr	
if __name__ == "__main__":	
        newtext = "transcript file codec_heck.log\n";

	if(len(sys.argv) != 3):
		print("Error : Command missing");
		sys.exit();
	
	fh = open(sys.argv[1], 'r');
	for line in fh:
		newtext = newtext + line;


        save_file(sys.argv[2], newtext);

		
	print("\n\n----------------------------------------------------------------------------------------\nStart Code Check")
	
	
	

import sys
import re

if __name__ == "__main__":
	if len(sys.argv) != 3:
		print("param-0 : source file")
		print("param-1 : destination file")
		sys.exit()

	src = open(sys.argv[1], "r")
	dest = open(sys.argv[2], "w")

	for line in src.readlines():
		if line.count('# [INFO]Time :'):
			match = re.match(r'[\#\s\t\[\]A-Za-z\:0-9,()]*Load/Store([\[\]SL,\s\t0-9a-f]*)', line.rstrip("\n"))
			if match == None:
				print("internal Error")

			r_data = match.group(1)
			print(r_data)
			dest.write(r_data + "\n")

	src.close()
	dest.close()

	print("done")


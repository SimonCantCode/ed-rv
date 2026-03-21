default:
	rm -f write_to_file
	riscv64-linux-gnu-as write_to_file.s -o write_to_file.o
	riscv64-linux-gnu-gcc -o write_to_file write_to_file.o -nostdlib -static

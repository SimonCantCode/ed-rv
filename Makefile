default:
	rm -f ed-rv ed-rv.o
	riscv64-linux-gnu-as ed-rv.s -o ed-rv.o
	riscv64-linux-gnu-gcc -o ed-rv ed-rv.o -nostdlib -static

clean:
	rm -f ed-rv ed-rv.o ed-rv_buff

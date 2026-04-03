# Defined constants
.include "constants.s"

### --- Register "defenitions" --- ###
# s1 is always used to store the returned file descriptor number.
# s2 is always used to check for unwritten changes. 1 for true 0 for false.
#
# (i wish .set unwritten_changes, s2 would just work instead)
###

.text
.global _start

_start:
	# initialize global pointer
	la gp, __global_pointer$ # name defined from default linker script
	j main

main:
	# print welcome meassage
	addi a7, zero, 64
	addi a0, zero, 1 #stdout
	la a1, welcome
	addi a2, zero, 43 # bytes
	ecall

	# (begining of) open syscall, used to open buffer as file.
	addi a7, zero, 56
	addi a0, zero, AT_FDCWD # dirfd

	# check if argv[1] empty <=> argc < 2
	ld t0, 0(sp) # argc
	addi t1, zero, 2
	bltu t0, t1, newfile # if argc < (unsigned) 2: j newfile
		ld a1, 16(sp) # set filename to argv[1]
		#TODO make a copy as a file buffer if opening existing file
		j newfile_end
	newfile:
		la a1, buffer_path # path
	newfile_end:

	# continuation of open syscall
	addi a2, zero, O_CREAT|O_RDWR # flags
	addi a3, zero,  S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH # mode, eg, file permissions if creating new file.
	ecall

	#save returned file descriptor
	addi s1, a0, 0

	# main normal_loop
	normal_loop:
		# Read syscall
		addi a7, zero, 63
		addi a0, zero, 0 #stdin
		la	 a1, input_buffer
		addi a2, zero, 8
		ecall

		# chech first character of read string
		lb t0, 0(a1)
		addi t1, zero, 113 # 'q'
		addi t2, zero, 64 # '@'
		
		# If print file command
		bne t0, t2, 1f
			jal ra, print_file
		1: # skip print

		bne t0, t1, normal_loop # if t0 != 'q': normal_loop

	# Checks for unwritten changes
	beqz s2, break # s2 = unwritten_changes (true/false)
		#TODO print error meassage here
		j normal_loop
	break:

	# close syscall
	addi a7, zero, 57
	add a0, s1, 0 # s1 is file descriptor returned from open()
	ecall

	# exit syscall
	addi a7, zero, 93
	# add a0, zero, a0
	ecall

# Functions moved out to reduce clutter
print_file:
	# lseek syscall to read from begining of file
	addi a7, zero, 62
	addi a0, s1, 0 # fd
	addi a1, zero, 0 # bytes in (beginning)
	addi a2, zero, SEEK_SET
	ecall

	### Read from file test
	addi a7, zero, 63
	addi a0, s1, 0
	la	 a1, read_buffer
	addi a2, zero, 255
	ecall

	### loop to find newlines
	# nl_loop:
	# addi t0, zero, 0 # i
	# lb t1, 0(a1) # could just subtract in the end to get number of itterations, idk
	#
	#
	#
	# addi a1, zero, 1
	# addi t0, zero, 1

	# print what was read 
	addi a7, zero, 64
	#la a1, welco #same buffer still in a1
	addi a2, a0, 0 # print bytes read
	addi a0, zero, 1 #stdout
	ecall
	ret

.data
.align 3 # = 2^3 = 8 byte alignemnt, reccomended for RV64, apparently
welcome:
	.ascii "Welcome to ed-rv! Press q<Enter> to quit.\n\0"
buffer_path: #TODO change to /tmp/ed-rv_buff
	.ascii "ed-rv_buff\0"
input_buffer: .space 8
read_buffer: .space 255

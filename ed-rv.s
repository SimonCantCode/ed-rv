# flags for open()
.equ AT_FDCWD, -100
.equ O_RDWR, 2
.equ O_CREAT, 64

# file permissions
.equ S_IRUSR, 00400 #user has read permission
.equ S_IWUSR, 00200 #user has write permission
.equ S_IRGRP, 00040 #group has read permission
.equ S_IROTH, 00004 #others have read permission

.text
.global _start

main:
	# print welcome meassage
	addi a7, zero, 64
	addi a0, zero, 1 #stdout
	la a1, welcome
	addi a2, zero, 43 # bytes
	ecall

	# open syscall, used to open buffer as file.
	addi a7, zero, 56
	addi a0, zero, AT_FDCWD # dirfd

	# check if argv[1] empty <=> argc < 2
	ld t0, 0(sp) # argc
	addi t1, zero, 2
	bltu t0, t1, newfile # if argc < (unsigned) 2: j newfile

	ld a1, 16(sp) # set filename to argv[1]
	j newfile_end
	newfile:
		la a1, buffer_path # path
	newfile_end:

	addi a2, zero, O_CREAT|O_RDWR # flags
	addi a3, zero,  S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH # mode
	ecall

	# main loop
	loop:
		# Read syscall
		addi a7, zero, 63
		addi a0, zero, 0 #stdin
		la	 a1, input_buffer
		addi a2, zero, 8
		ecall

		# chech first character of read string
		lb t0, 0(a1)
		addi t1, zero, 113
		bne t0, t1, loop # if t0 != 'q': loop
		#TODO use s1 to indicate if it has a filename or not or something

	# close syscall
	addi a7, zero, 57
	# add a0, zero, a0 # file descriptor returned from open() in a0 already
	ecall

	# exit syscall
	addi a7, zero, 93
	# add a0, zero, a0
	ecall

_start:
	# initialize global pointer
	la gp, __global_pointer$ # name defined from default linker script
	j main

.data
.align 3 # = 2^3 = 8 byte alignemnt, reccomended for RV64, apparently
welcome:
	.ascii "Welcome to ed-rv! Press q<Enter> to quit.\n\0"
buffer_path: #TODO change to /tmp/ed-rv_buff
	.ascii "ed-rv_buff\0"
input_buffer: .space 8

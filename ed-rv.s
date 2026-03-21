# flags for open()
.equ AT_FDCWD, -100
.equ O_RDWR, 2
.equ O_CREAT, 64

# file permissions
.equ S_IRUSR, 00400 #user has read permission
.equ S_IWUSR, 00200 #user has write permission
.equ S_IRGRP, 00040 #group has read permission
.equ S_IROTH, 00004 #others have read permission

.global _start

_start:
	# initialize global pointer
	la gp, __global_pointer$ # name defined from default linker script

	# open syscall
	addi a7, zero, 56
	addi a0, zero, AT_FDCWD # dirfd
	la a1, hello # path
	addi a2, zero, O_CREAT|O_RDWR # flags
	addi a3, zero,  S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH # mode
	ecall

	# close syscall
	addi a7, zero, 57
	# add a0, zero, a0 # file descriptor returned from open() in a0 already
	ecall

	# exit syscall
	addi a7, zero, 93
	# add a0, zero, a0
	ecall

hello:
	.ascii "myfile\0"

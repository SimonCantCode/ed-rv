# Defined constants
.include "constants.s"

# For line numbers (doesnt work)
.set LN_TEST, 0

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

		# check first character of read string
		lb t0, 0(a1)

		#TODo js use the same register
		addi t1, zero, 113 # 'q'
		addi t2, zero, 64 # '@'
		addi t3, zero, 48 # '0'
		addi t4, zero, 99 # 'c'
		
		# If print file command
		bne t0, t2, 1f
			jal ra, print_file
		1: # skip print

		# if 0 command
		bne t0, t3, 1f
			# lseek syscall
			addi a7, zero, 62
			addi a0, s1, 0 # fd
			addi a1, zero, 0 # bytes in
			addi a2, zero, SEEK_SET
			ecall
		1:

		# if c command
		bne t0, t4, 1f
			# read what to replace with
			addi a7, zero, 63
			addi a0, zero, 0 #stdin
			la	 a1, input_buffer
			addi a2, zero, 8
			ecall

			# lb t0, 0(a1)

			#replace character with write syscall
			addi a7, zero, 64
			addi a0, s1, 0
			# la a1, test
			addi a2, zero, 1 # bytes
			ecall
		1:

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

	1:
	### Read from file test
	addi a7, zero, 63
	addi a0, s1, 0
	la	 a1, read_buffer
	addi a2, zero, 255
	ecall

	# save returned val
	addi t5, a0, 0
	addi t4, a1, 0 # save read buff

	# Holy sphaghetti ill do ts later
	.if LN_TEST
	## loop to find newlines
	addi t2, zero, 10 # newline
	# new a1 in t3
	addi t3, a1, 0
	addi t0, zero, 0 # i  # could just subtract in the end to get number of itterations, idk
	nl_loop:
	lb t1, 0(t3)
	#unsafe lol but eh

	addi t3, t3, 1
	addi t0, t0, 1

	bne t1, t2, nl_loop

	# print line number (placeholder)
	addi a7, zero, 64
	addi a0, zero, 1 #stdout
	la a1, line_number
	addi a2, zero, 7 # bytes
	ecall
	.else
	addi t0, t5, 0
	.endif

	# print what was read 
	addi a7, zero, 64
	addi a1, t4, 0 
	addi a2, t0, 0 # print bytes read
	addi a0, zero, 1 #stdout
	ecall

	# bytes read still in a2
	bne t5, zero, 1b # print one more time if not at end of file (where a2 would be 0)
	ret

.data
.align 3 # = 2^3 = 8 byte alignemnt, reccomended for RV64, apparently
welcome:
	.ascii "Welcome to ed-rv! Press q<Enter> to quit.\n\0"
buffer_path: #TODO change to /tmp/ed-rv_buff
	.ascii "ed-rv_buff\0"
.if LN_TEST
line_number: .ascii "ln:    \0"
.endif
test: .ascii "p"
input_buffer: .space 8
read_buffer: .space 255

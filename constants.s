# flags for open()
.equ AT_FDCWD, -100
.equ O_RDWR, 2
.equ O_CREAT, 64

# flag for lseek
.equ SEEK_SET, 0 # "The file offset is set to offset bytes."

# file permissions
.equ S_IRUSR, 00400 #user has read permission
.equ S_IWUSR, 00200 #user has write permission
.equ S_IRGRP, 00040 #group has read permission
.equ S_IROTH, 00004 #others have read permission


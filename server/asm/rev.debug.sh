nasm -felf64 -o reverb.o reverb.asm
ld -o ./reverb ./reverb.o
gdb ./reverb
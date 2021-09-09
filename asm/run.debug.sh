nasm -felf64 -o audio.o main.asm
ld -o ./audio ./audio.o
gdb ./audio
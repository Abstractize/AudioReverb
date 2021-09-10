nasm -felf64 -o dereverb.o dereverb.asm
ld -o ./dereverb ./dereverb.o
gdb ./dereverb
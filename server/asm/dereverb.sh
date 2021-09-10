rm -f ./newsongdereverb.wav
touch ./newsongdereverb.wav
nasm -felf64 -o ./dereverb.o ./dereverb.asm
ld -o ./dereverb ./dereverb.o
./dereverb
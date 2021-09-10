rm -f ./newsongreverb.wav
touch ./newsongreverb.wav
nasm -felf64 -o ./reverb.o ./reverb.asm
ld -o ./reverb ./reverb.o
./reverb
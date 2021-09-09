rm -f ./newsong.wav
touch ./newsong.wav
nasm -felf64 -o audio.o main.asm
ld -o ./audio ./audio.o
./audio
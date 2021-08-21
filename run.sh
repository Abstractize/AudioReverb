mkdir -p build && cd build
nasm -felf64 -o audio.o ../main.asm
ld -o audio audio.o
./audio

cd ..
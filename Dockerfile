FROM ubuntu as base

RUN apt update
RUN apt install -y nasm 
RUN apt install -y gdb 
RUN apt install -y build-essential

COPY . /usr/src/app

WORKDIR /usr/src/app

RUN nasm -felf64 -o audio.o main.asm
RUN ld -o ./audio ./audio.o
CMD ./audio
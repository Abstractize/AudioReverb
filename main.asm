%include "linux64.inc"

; DATA ;
section .data
  k: db 10
  filename: db "song.wav", 0
  new_filename: db "newsong.wav", 0
  bytes_to_read: dd 105054
  value_a: dw 0x0180 ; binary: 0 000 0001.1000 0000 nondecimal: 384 decimal: 1.5
  value_b: dw 0x8340 ; binary: 1 000 0011.0100 0000 nondecimal:-832 decimal:-3.25
     ; result 0x04C0 ; binary: 0 000 0100.1100 0000 nondeciaml:-448 decimal:-1.75
  ; VARIABLES ;
section .bss
  offsetcounter resq 1 ; Counter for the offset
  stored_read_value resq 1 ; Store Value from Reading
  filecouter resq 1
  filesize resq 1
  data_one resq 1
  data_two resq 1
  data_tre resq 1
  data_for resq 1
  newfilecounter resq 1
  newline resq 1

section .text
  global _start

_start:
  mov rax, 0
; Initialize Values
  mov [filecouter], rax;
  mov [newfilecounter], rax;
  mov [offsetcounter], rax
  mov rax, 10
  mov [newline], rax;
; Read and Copy Until Data
  call _read_and_copy_until_data
  jmp _end

;;; COPY HEADER FILE ;;;
_read_and_copy_until_data:
  mov rax, 'd'
  cmp [data_one], rax
  jne _read_and_copy

  mov rax, 'a'
  cmp [data_two], rax
  jne _read_and_copy

  mov rax, 't'
  cmp [data_tre], rax
  jne _read_and_copy

  mov rax, 'a'
  cmp [data_for], rax
  jne _read_and_copy

  ret


_read_and_copy:
  ; Open File
  mov rax, SYS_OPEN
  mov rdi, filename
  mov rsi, O_RDONLY
  mov rdx, 0
  syscall

; Read Files
  push rax
  mov rdi, rax
  mov rax, SYS_LSEEK
  mov rsi, [offsetcounter]
  mov rdx, 0
  syscall ; Execute Offset

  mov rax, SYS_READ
  mov rsi, stored_read_value
  mov rdx, 1 ; Amount of Bytes to Read
  syscall

; Close File
  mov rax, SYS_CLOSE
  pop rdi
  syscall

; Open New File
  mov rax, SYS_OPEN
  mov rdi, new_filename
  mov rsi, O_WRONLY
  mov rdx, 0644o
  syscall

; Write to the File
  push rax
; Offset
  mov rdi, rax
  mov rax, SYS_LSEEK
  mov rsi, [offsetcounter]
  mov rdx, 0
  syscall ; Execute Offset
; Copy to new File
  mov rax, SYS_WRITE
  mov rsi, stored_read_value
  mov rdx, 1
  syscall

; Close File
  mov rax, SYS_CLOSE
  pop rdi
  syscall

; Set Variables for NEXT LOOP
  mov rax, 1
  add [offsetcounter], rax
  add [filecouter], rax
  add [newfilecounter], rax
; Assign values to check data word
  mov rax, [data_two]
  mov [data_one], rax
  mov rax, [data_tre]
  mov [data_two], rax
  mov rax, [data_for]
  mov [data_tre], rax
  mov rax, [stored_read_value]
  mov [data_for], rax
  
; PRINT TO CHECK
  ;call _print_check

; LOOPS
  jmp _read_and_copy_until_data

_print_check:
  print data_one
  print data_two
  print data_tre
  print data_for
  print newline
  ret
;;; PROCESS DATA ;;;
_readfile:
; Open File
  mov rax, SYS_OPEN
  mov rdi, filename
  mov rsi, O_RDONLY
  mov rdx, 0
  syscall

; Read Files
  push rax
  mov rdi, rax
  mov rax, SYS_LSEEK
  mov rsi, [offsetcounter]
  mov rdx, 0
  syscall ; Execute Offset
  mov rax, SYS_READ
  mov rsi, stored_read_value
  mov rdx, 2 ; Amount of Bytes to Read
  syscall
; Close File
  mov rax, SYS_CLOSE
  pop rdi
  syscall

  call _printfile

  mov rax, 2
  add [offsetcounter], rax

  ret

_openfile:
  
  ret
  
_getfileinfo:
  
  ret

_closefile:

  ret

_printfile:
  print stored_read_value
  ret

_writefile:
  ret

_check_header:
; Checks if file is RIFF type
; If it is correct goes to check other data
; Else exits the program with error
  ret

_apply_header:
; get header
; copy header
; store header in new file
  ret
_check_fmt:
; Checks if file is fmt type
; If is correct goes to apply fmt
; Else exits the program with error
  ret
_apply_fmt:
; get fmt
; copy fmt
; store fmt in new File
  ret

_check_data:
; Checks if file is DATA type
; If is correct goes to apply fmt
; Else exits the program with error
  ret

_apply_reverb:
  ret

; ;; FIXED POINT ARITHM;;;
_add:
  add rax, rbx
  ret

_multiply:

  ret

  ; ;; END ;;;
_end:
  exit
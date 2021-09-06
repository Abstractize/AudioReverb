%include "linux64.inc"

; DATA ;
section .data
  k: db 10
  filename: db "song.wav", 0
  new_filename: db "newsong.wav", 0
  bytes_to_read: dq 105054
  value_a: dw 0x0180 ; binary: 0 000 0001.1000 0000 nondecimal: 384 decimal: 1.5
  value_b: dw 0x8340 ; binary: 1 000 0011.0100 0000 nondecimal:-832 decimal:-3.25
     ; result 0x04C0 ; binary: 0 000 0100.1100 0000 nondeciaml:-448 decimal:-1.75
  newline: dq 10
  ; VARIABLES ;
section .bss
  ;;; WRITING VARIABLES ;;;
  offsetcounter resq 1 ; Counter for the offset
  filesize resq 1

  ;;; HEADER VARIABLES ;;;
  stored_read_value resq 1 ; Store Value from Reading
  data_one resq 1
  data_two resq 1
  data_tre resq 1
  data_for resq 1

  ;;; DATA VARIABLES ;;;
  reverb resq 1
  data_read_value resq 2; 

section .text
  global _start

_start:
  mov rax, 0
; Initialize Values
  mov [offsetcounter], rax
  mov rax, 10
  mov [newline], rax;
  mov rax, 1
  mov [reverb], rax;
; Read and Copy Until Data
  call _read_and_copy_until_data
  call _apply_effect
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

; Write to the New File
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
  call _print_check

; LOOPS
  jmp _read_and_copy_until_data

_print_check:
  print data_one
  print data_two
  print data_tre
  print data_for
  print newline
  ret

;;; Effect Processing ;;;
_apply_effect:
  call _apply_reverb
  call _deapply_reverb
  ret

_apply_reverb:
  mov rax, 1
  cmp [reverb], rax
  je _reverb_if
  ret

_reverb_if:
  mov rax, [bytes_to_read]
  cmp [offsetcounter], rax
  jl _reverb
  ret

_reverb:
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
  mov rsi, data_read_value
  mov rdx, 2 ; Amount of Bytes to Read
  syscall
; Close File
  mov rax, SYS_CLOSE
  pop rdi
  syscall

; APPLY REVERB

  print data_read_value
  ; FOR NOW WE'LL COPY

; Open New File
  mov rax, SYS_OPEN
  mov rdi, new_filename
  mov rsi, O_WRONLY
  mov rdx, 0644o
  syscall

; Write to the New File
  push rax
; Offset
  mov rdi, rax
  mov rax, SYS_LSEEK
  mov rsi, [offsetcounter]
  mov rdx, 0
  syscall ; Execute Offset
; Copy to new File
  mov rax, SYS_WRITE
  mov rsi, data_read_value
  mov rdx, 2
  syscall

; Close File
  mov rax, SYS_CLOSE
  pop rdi
  syscall

  ; FOR NOW WE'LL COPY
  mov rax, 2
  add [offsetcounter], rax

  jmp _reverb_if

_deapply_reverb:
  mov rax, 0
  cmp [reverb], rax
  je _dereverb_if
  ret

_dereverb_if:
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
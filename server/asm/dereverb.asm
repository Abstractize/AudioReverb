%include "linux64.inc"

; DATA ;
section .data
  filename: db "desong.wav", 0
  new_filename: db "newsongdereverb.wav", 0
  bytes_to_read: dq 99710
  newline: dq 10
  counterhead: db "# Count: "
  get: db "get: ", 0
  store: db "store: ", 0
  ; VARIABLES ;
section .bss
  k resq 1
  alpha resq 1; float = 4 bytes, fixed point 0000.9999(hex) = 0.6(dec)
  ;;; debugging ;;;
  printval resq 1;
  ;;; WRITING VARIABLES ;;;
  offsetcounter resq 1 ; Counter for the offset
  counter resq 1; counter for buffer
  filesize resq 1

  ;;; HEADER VARIABLES ;;;
  stored_read_value resq 1 ; Store Value from Reading
  data_one resq 1
  data_two resq 1
  data_tre resq 1
  data_for resq 1

  ;;; DATA VARIABLES ;;;
  reverb resq 1
  data_read_value resw 1; 
  data_read_value_k resw 1;

  ;;; CIRCULAR BUFFER ;;;
  array_value resw 1
  ;;; Fixed Point Conversion ;;;
  fractional_bits resb 1
section .text
  global _start

_start:
  mov rax, 0
; Initialize Values
  mov [offsetcounter], rax
  mov rax, 10
  mov [newline], rax;
; Initialize K
  mov rax, 50
  mov [k], rax
; Initialize Alpha
  mov rax, 0x99 ; Hex 16 bits: 00.99 -> Dec: 0.6
  mov [alpha], rax

; Initialize Type of Effect
  mov rax, 1
  mov [reverb], rax;
; Initialize Fractiona Bits for Conversions
  mov al, 8
  mov [fractional_bits], al
; Initialize Buffer Counter
  mov rax, 0
  mov [counter], rax

; Read and Copy Until Data
  call _read_and_copy_until_data
  call _apply_dereverb
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
  
; LOOPS
  jmp _read_and_copy_until_data

;;; Effect Processing ;;;
_apply_dereverb:
  call _dereverb_if
  ret

_dereverb_if:
  mov rax, [bytes_to_read]
  cmp [offsetcounter], rax
  jl _dereverb_loop
  ret
  
_dereverb_loop:
; Open File
  mov rax, SYS_OPEN
  mov rdi, filename
  mov rsi, O_RDONLY
  mov rdx, 0
  syscall

; Read File for x(n)
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

  ; Open File
  mov rax, SYS_OPEN
  mov rdi, filename
  mov rsi, O_RDONLY
  mov rdx, 0
  syscall

; Read File for x(n - k)
  mov rdx, [k]
  imul rdx, 2
  push rax
  mov rdi, rax
  mov rax, SYS_LSEEK
  mov rsi, [offsetcounter]
  sub rsi, rdx
  mov rdx, 0
  syscall ; Execute Offset
  mov rax, SYS_READ
  mov rsi, data_read_value_k
  mov rdx, 2 ; Amount of Bytes to Read
  syscall

  ; Close File
  mov rax, SYS_CLOSE
  pop rdi
  syscall

; Checks if counter - k < 0
  mov r15, [k]
  mov r14, [counter]

  call _clear_data_read_value_k; if counter - k < 0 data_read_value = 0;
; APPLY DEREVERB

; Effect
  ; rax = x(n)
  mov rax, [data_read_value]; Int is 16 Bits
  call _convert_int_fixed; WAV Has Samples as Ints, convert to 24 bits Fixed
  mov rbx, rax ; rbx = x(n)
  mov rax, [data_read_value_k] ; r(ax) = x(n-k)
  call _convert_int_fixed 
  call _dereverb ; returns converted value in rax
  call _convert_fixed_int; converts from fixed to 16 bits int
  mov [data_read_value], ax

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
  mov rsi, data_read_value; 16 bits

  mov rdx, 2
  syscall

; Close File
  mov rax, SYS_CLOSE
  pop rdi
  syscall

  mov rax, 2
  add [offsetcounter], rax
  mov rax, 1
  add [counter], rax

  jmp _dereverb_if

_clear_data_read_value_k:
; r14: counter
; r15: k
  cmp r14, r15; counter < k
  jl _clear_k
  ret

_clear_k:
  
  mov r15, 0
  mov [data_read_value_k], r15
  ret

_negate:
  xor rbx, 0xFFFFFF
  ret

_dereverb:
  ; rax = x(n-k)
  ; rbx = x(n)
  ; y(n) = (1-alpha) x(n) + alpha y(n-k) 
  ;mov rdx, rax ; rdx = rax = x(n-k)
  mov rcx, rbx ; rcx = x(n)

  mov rbx, rax ; rbx = x(n-k)
  mov rax, [alpha]; rax = alpha
  
  call _multiply; rax = alpha x(n-k)

  mov rbx, rax; rbx = alpha x(n-k)

  cmp rbx, 0
  jne _negate ; rbx = - alpha x(n-k)
  
  mov rax, rcx; rax = x(n)

  call _add
  
  mov rcx, rax
  mov rbx, [alpha]
  call _negate
  mov rax, 0x100
  
  call _add

  mov rdi, 0x100
  mov rsi, rax
  idiv rsi; returns in rax
  
  mov rbx, rcx
  call _multiply
  ret


;;; Conversions ;;;
_convert_int_fixed:
  shl eax, 8; Converts to 24 bits
  ret

_convert_fixed_float: ;number in eax; 24 bits -> 16 bits
  mov ebx, 1
  shl ebx, 8
  mov rdi, rax
  mov rsi, rbx
  idiv rsi; returns in rax
  ret

_convert_float_fixed: ;number in rax
  mov ebx, 1
  shl ebx, 8
  imul eax, ebx
  ;; round
  call _round
  ret

_convert_fixed_int:; 24 bits -> 16 bits
  shl eax, 8 ; deletes gap
  shr eax, 16; converts to 16
  ret

;;; MATH PACKAGE ;;;

_round:
  ret

;;; FIXED POINT ARITHM;;;

_add:
  ; clean a to 24 bits
  shl rax, 40
  shr rax, 40
  ; clean b to 24 bits
  shl rbx, 40
  shr rbx, 40

  ;;; A PART ;;;
  ; r13 a decimals 8 bit
  mov r13, rax; r13 = 0xAAAA.AA
  shl r13, 56
  shr r13, 56 ; r13 = 0x0000.AA
  ; r14 a int part 15 bit
  shr rax, 8 ; cuts decimal part
  mov r14, rax; r14 = AAAA
  shl r14, 49;
  shr r14, 49; deletes sign
  ; rax a sign
  shr rax, 15; moves sign to bit 1

  ;;; B PART ;;;
  ; r10 b decimals 8 bit
  mov r10, rbx; r13 = 0xBBBB.BB
  shl r10, 56
  shr r10, 56 ; r13 = 0x0000.BB
  ; r11 b int part 15 bit
  shr rbx, 8 ; cuts decimal part
  mov r11, rbx; r14 = AAAA
  shl r11, 49;
  shr r11, 49; deletes sign
  ; rbx b sign
  shr rbx, 15 ; moves sign to bit 1

  ;;; DECIMAL ;;;
  ; calculate decimal 8 bit
  add r13, r10 ; r13 = r13 + r10 
  
  ;;; INT ;;;
  ; calculate int
  add r14, r11

  ;;; SIGN ;;;
  mov r15, r14; overflow + 15
  shr r15, 15; overflow

  xor rax, rbx

  ; add all
  shl rax, 15
  xor rax, r14; add int
  shl rax, 8
  xor rax, r13; add float

  ; clear to 24 bits
  shl rax, 40
  shr rax, 40

  ret

_neg_to_pos_a:
  cmp rsi, 0
  jne _transform_a
  ret

_transform_a:
  xor eax, 0xFFFFFF00
  ret

_neg_to_pos_b:
  cmp rdi, 0
  jne _transform_b
  ret

_transform_b:
  xor ebx, 0xFFFFFF00
  ret

_multiply:
;;; PREPARE ;;;
  shl rax, 40 ;clean rax to 24 bits
  mov rsi, rax; copy value
  shr rsi, 63 ; get sing of a
  shr rax, 32 ;clean rax to 32 bits AAAA.BB00
  call _neg_to_pos_a
  ; r14 = b 8 bits + 00
  mov r14, rax
  shl r14, 48 ; clean r14 to 16 bits
  shr r14, 48 ; clean r14 to 16 bits
  ; r15 = a 16 bits
  shr rax, 16; 0xAAAABB -> 0xAAAA
  mov r15, rax

  ; r12 = d 8 bits + 00
  shl rbx, 40 ;clean rbx to 24 bits
  mov rdi, rbx; copy value
  shr rdi, 63; get sign of b
  shr rbx, 32 ;clean rbx to 32 bits
  
  call _neg_to_pos_b

  mov r12, rbx
  shl r12, 48 ; clean r12 to 16 bits
  shr r12, 48 ; clean r12 to 16 bits
  ; r13b = c 16 bits
  shr rbx, 16; 0xCCCCDD00 -> 0xCCCC
  mov r13, rbx

;;; DO ;;;
  ; r11w high
  mov r11d, r15d
  imul r11d, r13d ; a * c
  shl r11d, 16 ; << 16

  ; r10w mid
  mov r10d, r14d
  imul r10d, r13d; b * c
  mov eax, r10d
  mov r10d, r15d
  imul r10d, r12d ; a * d
  add r10d, eax; a * d + b * c 

  ; r9w low
  mov r9d, r14d
  imul r9d, r12d; b * d
  shr r9d, 16; >> 16

  ; high << 8 + mid + low >> 8
  mov eax, 0
  add eax, r11d
  add eax, r9d
  add eax, r10d

  ; transform to negative if needed
  xor rsi, rdi
  call _neg_to_pos_a
  ; clear to 24 bits
  shl rax, 32
  shr rax, 40
  ret

;;; debug ;;;
_break_on_k:
  mov r8, [k]
  mov rbp, [counter]
  cmp r8, rbp
  je _break
  ret

_break_0:
  mov r8, 0
  mov rbp, [counter]
  cmp r8, rbp
  je _break
  ret

_break:
  ret
  ; ;; END ;;;
_end:
  exit
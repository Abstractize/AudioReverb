%include "linux64.inc"

; DATA ;
section .data
  filename: db "song.wav", 0
  new_filename: db "newsong.wav", 0
  bytes_to_read: dq 105054
  newline: dq 10
  ;;; CIRCULAR BUFFER ;;;
  buffer: times 50 dq 0 ; Uses K
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

  ;;; CIRCULAR BUFFER ;;;
  array_value resw 1
  ;;; Fixed Point Conversion ;;;
  fractional_bits resb 1
section .text
  global _start

_start:
  call _create_file
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
; Initialize Buffer
  call _initialize_circular_buffer
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
  call _apply_effect
  jmp _end

_create_file:
  ret

_initialize_circular_buffer:
  ; r15 as counter
  mov r15, 0
  call _initialize_circular_buffer_if
  ret

_initialize_circular_buffer_if:  
  cmp [k], r15
  jg _fill_buffer_part
  ret
; I know it's not necesary but i need it as an example on how to use arrays
_fill_buffer_part:
  ; assign value
  mov rax, 0
  mov r14, r15
  imul r14, 2
  mov [buffer + r14], rax
  mov rax, [buffer + r14]
  mov [array_value], rax
  ; increments
  add r15, 1
  jmp _initialize_circular_buffer_if

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
  jl _reverb_loop
  ret

_reverb_loop:
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

  ;print data_read_value; check if is comming in groups of 2
  ;print newline
; APPLY REVERB

; Effect
  ; rax = x(n)
  mov rax, [data_read_value]; Int is 16 Bits
  call _convert_int_fixed; WAV Has Samples as Ints, convert to 24 bits Fixed
  call _reverb ; returns converted value in rax
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

  jmp _reverb_if

_reverb:
  ; rax = x(n)
  
  mov r14, rax ; r14 = x(n)
  
  ;mov rax, [alpha]; rax = alpha
  ;xor rax, 0xFFFF00; rax = -alpha
  ;mov rbx, rax; = rav = -alpha
  ;mov rax, 0x100; mov 1.00 -> dec 1.0
  ;call _add; rax = 1-alpha
  ;mov rbx, r14; rbx = x(n)
  ;call _multiply; rax = rax * rbx = (1-alpha) x(n)
  ;mov r14, rax; = r14 = (1-alpha) x(n)
  call _get_circular_buffer; rax = y(n-k)
  shl rax, 40
  shr rax, 40 ; adjusts to 24 bits

  ;mov rbx, rax; rbx = rax = y(n-k)
  ;mov rax, [alpha]; rax = alpha
  ;call _multiply; rax = alpha * y(n-k)
  mov rbx, rax ; rbx = alpha * y(n-k)
  mov rax, r14 ; rax = x(1-alpha) x(n)

  call _add; rax = rax + rbx = x(n) + y(n-k)

  call _store_circular_buffer; stores in circular buffer
  ret

_deapply_reverb:
  mov rax, 0
  cmp [reverb], rax
  je _dereverb_if
  ret

_dereverb_if:
  ret

;;; CIRCULAR BUFFER ;;;
_store_circular_buffer:
  mov r9, rax
  mov rdi, [counter]
  mov rsi, [k]
  ; rdi % rsi
  mov rax, rdi
  cdq
  idiv rsi; rdx = rdi % rsi
  mov rax, rdx; rax <- %
  imul rax, 4; * 4 because of q
  mov [buffer + rax], r9
  mov rax, r9
  ret

_get_circular_buffer:
  mov rdi, [counter]
  mov rsi, [k]
  ; rdi % rsi
  mov rax, rdi
  cdq
  idiv rsi
  mov rax, rdx
  imul rax, 4; * 4 because of q
  mov rax, [buffer + rax]
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

  call _break_on_k

  ;;; DECIMAL ;;;
  ; calculate decimal 8 bit
  add r13, r10 ; r13 = r13 + r10 
  
  call _break_on_k

  ;;; INT ;;;
  ; calculate int
  add r14, r11

  call _break_on_k

  ;;; SIGN ;;;
  mov r15, r14; overflow + 15
  shr r15, 15; overflow

  xor rax, rbx
  xor rax, r15

  ; add all
  shl rax, 15
  xor rax, r14; add int
  shl rax, 8
  xor rax, r13; add float

  call _break_on_k

  ; clear to 24 bits
  shl rax, 40
  shr rax, 40

  ret

_add_a_neg_b_pos:
  ; a = r14
  ; b = r10
  mov r15, r14; r15 = neg = r14
  xor r15, 0x7FFF; |neg| = r15

  ; get sign
  cmp r15, r10; compare whos bigger
  jg _add_a_neg_gt_b_pos; a > b
  jl _add_a_neg_lw_b_pos; a < b
  call _add_a_eq_b; a = b

  ; add values
  xor r14, r10

  shl rax, 15; mov sign to 16 bit
  xor rax, r14; add int part

  ret

_add_a_pos_b_neg:
  ; a = r14
  ; b = r10
  mov r15, r10; r15 = neg = r10
  xor r15, 0x7FFF; |neg| = r15
  
  ; get sign
  cmp r14, r15; compare whos bigger
  cmp r15, r10; compare whos bigger
  jg _add_a_pos_gt_b_neg; a > b
  jl _add_a_pos_lw_b_neg; a < b
  call _add_a_eq_b; a = b

  ; add values
  xor r14, r10
  
  shl rax, 15; mov sign to 16 bit
  xor rax, r14; and int part
  
  ret

_add_equal:
  xor r14, r11; a + b
  shl rax, 15
  xor rax, r14
  ret

_add_a_neg_gt_b_pos:
  mov rax, 1
  ret

_add_a_neg_lw_b_pos:
  mov rax, 0
  ret

_add_a_pos_gt_b_neg:
  mov rax, 0
  ret

_add_a_pos_lw_b_neg:
  mov rax, 1
  ret

_add_a_eq_b:
  mov rax, 0
  ret

_multiply:
;;; PREPARE ;;;
  ; r14 = b 8 bits
  shl rax, 8 ;clean rax to 24 bits
  shr rax, 8 ;clean rax to 24 bits
  mov r14, rax
  shl r14, 24 ; clean r14 to 8 bits
  shr r14, 24 ; clean r14 to 8 bits
  ; r15 = a 16 bits
  shr rax, 8; 0xAAAABB -> 0xAAAA
  mov r15, rax
  ; r12 = d 8 bits 
  shl rbx, 8 ;clean rbx to 24 bits
  shr rbx, 8 ;clean rbx to 24 bits
  mov r12, rbx
  shl r12, 24 ; clean r12 to 8 bits
  shr r12, 24 ; clean r12 to 8 bits
  ; r13b = c 16 bits
  shr rbx, 8; 0xCCCCDD -> 0xCCCC
  mov r13, rbx
;;; DO ;;;
  ; r11w high
  mov r11, r15
  imul r11, r13 ; a * c
  shl r11, 8 ; << 8
  ; r10w mid
  mov r10, r14
  imul r10, r13; b * c
  mov rax, r10
  mov r10, r15
  imul r10, r12 ; a * d
  add r10, rax; a * d + b * c 
  ; r9w low
  mov r9, r14
  imul r9, r12; b * d
  shr r9, 8; >> 8
  ; high << 8 + mid + low >> 8
  mov rax, 0
  add rax, r11
  add rax, r9
  add rax, r10
  ; clear to 24 bits
  shl rax, 40
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
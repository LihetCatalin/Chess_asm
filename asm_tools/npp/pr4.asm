.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
a dw 2027
b dw 10
rez dw ?
.code
start:
	;aici se scrie codul
	mov ax, a
	shr ax, 1
	jc formula_2           ;prin shiftare, bitul 0 ajunge in CF, daca e 1 numarul este impar
	;aceeasi metoda pt b, dar aplicata de 3 ori, daca unul din bitii 2-0 este 1, elementul nu este divizibil cu 8
	mov ax, b
	shr ax, 1
	jc formula_2
	shr ax, 1
	jc formula_2
	shr ax, 1
	jc formula_2
	;daca ajungem in partea asta de cod, atunci a este par si b divizibil cu 8
	mov eax, 0
	mov edx, 0      ;resetam eax, edx
	mov ax, a
	mul ax  ;a*a
	mov ebx, 3
	div bx  ;(a*a)/3
	
	mov bx, b
	shl bx, 2    ;;b*4
	
	add ax, bx     ;;(a*a)/3 + b*4
	mov rez, ax
	jmp final
	
	formula_2:
	mov eax, 0
	mov edx, 0
	mov ax, a
	shr ax, 2   ;;a/4
	
	mov bx, b
	shl bx, 4   ;;b*16
	
	mov rez, ax
	add rez, bx    ;;a/4+b*16
	
	mov ax, a
	mul b
	
	sub rez, ax          ;;a/4+b*16-a*b
		
	final:
	
	
	
	;terminarea programului
	push 0
	call exit
end start

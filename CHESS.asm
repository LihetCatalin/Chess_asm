.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
format DB "%d %d", 10, 0
window_title DB "CHESS",0
area_width EQU 400
area_height EQU 400
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20

xx dd 0
yy dd 0

xpoz dd 0
ypoz dd 0

x_piesa dd 0
y_piesa dd 0

player_turn dd 0

square equ 40

p_piese DB 8, 10, 9, 11, 12, 9, 10, 8
		DB 7, 7, 7, 7, 7, 7, 7, 7
		DB 0, 0, 0, 0, 0, 0, 0, 0
		DB 0, 0, 0, 0, 0, 0, 0, 0
		DB 0, 0, 0, 0, 0, 0, 0, 0
		DB 0, 0, 0, 0, 0, 0, 0, 0
		DB 1, 1, 1, 1, 1, 1, 1, 1
		DB 2, 4, 3, 5, 6, 3, 4, 2
			
		

include digits.inc
include letters.inc
include picture.inc
include colors.inc
include BlackPieces.inc


.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_black_pieces proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	shl eax, 2
	lea esi, BlackPieces

draw_bpiece:
	mov ebx, square
	mul ebx
	mov ebx, square
	mul ebx
	add esi, eax
	mov ecx, square
bucla_bpiece_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, square
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, square
bucla_bpiece_coloane:
	push eax
	mov eax, [esi]
	cmp eax, 0EEEEEEh
	jg next_black
	mov dword ptr [edi], eax
	next_black:
	pop eax
	
	add esi, 4
	add edi, 4
	loop bucla_bpiece_coloane
	pop ecx
	loop bucla_bpiece_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_black_pieces endp

make_bpiece_macro macro piece, drawArea, x, y
	push y
	push x
	push drawArea
	push piece
	call make_black_pieces
	add esp, 16
endm

make_white_pieces proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	shl eax, 2
	lea esi, BlackPieces

draw_wpiece:
	mov ebx, square
	mul ebx
	mov ebx, square
	mul ebx
	add esi, eax
	mov ecx, square
bucla_wpiece_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, square
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, square
bucla_wpiece_coloane:
	push eax
	mov eax, [esi]
	cmp eax, 0EEEEEEh
	jg next_white
	mov dword ptr [edi], 0FAFAFAh 
	next_white:
	pop eax
	
	add esi, 4
	add edi, 4
	loop bucla_wpiece_coloane
	pop ecx
	loop bucla_wpiece_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_white_pieces endp

make_wpiece_macro macro piece, drawArea, x, y
	push y
	push x
	push drawArea
	push piece
	call make_white_pieces
	add esp, 16
endm

color proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat 
	shl eax, 2
	lea esi, colors
	
draw_color:
	mov ebx, square
	mul ebx
	mov ebx, square
	mul ebx
	add esi, eax
	mov ecx, square
bucla_color_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, square
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, square
bucla_color_coloane:
	push eax
	mov eax, [esi]
	mov dword ptr [edi], eax
	pop eax
	
	add esi, 4
	add edi, 4
	loop bucla_color_coloane
	pop ecx
	loop bucla_color_linii
	popa
	mov esp, ebp
	pop ebp
	ret
color endp

make_color_macro macro color_number, drawArea, x, y
	push y
	push x
	push drawArea
	push color_number
	call color
	add esp, 16
endm

create_board macro n
local linie, coloana, inchis, deschis
pusha
xor esi, esi

linie:

xor edi, edi

coloana:
;;creez tabla de dimensiune 8x8
;calculez coordonatele
xor ecx, ecx
mov eax, edi
mov ecx, square
mul ecx
mov ebx, eax
mov eax, esi
mul ecx

xor ecx, ecx
add ecx, esi
add ecx, edi
shr ecx, 1
jc deschis
make_color_macro 0, area, eax, ebx
jmp inchis

deschis:
make_color_macro 1, area, eax, ebx

inchis:

inc edi
cmp edi, n
jle coloana

inc esi
cmp esi, n
jle linie
popa
endm

populate_board macro m
;black pawns
make_bpiece_macro 0, area, 0, 240
make_bpiece_macro 0, area, 40, 240
make_bpiece_macro 0, area, 80, 240
make_bpiece_macro 0, area, 120, 240
make_bpiece_macro 0, area, 160, 240
make_bpiece_macro 0, area, 200, 240
make_bpiece_macro 0, area, 240, 240
make_bpiece_macro 0, area, 280, 240

;black rooks
make_bpiece_macro 1, area, 0, 280
make_bpiece_macro 1, area, 280, 280

;black knights
make_bpiece_macro 3, area, 40, 280
make_bpiece_macro 3, area, 240, 280

;black bishops
make_bpiece_macro 2, area, 80, 280
make_bpiece_macro 2, area, 200, 280

;black queen(4) and king(5)
make_bpiece_macro 4, area, 120, 280
make_bpiece_macro 5, area, 160, 280

;white pawns
make_wpiece_macro 0, area, 0, 40
make_wpiece_macro 0, area, 40, 40
make_wpiece_macro 0, area, 80, 40
make_wpiece_macro 0, area, 120, 40
make_wpiece_macro 0, area, 160, 40
make_wpiece_macro 0, area, 200, 40
make_wpiece_macro 0, area, 240, 40
make_wpiece_macro 0, area, 280, 40

;white rooks
make_wpiece_macro 1, area, 0, 0
make_wpiece_macro 1, area, 280, 0

;white knights
make_wpiece_macro 3, area, 40, 0
make_wpiece_macro 3, area, 240, 0

;white bishops
make_wpiece_macro 2, area, 80, 0
make_wpiece_macro 2, area, 200, 0

;white queen(4) and king(5)
make_wpiece_macro 4, area, 120, 0
make_wpiece_macro 5, area, 160, 0
endm

letters_digits macro
make_text_macro 'A' ,area, 15, 320
make_text_macro 'B' ,area, 55, 320
make_text_macro 'C' ,area, 95, 320
make_text_macro 'D' ,area, 135, 320
make_text_macro 'E' ,area, 175, 320
make_text_macro 'F' ,area, 215, 320
make_text_macro 'G' ,area, 255, 320
make_text_macro 'H' ,area, 295, 320

make_text_macro '8', area, 330, 10
make_text_macro '7', area, 330, 50
make_text_macro '6', area, 330, 90
make_text_macro '5', area, 330, 130
make_text_macro '4', area, 330, 170
make_text_macro '3', area, 330, 210
make_text_macro '2', area, 330, 250
make_text_macro '1', area, 330, 290
endm

print macro a, b
	push b
	push a
	push offset format
	call printf
	add esp, 12
endm

calculeaza_coordonate macro a, b
	mov ebx, square
	xor edx, edx
	mov eax, esi
	mul ebx
	mov a, eax
	
	xor edx, edx
	mov eax, edi
	mul ebx
	mov b, eax
	xor edx, edx
endm

calculeaza_coordonate_invers macro a, b
	mov ebx, square
	
	xor edx, edx
	mov eax, edi
	div ebx
	mov b, eax
	
	xor edx, edx
	mov eax, esi
	div ebx
	mov a, eax
	xor edx, edx
endm

clear_color macro n
	create_board n
	xor esi, esi
	clear_color_line:
	xor edi, edi
	clear_color_column:
	
	calculeaza_coordonate xx, yy
	
	cmp p_piese[edi*8+esi], 0
	je end_clear
	
	put_black_pawn:
	cmp p_piese[edi*8+esi], 1   ;;black pawn
	jne put_black_rook
	make_bpiece_macro 0, area, xx, yy
	jmp end_clear
	
	put_black_rook:
	cmp p_piese[edi*8+esi], 2	;;black rook
	jne put_black_bishop
	make_bpiece_macro 1, area, xx, yy
	jmp end_clear
	
	put_black_bishop:
	cmp p_piese[edi*8+esi], 3   ;;black bishop
	jne put_black_knight
	make_bpiece_macro 2, area, xx, yy
	jmp end_clear
	
	put_black_knight:
	cmp p_piese[edi*8+esi], 4   ;;black knight
	jne put_black_queen
	make_bpiece_macro 3, area, xx, yy
	jmp end_clear
	
	put_black_queen:
	cmp p_piese[edi*8+esi], 5    ;;black queen
	jne put_black_king
	make_bpiece_macro 4, area, xx, yy
	jmp end_clear
	
	put_black_king:
	cmp p_piese[edi*8+esi], 6     ;;black king
	jne put_white_pawn
	make_bpiece_macro 5, area, xx, yy
	jmp end_clear
	
	put_white_pawn:
	cmp p_piese[edi*8+esi], 7 	;;white pawn
	jne put_white_rook
	make_wpiece_macro 0, area, xx, yy
	jmp end_clear
	
	put_white_rook:
	cmp p_piese[edi*8+esi], 8      ;;white rook
	jne put_white_bishop
	make_wpiece_macro 1, area, xx, yy
	jmp end_clear
	
	put_white_bishop:
	cmp p_piese[edi*8+esi], 9      ;;white bishop
	jne put_white_knight
	make_wpiece_macro 2, area, xx, yy
	jmp end_clear
	
	put_white_knight:
	cmp p_piese[edi*8+esi], 10     ;;white knight
	jne put_white_queen
	make_wpiece_macro 3, area, xx, yy
	jmp end_clear
	
	put_white_queen:
	cmp p_piese[edi*8+esi], 11      ;;white queen
	jne put_white_king
	make_wpiece_macro 4, area, xx, yy
	jmp end_clear
	
	put_white_king: 	;;white king
	cmp p_piese[edi*8+esi], 12     ;;white queen
	jne end_clear
	make_wpiece_macro 5, area, xx, yy
	
	end_clear:
	
	inc edi
	cmp edi, n
	jbe clear_color_column
	inc esi
	cmp esi, n
	jbe clear_color_line
endm

clear_blue macro n
	local false, clear_blue_line, clear_blue_column
	xor esi, esi
	clear_blue_line:
	xor edi, edi
	clear_blue_column:
	
	cmp p_piese[edi*8+esi], 25
	jne false
	mov p_piese[edi*8+esi], 0
	false:
	
	inc edi
	cmp edi, n
	jbe clear_blue_column
	inc esi
	cmp esi, n
	jbe clear_blue_line

endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

players_turn macro n
local player_2, end_turns
cmp player_turn, 0
jne player_2
make_text_macro 'A', area, 30, 340
make_text_macro 'L', area, 40, 340
make_text_macro 'B', area, 50, 340
make_text_macro ' ', area, 60, 340
make_text_macro 'T', area, 70, 340
make_text_macro 'R', area, 80, 340
make_text_macro 'E', area, 90, 340
make_text_macro 'B', area, 100, 340
make_text_macro 'U', area, 110, 340
make_text_macro 'I', area, 120, 340
make_text_macro 'E', area, 130, 340
make_text_macro ' ', area, 140, 340
make_text_macro 'S', area, 150, 340
make_text_macro 'A', area, 160, 340
make_text_macro ' ', area, 170, 340
make_text_macro 'M', area, 180, 340
make_text_macro 'U', area, 190, 340
make_text_macro 'T', area, 200, 340
make_text_macro 'E', area, 210, 340
make_text_macro ' ', area, 220, 340
make_text_macro ' ', area, 230, 340
jmp end_turns

player_2:
make_text_macro 'N', area, 30, 340
make_text_macro 'E', area, 40, 340
make_text_macro 'G', area, 50, 340
make_text_macro 'R', area, 60, 340
make_text_macro 'U', area, 70, 340
make_text_macro ' ', area, 80, 340
make_text_macro 'T', area, 90, 340
make_text_macro 'R', area, 100, 340
make_text_macro 'E', area, 110, 340
make_text_macro 'B', area, 120, 340
make_text_macro 'U', area, 130, 340
make_text_macro 'I', area, 140, 340
make_text_macro 'E', area, 150, 340
make_text_macro ' ', area, 160, 340
make_text_macro 'S', area, 170, 340
make_text_macro 'A', area, 180, 340
make_text_macro ' ', area, 190, 340
make_text_macro 'M', area, 200, 340
make_text_macro 'U', area, 210, 340
make_text_macro 'T', area, 220, 340
make_text_macro 'E', area, 230, 340

end_turns:
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
black_pawn_possible_moves macro x, y
	local prima_linie, end_pawn
	pusha
	mov esi, x
	mov edi, y
    cmp edi, 240
	je prima_linie 
	;;alta linie
	cmp edi, 0
	je end_pawn
	sub edi, 40
	calculeaza_coordonate_invers xpoz, ypoz
	mov eax, xpoz
	mov ebx, ypoz
	cmp p_piese[ebx*8+eax], 0
	jne end_pawn
	mov p_piese[ebx*8+eax], 25
	make_color_macro 2, area, esi, edi
	jmp end_pawn
	
	;;prima linie
	prima_linie:
	sub edi, 40
	calculeaza_coordonate_invers xpoz, ypoz
	mov eax, xpoz
	mov ebx, ypoz
	cmp p_piese[ebx*8+eax], 0
	jne end_pawn
	mov p_piese[ebx*8+eax], 25
	make_color_macro 2, area, esi, edi
	sub edi, 40
	calculeaza_coordonate_invers xpoz, ypoz
	mov eax, xpoz
	mov ebx, ypoz	
	cmp p_piese[ebx*8+eax], 0
	jne end_pawn
	mov p_piese[ebx*8+eax], 25
	make_color_macro 2, area, esi, edi
	end_pawn:
	popa
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
white_pawn_possible_moves macro x, y
	local prima_linie_white, end_white_pawn
	pusha
	mov esi, x
	mov edi, y
    cmp edi, 40
	je prima_linie_white 
	;;alta linie
	cmp edi, 280
	je end_white_pawn
	add edi, 40
	calculeaza_coordonate_invers xpoz, ypoz
	mov eax, xpoz
	mov ebx, ypoz
	cmp p_piese[ebx*8+eax], 0
	jne end_white_pawn
	mov p_piese[ebx*8+eax], 25
	make_color_macro 2, area, esi, edi
	jmp end_white_pawn
	
	;;prima linie
	prima_linie_white:
	add edi, 40
	calculeaza_coordonate_invers xpoz, ypoz
	mov eax, xpoz
	mov ebx, ypoz
	cmp p_piese[ebx*8+eax], 0
	jne end_white_pawn
	mov p_piese[ebx*8+eax], 25
	make_color_macro 2, area, esi, edi
	add edi, 40
	calculeaza_coordonate_invers xpoz, ypoz
	mov eax, xpoz
	mov ebx, ypoz	
	cmp p_piese[ebx*8+eax], 0
	jne end_white_pawn
	mov p_piese[ebx*8+eax], 25
	make_color_macro 2, area, esi, edi
	
	end_white_pawn:

	popa
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rook_possible_moves macro x, y
local rook_up, rook_down, rook_left, rook_right, rook_move_end, next_rook_down, next_rook_left, next_rook_right
pusha

mov esi, x
mov edi, y
rook_up:
cmp edi, 0
je next_rook_down
sub edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_rook_down
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
cmp edi, 0
jae rook_up

next_rook_down:

mov esi, x
mov edi, y
rook_down:

cmp edi, 280
je next_rook_left
add edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_rook_left
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
cmp edi, 280
jbe rook_down

next_rook_left:

mov esi, x
mov edi, y
rook_left:

cmp esi, 0
je next_rook_right
sub esi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_rook_right
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
cmp esi, 0
jae rook_left

next_rook_right:

mov esi, x
mov edi, y
rook_right:
cmp esi, 280
je rook_move_end
add esi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne rook_move_end
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
cmp esi, 280
jbe rook_right

rook_move_end:
popa

endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bishop_possible_moves macro x, y
local bishop_up_left, bishop_up_right, bishop_down_left, bishop_down_right, next_bishop_down_left, next_bishop_down_right 
local next_bishop_up_right, bishop_move_end
pusha

mov esi, x
mov edi, y
bishop_up_left:
cmp edi, 0
je next_bishop_up_right
cmp esi, 0
je next_bishop_up_right
sub edi, 40
sub esi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_bishop_up_right
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
cmp edi, 0
jae bishop_up_left
cmp esi, 0
jae bishop_up_left

next_bishop_up_right:

mov esi, x
mov edi, y
bishop_up_right:

cmp edi, 0
je next_bishop_down_left
cmp esi, 280
je next_bishop_down_left
sub edi, 40
add esi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_bishop_down_left
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
cmp edi, 0
jae bishop_up_right
cmp esi, 280
jbe bishop_up_right

next_bishop_down_left:

mov esi, x
mov edi, y
bishop_down_left:

cmp esi, 0
je next_bishop_down_right
cmp edi, 280
je next_bishop_down_right
sub esi, 40
add edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_bishop_down_right
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
cmp esi, 0
jae bishop_down_left
cmp edi, 280
jbe bishop_down_left

next_bishop_down_right:

mov esi, x
mov edi, y
bishop_down_right:
cmp esi, 280
je bishop_move_end
cmp edi, 280
je bishop_move_end
add esi, 40
add edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne bishop_move_end
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
cmp esi, 280
jbe bishop_down_right
cmp edi, 280
jbe bishop_down_right

bishop_move_end:

popa
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
knight_possible_moves macro x, y
local position1, position2, position3, position4, position5, position6, position7, position8, knight_move_end
pusha

mov esi, x
mov edi, y
position1:
cmp esi, 280
je position2
cmp edi, 40
jbe position2
add esi, 40
sub edi, 80
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne position2
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

position2:
mov esi, x
mov edi, y
cmp esi, 240
jae position3
cmp edi, 0
je position3
add esi, 80
sub edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne position3
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

position3:
mov esi, x
mov edi, y
cmp esi, 240
jae position4
cmp edi, 280
je position4
add esi, 80
add edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne position4
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

position4:
mov esi, x
mov edi, y
cmp esi, 280
je position5
cmp edi, 240
jae position5
add esi, 40
add edi, 80
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne position5
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi


position5:
mov esi, x
mov edi, y
cmp esi, 0
je position6
cmp edi, 240
jae position6
sub esi, 40
add edi, 80
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne position6
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

position6:
mov esi, x
mov edi, y
cmp esi, 40
jbe position7
cmp edi, 280
je position7
sub esi, 80
add edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne position7
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

position7:
mov esi, x
mov edi, y
cmp esi, 40
jbe position8
cmp edi, 0
je position8
sub esi, 80
sub edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne position8
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

position8:
mov esi, x
mov edi, y
cmp esi, 0
je knight_move_end
cmp edi, 40
jbe knight_move_end
sub esi, 40
sub edi, 80
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne knight_move_end
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi


knight_move_end:

popa
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
queen_possible_moves macro x, y
local queen_up, next_queen_right_up, queen_right_up, next_queen_right, queen_right, next_queen_right_down, queen_right_down, queen_end_move
local next_queen_down, queen_down, next_queen_left_down, queen_left_down, next_queen_left, queen_left, next_queen_left_up, queen_left_up
pusha

mov esi, x
mov edi, y
queen_up:
cmp edi, 0
je next_queen_right_up
sub edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_queen_right_up
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
jmp queen_up

next_queen_right_up:
mov esi, x
mov edi, y
queen_right_up:
cmp esi, 280
je next_queen_right
cmp edi, 0
je next_queen_right
add esi, 40
sub edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_queen_right
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
jmp queen_right_up

next_queen_right:
mov esi, x
mov edi, y
queen_right:
cmp esi, 280
je next_queen_right_down
add esi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_queen_right_down
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
jmp queen_right

next_queen_right_down:
mov esi, x
mov edi, y
queen_right_down:
cmp esi, 280
je next_queen_down
cmp edi, 280
je next_queen_down
add esi, 40
add edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_queen_down
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
jmp queen_right_down


next_queen_down:
mov esi, x
mov edi, y
queen_down:
cmp edi, 280
je next_queen_left_down
add edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_queen_left_down
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
jmp queen_down

next_queen_left_down:
mov esi, x
mov edi, y
queen_left_down:
cmp esi, 0
je next_queen_left
cmp edi, 280
je next_queen_left
sub esi, 40
add edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_queen_left
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
jmp queen_left_down

next_queen_left:
mov esi, x
mov edi, y
queen_left:
cmp esi, 0
je next_queen_left_up
sub esi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne next_queen_left_up
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
jmp queen_left

next_queen_left_up:
mov esi, x
mov edi, y
queen_left_up:
cmp esi, 0
je queen_end_move
cmp edi, 0
je queen_end_move
sub esi, 40
sub edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne queen_end_move
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi
jmp queen_left_up

queen_end_move:

popa
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
king_possible_moves macro x, y
local king_position1, king_position2, king_position3, king_position4, king_position5, king_position6, king_position7
local king_position8, king_end_move
pusha

mov esi, x
mov edi, y
king_position1:
cmp edi, 0
je king_position2
sub edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne king_position2
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

king_position2:
mov esi, x
mov edi, y
cmp edi, 0
je king_position3
cmp esi, 280
je king_position3
sub edi, 40
add esi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne king_position3
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

king_position3:
mov esi, x
mov edi, y
cmp esi, 280
je king_position4
add esi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne king_position4
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

king_position4:
mov esi, x
mov edi, y
cmp edi, 280
je king_position5
cmp esi, 280
je king_position5
add esi, 40
add edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne king_position5
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

king_position5:
mov esi, x
mov edi, y
cmp edi, 280
je king_position6
add edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne king_position6
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

king_position6:
mov esi, x
mov edi, y
cmp edi, 280
je king_position7
cmp esi, 0
je king_position7
add edi, 40
sub esi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne king_position7
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

king_position7:
mov esi, x
mov edi, y
cmp esi, 0
je king_position8
sub esi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne king_position8
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

king_position8:
mov esi, x
mov edi, y
cmp edi, 0
je king_end_move
cmp esi, 0
je king_end_move
sub esi, 40
sub edi, 40
calculeaza_coordonate_invers xpoz, ypoz
mov eax, xpoz
mov ebx, ypoz
cmp p_piese[ebx*8+eax], 0
jne king_end_move
mov p_piese[ebx*8+eax], 25
make_color_macro 2, area, esi, edi

king_end_move:

popa
endm

make_move proc
	push ebp
	mov ebp, esp
	pusha

	mov esi, [ebp+arg1]
	mov edi, [ebp+arg2]
	calculeaza_coordonate_invers xx, yy
	mov esi, xx
	mov edi, yy
	;print esi, edi
	
	move_black_pawn:
	cmp p_piese[edi*8+esi], 1   ;;black pawn
	jne move_black_rook
	make_bpiece_macro 0, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 1
	jmp end_move
	
	move_black_rook:
	cmp p_piese[edi*8+esi], 2	;;black rook
	jne move_black_bishop
	make_bpiece_macro 1, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 2
	jmp end_move
	
	move_black_bishop:
	cmp p_piese[edi*8+esi], 3   ;;black bishop
	jne move_black_knight
	make_bpiece_macro 2, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 3
	jmp end_move
	
	move_black_knight:
	cmp p_piese[edi*8+esi], 4   ;;black knight
	jne move_black_queen
	make_bpiece_macro 3, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 4
	jmp end_move
	
	move_black_queen:
	cmp p_piese[edi*8+esi], 5    ;;black queen
	jne move_black_king
	make_bpiece_macro 4, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 5
	jmp end_move
	
	move_black_king:
	cmp p_piese[edi*8+esi], 6     ;;black king
	jne move_white_pawn
	make_bpiece_macro 5, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 6
	jmp end_move
	
	move_white_pawn:
	cmp p_piese[edi*8+esi], 7 	;;white pawn
	jne move_white_rook
	make_wpiece_macro 0, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 7
	jmp end_move
	
	move_white_rook:
	cmp p_piese[edi*8+esi], 8      ;;white rook
	jne move_white_bishop
	make_wpiece_macro 1, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 8
	jmp end_move
	
	move_white_bishop:
	cmp p_piese[edi*8+esi], 9      ;;white bishop
	jne move_white_knight
	make_wpiece_macro 2, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 9
	jmp end_move
	
	move_white_knight:
	cmp p_piese[edi*8+esi], 10     ;;white knight
	jne move_white_queen
	make_wpiece_macro 3, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 10
	jmp end_move
	
	move_white_queen:
	cmp p_piese[edi*8+esi], 11      ;;white queen
	jne move_white_king
	make_wpiece_macro 4, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 11
	jmp end_move
	
	move_white_king: 	
	cmp p_piese[edi*8+esi], 12     ;;white king
	jne end_move
	make_wpiece_macro 5, area, xpoz, ypoz
	mov p_piese[edi*8+esi], 0
	mov esi, xpoz
	mov edi, ypoz
	calculeaza_coordonate_invers xpoz, ypoz
	mov esi, xpoz
	mov edi, ypoz
	mov p_piese[edi*8+esi], 12
	
	end_move:
	clear_blue 7
	clear_color 7
	
	
	popa
	mov esp, ebp
	pop ebp
	ret
make_move endp
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	;;generam tabla initiala
	create_board 7
	populate_board 7
	letters_digits
	players_turn 7
	jmp afisare_litere
	
evt_click:
	clear_color 7
	players_turn 7
	
	xor edx, edx
	mov ebx, square
	mov eax, [ebp+arg2]
	cmp eax, 320
	ja outside
	div ebx
	mov esi, eax        ;;am aflat coloana pe care se afla piesa
	
	xor edx, edx
	mov eax, [ebp+arg3]
	cmp eax, 320
	ja outside
	div ebx
	mov edi, eax     	;;am aflat linia pe care se afla piesa
	
	cmp p_piese[edi*8+esi], 25
	jne empty_space
	not player_turn
	;print player_turn, player_turn
	calculeaza_coordonate xpoz, ypoz
	push y_piesa
	push x_piesa
	call make_move
	add esp, 8
	players_turn 7
	jmp afisare_litere
	
	
	empty_space:
	cmp p_piese[edi*8+esi], 0
	jne turns
	clear_blue 7
	jmp afisare_litere
	
	turns:
	cmp player_turn, 0
	je white_turn
	
	black_pawn:
	cmp p_piese[edi*8+esi], 1   ;;black pawn
	jne black_rook
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	black_pawn_possible_moves xx, yy
	jmp afisare_litere
	
	black_rook:
	cmp p_piese[edi*8+esi], 2    ;;black rook
	jne black_bishop
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	rook_possible_moves xx, yy
	jmp afisare_litere
	
	black_bishop:
	cmp p_piese[edi*8+esi], 3    ;;black bishop
	jne black_knight
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	bishop_possible_moves xx, yy
	jmp afisare_litere
	
	black_knight:
	cmp p_piese[edi*8+esi], 4   ;;black knight
	jne black_queen
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	knight_possible_moves xx, yy
	jmp afisare_litere	
	
	black_queen:
	cmp p_piese[edi*8+esi], 5   ;;black queen
	jne black_king
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	queen_possible_moves xx, yy
	jmp afisare_litere
	
	black_king:
	cmp p_piese[edi*8+esi], 6   ;;black king
	jne afisare_litere
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	king_possible_moves xx, yy
	jmp afisare_litere
	
	
	white_turn:
	
	
	white_pawn:
	cmp p_piese[edi*8+esi], 7   ;;white pawn
	jne white_rook
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	white_pawn_possible_moves xx, yy
	jmp afisare_litere
	
	white_rook:
	cmp p_piese[edi*8+esi], 8   ;;white rook
	jne white_bishop
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	rook_possible_moves xx, yy
	jmp afisare_litere
	
	white_bishop:
	cmp p_piese[edi*8+esi], 9   ;;white bishop
	jne white_knight
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	bishop_possible_moves xx, yy
	jmp afisare_litere
	
	white_knight:
	cmp p_piese[edi*8+esi], 10   ;;white knight
	jne white_queen
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	knight_possible_moves xx, yy
	jmp afisare_litere
	
	white_queen:
	cmp p_piese[edi*8+esi], 11   ;;white queen
	jne white_king
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	queen_possible_moves xx, yy
	jmp afisare_litere
	
	white_king:
	cmp p_piese[edi*8+esi], 12   ;;white king
	jne afisare_litere
	calculeaza_coordonate xx, yy
	mov eax, xx
	mov ebx, yy
	mov x_piesa, eax
	mov y_piesa, ebx
	clear_blue 7
	king_possible_moves xx, yy
	jmp afisare_litere
	
	outside:
	clear_blue 7
evt_timer:
	inc counter
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 390, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 380, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 370, 10
	

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start

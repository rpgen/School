.model	small
.486

.stack 100h

.data
	seed dd 12345678h
	
.code
longrand proc far C	
	mov   eax, 214013
	mul  seed
	xor   edx, edx
	add   eax, 2531011
	mov   seed, eax		; save the seed for the next call
	shld  edx ,eax, 16	; copy upper 16 bits of EAX to DX
	ret
longrand endp


initialize proc
	push ax
	push bx
	mov ax, 0200h	; green font on black
	mov bx, 0
i0:		
	;call longrand	;toggle for initial blank screen
	mov ah, 02
	mov al, bl
	mov es:[bx], ax
	
	inc bx
	inc bx
	cmp bx, 3996;4000
	jl i0
	
	pop bx
	pop ax
	ret
initialize endp


shiftup proc
	push ax
	push bx
	mov bx, 0
s0:	mov ax, es:[bx+160]
	mov es:[bx], ax
	inc bx
	inc bx
	
	cmp bx, 3840	;up to line 24
	jl s0
	pop bx
	pop ax
	call newline
	ret
shiftup endp


newline proc
	push ax
	push bx
	push cx
	push dx
	
	mov bx, 3840
	mov cx, 4
	
n0:	call longrand
	cmp dl, 50h 	;random threshold
	mov ah, 02
	jg n1
	mov ax, 0
n1:	mov es:[bx], ax	
	inc bx
	inc bx
	cmp bx, 4000
	jl n0

	pop dx
	pop cx
	pop bx
	pop ax
	ret
newline endp


inter proc
	call shiftup	
	;mov cx, 0
	iret
inter endp	


main	proc
	mov ax, @data
	mov ds, ax	
	mov ax, 0b800h
	mov es, ax

installhandler:
	cli	
	push ds
	mov ax, @code
	mov ds, ax
	mov ah, 25h
	mov al, 9
	mov dx, offset inter
	int 21h
	pop ds
	sti
		
	call initialize

	;change cx to the amount of times you want it to run
	;mov cx, 0FFFh;	
L0:	;mov eax, 0007FFFFh	
L1:	;dec eax
	;cmp eax, 1
	;jg L1
	;call shiftup
	;loop L0
	
	mov	ax,4c00h
	int	21h					; Call DOS interrupt 21h
main	endp
	
end	main

IDEAL
MODEL small
STACK 100h
DATASEG
ARR1 DB 50 DUP (?)
ARR2 DB 50 DUP (?)
counter1 DW 0
counter2 DW 0
counter3 DB 0
filename1 DB 'NORMAL1.bmp', 0
filename2 DB 'YELLOW1.bmp', 0
filename3 DB 'RED1.bmp', 0
filename4 DB 'GREEN1.bmp', 0
filename5 DB 'BLUE1.bmp', 0
filehandle DW ?
Header DB 54 dup (0)
Palette DB 256*4 dup (0)
ScrLine DB 320 dup (0)
ErrorMsg DB 'Error', 13, 10 ,'$'

CODESEG

proc Waitgametick
    push ax
    push cx
    push dx
    mov ah, 2ch
    mov cx, 1 ; amount of ticks
delay_loop:
    push cx
    int 21h
    mov dh, bh
tick_loop:
    int 21h
    cmp dh, bh
    je tick_loop
    pop cx
    loop delay_loop
    pop dx
    pop cx
    pop ax
    ret
endp Waitgametick


proc OpenFile
; Open file
	mov ah, 3Dh
	xor al, al
	int 21h
	jc openerror
	mov [filehandle], ax
	ret
openerror :
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	ret
endp OpenFile

proc ReadHeader
	; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp ReadHeader

proc ReadPalette
	; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette
proc CopyPal
	; Copy the colors palette to the video memory
	; The number of the first color should be sent to port 3C8h
	; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
	; Copy starting color to port 3C8h
	out dx,al
	; Copy palette itself to port 3C9h
	inc dx
PalLoop:
	; Note: Colors in a BMP file are saved as BGR values rather than RGB.
	mov al,[si+2] ; Get red value .
	shr al,2 ; Max. is 255, but video palette maximal
	; value is 63. Therefore dividing by 4.
	out dx,al ; Send it .
	mov al,[si+1] ; Get green value .
	shr al,2
	out dx,al ; Send it .
	mov al,[si] ; Get blue value .
	shr al,2
	out dx,al ; Send it .
	add si,4 ; Point to next color .
	; (There is a null chr. after every color.)
	loop PalLoop
	ret
endp CopyPal
	
proc CopyBitmap
	; BMP graphics are saved upside-down .
	; Read the graphic line by line (200 lines in VGA format),
	; displaying the lines from bottom to top.
	mov ax, 0A000h
	mov es, ax
	mov cx,200
PrintBMPLoop :
	push cx
	; di = cx*320, point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	; Read one line
	mov ah,3fh
	mov cx,320
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,320
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	 ;rep movsb is same as the following code :
	 ;mov es:di, ds:si
	 ;inc si
	 ;inc di
	 ;dec cx
	 ;loop until cx=0
	pop cx
	loop PrintBMPLoop
	ret
endp CopyBitmap


start:
	mov ax, @data
	mov ds, ax


; first step
basicIMAGE:
	mov dx, offset filename1
	; Graphic mode
	mov ax, 13h
	int 10h
	; Process BMP file
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
	; Wait for key press
	mov ah,1
	int 21h
	; Back to text mode
	call Waitgametick
	call Waitgametick
	call Waitgametick
	jmp randomNUM
	
	
; fourth step
BLUEimage:
	mov dx, offset filename5
	; Graphic mode
	mov ax, 13h
	int 10h
	; Process BMP file
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
	; Wait for key press
	mov ah,1
	int 21h
	
; fourth step
GREENimage:
	mov dx, offset filename4
	; Graphic mode
	mov ax, 13h
	int 10h
	; Process BMP file
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
	; Wait for key press
	mov ah,1
	int 21h

; fourth step	
REDimage:
	mov dx, offset filename3
	; Graphic mode
	mov ax, 13h
	int 10h
	; Process BMP file
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
	; Wait for key press
	mov ah,1
	int 21h

Bluestep:
	jmp BLUEimage

Greenstep:
	jmp GREENimage

Redstep:
	jmp REDimage



; fourth step	
YELLOWimage:
	mov dx, offset filename2
	; Graphic mode
	mov ax, 13h
	int 10h
	; Process BMP file
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
	; Wait for key press
	mov ah,1
	int 21h
	
	
; second step	
randomNUM:
	; random number between 0-3, returns at the last bits 00, 01, 10, 11 and add it to ARR1
	
	xor ax, ax
	xor bx, bx
	mov ax, 40h
	mov es, ax
	mov ax, [es:6Ch]      ; reads from the clock
	and al, 00000011b   ; saves the value in al
	add al, 1
	mov bx, [counter1]
	mov [ARR1 + bx], al
	inc [counter1]
	mov cx, [word ptr counter1]
	xor bx, bx
	mov dx, cx             ; dx n cx contain the value of counter1
	mov bx, offset ARR1    ; bx is the first index in ARR1
	jmp picNUM

; third step 	
picNUM:
	add bx, dx
	sub bx, cx
	cmp [word ptr bx], 4
	je Bluestep    ; if the random number is 4 then the blue pic opens
	cmp [word ptr bx], 3
	je Greenstep    ; "                     " 3 then the green pic opens
	cmp [word ptr bx], 2        
	je Redstep      ; "                     " 2 then the red pic opens
	cmp [word ptr bx], 1
	je YELLOWimage   ; "                     " 1 then the yellow pic opens
	
loop picNUM
	
randomstep:
	jmp randomNUM
	
; fifth step ,,,,,,,,,,,,, need to add xor ax,ax before input
input:		
	xor ax, ax
	mov ah, 1   ; takes input + saves the value in al
	int 21h
	cmp al, "t"
	je ifT
	cmp al, "y"
	je ifY
	cmp al, "g"
	je ifG
	cmp al, "h" 
	je ifH
	
ifT:
	mov al, 3
	jmp AD      ; adds to ARR2
	;jmp print
ifY:
	mov al, 1
	jmp AD      ; adds to ARR2
	;jmp print
ifG:
	mov al, 4
	jmp AD      ; adds to ARR2
	;jmp print
ifH:
	mov al, 2
	jmp AD      ; adds to ARR2
	;jmp print
	
										;print:	
										;	add al, '0'
										;	mov dl, al 
										;	mov ah, 2
										;	int 21h
	
AD:
	xor bx, bx
	mov bx, [counter2]
	mov [ARR2 + bx], al
	inc [counter2]
	mov cx, 51
	mov dx, cx
	xor bx, bx
	jmp ARRcmp

; sixth step 
ARRcmp: ; compare every index in the ARRs
	xor ax, ax
	mov bx, offset ARR1
	add bx, dx
	sub bx, cx
	mov ax, [bx]
	mov bx, offset ARR2
	Add bx, dx
	sub bx, cx
	cmp ax, [bx]
	jne exit
	je randomstep
	



resetARR2:
	;mov cx, 51
	;mov dx, cx
	mov bx, offset ARR2
	add bx, dx
	sub bx, cx
	mov [word ptr bx], 0
	
	
	
	
	
exit :
	mov ax, 4c00h
	int 21h
END start	
	
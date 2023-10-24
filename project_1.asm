COMMENT !
--------------------------------------------------
	Description:
	This assembly program calculates 
	the following expression after adding
	array elements to data labels 
	(num1, num2, num3, and num4): 
	total =  (num3 + num4) - (num1 + num2) + 1.

	Ahmad Gazali
	Section 05
	Project 01
	9-17-2023
--------------------------------------------------
!

.386 ; 32-bit processor
.model flat,stdcall ; Protected mode and Standard call convention
.stack 4096 ; 4096-byte sized stack

ExitProcess PROTO, dwExitCode:DWORD ; Windows exit process

.DATA
arr SWORD 1000h, 2000h, 3000h, 4000h
sizeOfElement EQU TYPE arr ; Used to increment the array pointer
num1 SWORD 1d 
num2 SWORD 2d
num3 SWORD 4d
num4 SWORD 8d
total SWORD ?

.CODE
main	PROC
	MOV esi, offset arr ; Get the address of the array
	XOR eax, eax ; Clear the eax register

	; STEP 1
	; Add each array element value to each data
	; label and store the sum in the data label.
	;--------------------------------------------------
	MOV ax, num1 ; Move first operand to the AX register because it is 16-bit
	ADD ax, [esi] ; Add the second operand from the array to num1 in AX
	MOV num1, ax ; Replace num1 with the new value in AX
	MOV ebx, offset num1 ; Set ebx to num1's offset and view the new change in memory while debugging
	XOR eax, eax ; Clear eax once again
	ADD esi, sizeOfElement ; Increment the pointer to the next array element.

	MOV ax, num2
	ADD ax, [esi]
	MOV num2, ax
	MOV ebx, offset num2
	XOR eax, eax
	ADD esi, sizeOfElement

	MOV ax, num3
	ADD ax, [esi]
	MOV num3, ax
	MOV ebx, offset num3
	XOR eax, eax
	ADD esi, sizeOfElement

	MOV ax, num4
	ADD ax, [esi]
	MOV num4, ax
	MOV ebx, offset num4
	XOR eax, eax
	
	; STEP 2
	; Perform (num3 + num4) - (num1 + num2) + 1
	; operations in order of precedence.
	;--------------------------------------------------
	XOR ebx, ebx ; Clear the EBX register for use
	MOV ax, num3
	ADD ax, num4 ; num3 + num4
	MOV bx, ax ; Set the number aside
	XOR eax, eax ; Clear EAX for use again

	MOV ax, num1
	ADD ax, num2 ; num1 + num2
	SUB bx, ax ; (num3 + num4) - (num1 + num2)
	INC bx ; (num3 + num4) - (num1 + num2) + 1
	MOV total, bx ; Move total from bx to total variable

	INVOKE ExitProcess,0
main	ENDP
end		main

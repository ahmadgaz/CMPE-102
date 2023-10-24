;--------------------------------------------------
;	Description:
;	This assembly program reads an integer which 
;	is an index of one array and copies elements 
;	of that array to another array.
;
;	Ahmad Gazali
;	Section 05
;	Project 02
;	10-23-2023
;--------------------------------------------------

.386
include Irvine32.inc
.stack 4096

ExitProcess PROTO, dwExitCode:DWORD

.data

; Project messages
projectTitle BYTE "--- ARRAY COPYINATOR! ---", 13, 10, 13, 10,13, 10,
"               /`-~\                      	  ", 13, 10,
"           ___/_____\___                       	  ", 13, 10,
"         _.-^~~^^^`~-,_,,~''''''```~,''``~'``~,	  ", 13, 10,
" ______,'  -o  :.  _    .          ;     ,'`,  `. ", 13, 10,
"(      -\.._,.;;'._ ,(   }        _`_-_,,    `, `,", 13, 10,
" ``~~~~~~'   ((/'((((____/~~~~~~'(,(,___>      `~'", 13, 10, 13, 10,13, 10,0
terminationMessage BYTE "--- PROGRAM TERMINATED ---", 0
indexInputPrompt BYTE "Index (0 - 4) [default: 0]: ", 0
continuePrompt BYTE "Continue? (y/n): ", 0
invalidInputMessage BYTE "Invalid input. Try again.", 13, 10, 0
tooManyNumbersMessage BYTE "Too many numbers for the target array.", 13, 10, 0
hCrlf BYTE "h", 13, 10, 0

; User input
startIndex SBYTE -1
continueInput BYTE 2 DUP(0)

; Arrays
ALIGN 4 ; Aligns the arrays on a DWORD
arr1 DWORD 1, 2, 3, 4, 5
arr2 DWORD ($ - arr1)/TYPE DWORD DUP(0)

.code
main PROC
	pushad

	; Display the project title
	call displayTitle
	

	;--------------------------------------------------
	;--------------------------------------------------
	;				INDEX INPUT SECTION
	;--------------------------------------------------
	;--------------------------------------------------

	jmp ResetIndexInput ; Skip the invalid input message by default

	; Jump here when the index input is invalid to print the invalid input message
InvalidIndexInput:
	mov edx, offset invalidInputMessage
	call WriteString ; Writes the string at edx to the console

	; Jump here when skipping the invalid input message
ResetIndexInput:

	; Prints the user prompt to input an index into the console
	mov edx, offset indexInputPrompt
	call WriteString

	; Reads the user input integer from the keyboard
	call ReadInt ; Reads the index input into eax, AN EMPTY INPUT DEFAULTS TO 0
	mov startIndex, al

	; If (startIndex < 0 || startIndex > 4) Retry input
	cmp startIndex, 0
	jl InvalidIndexInput
	cmp startIndex, 4
	jg InvalidIndexInput

	;--------------------------------------------------
	; Calls the copyArray procedure which copy's arr1 to arr2 
	; and then uses showArray to display the new array
	;--------------------------------------------------
	mov esi, offset arr2 ; Target array
	mov edi, offset arr1 ; Source array
	movzx eax, startIndex ; Move the startIndex to eax zero extended
	mov ebx, lengthof arr2 ; The number of elements in arr2
	mov ecx, lengthof arr1 ; The number of elements in arr1
	call copyArray


	;--------------------------------------------------
	;--------------------------------------------------
	;			"CONTINUE?" INPUT SECTION
	;--------------------------------------------------
	;--------------------------------------------------

	jmp ResetContinueInput ; Skip the invalid input message by default

	; Jump here when the "continue?" input is invalid to print the invalid input message
InvalidContinueInput:
	mov edx, offset invalidInputMessage
	call WriteString

	; Jump here when skipping the invalid input message
ResetContinueInput:

	; Prints the user prompt whether they want to continue the program or not
	mov edx, offset continuePrompt
	call WriteString

	; Reads the user input for whether to continue or not from the keyboard
	mov edx, offset continueInput ; Used by ReadString to read from the console into continueInput
	mov ecx, sizeof continueInput ; Used by ReadString
	call ReadString

	; If (continueInput == "y") Continue program
	cmp continueInput, 121 ; "y" == 121
	je ResetIndexInput

	; Else if (continueInput != "n") Retry input
	cmp continueInput, 110 ; "n" == 110
	jne InvalidContinueInput

	; Print the program termination message
	call endProgram

	popad
	INVOKE ExitProcess, 0
main ENDP

;--------------------------------------------------
;	Procedure:
;	displayTitle
;
;	Description:
;	Displays the projects name on the console
;	using the Irvine32 WriteString procedure
;
;	Recieves:	None
;	Returns:	None
;--------------------------------------------------
displayTitle PROC
	push edx ; This procedure uses edx, so we push it's current value onto the stack and pop it off at the end of the proc
	mov edx, offset projectTitle
	call WriteString ; Writes the string at edx to the console
	pop edx
	ret
displayTitle ENDP

;--------------------------------------------------
;	Procedure:
;	copyArray
;
;	Description:
;	Copys a source array to a target array then 
;	prints the results to the console
;
;	Recieves:	ESI = the target array offset
;				EDI = the source array offset
;				EAX = the index to start copying 
;				the source array onto target from
;				EBX = number of elements in the 
;				target array
;				ECX = number of elements in the 
;				source array
;	Returns:	None
;--------------------------------------------------
copyArray PROC
	; Push EDX onto the stack for use to write messages to the console
	push edx

	; Push the procedure arguments onto the stack, then pop them off at the end of the proc
	push esi
	push edi
	push eax
	push ebx
	push ecx

	;--------------------------------------------------
	;--------------------------------------------------
	;	Here is an example of the operations that take 
	;	place in this procedure using pseudocode where
	;	target array is {0,0,0,0,0} and source array is {1,2,3,4,5,6}:
	;	
	;	temp = ?
	;	target = 00000000h
	;	source = 00008000h
	;	index = 2
	;	target_length = 5
	;	source_length = 6
	;	
	;	source_length -= 2	// => 4 
	;	// 5 >= 4 so we can continue 
	;	
	;	temp = 4
	;	index *= temp	// => 8
	;	source += index	// => 00008008h
	;	
	;	temp = target	// => 00000000h
	;	
	;	target = source	// => 00008008h
	;	showArray(target, source_length)	// (00008008h, 4)
	;	
	;	target_length -= source_length	// => 1
	;	target = temp	// => 00000000h
	;	temp = 4
	;	source_length *= temp	// => 16
	;	target += source_length	// => 00000010h
	;
	;	source_length = target_length	// => 1
	;	showArray(target, source_length)	// (00000010h, 1)
	;	
	;	OUTPUT:
	;	00000003h
	;	00000004h
	;	00000005h
	;	00000006h
	;	00000000h
	;--------------------------------------------------
	;--------------------------------------------------

	; Subtract the index of source array from the number of elements in the source array to get AMOUNT OF NUMBERS we need to copy onto the target array
	sub ecx, eax

	; After the operation above, if (EBX < ECX) Print too many numbers message and end the procedure
	cmp ebx, ecx
	jl TooManyNumbers

	; At this point we don't need EDX for the "too many numbers" message, we can use it for other operations
	; Get the offset of the source array index we want into EDI
	mov edx, TYPE DWORD
	imul eax, edx
	add edi, eax

	; Temporarily move target array offset to EDX
	mov edx, esi
	
	; Print the numbers we need from the source array given that ESI is pointing to the right index and ECX contains the size of the sub array
	mov esi, edi
	call showArray

	; Subtract the amount of numbers that have been printed to the console from the target array size
	sub ebx, ecx

	; Get the offset of the target array index where the remaining target array values begin
	mov esi, edx
	mov edx, TYPE DWORD
	imul ecx, edx
	add esi, ecx

	; Print remaining numbers (if any) in the target array
	mov ecx, ebx
	call showArray	

	jmp EndProcedure ; Skip the too many numbers message by default

	; Jump here if there are too many numbers to copy onto the target array
TooManyNumbers:
	mov edx, offset tooManyNumbersMessage
	call WriteString ; Write the string at offset at edx to the console

EndProcedure:
	pop ecx
	pop ebx
	pop eax
	pop edi
	pop esi
	pop edx
	ret
copyArray ENDP

;--------------------------------------------------
;	Procedure:
;	showArray
;
;	Description:
;	Displays the array that you pass into it on
;	the console
;
;	Recieves:	ESI = the array offset
;				ECX = number of elements in the 
;				array
;	Returns:	None
;--------------------------------------------------
showArray PROC
	push edx
	push eax
	push esi
	push ecx
	mov edx, offset hCrlf ; Used by WriteString to add an "h\n" to each hex number

	cmp ecx, 0 ; If the loop value is 0, skip to the end
	je SKIP

	; Print each value to the console using this loop
L1:
	mov eax, DWORD PTR [esi] ; Redundant, but wasn't sure where else to place the PTR keyword
	call WriteHex
	call WriteString
	add esi, TYPE DWORD
	loop L1

SKIP:
	pop ecx
	pop esi
	pop eax
	pop edx
	ret
showArray ENDP

;--------------------------------------------------
;	Procedure:
;	endProgram
;
;	Description:
;	Displays the termination message on the
;	console using the Irvine32 WriteString 
;	procedure
;
;	Recieves:	None
;	Returns:	None
;--------------------------------------------------
endProgram PROC
	push edx ; This procedure uses edx, so we push it's current value onto the stack and pop it off at the end of the proc
	mov edx, offset terminationMessage
	call WriteString ; Write the string at offset at edx to the console
	pop edx
	ret
endProgram ENDP
END main

TITLE Program Composite Numbers   (composite.asm)

; Author: Helen Jiang
; Last Modified: 11/4/18
; Course number/section: CS271-400
; Project Number: 4                 Due Date: 11/4/18
; Description: Program calculate composite numbers. 
;				Prompts user to enter a number a range between [1...400]
;				Program then calculates and displays all composites up to nth composite
;				Results are displayed 10 composite per line with a tab between each number
;				Program is modularized into different procedures

INCLUDE Irvine32.inc
UPPER_LIMIT = 400
LOWER_LIMIT = 1


.data
programTitle		BYTE    "Composite Numbers          Programmed by Helen Jiang", 0dh, 0ah, 0		; program title
intro1				BYTE	"Enter the number of composite numbers you would like to see. Enter between [1...400].", 0dh, 0ah, 0	;intro of what program does
EC1					BYTE	"EC1: align the output columns.", 0								; extra credit to align output columns by a tab space
prompt1				BYTE	"Enter the number of composites to display [1...400]: ",0		; prompt to enter a number
errorMessage		BYTE	"Out of range. Try again. ",0dh, 0ah, 0
goodbye1			BYTE	"Results certified by Helen. Goodbye. ", 0dh, 0ah, 0
n					DWORD	?																; number entered by user to display nth composite number
currentNum			DWORD	?																; the current composite number to be tested and shown; currentNum will increment until totalNum = n 
compositeN			DWORD	?																; the composite number to be displayed 
goodData			DWORD	?																; data is set to 1 if n is within range or 0 if not within range
lineNum				DWORD	0																;	keeps track of the numbers to make sure there are 10 numbers per line
isCompositeN		DWORD	?																; isCompositeN is set to 1 if n is composite or 0 if not composite
totalCompositeN		DWORD	0																; total number of composites displayed so far, totalComposite should equal n at end of program


.code
COMMENT !--------------------------------------------------------------
	main procedure calls all of the other procedures in the program 
-----------------------------------------------------------------------!
main PROC
	call	intro
	call	getUserData
	call	showComposites
	call	farewell

	
exit
main ENDP





COMMENT !----------------------------------------------------------------
	intro procedure displays the program title and
	program intro 
-------------------------------------------------------------------------!
intro PROC
	mov		edx, OFFSET programTitle				;displays program title
	call	WriteString
	mov		edx, OFFSET EC1							;displays extra credit 1
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET intro1						;displays program intro
	call	WriteString
	call	CrLf
	ret
intro ENDP


COMMENT !-----------------------------------------------------------------
	getUserData procedure prompts for user input 
	cals subprocdure to validate result
-------------------------------------------------------------------------!
getUserData PROC
RepeatGetData:
				mov		edx, OFFSET prompt1						; asks for input and stores n into eax
				call	WriteString
				call	ReadInt
				mov		n, eax
				call	dataValidation							; call dataValidation procedure to check if number is withint [1...400]
				cmp		goodData, 0
				je		RepeatGetData							; if number isn't within range, indicated by the bool goodData = 0, we repeat asking for data

				ret
getUserData ENDP


COMMENT !-----------------------------------------------------------------
	data validates that number is between [1...400]
	called by getUserData
-------------------------------------------------------------------------!
dataValidation PROC
				cmp		n, UPPER_LIMIT						; checks n against upper limit = 400 and if greater than 400, jump to setDataFalse
				jg		setDataFalse							
				cmp		n, LOWER_LIMIT						; checks n against lower limit = 1 and if less than 1, jump to setDataFalse
				jl		setDataFalse
				mov		goodData, 1							; if data is within range, set bool to 1
				jmp		endDataValidation
setDataFalse:
				mov		goodData, 0							;bad data: set bool to 0 and display error message
				mov		edx, OFFSET errorMessage
				call	WriteString
endDataValidation: 
				ret
dataValidation ENDP


COMMENT !-----------------------------------------------------------------
	shows each composite number up to n 
	do{
		call isComposite
		if(isCompositeN == 1)
			call print
		currentNum++
	}while(totalCompositeN < n)
-------------------------------------------------------------------------!
showComposites PROC
				mov		currentNum, 4					;starts at 4 because that's the smallest composite
checkComposite:
				mov		isCompositeN, 0					;mark false for each loop 
				call	isComposite						;call isComposite to check if currentNum is composite
				cmp		isCompositeN, 1					;if currentNum is composite, print currentNum
				je		callPrint
checkTotalComposite:
				inc		currentNum						; after printing, we increment currentNym
				mov		eax, totalCompositeN			;check if totalComposite numbers printed has exceeded n, 
				cmp		eax, n
				jl		checkComposite					;if not, we loop for next currentNum
				jmp		endShowComposites

callPrint:	
				call	print							;call print to print currentNum
				jmp		checkTotalComposite				;after printing, jump to check if total composites have all been printed
endShowComposites:
				call	CrLf
				ret
showComposites ENDP


COMMENT !-----------------------------------------------------------------
	determines if that nth number is composite 
	called by showComposites
	for(int i = 2; i < currentNum - 1; i++) {
		if(currentNum % i == 0) 
			isCompositeN = 1
			totalComposite++
		else
			isCompositeN = 0
	}
-------------------------------------------------------------------------!
isComposite PROC
		mov		eax, currentNum							;set ecx to currentNum - 2 beacuse we only need to check up to currentNum - 1 and i starts at 2
		sub		eax, 2
		mov		ecx, eax
		mov		eax, currentNum							;move currentNum into eax so div can perform eax/ebx
		mov		edx, 0									;set remainder to 0
		mov		ebx, 2									;set ebx to 2

forLoop:
		mov		eax, currentNum
		div		ebx										;div by ebx
		cmp		edx, 0									; if remainder is 0, we go to found and exits procedure
		je		found
		mov		edx, 0									; if not found, we set edx = 0 and repeats the forLoop
		inc		ebx
		loop	forLoop
		jmp		endIsComposite
found:
		mov		isCompositeN, 1							;set isCompositeN to found and exit
		inc		totalCompositeN
		ret
endIsComposite:
		mov		isCompositeN, 0							;set isCompositeN to not found and exit
		ret
isComposite ENDP


COMMENT !-----------------------------------------------------------------
	prints each composite number
	10 numbers per line
	1 tab space inbetween each number to align columns 
-------------------------------------------------------------------------!
print PROC
		inc		lineNum									;increment lineNum for each number printed
		mov		eax, currentNum
		call	writeDec 
		mov     al, 9									; ASCII CHAR 9 =  TAB
        call    WriteChar								;writes tab to align text
		cmp		lineNum, 10								;tests to see greater than 10 numbers have been printed
		jge		newLine									;jump to newLine if 10 numbers have been printed already
		jmp		endPrint

newLine:
		call	crLf									;move cursor to new line
		mov		lineNum, 0								;reset lineNum = 0 
		jmp		endPrint
endPrint:

		ret
print ENDP


COMMENT !-----------------------------------------------------------------
	Displays farewell message
-------------------------------------------------------------------------!
farewell PROC
	mov		edx, OFFSET goodbye1						;goodbye message
	call	WriteString
	ret
farewell ENDP


END main

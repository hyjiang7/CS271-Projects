TITLE Low-level I/O (prog6a.asm)
; Author: Helen Jiang
; Last Modified: 12/1/18
; Course number/section: CS271-400
; Project Number: 6                 Due Date: 12/2/18
; Description: Program asks for 10 user integers that will be read as a string
;				and interpreted into a integers. 
;				The program will return the the sum and the average of these numbers

INCLUDE Irvine32.inc
MAXSIZE = 100
MAXNUM = 10

COMMENT !----------------------------------------------------------------
	getString MACRO displays the prompt and get user's input into a memory location
	receives: prompt, instring
	returns: none
	registers changed: eax
-------------------------------------------------------------------------!
getString	MACRO	prompt, inString
	push	edx				;Save edx register
	push	ecx
	mov		edx, prompt
	call	WriteString
	mov		edx, inString
	mov		ecx, MAXSIZE
	call	readString
	pop		ecx
	pop		edx					;Restore edx
ENDM

COMMENT !----------------------------------------------------------------
	displayString MACRO displays the parameter
	receives: outstring
	returns: none
	registers changed: none
-------------------------------------------------------------------------!
displayString	MACRO	outString
	push	edx
	mov		edx, outString
	call	WriteString
	call	CrLf
	pop		edx
ENDM

.data
programTitle					BYTE	"Assignment 6a: Designing low-level I/O procedures by Helen Jiang",0dh, 0ah,0
intro1							BYTE	"Provide 10 unsigned decimal integers. "
								BYTE	"Each number needs to be small enough to fit inside a 32-bit register. "
								BYTE	"After you have finished inputting the raw numbers, I will display the integers, their sum and average value." ,0dh, 0ah,0
prompt1							BYTE	"Please enter an unsigned number: ",0dh, 0ah,0
errorMessage					BYTE	"ERROR: You did not enter an unsigned number or number was too big" ,0dh, 0ah,0
numbers							DWORD	MAXNUM DUP(?)
sum								DWORD	?
average							DWORD	?
inString						BYTE	MAXSIZE DUP(?)
outString						BYTE	MAXSIZE DUP(?)
title1							BYTE	"You entered the following numbers: ", 0
title2							BYTE	"The sum of these numbers is: ", 0
title3							BYTE	"The average is: ",0
goodbye1						BYTE	"Thanks for playing!",0dh, 0ah,0

.code
main PROC

	;display intro
	push	OFFSET programTitle
	push	OFFSET intro1
	call	intro

	;read vals from user
	push	OFFSET errorMessage
	push	OFFSET prompt1
	push	OFFSET inString
	push	OFFSET numbers
	call	readVal
	
	;calculate sum and average
	push	OFFSET numbers
	push	OFFSET sum
	push	OFFSET average
	call	calculate

	;print the array of numbers
	push	OFFSET outString
	push	OFFSET inString
	push	OFFSET title1
	push	OFFSET numbers
	call	printNumbers

	;print the sum
	push	OFFSET outString
	push	OFFSET inString
	push	OFFSET title2
	push	OFFSET sum
	call	printVal

	;print the average
	push	OFFSET outString
	push	OFFSET inString
	push	OFFSET title3
	push	OFFSET average
	call	printVal

	;display goodbye message
	push	OFFSET goodbye1
	call	farewell

	exit
main ENDP


COMMENT !----------------------------------------------------------------
	intro procedure displays the program title and
	program intro 
	receives: programTitle[ebp+40], intro1[ebp+36]
	returns: none
	registers changed: none
-------------------------------------------------------------------------!
intro PROC
			pushad
			mov		ebp, esp
			mov		edx, [ebp + 40]														;display programTitle
			call	WriteString
			mov		edx, [ebp +36]														;display intro1
			call	WriteString
			call	CrLf
			popad
			ret 8
intro ENDP


COMMENT !-----------------------------------------------------------------
	getData procedure prompts for user input 
	receives: errorMessage[ebp+48], prompt1 [ebp+44], inString [ebp+40], numbers [ebp+36]
	returns:  numbers
	registers changed: none
	formula to calculate number: x= 10x +(al-48)
-------------------------------------------------------------------------!
readVal PROC
			pushad
			mov			ebp, esp
			mov			edx, 1
			mov			edi, [ebp+36]
			
newNumber:
			getString	[ebp+44], [ebp+40]						; pass prompt and inString
			mov			ecx, eax
			mov			esi, [ebp + 40]							; move esi to point to beginning of inString				
			mov			ebx, 0									; x = 0; 
			cld
counter:
			lodsb												; load bit from inString into AL
			cmp			al, 48									; make sure al is not less than 0
			jb			error
			cmp			al, 57									; make sure al is not greater than 9
			ja			error
			sub			al, 48									; perform (al-48)
			
			push		edx										; save edx, eax registers before multiplication
			push		eax
			mov			edx, 0
			mov			eax, 10									; perform 10x
			mul			ebx
			mov			ebx, eax								; move eax back into ebx (x), which is x in this case
			add			edx, 0									; if edx is not 0, there is overflow and jmp to error
			jnz			mulError
			pop			eax										; return eax, edx values to registers
			pop			edx
			
			add			ebx, eax								; we are adding 10x to (al-48) to get number (x)
			jc			error									; if there is carry in adding, jmp to error
			mov			[edi], ebx								; save first number in number[y], where y is the nth number user has inputted
			loop		counter									; loop back to counter to load next char byte
			add			edi, 4									; increment edi to number[y+1]

			inc			edx										; edx used as outer loop counter
			cmp			edx, MAXNUM								; if edx is less then 10, keep getting new number
			jle			newNumber
			jmp			endReadVal								; end outer loop by jumping to end

mulError:
			pop			eax										; since there was mul overflow, we still need to pop eax and edx before displaying error message to keep stack clean
			pop			edx
error:	
			push		edx										; save edx before displaying error message
			mov			edx, [ebp+48]							; display error message
			call		WriteString
			pop			edx										; pop edx val back into edx
			jmp			newNumber								; jmp to newNumber to prompt user for another number


endReadVal:
			popad
			ret		16
readVal ENDP

COMMENT !-----------------------------------------------------------------
	calculate procedure calculates the sum and average
	receives: numbers[ebp + 44], sum [ebp+40], average[ebp + 36]
	returns:  sum, average
	registers changed: none
-------------------------------------------------------------------------!
calculate PROC
	pushad
	mov		ebp, esp
	mov		ecx, MAXNUM									; have loop run 10 times
	mov		esi, [ebp + 44]								; move numbers[0] into esi
	mov		edi, [ebp + 40]								; move address of sum into edi
	mov		ebx, 0

getSum:
	mov		eax, [esi]									; move each number into eax
	add		ebx, eax									; sum is accumulator
	add		esi, 4										; get next element in numbers
	loop	getSum										; keep adding until ecx is 0
	mov		[edi], ebx									; save ebx into sum


	mov		edx, 0										; clear out edx for multiplication
	mov		eax, [edi]									; move sum into eax					
	mov		ebx, MAXNUM									; move 10 into ebx
	div		ebx											; sum/10 = average; average saved in eax
	mov		edi, [ebp + 36]								; move address of average into edi
	mov		[edi], eax									; save eax into average

	popad
	ret		12
calculate ENDP





COMMENT !-----------------------------------------------------------------
	writeVal procedure convert value passed in into string and call displayString to write to screen
	receives: value[ebp+36], inString[ebp+44], outString[ebp+40]
	returns:  none
	registers changed: none
	We convert the value into string by converting backwards. 
	So, if 251 were to be converted, the inString will store 152 
	We have to reverse the string into outString before we can display value
-------------------------------------------------------------------------!
writeVal PROC
			pushad
			mov		ebp, esp
			mov		eax, [ebp+36]								; let eax store the val to be printed
			mov		edi, [ebp+44]								; move inString into edi
			mov		ecx, 0										; keeps track of the number of digits in the value
			cld


moreNum: 
			inc		ecx
			mov		edx, 0
			mov		ebx, 10
			div		ebx
			add		edx, 48										; add 48 to remainder to get ASCII char value
			mov		ebx, eax									; save eax quotient into ebx 
			mov		eax, edx									; save char into eax
			stosb												; load al char in eax into inString in edi
			mov		eax, ebx									; put val of quotient back into eax
			add		eax, 0										; if the quotient is 0, then there are no more digits to be converted
			jnz		moreNum		

			stosb												; 0 is added to last place inString



;we now reverse whatever is in inString by starting at end of string
			mov		esi, [ebp+44]
			add		esi, ecx									; we start at the back of string when we add ecx to esi
			dec		esi											; dec esi to start before null character
			mov		ebx, [ebp+40]								; move outstring into edi
			std
reverse:
			lodsb												; char loaded into al
			mov		[ebx], eax                                  ; load al into outsting
			inc		ebx
			loop	reverse										; we reverse until no more digits left

			mov		eax, 0
			mov		[ebx], eax									; add the null to outString
			
			displayString [ebp + 40]							; call display string to display value as string



	popad
	ret		12
writeVal ENDP




COMMENT !-----------------------------------------------------------------
	printNumbers procedure calls writeVal to convert numbers to string 
	receives: title[ebp+40], numbers[ebp+36], inString[ebp + 44], outString[ebp+48]
	returns:  none
	registers changed: none
-------------------------------------------------------------------------!
printNumbers PROC
		pushad
		mov				ebp, esp
		displayString	[ebp+40]
	
		; go through array and call writeVal for each number in array
		mov			ecx, MAXNUM
		mov			esi, [ebp +36]

moreVal:
		push		[ebp+44]					; push inString
		push		[ebp+48]					; push outString
		push		[esi]						; push value in array element 
		call		writeVal					; call writeVal
		add			esi, 4						; increment esi to next array element
		loop		moreVal						; keep going until ecx reaches 0

		call		CrLf
		popad
		ret		16
printNumbers ENDP


COMMENT !-----------------------------------------------------------------
	printVal procedure calls writeVal to convert val to string 
	receives: title[ebp+40], value[ebp+36], inString[ebp + 44], outString[ebp+48]
	returns:  none
	registers changed: none
-------------------------------------------------------------------------!
printVal PROC
			pushad
			mov				ebp, esp
			displayString	[ebp+40]

			mov			esi, [ebp + 36]				; put address of vlaue into esi
			push		[ebp+44]					; push inString
			push		[ebp+48]					; push outString
			push		[esi]						; push value in array element 
			call		writeVal					; call writeVal


			popad
			ret 16
printVal ENDP



COMMENT !-----------------------------------------------------------------
	Displays farewell message
	Receives: goodbye1
	returns: none
	registers changed: none
-------------------------------------------------------------------------!
farewell PROC
			pushad
			mov		edx, [esp + 36]						;displays goodbye1
			call	WriteString
			popad
			ret		4
farewell ENDP

END main
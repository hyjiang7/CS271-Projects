TITLE Program Sorting Random Integers (sorting.asm)

; Author: Helen Jiang
; Last Modified: 11/12/18
; Course number/section: CS271-400
; Project Number: 4                 Due Date: 11/18/18
; Description: Program generates random numbers and sorts them in descending order.
;				Program asks user to enter the number of random numbers they want to be sorted...between [10...200]
;				Random numbers will be within the range [100...999]
;				Program displays the sorted list, 10 numbers per line

INCLUDE Irvine32.inc
MIN = 10
MAX = 200
LO = 100
HI = 999

.data
programTitle		BYTE    "Sorting Random Integers          Programmed by Helen Jiang", 0dh, 0ah, 0					; program title
intro1				BYTE	"This program generates random numbers in the range [100...999], "							;intro of what program does
					BYTE	"displays the original list, sorts the list and calculates the median value. "		
					BYTE	"Finally, it displays the list sorted in descending order. ", 0dh, 0ah, 0
prompt1				BYTE	"How many numbers should be generated [10...200]: ",0										; prompt to enter a number
errorMessage		BYTE	"Out of range. Try again. ",0dh, 0ah, 0														; message displayed if input out of range
goodbye1			BYTE	"Results certified by Helen. Goodbye. ", 0dh, 0ah,0													
unsortedTitle		BYTE	"The unsorted random numbers: ",0dh, 0ah,0													; title for unsorted
sortedTitle			BYTE	"The sorted list: ",0dh, 0ah,0																; title for sorted
medianTitle			BYTE	"The median is: ",0dh, 0ah,0																; title for median value
arrSize				DWORD	?																							; number of random numbers to be generated, (size of the list)
list				DWORD	500 DUP(?)																					; the array list of numbers to be sorted



.code
COMMENT !--------------------------------------------------------------
	main procedure calls all of the other procedures in the program 
	-procedure also passes all variables to the stack for reference passing
	-procedure also generates the seed
-----------------------------------------------------------------------!
main PROC
	call	Randomize

	push	OFFSET programTitle				
	push	OFFSET intro1
	call	intro							; displays intro

	push	OFFSET errorMessage
	push	OFFSET prompt1
	push	OFFSET arrSize
	call	getUserData						; gets user data

	push	OFFSET list
	push	arrSize
	call	fillArray						; fill array with random ints

	push	OFFSET list
	push	arrSize
	push	OFFSET unsortedTitle
	call	displayArray					; display array elements

	push	OFFSET list
	push	arrSize	
	call	sortList						; sorts list in descending order

	push	OFFSET list
	push	arrSize
	push	OFFSET sortedTitle
	call	displayArray					; display array elements

	push	OFFSET list
	push	arrSize
	push	OFFSET medianTitle
	call	displayMedian					; calculates and display median value


	push	OFFSET goodbye1
	call	farewell						; display goodbye message
	
	exit
main ENDP


COMMENT !----------------------------------------------------------------
	intro procedure displays the program title and
	program intro 
	receives: programTitle, intro1
	returns: none
	registers changed: edx
-------------------------------------------------------------------------!
intro PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp + 12]							;displays program title
	call	WriteString
	mov		edx, [ebp + 8]							;displays program intro
	call	WriteString
	call	CrLf
	pop		ebp
	ret		8
intro ENDP




COMMENT !-----------------------------------------------------------------
	getUserData procedure prompts for user input 
	checks if the size is within [10...200]
	receives: arrSize
	returns:  arrSize
	registers changed: edx, ebx, eax
-------------------------------------------------------------------------!
getUserData PROC
				push	ebp
				mov		ebp, esp
RepeatGetData:
				mov		edx, [ebp + 12]						; displays prompt1 to ask for size
				call	WriteString
				call	ReadInt
				mov		ebx, [ebp + 8]
				mov		[ebx], eax							; stores the value entered by user into arrSize
				cmp		eax, MIN
				jl		OutOfRange							; cmp arrSize to MIN and MAX, if out of range, display error message
				cmp		eax, MAX
				jg		OutOfRange
				jmp		EndGetUserData
				
OutOfRange:
				mov		edx, [ebp + 16]						; displays errorMessage and will bring user back to prompt 
				call	WriteString
				jmp		RepeatGetData

EndGetUserData:
				pop		ebp
				ret		12
getUserData ENDP



COMMENT !-----------------------------------------------------------------
	Fills array with random integers betweeen [100...999]
	Receives: list, arrSize
	returns: list filled with numbers
	registers changed: ecx, eax, esi
-------------------------------------------------------------------------!
fillArray PROC
			push	ebp
			mov		ebp, esp
			mov		esi, [ebp + 12]						; @list moved into esi; esi = list[0]
			mov		ecx, [ebp + 8]
getRandom:
			mov		eax, (HI - LO + 1)					; generates a number between 0-899
			call	RandomRange
			add		eax, 100							; add 100 to get a number between 100-999
			mov		[esi], eax
			add		esi, 4
			loop	getRandom

			pop		ebp
			ret		8
fillArray ENDP



COMMENT !-----------------------------------------------------------------
	Displays the contents in list array
	10 numbers per line 
	Receives: title, arrSize, list
	Returns: none
	registers changed: ecx, esi, eax, edx
-------------------------------------------------------------------------!
displayArray PROC
			push	ebp
			mov		ebp, esp
			mov		edx, [ebp + 8]				; displays the title of the list
			call	WriteString
			mov		esi, [ebp + 16]				; @list is moved into esi
			mov		ecx, [ebp + 12]				; arraySize is moved into ecx to act as loop counter
			mov		ebx, 0
print:
			mov		eax, [esi]					; list[esi] is moved into eax to print to screen
			call	WriteDec
			mov		eax, 0
			mov     al, 9						; ASCII CHAR 9 =  TAB
			call    WriteChar					; writes tab to align text
			add		esi, 4						; increment for each list element; 4 because DWORD
			inc		ebx							; use ebx to keep track the numbers printed on each line so far
			cmp		ebx, 10						; cmp ebx to 10, if greater than 10, we print the newLine 
			jge		newLine
backToLoop:
			loop	print						; loop for each element in the list
			jmp		endDisplayArray				; once printed all elements, end procedure

newLine:
			call	CrLf						; print newLine
			mov		ebx, 0						; reset ebx to 0
			jmp		backToLoop					; go back to printing loop

endDisplayArray:
			call	CrLf
			pop		ebp
			ret		12
displayArray ENDP





COMMENT !-----------------------------------------------------------------
	 Sorts list in descending order
	 calls subprocedure exchange
	 Sorts using the selection sort provided by prog5 instructions
	 for(k=0; k<request-1; k++) {
		i = k;
		for(j=k+1; j<request; j++) {
			if(array[j] > array[i])
				i = j;
		}
		exchange(array[k], array[i]);
	}
	 Receives: arrSize, list
	 Outputs: list with sorted numbers 
	 registers changed: esi, edx, ecx, ebx, eax, edi
-------------------------------------------------------------------------!
sortList PROC
				push	ebp
				mov		ebp, esp
				mov		esi, [ebp + 12]					; @list stored in esi
				mov		ecx, [ebp + 8]					; ecx stores array size
				dec		ecx								; outerloop goes to request - 1

outerLoop:
				push	ecx								; save the outer loop's ecx counter to stack
				mov		ecx, [ebp + 8]					; set new ecx counter for inner loop to set up inner loop

				mov		edi, esi						; esi is k and edi is i; i = k
				mov		eax, esi  						; use eax as j counter
				add		eax, 4							; j = k + 1
	
innerLoop:
				mov		ebx, [eax]
				cmp		ebx, [edi]						; cmp array[j] to array[i]
				jg		setGreatest						; if array[j] > array[i], go to setGreatest
backToInnerLoop:
				add		eax, 4							; j++
				loop	innerLoop
				jmp		endInnerLoop

setGreatest:
				mov		edi, eax						; i = j
				jmp		backToInnerLoop

endInnerLoop:
				push	esi								; push the addresses of the 2 vals to be exchanged onto stack
				push	edi
				call	exchange						; call subprocedure to exchange values

				pop		ecx								; pop outer loop's ecx counter from stack
				add		esi, 4							; k++
				loop	outerLoop


				pop		ebp
				ret		8
sortList ENDP


COMMENT !-----------------------------------------------------------------
	Swaps the two values 
	Receives: &val1, &val2
	Output: swapped val1 and val2 
	registers changed: none; all saved onto stack and popped off 
-------------------------------------------------------------------------!
exchange PROC
	pushad							; push all registers onto stack
	mov		ebp, esp
	mov		eax, [ebp + 36]			; have eax point to val1
	mov		ecx, [eax]				; store val1 of eax into ecx

	mov		ebx, [ebp + 40]			; have ebx point to val2
	mov		edx, [ebx]				; store val2 of ebx into edx

	mov		[eax], edx				; store val2 into value that eax was pointing to
	mov		[ebx], ecx				; store val1 into value that ebx was pointing to
	
	popad							; push all registers back from stack


	ret		8
exchange ENDP


COMMENT !-----------------------------------------------------------------
	Calculates the median of the array
	Receives: list, arrSize, title
	Returns: None
	registers changed: edx, edx, eax, ebx, ex
-------------------------------------------------------------------------!
displayMedian PROC
			push	ebp
			mov		ebp, esp
			mov		esi, [ebp + 16]					; esi stores @list

			mov		edx, [ebp + 8]					; edx stores the title for displayMedian
			call	WriteString


			mov		edx, 0							; clear out edx
			mov		eax, [ebp + 12]					; eax stores the number of elements in list (arrSize)
			mov		ebx, 2						
			div		ebx								; div arrSize/2 to check if the number of elements are even; the middle element number is stored in eax
			
			cmp		edx, 0							; if there are no remainders, then arrSize is even
			je		evenSize

			mov		ebx, 4
			mul		ebx								; eax is now in a multiple of 4 to correspond to DWORD
			add		esi, eax
			mov		eax, [esi]						; mov value of middle element of array into eax
			call	WriteDec
			call	CrLf
			jmp		endDisplayMedian
evenSize:
			mov		edx, 0
			mov		ebx, 4
			mul		ebx								; eax is now in a multiple of 4 to correspond to DWORD
			mov		ecx, [esi + eax]
			sub		eax, 4

			mov		eax, [esi + eax]
			add		eax, ecx						; add the two middle values together and div by 2

			mov		ebx, 2
			div		ebx

			cmp		edx, 1							; if there is a remainder, we round the number up 
			je		roundUp
			call	WriteDec						; if no remainder, just print value in eax
			call	CrLf
			jmp		endDisplayMedian

roundUp:
			inc		eax								; round up by incrementing eax
			call	WriteDec
			call	CrLf

endDisplayMedian: 
			pop		ebp
			ret		12
displayMedian ENDP





COMMENT !-----------------------------------------------------------------
	Displays farewell message
	Receives: goodbye1
	returns: none
	registers changed: edx
-------------------------------------------------------------------------!
farewell PROC
	mov		edx, [esp + 4]						;displays goodbye1
	call	WriteString
	ret		4
farewell ENDP



END main
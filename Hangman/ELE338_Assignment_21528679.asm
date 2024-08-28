data segment
;MENU
box db 201,20 dup(205),187,'$'
box1 db 186,20 dup(32),186,'$'
box2 db 200,20 dup(205),188,'$' 
option0 db '      RESUME "R"','$'
option1 db '    NEW GAME "N"','$'
option2 db '      LEVEL "L"','$'
option3 db '    HIGH SCORE "H"','$'
option4 db '     CREDITS "C"','$'
option5 db '     EXIT "Esc"','$'

res db 0 ;for controling the resume game

;NEW GAME

;Shortcuts                 
menu db 201,20 dup(205),187,'$'
menu1 db 186,'     Score =    %   ',186,'$' 
menu2 db 30 dup(205),'$'
menu3 db  186,'  F2  ',186,' F3   ',186,' Tab  ',186,' Esc   ',186,'$'
menu4 db  186,' Menu ',186,'Reset ',186,'Score ',186,' Quit  ',186,'$'

esc_back  db "Press 'Backspace' for return menu ",15 dup(32),"Press 'Esc' for exit the game","$" 

;Last Try
try db 201,20 dup(205),187,'$'
try1 db 186,'   Last Try =       ',186,'$'
try2 db 30 dup(205),'$'
try3 db  186,' Pick a letter.             ',186,'$'
try4 db  'You tried that one.(Press any key)','$' 
try5 db  'Only English Characters.(Press any key)','$'
space0 db '                                         ','$'

used_letter db 0 ;for controling the used letter 

;Letters
vowels db 201,205,185,'Vowels Left',204,205,187,'$'
vowels1 db 186,'   A E I O U   ',186,'$'            
consonants1 db 186,' B C D F G H J K L M N P Q R S T V W X Y Z ',186,'$'
vowels2 db 200,15 dup(205),188,'$'
consonants2 db 200,43 dup(205),188,'$'  
consonants db 201,12 dup(205),185,'Consonants Left',204,14 dup(205),187,'$'

copy_vow db 18 dup(0),'$'  ;for checking the used vowels
copy_cons db 50 dup(0),'$' ;for checking the used consonants

;HARDNESS
level db '       EASY "E"','$'
level1 db '     MEDIUM "M"','$'
level2 db '      HARD "H"','$'

level_numb db 1 dup(0),  ;for controling the levels  

select_easy db  "'Easy' is selected  ","$"
select_med  db  "'Medium' is selected","$"
select_hard db "'Hard' is selected  ","$"

;HIGH SCORE
high_score1 db 0 
high_score2 db 0
high_score3 db 0
high_score4 db 0
high_score5 db 0
mark db 16,"    %","$"
high_text db "Top 5 High Scores","$"
 
;CREDITS
credit db 16,'Hasan Huseyin YILDIRIM','$' 
credit1 db 16,'21528679','$'  
credit2 db 16,'HACETTEPE UNIVERSITY','$'
credit3 db 16,'ELECTRICAL and ELECTRONIC ENGINEERING','$'
credit4 db 16,'ELE338 - MICROPROCESSOR ARCHITECTURE and PROGRAMMING LAB.','$'
credit5 db 16,'Assignment Group 5 - Hangman Word Game',10,13,'$'


file db "mywords.txt",0 ;the file of the used words

text db 11 dup(0),"$" ;for saving the words selected
buf db ?,0 ;for reading a letter into the words file
line1 db ? ;for checking the number of the selected word
line db ?  ;for the number of the selected word
long db ?  ;for length of the words
lives db 10 ;players have 10 lives to spend
hits db 0   ;for counting the correct letter used
errors db 0 ;for counting the wrong letter used
bolum db 0  ;quotient for the score calculation 
kalan db 0  ;remainder for the score calculation 
score db 0,"$";for saving the score 


word_size db 11 dup(0),10,13,"$" ;for writing "-" to specify the length of the words
win_message db "YOU WIN (Select an option)$" ;message for winning
lose_message db "YOU DIE (Select an option)$" ;message for losing 

data ends

 


stack segment
    dw   128  dup(0)
stack ends

code segment
start:
mov ax,data
mov ds,ax

;MACROS

;Macro to specify the location 
location macro p2,p3,p4  
     mov ah,02h ;set cursor position
     mov dh,p2  ;row
     mov dl,p3  ;column
     mov bh,p4  ;page number
     int 10h
endm

;Macro to print the options box
drawbox macro row1,row2,row3 
location row1,25,1
mov dx,offset box
call print1 
location row2,25,1
mov dx,offset box1
call print1
location row3,25,1
mov dx,offset box2
call print1 
endm 

;Macro to print the levels box
drawbox1 macro rw1,rw2,rw3 
location rw1,25,2
mov dx,offset box
call print1
location rw2,25,2
mov dx,offset box1
call print1
location rw3,25,2
mov dx,offset box2
call print1 
 endm

;Macro to print a repetead character on a row 
drawing macro d1,d2,d3,d4  
    local don
mov cx,d1  ;the number of the repetition
mov bl,d2  ;column
don:
location d3,bl,0
call d4  ;call the procedure
inc bl   ;shift column to the right
loop don 
endm

;Macro to print a repetead character on a column      
drawing1 macro m1,m2,m3,m4 
    local don1
mov cx,m1   ;the number of the repetition
mov bl,m2   ;row
don1:
location bl,m3,0
call m4   ;call the procedure
inc bl    ;shift row to the down
loop don1 
 endm      

;Macro to print a character
char macro c1
    mov ah,02h 
    mov dl,c1  ;character
    int 21h
 endm    

;Macro to print the hanging parts by the error numbers
hanging macro h1,h2                                                            
mov al,ds:[errors]
cmp al,h1 
je h2
 endm

mov ah,00h
mov al,03h;set video mode
int 10h

;CODES FOR HANGMAN 

;MENU
newgame:  
;if there is resume game option box before,clear it
location 1,20,1
mov dx,offset space0  
call print1 
location 2,20,1
mov dx,offset space0
call print1
location 3,20,1
mov dx,offset space0
call print1  

call activepage1 ;get page 1  

;set menu quality and clear screen                                                 
mov ah,06h
mov al,0
mov bh,01110001b;blue writing on gray backround
mov cl,0
mov ch,0
mov dl,79
mov dh,24
int 10h

;MENU

jmp ngame;Jump the beginning of the game

;RESUME GAME 
resume:


call activepage1 ;get page 1  

cmp ds:[res],1 ;check  res is equal to 1
je resume_game ;if res is equal to 1,then resume the game
mov ds:[res],1 ;get res equals 1

drawbox 1,2,3  ;print the option box
location 2,26,1
mov dx,offset option0 ;print 'RESUME "R"'
call print1 
jmp null  

;The beginning of the game 
ngame:  
     
drawbox 5,6,7 ;print the option box

location 6,26,1
mov dx,offset option1 ;print 'NEW GAME "N"'
call print1

drawbox 9,10,11 ;print the option box
 
location 10,26,1
mov dx,offset option2 ;print 'LEVEL "L"'
call print1

drawbox 13,14,15 ;print the option box

location 14,26,1
mov dx,offset option3 ;print 'HIGH SCORE "H"'
call print1

drawbox 17,18,19 ;print the option box

location 18,26,1
mov dx,offset option4 ;print 'CREDITS "C"'
call print1

drawbox 21,22,23 ;print the option box

location 22,26,1
mov dx,offset option5 ;print 'EXIT "Esc"'
call print1 

null:
call activepage1 ;get page 1
mov ah,07h ;get a character
int 21h

and al,11011111b  ;convert the letter to uppercase

cmp al,78  
je new   ;if the letter is "N",jump NEW GAME
cmp al,76
je hardness ;if the letter is "L",jump LEVEL
cmp al,72
je high1    ;if the letter is "H",jump HIGH SCORE
cmp al,67
je info     ;if the letter is "C",jump CREDITS
cmp al,27
je exit     ;if the letter is "Esc",jump exit
cmp al,82
je resume   ;if the letter is "R",jump RESUME 

jmp null    ;if the letter is not like the above ones,get a character again

 
 
;NEWGAME
new:
mov ds:[errors],0h ;clear errors 
mov ds:[hits],0h   ;clear hits
mov ds:[score],0h  ;clear score

call activepage0 ;get page 0                                                  

;set menu quality and clear screen                                                
mov ah,06h
mov al,0
mov bh,01110001b;blue writing on gray backround
mov cl,0
mov ch,0
mov dl,79
mov dh,24
int 10h

;Shortcuts 

;print the shorcut boxs and options 
location 1,46,0
mov dx,offset menu
call print1
location 2,46,0
mov dx,offset menu1
call print1 
location 3,42,0
mov dx,offset menu2
call print1

location 3,42,0
char 201  
location 3,46,0
char 202 
location 3,49,0
char 203 
location 3,56,0
char 203
location 3,63,0
char 203
location 3,67,0
char 202
location 3,71,0
char 187

location 4,42,0
mov dx,offset menu3
call print1
 
location 5,42,0
mov dx,offset menu4
call print1

location 6,42,0
mov dx,offset menu2
call print1
 
location 6,42,0
char 200 
location 6,49,0
char 202 
location 6,56,0
char 202
location 6,63,0
char 202
location 6,71,0
char 188

;print the last try boxs and texts
location 8,46,0
mov dx,offset try
call print1
  
location 9,46,0
mov dx,offset try1
call print1
 
location 10,42,0
mov dx,offset try2
call print1

location 10,42,0
char 201  
location 10,46,0
char 202
location 10,67,0
char 202
location 10,71,0
char 187
 
location 11,42,0
mov dx,offset try3
call print1 

location 12,42,0
mov dx,offset try2
call print1  

location 12,42,0
char 200 
location 12,71,0
char 188



;print the vowels left boxs and texts
location 17,48,0
lea dx,vowels
call print1

location 18,48,0
lea dx,vowels1
call print1

location 19,48,0
lea dx,vowels2
call print1  

;copy the vowels into the copy_vow
lea si,vowels1
lea di,copy_vow
copy_v:
mov al,[si]
mov [di],al
inc si
inc di
cmp al,"$"
jne copy_v 

;print the consonants left boxs and texts
location 21,35,0
lea dx,consonants
call print1  

location 22,35,0
lea dx,consonants1
call print1
 
location 23,35,0
lea dx,consonants2
call print1  

;copy the consonants into the copy_cons
lea si,consonants1
lea di,copy_cons
copy_c:
mov al,[si]
mov [di],al
inc si
inc di
cmp al,"$"
jne copy_c

 
;Select a word part 

kelime_bul:
mov ds:[line1],0 ;clear line1 for getting a new  word 
mov ds:[buf],0h    ;clear buf for getting a new  word 
mov ds:[long],0h   ;clear long for getting a new  word 
;initialize word_size
mov cx,11
lea si,word_size
initial:
mov al,0
mov [si],al 
inc si
loop initial

;initialize text
mov cx,11
lea si,text
initial1:
mov al,"$"
mov [si],al 
inc si
loop initial1 

;Find a random number between 0-60,because there are 60 words in the mywords.txt file 
xor ax,ax            
int 1ah              
mov ax,dx            
xor dx,dx            
mov bx,60            
div bx 
add dx,1                                            
lea di,line 
mov [di],dx ;store the random number into line as selected word line

mov dx,offset file ; address of file to dx
mov al,0 ; open file (read-only)
mov ah,3dh
int 21h 

mov bx,ax ; put handler to file in bx
mov cx,1 ; read one character at a time

read_char:
lea dx,buf
mov ah,3fh ; read from the opened file (its handler in bx)
int 21h
 
mov al,ds:[buf]
cmp al,10 
je new2
jmp read_char ;repeat if it is not new line

new2:
mov al,1
add ds:[line1],al ;count the words 
mov al,ds:[line]
cmp al,ds:[line1]
je yaz
jmp read_char ; repeat if it is not the selected word

yaz:  
lea si,text
lea dx,buf

yaz1:
mov ah,3fh ; read from the opened file (its handler in bx)
int 21h
mov al,ds:[buf]

mov [si],al
inc si 

cmp al,13
je terminate;write the word into text,until the line ends

mov cl,1
add ds:[long],cl ;count the number of letter that the word has
 
cmp al,10                                                      
jne yaz1;count the number of letter that the word has,until the line ends
 
terminate:
cmp ds:[level_numb],'e';check the hardness is easy
jne med1        ;if hardness is not selected as easy,jumb med1 for other checking  
cmp ds:[long],6 
jnb  kelime_bul ;if the length of word is not below 6,get a new word
jmp no_level    ;if it is,jumb no_level for beginning game
 
med1:
cmp ds:[level_numb],'m' ;check the hardness is medium
jne har1              ;if hardness is not selected as medium,jumb har1 for other checking 
cmp ds:[long],5
jna  kelime_bul  ;if the length of word is not above 5 ,get a new word
cmp ds:[long],8
jnb  kelime_bul  ;if the length of word is not below 8 ,get a new word
jmp no_level    ;if it is,jumb no_level for beginning game


har1:
cmp ds:[level_numb],'h';check the hardness is hard
jne no_level          ;if hardness is not selected as hard,jumb no_level for beginning game  
cmp ds:[long],7
jna  kelime_bul      ;if the length of word is not above 7 ,get a new word


no_level:

mov cl,ds:[long] 
mov al,"-" 
lea si,word_size 

;write "-" in the word length into word_size
kisa:
mov [si],al
inc si
loop kisa 
 


main_loop:
call activepage0 ;get page 0                                                   
location 14,52,0
lea dx,word_size ;print "-" in the word length  
call print1  

location 22,35,0
lea dx,copy_cons ;print the consonants if there is a chance on them 
call print1 

location 18,48,0
lea dx,copy_vow ;print the vowels if there is a chance on them 
call print1

 
  
call check_word ;call procedure to decide state of the game (win-lose) 
location 11,58,0 

      
location 2,60,0
mov al,ds:[score]
call score_write ;call procedure to print the score

resume_game:     ;if there is exiting the game,resume the game at here again

call activepage0 ;get page 0 

mov ds:[res],0 ;clear state of the resuming game

null3:  
mov ds:[used_letter],0 ;clear state of the used letter
mov  ah,00h ;get a character
int  16h
 
cmp ah,0h
je null3  ;if Capslock is used,get a new character
cmp ah,9h 
je high1  ;Press 'Tab' for getting the high scores
cmp ah,3dh  
je new      ;Press 'F3' for starting the new game
cmp al,1bh  
je exit     ;Press 'Esc' for exiting the game 
cmp ah,3ch   
je resume   ;Press 'F2' for returning the menu

cmp al,7bh  ;Check the used letter is english character or not
jna eng 

location 13,37,0
    mov dx,offset try5 ;print the message
    call print1
     
    mov ah,0
    int 16h   
    
    location 13,37,0
    mov dx,offset space0 ;clear the message
    call print1 
jmp null3 ;if the letter is not english character,get a new character   
eng:

or al,00100000b ;convert the character to lowercase 

location 9,61,0
mov ah,0eh ;print the last tried letter
int 10h

call check_used  ;call procedure to check the letter is used before 
cmp ds:[used_letter],1
je null3         ;if the letter is used before, get a new letter

call update_vowels ;call procedure to check the letter is in vowels and if it is,delete it in the vowels list 
call update_consonants ;call procedure to check the letter is in consonants and if it is,delete it in the consonants list
call update_word  ;;call procedure to check the letter is on the word and if it is,write it as finding letter

;print hangman for each wrong selected letter
hanging 1,hang1 ;print column of the scaffold 
hanging 2,hang2 ;print lower part of the scaffold
hanging 3,hang3 ;print upper part of the scaffold
hanging 4,hang4 ;print rope
hanging 5,hang5 ;print head of the hanging man
hanging 6,hang6 ;print body of the hanging man
hanging 7,hang7 ;print right arm of the hanging man
hanging 8,hang8 ;print left arm of the hanging man
hanging 9,hang9 ;print right leg of the hanging man
hanging 10,hang10 ;print left leg the hanging man

hg:
jmp main_loop 

;HANGMAN 

;Scaffold  
;Column of the scaffold
hang1: 
drawing1 20,3,0,draw   
jmp hg
;Lower part of the scaffold 
hang2: 
location 23,0,0
char 200  
location 21,2,0
char 200 
drawing 15,3,21,draw1
location 21,17,0 
char 187 
location 22,17,0 
char 186 
drawing 16,1,23,draw1 
location 23,17,0 
char 188 
drawing 15,2,22,draw3 
jmp hg
;Upper part of the scaffold 
hang3:  
location 2,0,0
char 201  
location 4,2,0
char 201 
drawing 16,1,2,draw1
location 2,17,0 
char 187 
location 3,17,0 
char 186 
drawing 15,3,4,draw1 
location 4,17,0 
char 188 
drawing 15,2,3,draw3  
jmp hg
;Rope
hang4: 
location 4,10,0
char 203
drawing1 2,5,10,draw2
jmp hg                                                        
;Head of the hanging man
hang5:  
location 6,10,0
char 178
drawing 6,7,7,head
drawing1 3,7,7,head1
drawing1 3,7,13,head1
drawing 7,7,10,head
drawing1 1,8,6,head2
location 9,10,0
char 196
jmp hg
;Body of the hanging man
hang6: 
location 10,10,0
char 219
drawing1 3,11,8,body
drawing1 3,11,9,body
drawing1 3,11,10,body1
drawing1 3,11,11,body 
drawing1 3,11,12,body  
drawing 5,8,14,head
jmp hg
;Right arm of the hanging man
hang7: 
location 11,7,0
char 207  
drawing1 3,12,6,body
location 15,6,0
char 219
location 16,6,0
char 88
jmp hg
;Left arm of the hanging man
hang8:  
location 11,13,0
char 207
drawing1 3,12,14,body
location 15,14,0
char 219
location 16,14,0
char 88 
jmp hg
;Right leg of the hanging man 
hang9: 
drawing1 5,14,8,head1
drawing1 5,14,9,head1
location 19,9,0
char 219
location 19,8,0
char 223
location 19,7,0
char 220 
jmp hg
;Left leg of the hanging man
hang10: 
location 14,10,0
char 219
drawing1 5,14,11,head1
drawing1 5,14,12,head1
location 19,11,0
char 219
location 19,12,0
char 223
location 19,13,0
char 220
jmp hg

;Losing the game  
game_over:
   call find_high ;call procedure to store the top 5 high scores
     ;make eyes of the hanging man 'x x',when he dies 
     location 8,9,0
     char 232 
     location 8,11,0
     char 232
     location 11,43,0 
    lea   dx, lose_message ;print lose message
    call  print1 
                                                       
location 14,52,0
lea dx,text      ;print the wanted word
call print1 

    want_ag0:
    mov ah,07h   ;get a character 
    int 21h
    cmp al,9h    ;Press 'Tab' for getting the high scores
    je high1
    cmp al,0dh   ;Press 'Enter' for starting the new game
    je new
    cmp al,1bh   ;Press 'Esc' for exiting the game  
    je exit   
    cmp al,8h    ;Press 'Backspace' for returning the menu
    je newgame
    jmp want_ag0 ;if the letter is not like the above ones,get a character again

;Winning the game
game_win: 

mov bl,ds:[kalan] 
add ds:[score],bl ;add the remainder(the remainder of 100/(hits+errors)) into the the score  
location 2,60,0
mov al,ds:[score] 
call score_write ;call procedure to print the score 
call find_high ;call procedure to store the top 5 high scores
    
call win_man ;call procedure to print winning man


    
    location 11,43,0
    lea     dx, win_message ;print win message
    call    print1

    want_ag1: 
    mov ah,07h   ;get a character
    int 21h
    cmp al,9h    ;Press 'Tab' for getting the high scores
    je high1
    cmp al,0dh   ;Press 'Enter' for starting the new game
    je new
    cmp al,1bh   ;Press 'Esc' for exiting the game 
    je exit   
    cmp al,8h    ;Press 'Backspace' for returning the menu
    je newgame
    jmp want_ag1 ;if the letter is not like the above ones,get a character again



;LEVEL

hardness:
call activepage2 ;get page 2                                                   

;set menu quality and clear screen                                                  
mov ah,06h
mov al,0
mov bh,01110001b;blue writing on gray backround
mov cl,0
mov ch,0
mov dl,79
mov dh,24
int 10h

drawbox1 6,7,8 ;print the level box

location 7,26,2
lea dx,level   ;print 'EASY "E"'
call print1 

drawbox1 10,11,12 ;print the level box

location 11,26,2
lea dx,level1    ;print 'MEDIUM "M"'
call print1

drawbox1 14,15,16 ;print the level box

location 15,26,2
lea dx,level2    ;print 'HARD "H"'
call print1 

location 23,1,2
lea dx,esc_back  ;print shorcuts for exiting the game or returning the menu
call print1

one_more:
mov ah,07h  ;get a character
int 21h 

cmp al,1bh  ;Press 'Esc' for exiting the game 
je exit   
cmp al,8h   ;Press 'Backspace' for returning the menu
je retur 

or al,00100000b ;convert the character to lowercase

cmp al,65h ;check the letter is 'e'
jne medium 

mov ds:[level_numb],'e' ;if easy is selected,make level_numb equals 1
location 18,26,2
lea dx,select_easy ;print the selected level
call print1
jmp one_more

medium:
cmp al,6dh  ;check the letter is 'm'
jne hard 

mov ds:[level_numb],'m' ;if medium is selected,make level_numb equals 2
location 18,26,2
lea dx,select_med  ;print the selected level
call print1
jmp one_more


hard: 
cmp al,68h  ;check the letter is 'h'
jne one_more 
mov ds:[level_numb],'h' ;if hard is selected,make level_numb equals 3
location 18,26,2
lea dx,select_hard ;print the selected level
call print1
jmp one_more ;repeat get a character until selected an option 

retur:
jmp null

;HIGH SCORES
high1:
call activepage3 ;get page 3  

;set menu quality and clear screen                                                  
mov ah,06h
mov al,0
mov bh,01110001b;blue writing on gray backround
mov cl,0
mov ch,0
mov dl,79
mov dh,24
int 10h 
                                         
;print high score text
location 3,15,3
lea dx,high_text
call print1  

;print 1st high score
location 5,15,3
lea dx,mark
call print1
location 5,17,3 
mov al,ds:[high_score1] 
call score_write

;print 2nd high score
location 7,15,3
lea dx,mark
call print1
location 7,17,3
mov al,ds:[high_score2] 
call score_write

;print 3rd high score
location 9,15,3
lea dx,mark
call print1
location 9,17,3
mov al,ds:[high_score3] 
call score_write

;print 4th high score
location 11,15,3
lea dx,mark
call print1
location 11,17,3
mov al,ds:[high_score4] 
call score_write

;print 5th high score
location 13,15,3
lea dx,mark
call print1
location 13,17,3
mov al,ds:[high_score5] 
call score_write


location 23,1,3
lea dx,esc_back ;print shorcuts for exiting the game or returning the menu
call print1

one_m:
mov ah,07h  ;get a character
int 21h 

cmp al,1bh  ;Press 'Esc' for exiting the game 
je exit   
cmp al,8h   ;Press 'Backspace' for returning the menu
je null        
jmp one_m  ;repeat get a character until selected an option 
         
;CREDITS
info:
call activepage4;get page 4

;set menu quality and clear screen                                                  
mov ah,06h
mov al,0
mov bh,01110001b;blue writing on gray backround
mov cl,0
mov ch,0
mov dl,79
mov dh,24
int 10h

;print credits
location 5,15,4
lea dx,credit
call print1

location 7,15,4
lea dx,credit1
call print1 

location 9,15,4
lea dx,credit2
call print1
 
location 11,15,4
lea dx,credit3
call print1
 
location 13,15,4
lea dx, credit4
call print1  

location 15,15,4
lea dx,credit5
call print1  

location 23,1,4
lea dx,esc_back
call print1

one_m1:
mov ah,07h  ;get a character
int 21h 

cmp al,1bh  ;Press 'Esc' for exiting the game 
je exit   
cmp al,8h   ;Press 'Backspace' for returning the menu
je null        
jmp one_m1  ;repeat get a character until selected an option                                   



exit:   ;Exit the game

mov ah,4ch
int 21h  

;PROCEDURES

;procedure to print an array
print1 proc 
    mov     ah,09h
    int     21h
    ret
print1 endp

;procedures to get pages
 
activepage0 proc ;page 0 
    mov ah,05h
    mov al,0
    int 10h
    ret
activepage0 endp

activepage1 proc ;page 1  
    mov ah,05h
    mov al,1
    int 10h
    ret
activepage1 endp

activepage2 proc ;page 2  
    mov ah,05h
    mov al,2
    int 10h
    ret
activepage2 endp

activepage3 proc ;page 3 
    mov ah,05h
    mov al,3
    int 10h
    ret
activepage3 endp 

activepage4 proc ;page 4  
    mov ah,05h
    mov al,4
    int 10h
    ret
activepage4 endp

;procedures to print hangman

;for scaffold parts 

draw proc 
char 186
char 178
char 186
ret  
draw endp  

draw1 proc
char 205
ret
draw1 endp

draw2 proc 
char 186
ret  
draw2 endp 

draw3 proc
char 178
ret
draw3 endp

;for head parts

head proc
char 223    
ret
head endp 


head1 proc
char 219    
ret
head1 endp 


head2 proc
char 40
char 219
char 32
char 248 
char 141
char 248
char 32
char 219
char 41
ret
head2 endp

;for body

body proc
char 207
ret
body endp

body1 proc
char 254
ret
body1 endp 


;procedure to convert the score from ascii character to decimal number and print it 
score_write proc
aam 
mov bl,al
mov al,ah
aam
add ax, 3030h
push ax
mov dl, ah
mov ah, 02h
int 21h
pop dx
mov ah, 02h
int 21h
mov al,bl
add al,30h
mov dl,al
mov ah,02h
int 21h
ret
score_write endp  


;procedure to check the letter is in vowels and if it is,delete it in the vowels list 
update_vowels proc
     
    lea si,copy_vow
    mov bl," "     
        
    up_loop:
    cmp [si],'$'
    je  end_w
    cmp [si],al
    je equa
    inc si
    jmp up_loop 
      
    equa:
    mov   [si],bl
    inc si
    jmp up_loop
     
    end_w:   
    ret
update_vowels endp

;procedure to check the letter is in consonants and if it is,delete it in the consonants list
update_consonants proc
     
    lea si,copy_cons
    mov bl," "     
        
    up_loop1:
    cmp [si],'$'
    je  end_w1
    cmp [si],al
    je equa1
    inc si
    jmp up_loop1 
     
   
    
    equa1:
    mov   [si],bl
    inc si
    jmp up_loop1
     
    end_w1: 
    ret
update_consonants endp 

;procedure to decide state of the game (win-lose) 

check_word proc                   
    mov     bl,ds:[lives]
    mov     bh,ds:[errors]
    cmp     bl,bh
    je      game_over ;if errors equal to lives,lose the game
    
    mov     bl,ds:[long]
    mov     bh,ds:[hits]
    cmp     bl, bh
    je      game_win ;if hits equal to long (the length of word),win the game
    
    ret

check_word endp   


;procedure to check the letter is on the word and if it is,write it as finding letter
update_word proc
     
    or al,00100000b
     
    lea     si,text
    lea     di,word_size     
    mov     bx, 0
        
    update_loop:
    cmp     [si],13
    je      end_word
     
    cmp     [si], al
    je      equals
                 
    increment:
    inc     si
    inc     di   
    jmp     update_loop    
                 
    equals:
    mov   [di], al
    inc ds:[hits] 
    mov bx,0
    mov     bx,1
    jmp     increment             
    
    end_word:  
    cmp     bx,1
    je      end_update
    
    inc ds:[errors]      
    
    end_update:
;calculate the score ( score = (hits)*100 / (errors+hits) )   
mov bl,ds:[hits]
add bl,ds:[errors]
mov ah,0
mov al,100
div bl
mov ds:[bolum],al
mov ds:[kalan],ah 
mov ah,0
mov bl,ds:[hits]
mul bl
mov ds:[score],al

    ret
update_word endp 


;procedure to store the top 5 high scores
find_high proc
mov al,ds:[score]
cmp al,ds:[high_score5] 
jna cik
mov ds:[high_score5],al 


mov al,ds:[high_score5]
cmp al,ds:[high_score4] 
jna cik
xchg ds:[high_score4],al 
mov ds:[high_score5],al



mov al,ds:[high_score4]
cmp al,ds:[high_score3] 
jna cik
xchg ds:[high_score3],al 
mov ds:[high_score4],al
 

mov al,ds:[high_score3]
cmp al,ds:[high_score2] 
jna  cik
xchg ds:[high_score2],al 
mov ds:[high_score3],al 

mov al,ds:[high_score2]
cmp al,ds:[high_score1] 
jna cik
xchg ds:[high_score1],al 
mov ds:[high_score2],al 

cik:
ret
find_high endp  

;procedure to check the letter is used  before
check_used proc
     
and al,11011111b  
 
lea di,copy_vow

check_v: 
mov cl,[di]
cmp cl,al
je no_used 
inc di  
cmp cl,"$"
jne check_v     
    
lea di,copy_cons
check_c:
mov cl,[di]            
cmp cl,al
je no_used 
inc di 
cmp cl,"$"
jne check_c
   
    location 13,42,0
    mov dx,offset try4 ;print the "tried that one" message
    call print1
     
    mov ah,0
    int 16h   
    
    location 13,37,0
    mov dx,offset space0 ;clear the "tried that one" message
    call print1  
    
    mov ds:[used_letter],1 ;store the information about the letter is used before 
    
no_used:
ret    
check_used endp

;procedure to print winning man
win_man proc 
call activepage0 ;get page 0
    
;set menu quality and clear screen                                                  
mov ah,06h
mov al,0
mov bh,01110001b;blue writing on gray backround
mov cl,0
mov ch,0
mov dl,30
mov dh,24
int 10h 
;Head of the free man 
drawing 6,7,8,head
drawing1 3,8,7,head1
drawing1 3,8,13,head1
drawing 7,7,11,head
drawing1 1,9,6,head2
location 10,10,0
char 28

;Body of the free man 
location 11,10,0
char 219
drawing1 3,12,8,body
drawing1 3,12,9,body
drawing1 3,12,10,body1
drawing1 3,12,11,body 
drawing1 3,12,12,body  
drawing 5,8,15,head

;Right arm of the free man 
location 8,5,0
char 88 
location 9,5,0
char 219
drawing1 3,10,5,body
location 12,6,0
char 207 
location 12,7,0
char 207  

;Left arm of the free man  
location 8,15,0
char 88
location 9,15,0
char 219
drawing1 3,10,15,body 
location 12,13,0
char 207  
location 12,14,0
char 207


;Right leg of the free man  
drawing1 5,15,8,head1
drawing1 5,15,9,head1
location 20,9,0
char 219
location 20,8,0
char 223
location 20,7,0
char 220 

;Left leg of the free man 
location 15,10,0
char 219
drawing1 5,15,11,head1
drawing1 5,15,12,head1
location 20,11,0
char 219
location 20,12,0
char 223
location 20,13,0
char 220  

;hearts
location 6,7,0
char 3  
location 5,8,0
char 3 
location 4,7,0
char 3
location 6,10,0
char 3
location 5,11,0
char 3
location 4,10,0
char 3   
location 6,13,0
char 3
location 5,14,0
char 3
location 4,13,0
char 3

ret
win_man endp
    

code ends  
end start

.MODEL SMALL
.STACK 100H
.DATA

msg   db 0dh,'Enter USB Drive name:  $' 

viri1 db ?,':\*.ini',0,0dh,0ah,'$'  

viri2 db ?,':\autorun.inf',0,0dh,0ah,'$'  

viri3 db ?,':\thumbs.db',0,0dh,0ah,'$'

viri4 db ?,':\*.lnk',0,0dh,0ah,'$' 

vdir  db ?,':\',0ffh,0,0dh,0ah,'$'          

DTA   db 128h dup(0),0dh,0ah,'$'

drive db ?,':\',0ffh,'\*.*',0

all   db ?,':\*.*',0

new   db 'wonka',0,'$'   

fname db ?,':\',128h dup(0),0dh,0ah,'$'

zero db   128h dup(0)
.CODE  

MAIN PROC 
    
    MOV AX,@DATA  
    MOV DS,AX     ;initialize data
    mov es,ax     

;prompt user to define drive name

prompt:    
    
    mov ah,9             ;function: PRINT STRING TO STANDARD OUTPUT 
    lea dx,msg           ;point to PROMPT
    int 21h              ;call DOS
    
    mov ah,1             ;function: SINGLE KEY INPUT
    int 21h              ;do it
                         ;drive name is in al now 

                        
    cmp al,'A'           ;check if name inside A to Z 
    jl  prompt           
    cmp al,'Z'
    jg small_hand        ;if not check small hand
    
small_hand:
 
    cmp al,'a'           ;check if name inside a to z
    jl prompt
    cmp al,'z'
    jg prompt
    
    clc                  ;clear carry flag after comparison
    
    

;set drive name for viri files
    mov fname,al
    mov drive,al 
    mov all,al 
    mov viri1,al        
    mov viri2,al
    mov viri3,al
    mov viri4,al
    mov vdir,al

;print the viri names and location to search in
    
    mov ah,2
    mov dl,0dh
    int 21h
    
    mov dl,0ah
    int 21h
    
    
    mov ah,9h
    mov dx, offset viri1
    int 21h   
    mov dx, offset viri2
    int 21h
    mov dx, offset viri3
    int 21h
    mov dx, offset viri4
    int 21h
    mov dx, offset vdir
    int 21h
   
    
;search for the viri files in the drive

    mov dx,OFFSET DTA     ; DS:DX points to DTA 
    mov ah,1AH            ; function 1Ah - set DTA
    int 21h               ; call DOS service 
    
;          *.*
;-------------------------    
    mov bx,'n'
    mov ah,4eh            ;function : FIND FIRST FILE SEARCH     
    mov dx,offset all   ;point to the viri1 string      
    mov cx,07h             ;read only,hidden,system attribute      
    int 21h               ;call DOS 
    
    call SEARCH                   
         

;          *.ini
;-------------------------    
    mov bx,'d'
    mov ah,4eh            ;function : FIND FIRST FILE SEARCH     
    mov dx,offset viri1   ;point to the viri1 string      
    mov cx,07h             ;read only,hidden,system attribute      
    int 21h               ;call DOS 
    
    call SEARCH                   
    
    
    
    

;        autorun.inf
;-------------------------    
    mov bx,'d'
    mov ah,4eh            ;function : FIND FIRST FILE SEARCH     
    mov dx,offset viri2   ;point to the viri2 string      
    mov cx,07h             ;read only,hidden,system attribute      
    int 21h               ;call DOS 
    
    call SEARCH                 
    
    
    
    
    

;         thumbs.db       
;-------------------------    
    mov bx,'d'
    mov ah,4eh            ;function : FIND FIRST FILE SEARCH     
    mov dx,offset viri3   ;point to the viri3 string      
    mov cx,07h            ;read only,hidden,system attribute      
    int 21h               ;call DOS 
    
    call SEARCH                     
    
    
    
    
    

;         *.lnk
;-------------------------    
    mov bx,'d'
    mov ah,4eh            ;function : FIND FIRST FILE SEARCH     
    mov dx,offset viri4   ;point to the viri4 string      
    mov cx,07h            ;read only,hidden,system attribute      
    int 21h               ;call DOS 
    
    call SEARCH                   
    
    
    
    
    

;     unnamed folder
;-------------------------    
    mov bx,'n'
    mov ah,4eh            ;function : FIND FIRST FILE SEARCH     
    mov dx,offset vdir    ;point to the vdir string      
    mov cx,17h            ;read only,hidden,system,directory attribute      
    int 21h               ;call DOS 
     
    call search
                             
    call unnamed                           
 
                          
                               
exit:
    mov ah,4ch           ;function: TERMINATE PROGRAM
    int 21h              ;do it
    
MAIN ENDP        






SEARCH PROC
     
    
next:        
     jc outf               ;if there is no file as specified 
                           ;carry flag is set. so if carry=1 
                           ;program will exit 
                           
;add drive:\ at start of file name
     
     mov al,[drive]                          
     mov di, offset DTA+1bh    ;point to 3 bytes before the name
     stosb
     
     mov al,[drive+1]                          
     mov di, offset DTA+1ch    ;point to 3 bytes before the name
     stosb
     
     mov al,[drive+2]                          
     mov di, offset DTA+1dh    ;point to 3 bytes before the name
     stosb  
     
;print names  
   
     mov ah,9h                 ;function:PRINT STRING TO STANDARD OUTPUT  
     mov dx, offset DTA+1bh    ;the file name in DTA is 
                               ;located at the 
                               ;dta address+1eh location
                               ;and drive at address+1bh
                               ;so point there                                                              
     int 21h                   ;call DOS

;change attributes to show files
                              
     mov ah,43h                ;function: get/change attributes
     mov dx, offset DTA+1bh
     mov al,1
     mov cx,0                  ;clear all attributes
     int 21h 
     
;delete
     cmp bx,'d'
     jne  uio
     call delete 
     
uio:
        
     
     clc 
     
     mov ah,4fh            ;functiom: find next file
     int 21h
     jmp next

outf:
     
     ret


     
SEARCH ENDP 

DELETE PROC
    push bx 
    
    
    mov ah,41h                   ;FUNCTION:DELETE FILE
    mov dx, offset DTA+1bh
    int 21h
    
    pop bx
    ret
DELETE ENDP 


;RMDIR PROC
;    push bx 
;    
;    
;    mov ah,3Ah                  ;function: REMOVE DIRECTORY
;    mov dx, offset DTA+1bh
;    int 21h
;    
;    pop bx
;    ret
;    
;RMDIR ENDP


UNNAMED PROC
    push bx
    
    
    mov ah,4eh            ;function : FIND FIRST FILE SEARCH     
    mov dx,offset drive   ;point to the new drive string      
    mov cx,07h             ;read only,hidden,system attribute      
    int 21h               ;call DOS 
    
    call new_SEARCH   
    
    mov ah,4eh            ;function : FIND FIRST FILE SEARCH     
    mov dx,offset drive   ;point to the new drive string      
    mov cx,10h             ;read only,hidden,system attribute      
    int 21h               ;call DOS 
    
    call new_SEARCH   
    
    
    
    pop bx
    ret
UNNAMED ENDP

new_SEARCH PROC
     
    
n_next:        
     jc n_outf               ;if there is no file as specified 
                           ;carry flag is set. so if carry=1 
                           ;program will exit 
                           
     
     
;print names  
   
     mov ah,9h                 ;function:PRINT STRING TO STANDARD OUTPUT  
     mov dx, offset DTA+1eh    ;the file name in DTA is 
                               ;located at the 
                               ;dta address+1eh location
                               ;and drive at address+1bh
                               ;so point there                                                              
     int 21h                   ;call DOS


     mov si, offset DTA+1eh 
     mov di, offset fname+3
     mov cx,20
     rep movsb   
     

     cld
     mov al,[drive]                          
     mov di, offset DTA+19h    ;point to 3 bytes before the name
     stosb
     
     mov al,[drive+1]                          
     mov di, offset DTA+1ah    ;point to 3 bytes before the name
     stosb
      
     mov al,[drive+2]                          
     mov di, offset DTA+1bh    ;point to 3 bytes before the name
     stosb
       
      mov al,[drive+3]                          
     mov di, offset DTA+1ch    ;point to 3 bytes before the name
     stosb
     
      mov al,[drive+4]                          
     mov di, offset DTA+1dh    ;point to 3 bytes before the name
     stosb 
      
     mov ah,56h
     mov dx,offset DTA+19h
     mov di, offset fname
     int 21h 
     
     mov si, offset zero 
     mov di, offset fname+3
     mov cx,20
     rep movsb
     
     clc 
     
     mov ah,4fh            ;functiom: find next file
     int 21h
     jmp n_next

n_outf:
     
     ret
     
new_SEARCH ENDP 
    END MAIN 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
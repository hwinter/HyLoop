;
; Program to wring out the bnh_splint CALL_EXTERNAL stuff.
;
; Modification History:
;    10-Feb-99 (BNH) - Written


;
; Program to wring out the bnh_splint CALL_EXTERNAL stuff.
;
; Modification History:
;    10-Feb-99 (BNH) - Written

PRINT, !MAKE_DLL.COMPILER_NAME
patc_dir=getenv('PATC')
patc_c_dir=getenv('PATC_C')
InputFiles='bnh_splint'
OutputFile='bnh_splint'
ExportedRoutineNames='bnh_splint'
COMPILE_DIRECTORY=patc_c_dir
DLL_PATH=''
EXPORTED_DATA=[ 'n_x', 'x', 'y', 'n_y',' x1', 'answer']
INPUT_DIRECTORY=patc_c_dir
OUTPUT_DIRECTORY=patc_c_dir
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the ooperating system dependent shared object that tells IDL 
;how to call and interpret the C code
MAKE_DLL, InputFiles , OutputFile, $
          ExportedRoutineNames , $ ;CC=string]$
          COMPILE_DIRECTORY=COMPILE_DIRECTORY,$
          DLL_PATH=DLL_PATH, $
          INPUT_DIRECTORY=INPUT_DIRECTORY, $ ; [,EXTRA_LFLAGS=string] [
          OUTPUT_DIRECTORY=OUTPUT_DIRECTORY, $ 
          /SHOW_ALL_OUTPUT, /VERBOSE
;         EXPORTED_DATA=EXPORTED_DATA,$ ; EXTRA_CFLAGS=string] $
;         [, LD=string] [, /NOCLEANUP] [,] $
print, 'Made DLL:'+OutputFile

x = dindgen(20)
y = x^2
;             0   1  2   3    4     5     6     7
x1 = double([1.5, 2, 4, 4.5, 7.85, 8.25, 9.15, 15.5])

n_x = n_elements(x)
n_y = n_elements(x1)

answer = make_array(n_y, /double)

;a = call_external(OutputFile+'.so',ExportedRoutineNames, $
;                  n_x, x, y, n_y, x1, answer)

 foo = call_external(dll_path, $ ; The SO
                     ExportedRoutineNames, $ ; The entry name
                     n_x, $                  ; # of elements in x, f(x)
                     x, $       ; x
                     y, $    ; f(x)
                     n_y, $ ; # elements in thing-to-interpolate
                     x1, $ ; thing-to-interpolate
                     answer, $  ; where the answer goes
                     /d_value, $ 
                     value=[1,0,0,1,0,0], $ 
                     /auto_glue,/cdecl, $
                    /ignore_exist,/SHOW_ALL_OUTPUT,/VERBOSE)




PLOT, X,Y
OPLOT, X1,ANSWER,PSYM=4
 
end

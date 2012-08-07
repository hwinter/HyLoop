;mk_patc_de_dv_dt_so

Hyloop_dir='g++'
PRINT, !MAKE_DLL.COMPILER_NAME
Hyloop_dir=getenv('HYLOOP')
hyloop_c_dir=Hyloop_dir+'c_codes'
InputFiles='patc_de_dv_dt'
OutputFile='patc_de_dv_dt'
ExportedRoutineNames='patc_de_dv_dt'
COMPILE_DIRECTORY=hyloop_c_dir
DLL_PATH=''
EXPORTED_DATA=[ 'n_x', 'x', 'y', 'n_y',' x1', 'answer']
INPUT_DIRECTORY=hyloop_c_dir
OUTPUT_DIRECTORY=hyloop_c_dir
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

end

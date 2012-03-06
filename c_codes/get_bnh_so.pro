function get_bnh_so, hostname,INITIALIZE=INITIALIZE

if n_params() le 0 then hostname=!COMPUTER

patc_dir=getenv('PATC')
patc_c_dir=getenv('PATC_C')
InputFiles='bnh_splint'
OutputFile='bnh_splint'
ExportedRoutineNames='bnh_splint'
COMPILE_DIRECTORY=patc_c_dir
DLL_PATH=''
;spawn, 'hostname -s',hostname

patc_c_dir=getenv('PATC_C')
Case strupcase(hostname) of 
    'MITHRA':dir=patc_c_dir+'mithra/'
    'FILAMENT':dir=patc_c_dir+'filament/'
    'EARTH':dir=patc_c_dir+'earth/'
    'WIND':dir=patc_c_dir+'wind/'
    'FIRE':dir=patc_c_dir+'fire/'
    'DAWNTREADER':dir=patc_c_dir+'dawntreader/'
    'TITAN':dir=patc_c_dir+'titan/'
    'JUPITER':dir=patc_c_dir+'jupiter/'
    'GALLATIN':dir=patc_c_dir+'gallatin/'
    'KOOTENAI':dir=patc_c_dir+'kootenai/'
    else: begin
        print,"Can't find so file"
        so_file=-1
        dll_path=-1
    goto, end_jump
    end
endcase

if keyword_set(INITIALIZE) then begin
    
    
    MAKE_DLL, InputFiles , OutputFile, $
              ExportedRoutineNames , $ ;CC=string]$
              COMPILE_DIRECTORY=dir,$
              DLL_PATH=DLL_PATH, $
              INPUT_DIRECTORY=dir, $ ; [,EXTRA_LFLAGS=string] [
              OUTPUT_DIRECTORY=dir, $ 
              /SHOW_ALL_OUTPUT, /VERBOSE
    


endif else dll_path=dir+OutputFile+'.so'
end_jump:

return, dll_path



END ; Of main

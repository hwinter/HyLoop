data_dir=getenv('DATA')+'/PATC/runs/'

;folders=data_dir+['2007_JUN_11a/',$
;                  '2007_JUN_11k']

folders=data_dir+['2007_AUG]
NO_CHR=1
freq_out=20

for i=0UL, n_elements(folders)-1ul do begin
    cd, folders[i]
    print,  folders[i]
    restore, 'startup_vars.sav'
    title_add='!9a!3='+ALPHA_STRING+' '
    
    ;mk_trace_movie,folders[i], gif_dir='./gifs/', $
    ;                file_prefix=OUTPUT_PREFIX, $
    ;                 ext='loop',title_add=title_add, $
    ;                 freq_out=freq_out

    mk_hd_movie2,folders[i] ,$
                 GIF_DIR='./gifs/',EXT='loop',$        
                 FILE_PREFIX=OUTPUT_PREFIX, CS=1, $
                 freq_out=freq_out
    
endfor
     
end


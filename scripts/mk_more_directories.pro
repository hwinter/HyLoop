
;.r mk_more_directories
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
data_dir=getenv('DATA')+'/PATC/runs/'
top_dir=data_dir+'piet_scaling_laws/'



cd , top_dir
dirs=file_search('./','*', /TEST_DIRECTORY, $
                 /FULLY_QUALIFY_PATH, $
                /MARK_DIRECTORY,$
                COUNT=n_dirs0)


for i=0ul, n_dirs0-1ul do begin
    cd, dirs[i]
    spawn, 'mkdir movies'
    spawn, 'mkdir gifs'
    spawn, 'mkdir plots'

    
    sub_dirs=file_search('./','*', /TEST_DIRECTORY, $
                         /FULLY_QUALIFY_PATH, $
                         /MARK_DIRECTORY,$
                         COUNT=n_sub_dirs)
    for j=0ul, n_sub_dirs-1ul do begin
        cd, sub_dirs[j]
        spawn, 'mkdir movies'
        spawn, 'mkdir gifs'
        spawn, 'mkdir plots'
        sub_sub_dirs=file_search('./','*', /TEST_DIRECTORY, $
                                 /FULLY_QUALIFY_PATH, $
                                 /MARK_DIRECTORY,$
                                 COUNT=n_sub_sub_dirs)
        
        for k=0ul, n_sub_sub_dirs-1ul do begin
            cd, sub_sub_dirs[k]
            spawn, 'mkdir movies'
            spawn, 'mkdir gifs'
            spawn, 'mkdir plots'
        endfor        
    endfor    
endfor



end

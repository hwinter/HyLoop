;.r mk_sim_mov2
data_dir=getenv('DATA')+'/PATC/runs/piet_scaling_laws/Const_flux/'

cd, data_dir
dirs=file_search('./', 'alpha=*', /TEST_DIRECTORY, $
                 /FULLY_QUALIFY_PATH,/MARK_DIRECTORY)

subdirs=file_search(dirs, 'n_depth*', /TEST_DIRECTORY,$
                    /FULLY_QUALIFY_PATH, COUNT=N_FOLDERS) 

subdirs=[subdirs, file_search(dirs, 'GS*', /TEST_DIRECTORY,$
                    /FULLY_QUALIFY_PATH, COUNT=N_FOLDERS) ]

N_FOLDERS=n_elements(subdirs)
NO_CHR=1
freq_out=30
READ_ME_FILE_NAME='README.txt'

for i=0UL, N_FOLDERS-1ul do begin
    cd, subdirs[i]
    print,  subdirs[i]
    Web_folder_name=subdirs[i]
    Web_folder_name=strsplit(Web_folder_name, $
                             '/',COUNT=string_count, /EXTRACT)
    print , Web_folder_name

    mk_hd_movie2,subdirs[i] ,$
                 GIF_DIR=subdirs[i]+'/gifs/',EXT='.loop',$        
                 FILE_PREFIX='T', CS=1, $
                 freq_out=freq_out  ,$
                 movie_name=subdirs[i]+'/movies/hd_movie'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endfor
end


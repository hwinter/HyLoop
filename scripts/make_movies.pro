;
;Regriding on
;Safety =5
;Length=3d9 ;30 Mega meters

data_dir=getenv('DATA')
data_dir=data_dir+'/PATC/runs/'
OUTPUT_PREFIX='a'
ext='loop'
;folders=data_dir+[,$
;                  ,$
;                  ,$
;                  ]

folders= file_search(data_dir,'2007_MAY_16*',$
                     /TEST_DIRECTORY, /MARK_DIRECTORY)  
folders=data_dir+'2007_MAY_16d/'
print , folders
 

for i=0UL , n_elements(folders) -1Ul  do begin     
    cd , folders[i]
 ;   mk_trace_movie, './', gif_dir='./gifs/', $
 ;                   file_prefix=OUTPUT_PREFIX, EXT=ext

    mk_hd_movie2, folders[i],$
                  GIF_DIR=folders[i]+'gifs/',EXT=ext, $        
                  FILE_PREFIX=OUTPUT_PREFIX, JS=1,$
                  freq_out=60., /cs
endfor


;save, loop, FILE=fname2
end

dirs = file_search('./', 'alpha*', $
                   COUNT=DIR_COUNT, $
                   /TEST_DIRECTORY, $
                   /FULLY_QUALIFY_PATH)


for i=0, DIR_COUNT-1 do begin
    print, dirs[i]
    cd, dirs[i]
    
    spawn, 'mkdir  n_depth=25_n_cells=500/'
    spawn, 'mkdir  n_depth=25_n_cells=500/gifs'
    
    spawn, 'mkdir  n_depth=25_n_cells=1000/'
    spawn, 'mkdir  n_depth=25_n_cells=1000/gifs'
    
    spawn, 'mkdir  n_depth=50_n_cells=500/'
    spawn, 'mkdir  n_depth=50_n_cells=500/gifs'
    
    spawn, 'mkdir  n_depth=50_n_cells=1000/'
    spawn, 'mkdir  n_depth=50_n_cells=1000/gifs'

    
endfor

END

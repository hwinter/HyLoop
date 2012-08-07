pro grid_test_script
data_dir=getenv('DATA')+'/PATC/runs/flare_exp_05/'

folders=['alpha=4/']

;folders=['alpha=-4/',$
;         'alpha=-3/',$
;         'alpha=-2/',$
;         'alpha=-1/',$
;         'alpha=0/',$
;         'alpha=1/',$
;         'alpha=2/',$
;         'alpha=3/',$
;         'alpha=4/']
grid_folders=['099_25/',$
              '199_25/',$
              '299_25/',$
              '399_25/',$
              '499_25/',$
              '599_25/',$
              '699_25/',$
              '799_25/',$
              '899_25/',$
              '999_25/']+'run_01/'

n_files=ulong(1d6)
n_folders=n_elements(folders)
n_grid_folders=n_elements(grid_folders)
for i=0ul, n_folders-1ul do begin
    for j=0ul , n_grid_folders-1ul do begin       
        files=file_search(data_dir+folders[i]+$
                           grid_folders[j],$
                           'patc*.loop', $
                           COUNT=N_loops, $
                           /FULLY_QUALIFY_PATH)
        
        if j eq 7 then begin
            restore, files[0]
            model_loop=loop
        endif

        
        n_files<=N_loops
    endfor
endfor

t_maxes=dblarr(n_grid_folders,n_files)
n_e_maxes=dblarr(n_grid_folders,n_files)
t_max_z=dblarr(n_grid_folders,n_files)
n_e_max_z=dblarr(n_grid_folders,n_files)
max_percent_diffs_t=dblarr(n_grid_folders,n_files)
max_percent_diffs_n_e=dblarr(n_grid_folders,n_files)
max_percent_diffs_t=dblarr(n_grid_folders,n_files)
max_percent_diffs_n_e=dblarr(n_grid_folders,n_files)




for i=0ul, n_folders-1ul do begin
    for j=0ul , n_grid_folders-1ul do begin
        files=file_search(data_dir+folders[i]+$
                           n_grid_folders[j],$
                           'patc*.loop', $
                           COUNT=N_loops, $
                           /FULLY_QUALIFY_PATH)

 ;       if 

        k=0
        restore, files[k]
        loop=compile_loop(loop, LOOP_TEMPLATE=model_loop)
        z_max_index=where(loop.axis[2, *] eq max(loop.axis[2, *]))
        temp=get_loop_temp(loop)
        t_maxes[j,k]=max(temp)
        n_e_maxes[j,k]=max(loop.state.n_e)
        t_max_z[j,k]=temp[z_max_index[0]]
        n_e_max_z[j,k]=loop.state.n_e[z_max_index[0]]
        sum_temp=temp
        sum_n_e=loop.state.n_e

        

        for k=1ul, n_files-1ul do begin
            restore, files[k]
            loop=compile_loop(loop, LOOP_TEMPLATE=model_loop)
        
            z_max_index=where(loop.axis[2, *] eq max(loop.axis[2, *]))
            temp=get_loop_temp(loop)
            t_maxes[j,k]=max(temp)
            n_e_maxes[j,k]=max(loop.state.n_e)
            t_max_z[j,k]=temp[z_max_index[0]]
            n_e_max_z[j,k]=loop.state.n_e[z_max_index[0]]
            
            
            max_percent_diffs_t[j,k]=abs(sum_temp-temp)/abs(temp)
            max_percent_diffs_n_e[j,k]= $
              abs(sum_n_e-loop.state.n_e)/abs(loop.state.n_e)

            sum_temp+=temp
            sum_n_e+=loop.state.n_e


            
        endfor

    endfor
endfor

times=dindgen(n_files)

plot,times, t_maxes



;window, 2

;max_
;plot, times,


end

;Compare each grid to the last one. (The last data point should be zero).
;no dist

pro  loop_grid_test3_t_n_e, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  MULTI_FOLDERS=MULTI_FOLDERS,$
  X_LABELS=X_LABELS, PLOT_PREFIX=PLOT_PREFIX,$
  MOVIE_NAME=MOVIE_NAME,$
  X_VALS=X_vals


if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05'
if size(MULTI_FOLDERS, /TYPE) ne 7 then begin
    MESSAGE,' Procedure loop_grid_test3_t_n_e reqires the keyword MULTI_FOLDERS to be set.'
    stop
end

if size(PLOT_PREFIX, /TYPE) ne 7 then $
  PREFIX='grid_test3_' else  PREFIX=PLOT_PREFIX

if size(MOVIE_NAME, /TYPE) ne 7 then $
  MOVIE_NAME=strcompress(STRING(BIN_DATE(), $  
                                Format='(A, I4, 5I2.2, A)'), $
                         /REMOVE)+'grid_test3_'

n_folders=n_elements(EXPERIMENT_DIR)
n_alphas=n_elements(ALPHA_FOLDERS)
n_mfs=n_elements(MULTI_FOLDERS)
TITLE='Grid Test 3'
if not keyword_set(X_VALS) then X_VALS_in=lindgen(n_mfs) else $
  X_VALS_in=X_VALS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make some plotting choices and take stock of the current plotting
;  environment so that we can reset.
old_state=!D.NAME
set_plot, 'ps'
tvlct, r_old,g_old,b_old,/GET
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;Make a circle for plotting
circle_sym, thick=8, /fill
FONT=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

for i=0ul,  n_folders-1ul do begin
    for j=0ul, n_alphas-1ul do begin   
        gif_files=''  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Here we make sure that all of the necessary directories exist        
        Current_folder=EXPERIMENT_DIR+'/'+ $
                       ALPHA_FOLDERS[i]+'/'
        movie_dir=Current_folder+'movies/'
        spawn, 'mkdir '+movie_dir
        movie_dir=movie_dir+'grid_tests/'
        spawn, 'mkdir '+movie_dir

        gif_dir=Current_folder+'gifs/'
        spawn, 'mkdir '+gif_dir
        gif_dir=gif_dir+'grid_tests/'
        spawn, 'mkdir '+gif_dir
        
        plots_dir=Current_folder+'plots/'
        spawn, 'mkdir '+plots_dir 
        plots_dir=plots_dir+'grid_tests/'
        spawn, 'mkdir '+plots_dir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Count the number of files in each grid folder and take the 
;  smallest one.       
        n_files=1d35
        for k=0ul, n_mfs-1ul do begin
            
             files=file_search(Current_folder+'/'+MULTI_FOLDERS[k]+'/' ,$
                                'patc*.loop', $
                           COUNT=N_loops, $
                           /FULLY_QUALIFY_PATH)
             
            n_files<=N_loops
        endfor                  ;k loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Put all of the files in a variable array.
        files=strarr(n_mfs,n_files)
        
        for k=0ul, n_mfs-1ul do begin
            files_temp=file_search(Current_folder+'/'+MULTI_FOLDERS[k]+'/' ,$
                                   'patc*.loop', $
                                   COUNT=N_loops, $
                                   /FULLY_QUALIFY_PATH)
            files[k, *]=files_temp[0:n_files-1ul]
        endfor                  ;k loop
            
        temp=dblarr(n_mfs,n_files)
        n_e=temp
        tstring=strarr(n_files)
        time=lonarr(n_files)
        Diff_n_e_array=make_array(n_mfs,n_files, /DOUBLE, /NOZERO)
        Diff_t_array=Diff_n_e_array

            restore, files[0,0]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For each step in time make a plot that shows how the temperature
; and density change as a function of grid spacing  
time=-1d0      
        for file_index=0ul, n_files-1ul do begin
;Make an array of loop structures,  One for each multiple folder.
;Also identify the index of the loop apex.
            restore, files[0,file_index]
            junk=max(loop.axis[2,*],z_temp)
            z=z_temp[0]           
            time=[time, loop.state.time]
            temp_temp=get_loop_temp(loop)
            temp[0,file_index ]=temp_temp[z]
            n_e[0,file_index ]=loop.state.n_e[z]
            
            tstring[file_index] = 'Time = '+$
                      string(loop[0].state.time,format='(f9.2)')+' s'
            for k=1ul, n_mfs-1ul do begin
                
                restore, files[k,file_index]
                junk=max(loop.axis[2,*],z_temp)
                z=z_temp[0]
                
                temp_temp=get_loop_temp(loop)
                temp[k, file_index ]=temp_temp[z]
                n_e[k,file_index ]= loop.state.n_e[z]
                
            endfor; n_mfs loop
            
            for k=0ul, n_mfs-1ul do begin
                
                
                n_e_temp=(n_e[n_mfs-1ul, file_index]-n_e[k, file_index])$
                         /n_e[n_mfs-1ul, file_index]
                Diff_n_e_array[k,file_index]=n_e_temp[0]*100.
                t_temp=(temp[n_mfs-1ul, file_index]-temp[k, file_index])$
                       /temp[n_mfs-1ul, file_index]
                Diff_t_array[k, file_index]=t_temp[0]*100.

            endfor; n_mfs loop
        endfor
        YRANGE_T=[min(Diff_t_array ),$
                         1.1*max(Diff_t_array)]
        YRANGE_N_e=[min(Diff_n_e_array ),$
                         1.1*max(Diff_n_e_array)]
        time=time[1:*]
 
        for file_index=0ul, n_files-1ul do begin         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a plot

            ps_name=plots_dir+prefix+string(time[file_index],format='(I05)')+'.eps'
            gif_name=gif_dir+prefix+string(time[file_index],format='(I05)')+'.gif'
            device, /portrait, file= ps_name , color=16, /enc
;Plot the temperature array  with no axes on the right
            plot,X_VALS_in, Diff_t_array[*,file_index] , $
                 YRANGE=YRANGE_T, $
                 YSTYLE=1, $
                 POSITION=[.19,.15, .85,.90], $
                 CHARTHICK=1.5, CHARSIZE=1.5, $
                 XTITLE=XTITLE,YTITLE='% Diff. T ',$
                 XTICKNAME=X_LABELS, /NODATA, FONT=0,$
                 THICK=10,$
                 XRANGE=[min(X_VALS_in), max(X_VALS_in)], XSTYLE=1

            OPLOT,X_VALS_in[*], Diff_t_array[*,file_index], THICK=8, COLOR=1
            OPLOT,X_VALS_in[*], Diff_t_array[*,file_index], SYMSIZE=10, COLOR=1, $
                   PSYM=4, /CLIP
            
            axis, YAXIS=1, $
                  YRANGE=YRANGE_N_e, $
                  YTITLE='% Diff. N!De!N',/YSTYLE, $
                  CHARTHICK=1.5, CHARSIZE=1.5,$
                  /SAVE, FONT=0;, THICK=10;,THICK=10

            oplot,X_VALS_in[*], Diff_n_e_array[*,file_index],$
                  COLOR=3,THICK=4
            OPLOT,X_VALS_in[*], Diff_n_e_array[*,file_index], SYMSIZE=10, COLOR=3, $
                   PSYM=4, /CLIP

            legend, ['Temp.', 'Dens.'],line=[0,0],$;PSYM=[4,4],$
                    COLOR=[1,3], /RIGHT, BOX=0,$
                    FONT=0,CHARTHICK=1.3, CHARSIZE=1.3, THICK=6
                         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            xyouts, 0.6,0.91, tstring[file_index],$
                    FONT=FONT,/NORMAL,$
                    CHARTHICK=1.5, CHARSIZE=1.5
            xyouts, 0.2,0.91, $
                    title,/NORMAL,FONT=FONT,$
                    CHARTHICK=1.8, CHARSIZE=2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
                      
            device, /CLOSE
            spawn, 'convert '+ ps_name+' '+gif_name
            print, gif_name
            gif_files=[gif_files, gif_name]
        endfor; file_index loop

        gif_files=gif_files[1:N_ELEMENTS(gif_files)-1UL]
        print, movie_dir+movie_name
        image2movie,gif_files, $
                    movie_name=movie_name+'.mpg',$
                    movie_dir=movie_dir,$
                    /mpeg,$     ;/java,$
                    scratchdir=gif_dir
        

    endfor                      ;j loop

endfor                          ;i loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the plotting environment.
tvlct, r_old,g_old,b_old
set_plot, old_state
end

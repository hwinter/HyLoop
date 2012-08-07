;

pro   loop_mrun_test1_t_n_e, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  GRID_FOLDERS=GRID_FOLDERS, $
  MULTI_FOLDERS=MULTI_FOLDERS,$
  X_LABELS=X_LABELS, PLOT_PREFIX=PLOT_PREFIX,$
  MOVIE_NAME=MOVIE_NAME, YRANGE_T=YRANGE_T,$
  YRANGE_N_E=YRANGE_N_E


if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05'
if size(MULTI_FOLDERS, /TYPE) ne 7 then begin
    MESSAGE,' Procedure loop_mrun_test_t_n_e reqires the keyword MULTI_FOLDERS to be set.'
    stop
end

if size(PLOT_PREFIX, /TYPE) ne 7 then $
  PREFIX='mrun_test1_' else  PREFIX=PLOT_PREFIX

if size(MOVIE_NAME, /TYPE) ne 7 then $
  MOVIE_NAME=strcompress(STRING(BIN_DATE(), $  
                                Format='(A, I4, 5I2.2, A)'), $
                         /REMOVE)+'mrun1_test_'


n_folders=n_elements(EXPERIMENT_DIR)
n_alphas=n_elements(ALPHA_FOLDERS)
n_grids=n_elements(GRID_FOLDERS)
n_mfs=n_elements(MULTI_FOLDERS)

n_e_div=1d8
T_Div=1d6
FONT=0
TITLE='Run Test 1'
EXTRA=gang_plot_pos(1,1,1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make some plotting choices and take stock of the current plotting
;  environment so that we can reset.
old_state=!D.NAME
set_plot, 'ps'
tvlct, r_old,g_old,b_old,/GET
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

for i=0ul,  n_folders-1ul do begin
    for j=0ul, n_alphas-1ul do begin   
        for k=0ul, n_alphas-1ul do begin   
            gif_files=''  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Here we make sure that all of the necessary directories exist        
            Current_folder=EXPERIMENT_DIR[i]+'/'+ $
                           ALPHA_FOLDERS[j]+'/'+ $
                           GRID_FOLDERS[k]+'/'

            Current_folder2=EXPERIMENT_DIR[i]+'/'+ $
                           ALPHA_FOLDERS[j]+'/'

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
            
            vars_dir=Current_folder+'vars/'
            spawn, 'mkdir '+vars_dir
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Count the number of files in each grid folder and take the 
;  smallest one.       
            n_files=1d35
            for l=0ul, n_mfs-1ul do begin
            
                files=file_search(Current_folder2+'/'+MULTI_FOLDERS[l]+'/' ,$
                                  'patc*.loop', $
                                  COUNT=N_loops, $
                                  /FULLY_QUALIFY_PATH)
                
                n_files<=N_loops
            endfor              ;k loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Put all of the files in a variable array.
            files=strarr(n_mfs,n_files)
            for l=0ul, n_mfs-1ul do begin
                files_temp=file_search(Current_folder2+'/'+MULTI_FOLDERS[l]+'/' ,$
                                       'patc*.loop', $
                                       COUNT=N_loops, $
                                       /FULLY_QUALIFY_PATH)
                files[l, *]=files_temp[0:n_files-1ul]
            endfor              ;k loop
            
            
            Avg_n_e_array=make_array(n_files, n_mfs-1ul, /DOUBLE, /NOZERO)
            n_e_error_array=Avg_n_e_array
            Avg_t_array=Avg_n_e_array
            t_error_array=Avg_n_e_array
            time=dblarr(n_files)
            tstring=strarr(n_files)
            n_e=make_array(n_files, n_mfs, /DOUBLE, /NOZERO)
            temp=n_e
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For each step in time make a plot that shows how the temperature
; and density change as a function of grid spacing        
            for file_index=0ul, n_files-1ul do begin
;Make an array of loop structures,  One for each multiple folder.
;Also identify the index of the loop apex.
                k=0ul
                restore, files[0,file_index]
                junk=max(loop.axis[2,*],z_temp)
                z=z_temp[0]
                time[file_index]=loop.state.time
                temp_temp=get_loop_temp(loop)
                temp[file_index,k]=temp_temp[z]
                n_e[file_index,k]=loop.state.n_e[z]
                
                tstring[file_index] = 'Time = '+$
                  string(loop[0].state.time,format='(f9.2)')+' s'
                print, 'On time step '+tstring[file_index]
                for l=1ul, n_mfs-1ul do begin
                    
                    restore, files[l,file_index]
                    junk=max(loop.axis[2,*],z_temp)
                    z=z_temp[0]
                    temp_temp=get_loop_temp(loop)
                    temp[file_index,l]=temp_temp[z]
                    n_e[file_index,l]=loop.state.n_e[z]
                    
                endfor          ; n_mfs loop
                
                for l=0ul, n_mfs-2ul do begin
                    n_e_temp=moment(n_e[file_index,0:l+1ul], SDEV=SDEV_TEMP)
                    Avg_n_e_array[file_index,l]=n_e_temp[0] ;/n_e_div
                    n_e_error_array[file_index,l]=SDEV_TEMP ;/n_e_div
                    t_temp=moment(temp[file_index,0:l+1ul], SDEV=SDEV_TEMP)
                    Avg_t_array[file_index,l]=t_temp[0] ;/T_Div
                    t_error_array[file_index,l]=SDEV_TEMP ;/T_Div
                endfor                                    ; n_mfs loop
                help, n_mfs, Avg_n_e_array, Avg_t_array
            endfor
            
            save, Avg_n_e_array, Avg_t_array, n_e_error_array, t_error_array, $
                  time, tstring,temp, n_e, FILE=vars_dir+'/mrun_test1_t_n_e.sav'
                                ; file_index loop
            
            Avg_t_array=Avg_t_array/T_div
            t_error_array=t_error_array/T_div
            Avg_n_e_array=Avg_n_e_array/n_e_div
            n_e_error_array=n_e_error_array/n_e_div
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the yranges
            if not keyword_set(YRANGE_T) then $
              YRANGE_Tin=[.98*min(Avg_t_array-t_error_array),$
                          1.02*max(Avg_t_array+t_error_array)] else $
              YRANGE_Tin =YRANGE_T
            
            if not keyword_set(YRANGE_N_E) then $ 
              YRANGE_N_Ein=[.98*min(Avg_n_e_array-n_e_error_array),$
                            1.02* max(Avg_n_e_array+n_e_error_array)]else $
              YRANGE_N_Ein=YRANGE_N_E
            for file_index=0ul, n_files-1ul do begin
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a plot

                ps_name=plots_dir+prefix+ $
                        string(time[file_index],format='(I05)')+'.eps'
                gif_name=gif_dir+prefix+ $
                         string(time[file_index],format='(I05)')+'.gif'
                device, /portrait, file= ps_name , color=16, /enc
;Plot the temperature array  with no axes on the right
                plot_x=indgen(n_mfs+1ul)+1
                plot,plot_x, Avg_t_array[file_index,*], $
                     YRANGE=YRANGE_Tin, $
                     YSTYLE=9, $
                     POSITION=[.2,.15, .85,.90], $
                     CHARTHICK=1.5, CHARSIZE=1.5, $
                                ;                 TITLE=TITLE, $
                     XTITLE='# Runs',$
                     YTITLE='Avg. T x '+ $
                     strcompress(string(T_div, FORMAT='(G7.2)'),$
                             /REMOVE_ALL)+ $
                     ' [K]',$
                     XTICKNAME=X_LABELS, /NODATA, FONT=FONT,$
                     THICK=10, $
                     XRANGE=[min(plot_x), max(plot_x)], XS=1
                
                OPLOT,indgen(n_mfs-1ul)+2, Avg_t_array[file_index,*], $
                      thick=8, COLOR=1
                
                errplot,indgen(n_mfs-1ul)+2, $
                        Avg_t_array[file_index,*]-t_error_array[file_index,*], $
                        Avg_t_array[file_index,*]+t_error_array[file_index,*], $
                        /CLIP, thick=8, COLOR=1, $
                        WIDTH=.04

                axis, YAXIS=1, $
                      YRANGE=YRANGE_N_Ein, $
                      YTITLE='Avg. N!De!N x '+ $
                      strcompress(string(n_e_div, FORMAT='(G7.2)'),$
                                  /REMOVE_ALL)+ $
                      ' [cm!E-3!N]',/YSTYLE, $
                      CHARTHICK=1.5, CHARSIZE=1.5,$
                      /SAVE, FONT=FONT

                oplot,indgen(n_mfs-1ul)+2,$
                      Avg_n_e_array[file_index,*],$
                      COLOR=3,thick=6
            
                errplot,indgen(n_mfs-1ul)+2,$
                        Avg_n_E_array[file_index,*]-n_e_error_array[file_index,*], $
                        Avg_n_e_array[file_index,*]+n_e_error_array[file_index,*], $
                        /CLIP,thick=6, COLOR=3, $
                        WIDTH=.04
                
                 
                legend, ['Temp.', 'Dens.'],line=[0,0],$ ;PSYM=[4,4],$
                        COLOR=[1,3], /RIGHT, BOX=0,$
                        FONT=0,CHARTHICK=1.3, CHARSIZE=1.3, THICK=6          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                xyouts, 0.2,0.91, $
                        title,/NORMAL,FONT=FONT,$
                        CHARTHICK=1.8, CHARSIZE=2
                xyouts, 0.6,0.91, tstring[file_index],$
                        FONT=FONT,/NORMAL,$
                        CHARTHICK=1.5, CHARSIZE=1.5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;           
                device, /CLOSE
                spawn, 'convert '+ ps_name+' '+gif_name
                print, gif_name
                gif_files=[gif_files, gif_name]
            endfor              ; file_index loop
            
            gif_files=gif_files[1:N_ELEMENTS(gif_files)-1UL]
            print, movie_dir+movie_name
            image2movie,gif_files, $
                        movie_name=movie_name+'.mpg',$
                        movie_dir=movie_dir,$
                        /mpeg,$ ;/java,$
                        scratchdir=gif_dir
        endfor                  ;k loop
    
    
    endfor                      ;j loop
    
endfor                          ;i loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the plotting environment.
tvlct, r_old,g_old,b_old
set_plot, old_state
end

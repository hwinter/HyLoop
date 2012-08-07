;
;This procedure produces a single plot that charts the %SDEV
;  of Temperature and electron number density as a function of time.
;
pro   loop_mrun_test3_t_n_e, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  GRID_FOLDERS=GRID_FOLDERS, $
  MULTI_FOLDERS=MULTI_FOLDERS,$
  X_LABELS=X_LABELS, PLOT_PREFIX=PLOT_PREFIX,$
  MOVIE_NAME=MOVIE_NAME, YRANGE=YRANGE


if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05'
if size(MULTI_FOLDERS, /TYPE) ne 7 then begin
    MESSAGE,' Procedure loop_mrun_test_t_n_e reqires the keyword MULTI_FOLDERS to be set.'
    stop
end

if size(PLOT_PREFIX, /TYPE) ne 7 then $
  PREFIX='mrun_test3_' else  PREFIX=PLOT_PREFIX

if size(MOVIE_NAME, /TYPE) ne 7 then $
  MOVIE_NAME=strcompress(STRING(BIN_DATE(), $  
                                Format='(A, I4, 5I2.2, A)'), $
                         /REMOVE)+'mrun3_test_'


n_folders=n_elements(EXPERIMENT_DIR)
n_alphas=n_elements(ALPHA_FOLDERS)
n_grids=n_elements(GRID_FOLDERS)
n_mfs=n_elements(MULTI_FOLDERS)

n_e_div=1d8
T_Div=1d6
FONT=0
TITLE='Run Test 3'
EXTRA=gang_plot_pos(1,1,1)
n_runs_string='# of Runs= '+string(n_mfs, FORMAT='(I03)')
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
        Current_folder=EXPERIMENT_DIR+'/'+ $
                       ALPHA_FOLDERS[i]+'/'+ $
                           GRID_FOLDERS[k]+'/'
        Current_folder2=EXPERIMENT_DIR+'/'+ $
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
        for l=0ul, n_mfs-1ul do begin
            
             files=file_search(Current_folder2+'/'+MULTI_FOLDERS[l]+'/' ,$
                                'patc*.loop', $
                           COUNT=N_loops, $
                           /FULLY_QUALIFY_PATH)
             
            n_files<=N_loops
        endfor                  ;l loop
        t_error=dblarr(n_files)
        n_e_error=dblarr(n_files)
        times=dblarr(n_files)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Put all of the files in a variable array.
        files=strarr(n_mfs,n_files)
        for l=0ul, n_mfs-1ul do begin
            files_temp=file_search(Current_folder2+'/'+MULTI_FOLDERS[l]+'/' ,$
                                   'patc*.loop', $
                                   COUNT=N_loops, $
                                   /FULLY_QUALIFY_PATH)
            files[l, *]=files_temp[0:n_files-1ul]
        endfor                  ;l loop
            

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For each step in time make a plot that shows how the temperature
; and density change as a function of grid spacing        
        for file_index=0ul, n_files-1ul do begin
;Make an array of loop structures,  One for each multiple folder.
;Also identify the index of the loop apex.
            restore, files[0,file_index]
            junk=max(loop.axis[2,*],z_temp)
            z=z_temp[0]
            time=loop.state.time
            temp_temp=get_loop_temp(loop)
            temp=temp_temp[z]
            n_e=loop.state.n_e[z]
            times[file_index]=loop[0].state.time
;            tstring = 'Time = '+$
;                      string(loop[0].state.time,format='(f9.2)')+' s'
            for l=1ul, n_mfs-1ul do begin
                
                restore, files[l,file_index]
                junk=max(loop.axis[2,*],z_temp)
                z=z_temp[0]
                time=loop.state.time
                temp_temp=get_loop_temp(loop)
                temp=[temp,temp_temp[z]]
                n_e=[n_e, loop.state.n_e[z]]
                
            endfor; n_mfs loop
            
            n_e_temp=moment(n_e, SDEV=SDEV_TEMP)
                             ;l loop
            n_e_error[file_index]=100.*(SDEV_TEMP/n_e_temp[0])
            t_temp=moment(temp, SDEV=SDEV_TEMP)
            t_error[file_index]=100.*(SDEV_TEMP/t_temp[0])
            
         
        endfor                  ; file_index loop   
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a plot
        
        ps_name=plots_dir+prefix+string(time,format='(I05)')+'.eps'
        gif_name=gif_dir+prefix+string(time,format='(I05)')+'.gif'
        device, /portrait, file= ps_name , color=16, /enc
;Plot the temperature array  with no axes on the right
        
        if not keyword_set(YRANGE) then $
          YRANGE_in=[.98*min(t_error),$
                     1.02*max(t_error)] else $
          YRANGE_in=YRANGE

        plot,times,t_error , $
             YRANGE=YRANGE_in, $
             YSTYLE=9, $
             POSITION=[.2,.15, .85,.90], $
             CHARTHICK=1.5, CHARSIZE=1.5, $
                                ;                 TITLE=TITLE, $
             XTITLE='Time [s]',$
             YTITLE='T %s!DN-1!N',$
             /NODATA, FONT=FONT,$
             THICK=10, $
             XRANGE=[min(times), max(times)], XS=1
        OPLOT,times,t_error , thick=8, COLOR=1

      ;  if not keyword_set(YRANGE) then $
          YRANGE_in=[.98*min(n_e_error),$
                     1.02*max(n_e_error)]; else $
         ; YRANGE_in=YRANGE

        axis, YAXIS=1, $
              YRANGE=YRANGE_in, $
              YTITLE='N!De!N %s!DN-1!N',$
              /YSTYLE, $
              CHARTHICK=1.5, CHARSIZE=1.5,$
              /SAVE, FONT=FONT
        oplot,times, n_e_error,$
              COLOR=3,thick=6
        
        
        legend, ['Temp.', 'Dens.'],line=[0,0],$ ;PSYM=[4,4],$
                COLOR=[1,3], /RIGHT, BOX=0,$
                    FONT=0,CHARTHICK=1.3, CHARSIZE=1.3, THICK=6
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        xyouts, 0.2,0.91, $
                title,/NORMAL,FONT=FONT,$
                CHARTHICK=1.8, CHARSIZE=2
        xyouts, 0.6,0.91, n_runs_string,$
                FONT=FONT,/NORMAL,$
                CHARTHICK=1.5, CHARSIZE=1.5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
            
            
        device, /CLOSE
        spawn, 'convert '+ ps_name+' '+gif_name
        print, gif_name
        gif_files=[gif_files, gif_name]
        
        gif_files=gif_files[1:N_ELEMENTS(gif_files)-1UL]
        print, ps_name
  ;      print, movie_dir+movie_name
   ;     image2movie,gif_files, $
   ;                 movie_name=movie_name+'.mpg',$
 ;                   movie_dir=movie_dir,$
 ;                   /mpeg,$     ;/java,$
 ;                   scratchdir=gif_dir
 ;       

    endfor                      ;k loop Grids
    endfor                      ;j loop Alphas

endfor                          ;i loop Experiments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the plotting environment.
tvlct, r_old,g_old,b_old
set_plot, old_state
end

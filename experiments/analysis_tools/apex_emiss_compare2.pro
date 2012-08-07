;
;This procedure produces a plot at every time step show the distribution of the 
;  totaled apex emission in the two maps defined by the keyword NAMES
; apex_emiss_compare2.pro
;
pro  apex_emiss_compare2, map_name ,$
  TITLE=TITLE,$
  YTITLES=YTITLES,NAMES=NAMES, $
  EXPERIMENT_DIR=EXPERIMENT_DIR,$
  plots_DIR=PLOTS_DIR,GIF_DIR=GIF_DIR, $
  MULTI_FOLDERS=MULTI_FOLDERS,$
  X_LABELS=X_LABELS, PLOT_PREFIX=PLOT_PREFIX,$
  MOVIE_NAME=MOVIE_NAME


if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05/'
if size(MULTI_FOLDERS, /TYPE) ne 7 then begin
    MESSAGE,' Procedure apex_emiss_compare reqires the keyword MULTI_FOLDERS to be set.'
    stop
endif 

;if size(map_name, /TYPE) ne 7 then begin
;    MESSAGE,' Procedure loop_mrun_test_apex_emiss reqires the  positional parameter (1) map_index.'
;    stop
;end
;if size(test_name, /TYPE) ne 7 then begin
;    MESSAGE,' Procedure loop_mrun_test_apex_emiss reqires the  positional parameter (2) vars_name.'
;    stop
;end

if size(PLOT_PREFIX, /TYPE) ne 7 then $
  PREFIX='mrun_test3_apex_emiss_' else  PREFIX=PLOT_PREFIX

if size(MOVIE_NAME, /TYPE) ne 7 then $
  MOVIE_NAME=strcompress(STRING(BIN_DATE(), $  
                                Format='(A, I4, 5I2.2, A)'), $
                         /REMOVE)+'mrun3_test_3_6_kev'

n_folders=n_elements(EXPERIMENT_DIR)
n_mfs=n_elements(MULTI_FOLDERS)

FONT=0
;TITLE='Run Test 3a'
EXTRA=gang_plot_pos(1,1,1)
n_runs_string='# of Runs= '+string(n_mfs, FORMAT='(I03)')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define coordinates
YC=0.0
XC=940.
xr=[XC-20, XC+35]
yr=[YC-50, YC+55]
;Now for the apex box
apex_xr=XC+[0,20]
apex_yr=YC+[-10,20]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make some plotting choices and take stock of the current plotting
;  environment so that we can reset.
old_state=!D.NAME
set_plot, 'ps'
tvlct, r_old,g_old,b_old,/GET
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
N_MAPS=1
            
n_files=100       
Apex_emission=dblarr(n_files, n_mfs, n_folders)
Apex_emiss_avg=dblarr(n_files,n_folders)
emiss_error= Apex_emiss_avg         
for i=0ul, n_folders-1ul do begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Here we make sure that all of the necessary directories exist        
    Current_folder=EXPERIMENT_DIR[i]+'/'
    PRINT, Current_folder
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;For each step in time make a plot that shows how the temperature
            k=0ul
            map_dir=Current_folder+MULTI_FOLDERS[k]+'maps/'
            restore, map_dir+map_name
            times=(map.time)
            temp_map=map
            temp_map=add_tag(temp_map, 0., 'ROLL')
            temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
            temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
            temp_map.xc=XC
            temp_map.yc=YC
;Apex submap
            sub_map,temp_map,a_map,xrange=apex_xr,yrange=apex_yr ;
            for ll=0,N_files -1ul do begin
                Apex_emission[ll, k, i]=total(a_map[ll].data)  
            endfor              ; ll loop N_MAPS

            for k=1ul, n_mfs-1ul do begin
                 map_dir=Current_folder+MULTI_FOLDERS[k]+'maps/'
                 PRINT, map_dir
                 restore, map_dir+map_name
                 temp_map=map
                 temp_map=add_tag(temp_map, 0., 'ROLL')
                 temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
                 temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
                 temp_map.xc=XC
                 temp_map.yc=YC
;Apex submap
                 sub_map,temp_map,a_map,xrange=apex_xr,yrange=apex_yr ;
                 for ll=0,N_files -1ul do begin
                     Apex_emission[ll, k, i]=total(a_map[ll].data)  
                 endfor         ; ll loop N_MAPS

        endfor                  ; n_mfs loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    for ll=0ul, n_files-1ul do begin
        junk=moment(Apex_emission[ll,*,i],SDEV=SDEV)
        Apex_emiss_avg[ll,i]=junk[0]
        emiss_error[LL,i]=(SDEV)


    endfor
endfor                         ; i loop, n_folders

 times=times[0:n_files-1ul]           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for ll=0ul, n_files-1ul do begin
;Make a plot      
            ps_name=plots_dir+prefix+string(times[ll],format='(I05)')+'.eps'
            gif_name=gif_dir+prefix+string(times[ll],format='(I05)')+'.gif'
            T_string='Time= '+string(times[ll],format='(I05)')+ 'sec.'
            set_plot, 'z'
            plot_histo, Apex_emission[ll, *,0],steps1, histo1
            plot_histo, Apex_emission[ll, *,1],steps2, histo2
            
            steps_old=steps2
            steps2=steps_old
            set_plot, 'ps'
            XRANGE=[min(steps1,steps2),$
                    max(steps1,steps2)]
            YRANGE=[.98*min([histo1,histo2]),$
                         1.02*max([histo1,histo2])]
            device, /portrait, file= ps_name , color=16, /enc
            
            steps2=steps_old
            tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;Plot the temperature array  with no axes on the right
            emiss_error[*,*]=0.
            
            steps2=steps_old
            plot,steps1,histo1 , $
                 YRANGE=YRANGE, $
                 YSTYLE=1, $
                 POSITION=[.2,.15, .85,.90], $
                 CHARTHICK=1.5, CHARSIZE=1.5, $
                                ;                 TITLE=TITLE, $
                 XTITLE='Flux',$
                 YTITLE='# In Bin',$
                 /NODATA, FONT=0,$
                 THICK=10, $
                 XRANGE=XRANGE, XS=1,XTICKS=3,$
                 PSYM=10;, xlog=1
            OPLOT,steps1,histo1 , thick=10, COLOR=1,$
                 PSYM=10
            OPLOT,[Apex_emiss_avg[ll,0],Apex_emiss_avg[ll,0] ],[yrange[0], yrange[1]] ,$
                  thick=10, COLOR=1,$
                  PSYM=10, line=1   

            
            steps2=steps_old
            OPLOT,steps2,histo2 , thick=10, COLOR=3,$
                 PSYM=10
            OPLOT,[Apex_emiss_avg[ll,1],Apex_emiss_avg[ll,1] ],[yrange[0], yrange[1]] ,$
                  thick=10, COLOR=3,$
                  PSYM=10, line=1    
     
            legend, [NAMES[0],NAMES[1]],line=[0,0],$ ;PSYM=[4,4],$
                    COLOR=[1,3], /RIGHT, BOX=0,$
                    FONT=0,CHARTHICK=1.3, CHARSIZE=1.3, THICK=6;,$
                    ;/BOTTOM
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
If KEYWORD_SET(  TITLE) THEN $
           xyouts, 0.2,0.91, $
                    title,/NORMAL,FONT=FONT,$
                    CHARTHICK=1.8, CHARSIZE=2
            xyouts, 0.6,0.91, T_string,$
                    FONT=FONT,/NORMAL,$
                    CHARTHICK=1.5, CHARSIZE=1.5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
            device, /CLOSE
            spawn, 'convert '+ ps_name+' '+gif_name
            print, gif_name
            
            print, ps_name
                                ;      print, movie_dir+movie_name
                                ;     image2movie,gif_files, $
   ;                 movie_name=movie_name+'.mpg',$
 ;                   movie_dir=movie_dir,$
 ;                   /mpeg,$     ;/java,$
 ;                   scratchdir=gif_dir
endfor
 ;       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reset the plotting environment.
tvlct, r_old,g_old,b_old
set_plot, old_state
end

;.r mk_xr_movie_02a.pro

;A program to make a series of images and a movie showing 
;  3-6 keV total,  non-thermal and thermal emissions.

;This requires that a series of averaged maps have been previously made

pro  mk_xr_movie_03a_t_binned, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  GRID_FOLDERS=GRID_FOLDERS, $
  MOVIE_NAME=MOVIE_NAME

bin_size=4
frame_count=4ul
;Average the runs 
;3-6 keV band
if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05'
if size(GRID_FOLDERS, /TYPE) ne 7 then $
 GRID_FOLDERS='699_25'

n_folders=n_elements(EXPERIMENT_DIR)
n_alphas=n_elements(ALPHA_FOLDERS)
n_grids=n_elements(GRID_FOLDERS)

MAP1_NAME='ti_poly_avg.map'
map1_index=7
MAP2_NAME='3_6kev_7arc_avg.map'
MAP2_therm_NAME='3_6kev_7arc_thermal_only_avg.map'
MAP2_nt_NAME='3_6kev_7arc_nt_only_avg.map'


prefix='image_3a_binned'
TITLE=['3-6 keV', $
       '3-6 keV NT ',$
       '3-6 keV Therm ' $
      ]
if not keyword_set(movie_name) then movie_name='3a_binned'
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
outs_y=30
outs_x=15.
cthick=5
n_images=1d7
fp_index=13
floor=1d-2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

image_name=['alpha_-4__hxr_3_6_']

set_plot, 'z'
delvarx, signal
apex_yrange=[-20,10]

Title1='Modeled Emission'
max_files=2400
set_plot,'x'
;restore, file

gif_files=''
for i=0ul,  n_folders-1ul do begin
    for j=0ul, n_alphas-1ul do begin
        for k=0ul, n_grids-1ul do begin
    
             
             Current_folder=EXPERIMENT_DIR+'/'+ $
                            ALPHA_FOLDERS[i]+'/'+ $
                            GRID_FOLDERS[j]+'/'
  ;  !p.multi=[0,2,2]
             movie_dir=Current_folder+'movies/'
             spawn, 'mkdir '+movie_dir
             gif_dir=Current_folder+'gifs/'
             spawn, 'mkdir '+gif_dir
             plots_dir=Current_folder+'plots/'
             spawn, 'mkdir '+plots_dir
             map_dir=Current_folder+'maps/'
             
             cd , map_dir
             print, 'Restoring: '+map_dir+MAP1_NAME
             restore, MAP1_NAME
             fp_map=time_bin_map(map,bin_size)
            ;fp_map=map;[0]
            ;fp_map.data=0
           ;  fp_map.data=(map[8].data+map[9].data)/2d0
             fp_map.xc=XC
             fp_map.yc=YC
             
             restore,  MAP2_NAME
             map2=time_bin_map(map,bin_size)
                                ;map2=map;
             map2.xc=XC
             map2.yc=YC       
             
             restore, MAP2_therm_NAME
             MAP2_therm=time_bin_map(map,bin_size)
             ;MAP2_therm=map
             MAP2_therm.xc=XC
             MAP2_therm.yc=YC
             temp_map=map2_therm
             temp_map=add_tag(temp_map, 0., 'ROLL')
             temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
             temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
             temp_map.xc=XC
             temp_map.yc=YC
             sub_map,temp_map,a_map_therm,xrange=apex_xr,yrange=apex_yr ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             restore, MAP2_nt_NAME
             MAP2_nt=time_bin_map(map,bin_size)
             ;MAP2_nt=map
             MAP2_nt.xc=XC
             MAP2_nt.yc=YC  
             temp_map=map2_nt
             temp_map=add_tag(temp_map, 0., 'ROLL')
             temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
             temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
             temp_map.xc=XC
             temp_map.yc=YC
             sub_map,temp_map,a_map_nt,xrange=apex_xr,yrange=apex_yr ; 
             
;Apex submap
            temp_map=map2[0]
            temp_map=add_tag(temp_map, 0., 'ROLL')
            temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
            temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
            temp_map.xc=XC
            temp_map.yc=YC
            sub_map,temp_map,a_map,xrange=apex_xr,yrange=apex_yr ;  
            a_map.data=0.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; n_maps=min([n_elements(fp),n_elements(map2)])
             n_maps=n_elements(map2)
             if size(n_images,/TYPE) ne 0 then  n_maps<=n_images
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;Cheat.  Ensure that the total sugnal is the sum of the two         
             for l=0ul ,  n_maps-1ul do begin
                 map2[l].data=MAP2_therm[l].data+MAP2_nt[l].data
             endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             therm_signal=dblarr(n_maps)
             nt_signal=dblarr(n_maps)
             for l=0, n_maps-1ul do begin
                 therm_signal[l]=total(a_map_therm[l].data)
                 nt_signal[l]=total(a_map_nt[l].data)
             endfor
movie_counter=0ul
         for l=0, n_maps-1ul do begin
;         for l=0ul, min([n_elements(map1),n_elements(map2)])-1ul do begin
             for zzz=0ul, frame_count do begin 
                 
             ps_name=plots_dir+prefix+string(movie_counter,format='(I05)')+'.eps'
             gif_name=gif_dir+prefix+string(movie_counter,format='(I05)')+'.gif'
             set_plot, 'ps'
             device, /portrait, file= ps_name , color=16, /enc
             loadct,3 , /SILENT
             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
        ;     help, fp_map[fp_index]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;First image     
loadct,3
             plot_map,fp_map[l] , $       ;/notitle, $
                      /iso,/square, $   ; _extra=gang_plot_pos(1,2,0), $
                      title=TITLE[0] , $
                      charthick=0.9, charsize=0.9, $
                   ;   /contour , /percent, levels=[80], $
                   ;   c_color=3 ,$
                      font=0 ,  background=255, $   ;color=0, $
                      grid=15 ,gcolor=255 ,xrange=xr, yrange=yr   ,$
                  ;    CTHICK= CTHICK,$
                      POSITION=[0.10, 0.43, .30, .95],$
                      XTICKS=3
             
             loadct, 0, /SILENT
                                ; plot_map, map2,contour=1, /over, cthick=1,$
                                ;                NLEVELS=10         
                                ;
             
             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
             help, map2[l]
             too_small=total(map2[l].data)
             if too_small[0] le .01 then map2[l].data[*,*]=0d0
             plot_map, map2[l],$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=255, $ 
                       /contour ,c_color=255 ,$
                       grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                       levels =[ 40., 60., 80.] ,$
                       /percent, /border,CTHICK= CTHICK,$
                       /OVER  ;, cstyle=2
                                ;   xyouts, outs_x, outs_y, 't='+map2[l].time+' sec', font =0,  $
          ;           charthick=.7, charsize=.9,color=3
          ;   xyouts, 900, 0, string(too_small)
           ;  goto, skip_point

;Overplot the apex map
             plot_map, a_map,$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=255, $ 
                       /BORDER, BTHICK=3,BCOLOR=0, $
                       /OVER , COLOR=0, $
                       levels =[ 40.] ,$
                       /percent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;Second image     
             loadct,3
             plot_map,fp_map[l] , $       ;/notitle, $
                      /iso,/square, $   ; _extra=gang_plot_pos(1,2,0), $
                      title=TITLE[1] , $
                      charthick=0.9, charsize=0.9, $
                    ;  /contour , /percent, levels=[80], $
                    ;  c_color=3 ,$
                      font=0 ,  background=255, $   ;color=0, $
                      grid=15 ,gcolor=255 ,xrange=xr, yrange=yr   ,$
                    ;  CTHICK= CTHICK,$
                      POSITION=[0.40, 0.43, .60, .95], /noerase  ,$
                      XTICKS=3,$
                      /NOYTICKS, /NOLABELS;ystyle=4


             loadct, 0, /SILENT
                                ; plot_map, map2,contour=1, /over, cthick=1,$
                                ;                NLEVELS=10         
                                ;
             
             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

             help, MAP2_NT[l]
             too_small=total(map2_NT[l].data)
             pmm,map2_NT[l].data
             
             if too_small[0] le .1 then map2_NT[l].data[*,*]=0d0
             plot_map, MAP2_NT[l],$ ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=255, $ 
                       /contour ,c_color=2 ,$
                       grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                       levels =[ 40., 60., 80.] ,$
                       /percent, /border,CTHICK= CTHICK,$
                       /OVER    ;, cstyle=2
         ;    xyouts, 900,20,  strcompress(string(too_small),/remove_all)

;Overplot the apex map
             plot_map, a_map,$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=255, $ 
                       /BORDER, BTHICK=3,BCOLOR=0, $
                       /OVER , COLOR=0, $
                       levels =[ 40.] ,$
                       /percent


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;Third image    
loadct,3 
             plot_map,fp_map[l] , $       ;/notitle, $
                      /iso,/square, $   ; _extra=gang_plot_pos(1,2,0), $
                      title=TITLE[2] , $
                      charthick=0.9, charsize=0.9, $
                ;      /contour , /percent, levels=[80], $
                 ;     c_color=3 ,$
                      font=0 ,  background=255, $   ;color=0, $
                      grid=15 ,gcolor=255 ,xrange=xr, yrange=yr   ,$
                 ;     CTHICK= CTHICK,$
                      POSITION=[0.70, 0.43, .90, .95], /noerase  ,$
                      /NOYTICKS, /NOLABELS,$
                      XTICKS=3;ystyle=4


             loadct, 0, /SILENT
                                ; plot_map, map2,contour=1, /over, cthick=1,$
                                ;                NLEVELS=10         
                                ;
             
             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
             help, MAP2_therm[l]
             too_small=total(map2_therm[l].data)
             if too_small[0] le .01 then map2_therm[l].data[*,*]=0d0
             pmm, map2_therm[l].data
             plot_map, MAP2_therm[l],$ ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=255, $ 
                       /contour ,c_color=1 ,$
                       grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                       levels =[ 40., 60., 80.] ,$
                       /percent, /border,CTHICK= CTHICK,$
                       /OVER  ;, cstyle=2
            ; xyouts, 900,20,  strcompress(string(too_small),/remove_all)

;Overplot the apex map
             plot_map, a_map,$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=255, $ 
                       /BORDER, BTHICK=3,BCOLOR=0, $
                       /OVER , COLOR=0, $
                       levels =[ 40.] ,$
                       /percent

             skip_point:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Bottom plot

             times=MAP2_NT[0:n_maps-1ul].time
             line=[1d-30, 200*max(therm_signal+nt_signal)]

             plot, times, (therm_signal+nt_signal), /nodata, $
                   POSITION=[0.12, 0.15, .95, .3333],$
                   font=0,charthick=0.9, charsize=0.9,$
                   yTITLE="Arbitrary Units", XTITLE="seconds",$
                   /noerase, /YLOG
             oplot, times, (therm_signal+nt_signal), thick=4
             oplot, times, (therm_signal), line=1, color=1, thick=4
             oplot, times, (nt_signal), line=2, color=2, thick=4
             oplot, [times[l], times[l]], line, thick=4
             
             xyouts, 0.05,0.05,  'Time= ' + $
                     strcompress(string(times[l], format='(f07.2)'), $
                                 /REMOVE), $
                     /NORMAL,font=0,$
                     charthick=1.3, charsize=1.3



             device, /close
;      stop
             spawn, 'convert '+ ps_name+' '+gif_name
   ;     spawn, "convert  -rotate '-90' "+ $
    ;           gif_name+'  '+gif_name
             print, gif_name
             gif_files=[gif_files, gif_name]
 ;     !p.multi=0
            movie_counter++
         endfor


         endfor

         gif_files=gif_files[1:N_ELEMENTS(gif_files)-1UL]
         print, movie_dir+movie_name
         image2movie,gif_files, $
                     movie_name=movie_name+'.mpg',$
                     movie_dir=movie_dir,$
                     /mpeg,$     ;/java,$
                     scratchdir=gif_dir ;,$  ;nothumbnail=1,$
;              /nodelete
     endfor
 endfor
endfor

;Folders


end

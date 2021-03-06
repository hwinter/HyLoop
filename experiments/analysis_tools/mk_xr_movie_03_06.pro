;.r mk_xr_movie_03a.pro

;A program to make a series of images and a movie showing 
;  6-12 keV total,  non-thermal and thermal emissions.

;This requires that a series of averaged maps have been previously made

;pro  mk_xr_movie_03_06, $
;  EXPERIMENT_DIR=EXPERIMENT_DIR, $
;  ALPHA_FOLDERS=ALPHA_FOLDERS, $
;  GRID_FOLDERS=GRID_FOLDERS

save_name='lc_hxr.sav'
;Average the runs 
;3-6 keV band
EXPERIMENT_DIR=getenv('DATA')+'/HyLoop/runs/flare_exp_05'

;if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
;  EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05'
;if size(GRID_FOLDERS, /TYPE) ne 7 then $
GRID_FOLDERS='699_25'

ALPHA_FOLDERS=['alpha=-4', 'alpha=0','alpha=4']
alphas=[-4.0, 0.0, 4.0]


n_folders=n_elements(EXPERIMENT_DIR)
n_alphas=n_elements(ALPHA_FOLDERS)
n_grids=n_elements(GRID_FOLDERS)

MAP1_NAME='25_50kev_7arc_avg.map'
map1_index=7
MAP2_NAME='3_6kev_7arc_med.map'
MAP2_therm_NAME='3_6kev_7arc_thermal_only_med.map'
MAP2_nt_NAME='3_6kev_7arc_nt_only_med.map'


prefix='image_3_06'
TITLE=['3-6 keV', $
       '3-6 keV NT ',$
       '3-6 keV Therm ' $
      ]
movie_name='avg_3_6_306'

YC=0.0
XC=00.
xr=[XC-20, XC+20]
yr=[YC-70, YC+70]
outs_y=30
outs_x=15.
cthick=5
n_images=150
fp_index=8
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

image_name=['alpha_-4__hxr_3_6_']

;set_plot, 'z'
delvarx, signal
apex_yrange=[-20,10]

;Rotate to have a limb loop
ay= 2.
az=0.
rot2=rotation(2,((!dpi*ay/180.)))
rot3=rotation(3,((!dpi*az/180.)))

Title1='Modeled Emission'
max_files=2400
set_plot,'x'
;restore, file

gif_files=''
for i=0ul,  n_folders-1ul do begin
    for j=0ul, n_alphas-1ul do begin
        for k=0ul, n_grids-1ul do begin
    
             
             Current_folder=EXPERIMENT_DIR[i]+'/'+ $
                            ALPHA_FOLDERS[j]+'/'+ $
                            GRID_FOLDERS[k]+'/'
  ;  !p.multi=[0,2,2]
             movie_dir=Current_folder+'movies/'
             spawn, 'mkdir '+movie_dir
             gif_dir=Current_folder+'gifs/'
             spawn, 'mkdir '+gif_dir
             plots_dir=Current_folder+'plots/'
             spawn, 'mkdir '+plots_dir
             map_dir=Current_folder+'maps/'
             
             cd , map_dir
             restore, MAP1_NAME
             fp_map=map
             fp_map.xc=XC
             fp_map.yc=YC
             fp_map.data=5
             
             restore,  MAP2_NAME
             map2=map
             map2.xc=XC
             map2.yc=YC       
             
             restore, MAP2_therm_NAME
             MAP2_therm=map
             MAP2_therm.xc=XC
             MAP2_therm.yc=YC
             restore, MAP2_nt_NAME
             MAP2_nt=map
             MAP2_nt.xc=XC
             MAP2_nt.yc=YC

        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; n_maps=min([n_elements(fp),n_elements(map2)])
             n_maps=n_elements(map2)
             if size(n_images,/TYPE) ne 0 then  n_maps<=n_images
             
             for l=0ul ,  n_maps-1ul do begin
                 map2[l].data=MAP2_therm[l].data+MAP2_nt[l].data
             endfor
             therm_signal=dblarr(n_maps)
             nt_signal=dblarr(n_maps)
             for l=0, n_maps-1ul do begin
                 therm_signal[l]=total(MAP2_therm[l].data)
                 nt_signal[l]=total(MAP2_nt[l].data)
             endfor

         for l=0, n_maps-1ul do begin
;         for l=0ul, min([n_elements(map1),n_elements(map2)])-1ul do begin
             ps_name=plots_dir+prefix+string(map2[l].time,format='(I05)')+'.eps'
             gif_name=gif_dir+prefix+string(map2[l].time,format='(I05)')+'.gif'
             set_plot, 'ps'
             device, /portrait, file= ps_name , color=16, /enc
             loadct,3 , /SILENT
             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
             help, fp_map[fp_index]
             plot_map,fp_map[fp_index] , $       ;/notitle, $
                      /iso,/square, $   ; _extra=gang_plot_pos(1,2,0), $
                      title=TITLE[0] , $
                      charthick=0.9, charsize=0.9, $
                      /contour , /percent, levels=[80], $
                      c_color=3 ,$
                      font=0 ,  background=255, $   ;color=0, $
                      grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                      CTHICK= CTHICK,$
                      POSITION=[0.10, 0.43, .30, .98]
             
             loadct, 0, /SILENT
                                ; plot_map, map2,contour=1, /over, cthick=1,$
                                ;                NLEVELS=10         
                                ;
             
             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
             help, map2[l]
             too_small=total(map2[l].data)
             if too_small[0] le .1 then map2[l].data[*,*]=0d0
             plot_map, map2[l],$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=255, $ 
                       /contour ,c_color=0 ,$
                       grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                       levels =[ 40., 60., 80.] ,$
                       /percent, /border,CTHICK= CTHICK,$
                       /OVER  ;, cstyle=2
                                ;   xyouts, outs_x, outs_y, 't='+map2[l].time+' sec', font =0,  $
          ;           charthick=.7, charsize=.9,color=3
          ;   xyouts, 900, 0, string(too_small)
           ;  goto, skip_point
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;Second image     
             plot_map,fp_map[fp_index] , $       ;/notitle, $
                      /iso,/square, $   ; _extra=gang_plot_pos(1,2,0), $
                      title=TITLE[1] , $
                      charthick=0.9, charsize=0.9, $
                      /contour , /percent, levels=[80], $
                      c_color=3 ,$
                      font=0 ,  background=255, $   ;color=0, $
                      grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                      CTHICK= CTHICK,$
                      POSITION=[0.40, 0.43, .60, .98], /noerase  ,$
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;Third image     
             plot_map,fp_map[fp_index] , $       ;/notitle, $
                      /iso,/square, $   ; _extra=gang_plot_pos(1,2,0), $
                      title=TITLE[2] , $
                      charthick=0.9, charsize=0.9, $
                      /contour , /percent, levels=[80], $
                      c_color=3 ,$
                      font=0 ,  background=255, $   ;color=0, $
                      grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                      CTHICK= CTHICK,$
                      POSITION=[0.70, 0.43, .90, .95], /noerase  ,$
                      /NOYTICKS, /NOLABELS;ystyle=4


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


             skip_point:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Bottom plot

             times=fp_map[0:n_maps-1ul].time
         
             line=[1, 200*max(therm_signal+nt_signal)]
             max_y=max(therm_signal+nt_signal)
             plot, times, (therm_signal+nt_signal), /nodata, $
                   POSITION=[0.12, 0.15, .95, .3333],$
                   font=0,charthick=0.9, charsize=0.9,$
                   yTITLE="Arbitrary Units", XTITLE="seconds",$
                   /noerase, /YLOG, yrange=[1.0, Max_y],/ys, $
                   xrange=[0, 150], /xs
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
      ;stop
             spawn, 'convert '+ ps_name+' '+gif_name
   ;     spawn, "convert  -rotate '-90' "+ $
    ;           gif_name+'  '+gif_name
             print, gif_name
             gif_files=[gif_files, gif_name]
 ;     !p.multi=0
         endfor

         gif_files=gif_files[1:N_ELEMENTS(gif_files)-1UL]
        print, movie_dir+movie_name
         image2movie,gif_files, $
                     movie_name=movie_name+'.mpg',$
                     movie_dir=movie_dir,$
                     /mpeg,$            ;/java,$
                     scratchdir=gif_dir, $ ;nothumbnail=1,$
                     /nodelete
                     
                                                                                                                                       
         total_signal=therm_signal+nt_signal
         save, therm_signal, nt_signal,total_signal, times, $
               file=EXPERIMENT_DIR[i]+'/'+ $
               ALPHA_FOLDERS[j]+'/'+save_name 

      endfor; k loop
     endfor; j loop
 endfor; i loop


end

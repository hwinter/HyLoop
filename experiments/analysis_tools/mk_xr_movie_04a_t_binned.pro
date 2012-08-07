;.r mk_xr_movie_02a.pro

;A program to make a series of images and a movie showing 
;  3-6 keV total,  non-thermal and thermal emissions.

;This requires that a series of averaged maps have been previously made

pro  mk_xr_movie_04a_t_binned, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  GRID_FOLDERS=GRID_FOLDERS, $
  MOVIE_NAME=MOVIE_NAME

bin_size=4
;Average the runs 
;3-6 keV band
if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05'
if size(GRID_FOLDERS, /TYPE) ne 7 then $
 GRID_FOLDERS='699_25'

n_folders=n_elements(EXPERIMENT_DIR)
n_alphas=n_elements(ALPHA_FOLDERS)
n_grids=n_elements(GRID_FOLDERS)

;Contour Map
MAP0_NAME='3_6kev_7arc_nt_only_avg.map'
;Plot windows
MAP1_NAME='ti_poly_avg.map'
MAP2_NAME='be_thin_avg.map'
MAP3_NAME='be_med_avg.map';'al_med_avg.map'
;MAP1_NAME=MAP2_NAME
n_images=75
prefix='image_4a_binned'
TITLE=['Ti-Poly', $
       'Be Thin',$
       'Be Med.' $              ;'Al Med.'
      ]
if not keyword_set(movie_name) then movie_name='avg_xrt_04a_binned'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define coordinates
YC=0.0
XC=940.
xr=[XC-20, XC+35]
yr=[YC-50, YC+55]
;Now for the apex box
apex_xr=XC+[0,10]+5.
apex_yr=YC+[0,10]

;Now for the footpoint box
fp_xr=930.+[0,10]
fp_yr=40.+[0,10]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
outs_y=30
outs_x=15.
cthick=5
floor=1d-2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
             restore, MAP0_NAME
             map0=time_bin_map(map,bin_size)
            ; fp_map=map         ;[0]
             map0.xc=XC
             map0.yc=YC
             delvarx, map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             restore,  MAP1_NAME
             map1=time_bin_map(map,bin_size)
             map1.xc=XC
             map1.yc=YC       
             
             temp_map=map1
             temp_map=add_tag(temp_map, 0., 'ROLL')
             temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
             temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
             temp_map.xc=XC
             temp_map.yc=YC
             sub_map,temp_map,a_map1,xrange=apex_xr,yrange=apex_yr 
             sub_map, temp_map, fp_map1, xrange=fp_xr,yrange=fp_yr
             fp_map_t=fp_map1[0]
             fp_map_t.data=0.
             delvarx, map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             restore, MAP2_name
             MAP2=time_bin_map(map,bin_size)
             MAP2.xc=XC
             MAP2.yc=YC

             temp_map=MAP2
             temp_map=add_tag(temp_map, 0., 'ROLL')
             temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
             temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
             temp_map.xc=XC
             temp_map.yc=YC
             sub_map,temp_map,a_map2,xrange=apex_xr,yrange=apex_yr 
             sub_map, temp_map, fp_map2, xrange=fp_xr,yrange=fp_yr
             delvarx, map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             restore, MAP3_NAME
             MAP3=time_bin_map(map,bin_size)
             ;map3.data=map1.data/map2.data
             MAP3.xc=XC
             MAP3.yc=YC  
             
             temp_map=MAP3
             temp_map=add_tag(temp_map, 0., 'ROLL')
             temp_map=add_tag(temp_map, 0., 'ROLL_ANGLE')
             temp_map=add_tag(temp_map, [0., 0.], 'ROLL_center')
             temp_map.xc=XC
             temp_map.yc=YC
             sub_map,temp_map,a_map3,xrange=apex_xr,yrange=apex_yr 
             sub_map, temp_map, fp_map3, xrange=fp_xr,yrange=fp_yr
             delvarx, map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
             if size(n_images,/TYPE) eq 0 then n_images=n_maps
             n_images<=n_maps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             a_signal_1=dblarr(n_elements(map1))
             a_signal_2=a_signal_1
             a_signal_3=a_signal_1
             fp_signal_1=a_signal_1
             fp_signal_2=a_signal_1
             fp_signal_3=a_signal_1
             scl_1=a_signal_3
             scl_2=scl_1
             scl_3=scl_1

             
             for l=0ul, n_maps-1ul do begin
                 
                 scl_1[l]=total(map1[l].data)
                 scl_2[l]=total(MAP2[l].data)
                 scl_3[l]=total(MAP3[l].data)
                 a_signal_1[l]=total(a_map1[l].data)
                 a_signal_2[l]=total(a_map2[l].data)
                 a_signal_3[l]=total(a_map3[l].data)
                 fp_signal_1[l]=total(fp_map1[l].data)
                 fp_signal_2[l]=total(fp_map2[l].data)
                 fp_signal_3[l]=total(fp_map3[l].data)
             endfor
             junk=max(scl_1,index_1)
             junk=max(scl_2,index_2)
             junk=max(scl_3,index_3)
    ;         junk=max(a_signal_1,index_1)
    ;         junk=max(a_signal_2,index_2)
    ;         junk=max(a_signal_3,index_3)
             index_1>=2.
             index_2>=2.
             index_3>=2.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         for l=0, n_images-1ul do begin
;         for l=0ul, min([n_elements(map1),n_elements(map2)])-1ul do begin
             ps_name=plots_dir+prefix+string(map2[l].time,format='(I05)')+'.eps'
             gif_name=gif_dir+prefix+string(map2[l].time,format='(I05)')+'.gif'
             set_plot, 'ps'
             device, /portrait, file= ps_name , color=16, /enc
             loadct,3 , /SILENT
             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
            ; help, fp_map[fp_index]


             too_small=total(map0[l].data)
             if too_small[0] le .1 then map0.data[*,*]=0d0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;First image 
             too_small=total(map1[l].data)
             if too_small[0] le .1 then map1[l].data[*,*]=0d0
             loadct, 3, /silent
             plot_map, map1[l],$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       font=0 , background=0,  $ 
                      charthick=1.2, charsize=1.2, $
                       grid=15 ,gcolor=255 ,xrange=xr, yrange=yr   ,$
                       /border,$
                       POSITION=[0.10, 0.43, .30, .93], /noerase, $
                       XTICKS=2,/NOLABELS , $
                      title=TITLE[0], last=map1[index_1];,/log

             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
           
  plot_map,map0[l] , $       ;/notitle, $
                      /iso,/square, $   ; _extra=gang_plot_pos(1,2,0), $
                      title=TITLE[0] , $
                      charthick=0.9, charsize=0.9, $
                      /contour , /percent,levels =[  60., 80.], $
                      c_color=3 ,$
                      font=0 ,  background=0, $   ;color=0, $
                      grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                      CTHICK= CTHICK,$
                      /OVER 


;Overplot the apex map
             plot_map, a_map,$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=0, $ 
                       /BORDER, BTHICK=4,BCOLOR=255, $
                       /OVER , COLOR=0, $
                       levels =[ 40.] ,$
                       /percent
;Overplot the footpoint map
             plot_map, fp_map_t,$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=0, $ 
                       /BORDER, BTHICK=4,BCOLOR=255, $
                       /OVER , COLOR=0, $
                       levels =[ 40.] ,$
                       /percent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;Second image     

             too_small=total(map2[l].data)
             if too_small[0] le .1 then map2[l].data[*,*]=0d0
             loadct, 3, /silent
             plot_map, map2[l],$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       font=0 ,   $ 
                      charthick=1.2, charsize=1.2, $
                       grid=15 ,gcolor=255 ,xrange=xr, yrange=yr   ,$
                       /border, background=0, $
                       POSITION=[0.40, 0.43, .60, .93], /noerase, $
                       XTICKS=2,/NOLABELS , $
                      title=TITLE[1],last=map2[index_2];,/log

             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
           
  plot_map,map0[l] , $       ;/notitle, $
                      /iso,/square, $   ; _extra=gang_plot_pos(1,2,0), $
                      title=TITLE[2] , $
                      charthick=0.9, charsize=0.9, $
                      /contour , /percent,levels =[  60., 80.], $
                      c_color=3 ,$
                      font=0 ,  background=0, $   ;color=0, $
                      grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                      CTHICK= CTHICK,$
                      /OVER 


;Overplot the apex map
             plot_map, a_map,$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=0, $ 
                       /BORDER, BTHICK=4,BCOLOR=255, $
                       /OVER , COLOR=0, $
                       levels =[ 40.] ,$
                       /percent
;Overplot the footpoint map
             plot_map, fp_map_t,$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=0, $ 
                       /BORDER, BTHICK=4,BCOLOR=255, $
                       /OVER , COLOR=0, $
                       levels =[ 40.] ,$
                       /percent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;Third image  
             too_small=total(map3[l].data)
             if too_small[0] le .1 then map3[l].data[*,*]=0d0
             loadct, 3, /silent
             plot_map, map3[l],$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       font=0 , background=0, $ 
                      charthick=1.2, charsize=1.2, $
                       grid=15 ,gcolor=255 ,xrange=xr, yrange=yr   ,$
                       /border,$
                       POSITION=[0.70, 0.43, .90, .93], /noerase, $
                       XTICKS=2,  /NOLABELS ,$
                      title=TITLE[2], last=map3[index_3];,/log

             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
           
  plot_map,map0[l] , $       ;/notitle, $
                      /iso,/square, $   ; _extra=gang_plot_pos(1,2,0), $
                      charthick=0.9, charsize=0.9, $
                      /contour , /percent,levels =[  60., 80.], $
                      c_color=3 ,$
                      font=0 ,  background=0, $   ;color=0, $
                      grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                      CTHICK= CTHICK,$
                      /OVER 

;Overplot the apex map
             plot_map, a_map,$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=0, $ 
                       /BORDER, BTHICK=4,BCOLOR=255, $
                       /OVER , COLOR=0, $
                       levels =[ 40.] ,$
                       /percent
;Overplot the footpoint map
             plot_map, fp_map_t,$          ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=0, $ 
                       /BORDER, BTHICK=4,BCOLOR=255, $
                       /OVER , COLOR=0, $
                       levels =[ 40.] ,$
                       /percent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             skip_point:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Bottom plot

             times=MAP1[0:n_maps-1ul].time
             line=[1d-30, 200*max([a_signal_1, $
                                   a_signal_2,a_signal_3] )]

             plot, times, (a_signal_1), /nodata, $
                   POSITION=[0.12, 0.15, .95, .3333],$
                   font=0,charthick=0.9, charsize=0.9,$
                   yTITLE="Ratio", XTITLE="Seconds",$
                   TITLE='Apex/FP Flux' ,/noerase,$
                   XRANGE=[0, 450],$
                   YRange=[.9*min([a_signal_1[0:n_images]/fp_signal_1[0:n_images],$
                                   a_signal_2[0:n_images]/fp_signal_2[0:n_images],$
                                   a_signal_3[0:n_images]/fp_signal_3[0:n_images]]), $
                           1.0*max([a_signal_1[0:n_images]/fp_signal_1[0:n_images],$
                                   a_signal_2[0:n_images]/fp_signal_2[0:n_images],$
                                   a_signal_3[0:n_images]/fp_signal_3[0:n_images]]) ];,$
                               ;  /YLOG
             oplot, times,$
                    (a_signal_1[0:n_images])/fp_signal_1[0:n_images],$
                    thick=4
             oplot, times, $
                    (a_signal_2[0:n_images])/fp_signal_2[0:n_images], $
                    color=1, thick=4
             oplot, times, $
                    (a_signal_3[0:n_images])/fp_signal_3[0:n_images],  $
                    color=2, thick=4 ;, psym=4
             oplot, [times[l], times[l]], line, thick=4

             legend, title, color=[0,1,2],box=0,$
                     thick=[4,4,4], /TOP,$; horizontal=1,$
                     line=[0,0,0],charthick=0.9, charsize=0.9,$
                     /RIGHT,font=0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;          
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

save,  a_signal_1,a_signal_2,a_signal_3,$
       fp_signal_1,fp_signal_2,fp_signal_3,$
       scl_1,scl_2,scl_3,times,$
       file=movie_dir+'sig_vars.sav'
end

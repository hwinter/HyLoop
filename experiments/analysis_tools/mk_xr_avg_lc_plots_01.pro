;.r mk_xr_avg_lc_plots_01.pro
;
;a script to make Apex to foot point ratio light curves
;This requires that a series of averaged maps have been previously made

;pro  mk_xr_movie_04a_t_binned, $
;  EXPERIMENT_DIR=EXPERIMENT_DIR, $
;  ALPHA_FOLDERS=ALPHA_FOLDERS, $
;  GRID_FOLDERS=GRID_FOLDERS, $
;  MOVIE_NAME=MOVIE_NAME

;bin_size=4
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

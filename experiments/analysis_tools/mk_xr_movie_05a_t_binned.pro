;.r mk_xr_movie_05a_t_binned.pro

;A program to make a series of images and a movie showing 
;  3-6 keV total,  non-thermal and thermal emissions.

;This requires that a series of averaged maps have been previously made

;pro  mk_xr_movie_05a_t_binned, $
;  EXPERIMENT_DIR=EXPERIMENT_DIR

bin_size=4
;Average the runs 
;3-6 keV band
if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR=getenv('DATA')+$
                 '/HyLoop/runs/2010_inj_pos/inj_gamma=-4/run_0050/'
if size(GRID_FOLDERS, /TYPE) ne 7 then $
 GRID_FOLDERS=''

n_folders=0
n_alphas=0;
n_grids=0;

;Contour Map
MAP0_NAME='ti_poly.map'
;Plot windows
MAP1_NAME='ti_poly.map'
MAP2_NAME='be_thin.map'
MAP3_NAME='be_med.map'


prefix='image_5a_binned'
TITLE=['Ti-Poly', $
       'Be Thin',$
       'Be Med.' $              ;'Al Med.'
      ]
if not keyword_set(movie_name) then movie_name='avg_xrt_05a_binned'
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
i=0
k=0 
             Current_folder=EXPERIMENT_DIR
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
             map0=map
;map0=time_bin_map(map,bin_size)
            ; fp_map=map         ;[0]
             map0.xc=XC
             map0.yc=YC
             delvarx, map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             restore,  MAP1_NAME
            ; map1=time_bin_map(map,bin_size)
             map1=map
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
            ; MAP2=time_bin_map(map,bin_size)
             map2=map
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
             ;MAP3=time_bin_map(map,bin_size)
             map3=map
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

             times=MAP1[0:n_maps-1ul].time
             line=[1d-30, 200*max([a_signal_1, $
                                   a_signal_2,a_signal_3] )]
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             skip_point:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Folders

save,  a_signal_1,a_signal_2,a_signal_3,$
       fp_signal_1,fp_signal_2,fp_signal_3,$
       scl_1,scl_2,scl_3,times,$
       file=movie_dir+'sig_vars.sav'
end

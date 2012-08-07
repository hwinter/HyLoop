;.r mk_7arc_average_maps.pro
;Average the runs 
;3-6 keV band
set_plot, 'z'
pro mk_7arc_average_maps, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  GRID_FOLDERS=GRID_FOLDERS, $
  RUN_FOLDERS=RUN_FOLDERS


in_names=['25_50kev_7arc.map',$
          '3_6kev_7arc.map',$
          '3_6kev_7arc_therm_only.map',$
          '3_6kev_7arc_nt_only.map' ,$
          '6_12kev_7arc_therm_only.map',$
          '6_12kev_7arc_nt_only.map',$
          '6_12kev_7arc.map',$
          'ti_poly.map'$
         ]

out_names=['25_50kev_7arc_avg.map',$
           '3_6kev_7arc_avg.map',$
           '3_6kev_7arc_therm_only_avg.map',$
           '3_6kev_7arc_nt_only_avg.map' ,$
           '6_12kev_7arc_therm_only_avg.map',$
           '6_12kev_7arc_nt_only_avg.map',$
           '6_12kev_7arc.map_avg',$
           'ti_poly_avg.map' $
          ]

n_map_files=n_elements(in_names)
if n_map_files ne n_elements(out_names) then begin
    
    print, 'Error:  Number of in files does not much number of out files.'
    print, 'mk3_6_7arc_average_map quitting.'
endif

XC=0.0
YC=900.
xr=[XC-10, XC+35]
yr=[YC-40, YC+40]
outs_y=30
outs_x=15.
cthick=5
n_images=120
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
data_dir=getenv('DATA')+'/PATC/runs/flare_exp_03/'
plots_dir=data_dir+'plots/'

spawn, 'mkdir '+plots_dir

image_name=['alpha_-4__hxr_3_6_']
;folders=['alpha=-4/',$
;         'alpha=-3/',$
;         'alpha=-2/',$
;         'alpha=-1/',$
;         'alpha=0/',$
;         'alpha=1/',$
;         'alpha=2/',$
;         'alpha=3/',$
;         'alpha=4/']
sub_folders=['699_25/run_01/',$
             '699_25/run_02/',$
             '699_25/run_03/',$
             '699_25/run_04/',$
             '699_25/run_05/']
grid_folders=['699_25/']
folders=['alpha=-4/']
;sub_folders=['699_25/run_01/']


n_folders=n_elements(folders)
n_runs=n_elements(sub_folders)
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

!P.multi=[0,1,2]

for i=0ul,  n_folders-1ul do begin

         movie_dir=data_dir+folders[i]+'movies/'
         spawn, 'mkdir '+movie_dir
         gif_dir=data_dir+folders[i]+'gifs/'
         spawn, 'mkdir '+gif_dir
         plots_dir=data_dir+folders[i]+'plots/'
         spawn, 'mkdir '+plots_dir
         map_dir_main=data_dir+folders+'699_25/maps/'
         spawn, 'mkdir '+map_dir_main
         
         for j=0ul, n_map_files-1ul do begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make averge map
;Start with the first run
             k=1
             
             map_dir=data_dir+folders[i]+sub_folders[k]+'maps/'
             cd , map_dir
             restore, in_names[j] ; , verbose=1            
             map[*].xc=XC
             map[*].yc=yc
             n_maps0=n_elements(map)
         
             map0=map
;Now do the subsequent runs.
             for k=1ul, n_runs-1ul do begin         
                 map_dir=data_dir+folders[i]+sub_folders[k]+'maps/'
                 cd , map_dir
                 restore,in_names[j]  ; , verbose=1
                 n_maps=n_elements(map)
                 map[*].xc=XC
                 map[*].yc=YC
         
                 for l=0, n_maps-1ul do begin
                     map0[l].data+=map[l].data ;[7]
                 endfor
             endfor

             map0[*].data/=n_runs
            print, map_dir_main+out_names[j]
            map=map0
            save, map,file=map_dir_main+out_names[j]
            delvarx, map
 endfor; j loop
endfor ;i loop
end


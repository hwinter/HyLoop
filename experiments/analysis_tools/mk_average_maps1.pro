;.mk_average_maps1.pro
;Average the runs 
;3-6 keV band

; fe05_mk3_6_7arc_average_map
pro mk_average_maps1,in_names, out_names, $
                     EXPERIMENT_DIR=EXPERIMENT_DIR, $
                     ALPHA_FOLDERS=ALPHA_FOLDERS, $
                     GRID_FOLDERS=GRID_FOLDERS, $
                     RUN_FOLDERS=RUN_FOLDERS
old_plot_state=!D.NAME

set_plot, 'z'


n_map_files=n_elements(in_names)
if n_map_files ne n_elements(out_names) then begin
    
    print, 'Error:  Number of in files does not much number of out files.'
    print, 'mk_average_map quitting.'
    stop
endif
t0=systime(0)

;RUN_FOLDERS='run_06/'

n_experiments=n_elements(EXPERIMENT_DIR)
if n_experiments le 0 then begin
    
    print, 'Error: Must define EXPERIMENT_DIR='
    print, 'mk_average_map quitting.'
    stop
endif
 
n_alphas=n_elements(ALPHA_FOLDERS)
if n_alphas le 0 then begin
    
    print, 'Error: Must define ALPHA_FOLDERS='
    print, 'mk_average_map quitting.'
    stop
endif
 
n_grids=n_elements(GRID_FOLDERS)
if n_grids le 0 then begin
    
    print, 'Error: Must define GRID_FOLDERS='
    print, 'mk_average_map quitting.'
    stop
endif
n_runs=n_elements(RUN_FOLDERS)
if n_runs le 0 then begin
    
    print, 'Error: Must define RUN_FOLDERS='
    print, 'mk_average_map quitting.'
    stop
endif

image_name=['alpha_4__hxr_3_6_']
yC=0.0
xC=900.
xr=[XC-10, XC+35]
yr=[YC-40, YC+40]
outs_y=30
outs_x=15.
cthick=5
n_images=120

delvarx, signal
apex_yrange=[-20,10]

Title1='Modeled Emission'
max_files=2400
set_plot,'z'
;restore, file

!P.multi=[0,1,2]
for i=0ul, n_experiments-1ul do begin
    for j=0ul, n_alphas-1ul do begin
        for k=0ul, n_grids-1ul do begin
            
            current_folder=EXPERIMENT_DIR[i]+ $
                           '/'+ALPHA_FOLDERS[j]+ $
                           '/'+GRID_FOLDERS[k]+ $
                           '/'
            print, 'Now working on: '+current_folder
    
            movie_dir=current_folder+'movies/'
            spawn, 'mkdir '+movie_dir
            gif_dir=current_folder+'gifs/'
            spawn, 'mkdir '+gif_dir
            plots_dir=current_folder+'plots/'
            spawn, 'mkdir '+plots_dir
            map_dir_main=current_folder+'maps/'
            spawn, 'mkdir '+map_dir_main
            
            for m=0ul, n_map_files-1ul do begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make average map
;Start with the first run
                l=1
            
                map_dir=current_folder+RUN_FOLDERS[l]+'/maps/'
                cd , map_dir
                print, in_names[m]
                print, 'Restoring file: '+map_dir+in_names[m]
                restore, in_names[m] ; , verbose=1            
                map[*].xc=XC
                map[*].yc=yc
                n_maps0=n_elements(map)
         
                map0=map
;Now do the subsequent runs
                for l=1ul, n_runs-1ul do begin         
                    map_dir=current_folder+RUN_FOLDERS[l]+'/maps/'
                    cd , map_dir
                    print, 'Restoring file: '+map_dir+in_names[m]
                    restore,in_names[m] , verbose=1
                    n_maps=n_elements(map)
                    map[*].xc=XC
                    map[*].yc=YC
                
                    for ll=0, n_maps-1ul do begin
                        map0[ll].data+=map[ll].data ;[7]
                    endfor                          ; ll loop
                endfor                              ; l loop
                
                map0[*].data/=n_runs
                print, map_dir_main+out_names[m]
                map=map0
                save, map,file=map_dir_main+out_names[m]
                delvarx, map
                
            endfor              ;m loop
        endfor                  ;k loop
    endfor                      ; j:loop
endfor                          ; i loop


set_plot, old_plot_state
END ;Of Main


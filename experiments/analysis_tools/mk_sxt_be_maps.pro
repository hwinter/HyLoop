;.r 

pro mk_sxt_be_maps, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  GRID_FOLDERS=GRID_FOLDERS, $
  RUN_FOLDERS=RUN_FOLDERS, $
  MAP_ID=MAP_ID, $
  MAP_NAME=MAP_NAME

if size(MAP_ID, /TYPE) ne 7 then $
  map_id='SXT (Model) Be'

if size(MAP_NAME, /TYPE) ne 7 then $
  map_name='sxt_be.map'



if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05'

if size(ALPHA_FOLDERS, /TYPE) ne 7 then $
  ALPHA_FOLDERS='/'

if size(GRID_FOLDERS, /TYPE) ne 7 then $
  GRID_FOLDERS='/'

if size(RUN_FOLDERS, /TYPE) ne 7 then $
   RUN_FOLDERS='/'
 ; RUN_FOLDERS=['run_01',$
 ;              'run_02',$
 ;              'run_03',$
 ;              'run_04',$
 ;              'run_05']

n_folders=n_elements(ALPHA_FOLDERS)
n_grids=n_elements(GRID_FOLDERS)
n_runs=n_elements(RUN_FOLDERS)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
filter_index=3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_plot, 'z'

delvarx, signal, map
apex_yrange=[-20,10]

;Rotate to have a limb loop
ay= 2.
az=0.
rot2=rotation(2,((!dpi*ay/180.)))
rot3=rotation(3,((!dpi*az/180.)))

fwhm=2.
res=2.5 ;SXT PFI res
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This is my attempt to stabilize the image as we zoom in.
arcsec_per_cm=1./(7.2d+7)
;Set the plot scaling
PAD=max(res)*720d*1d5*2D0*3D0
counter=0
for i=0ul,  n_folders-1ul do begin
    for j=0ul, n_grids-1ul  do begin
        for k=0ul, n_runs-1ul do begin
            delvarx,map
            
            Current_folder=EXPERIMENT_DIR+'/'+ $
                           ALPHA_FOLDERS[i]+'/'+ $
                           GRID_FOLDERS[j]+'/'+$
                           RUN_FOLDERS[k]+'/'
            
            
            map_dir=Current_folder+'maps/'
            spawn, 'mkdir '+map_dir
            
            
            files=file_search(Current_folder,$
                              '*.loop', $
                              COUNT=N_loops, $
                              /FULLY_QUALIFY_PATH)
            for l=0ul, N_loops-1ul do begin
                
                restore, files[l]
                old_loop=loop
                loops=loop
                loop.axis[0, *]=old_loop.axis[2, *]
                loop.axis[2, *]=old_loop.axis[0, *]
                old_loop=loop
                loop.axis=rot2#loop.axis
                
                loop=old_loop
                fwhm_in=fwhm
                res_in=res
                filter_INDEX_in=filter_INDEX
                temp_map=mk_loop_sxt_map(loop,$
                                         filter_INDEX=filter_INDEX_in, $
                                         exp=exp, XC=0.0, YC=0.0,$
                                         xrange=[-100, 100],$
                                         yrange=[-100,100], res=res_in, $
                                         fwhm=fwhm_in,$
                                         start_hour=start_hour, $
                                         start_minute=start_minute,$
                                         XMN_CM=XMN,XMX_CM=XMX,$
                                         YMN_CM=YMN,YMX_CM=YMX, $
                                         X_CENTER=X_CENTER, Y_CENTER=Y_CENTER,$
                                         /no_chr)
                temp_map.id= map_id
                temp_map.time=string(loop.state.time, format='(I05)')
                temp_map.xc=0.0
                temp_map.yc=0.0
                
                if size(map, /TYPE) EQ 0 then $
                  map=temp_map else $
                  map=concat_struct(map, temp_map)
            endfor              ;  l loop
            
            
            filename= map_dir+map_name
            print, 'Saving '+filename
            save,map , file=filename
        endfor                  ; k loop
        
    endfor                      ; j loop
    
endfor                          ; i loop


END ;of Main

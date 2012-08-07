;.r mk_hxr_20_30_7arc.pro 


pro mk_hxr_20_30_7arc, $
  EXPERIMENT_DIR=EXPERIMENT_DIR, $
  ALPHA_FOLDERS=ALPHA_FOLDERS, $
  GRID_FOLDERS=GRID_FOLDERS, $
  RUN_FOLDERS=RUN_FOLDERS, $
  MAP_ID=MAP_ID, $
  MAP_NAME=MAP_NAME

print, 'Running mk_hxr_20_30_7arc'
  
if size(MAP_ID, /TYPE) ne 7 then $
map_id='HXR 20-30 kev'

if size(MAP_NAME, /TYPE) ne 7 then $
  map_name='20_30kev_7arc.map'

if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05'

if size(ALPHA_FOLDERS, /TYPE) ne 7 then $
  ALPHA_FOLDERS='alpha=-4'

if size(GRID_FOLDERS, /TYPE) ne 7 then $
  GRID_FOLDERS='699_25'

if size(RUN_FOLDERS, /TYPE) ne 7 then $
  RUN_FOLDERS=['run_01',$
               'run_02',$
               'run_03',$
               'run_04',$
               'run_05']

set_plot, 'z'
;NT_ONLY=1
;THERM_ONLY=1
E_RANGE=[20., 30.]
fwhm=3.
res=7

n_folders=n_elements(ALPHA_FOLDERS)
n_grids=n_elements(GRID_FOLDERS)
n_runs=n_elements(RUN_FOLDERS)

delvarx, signal, map
apex_yrange=[-20,10]

;Rotate to have a limb loop
ay= 0.05
az=0.
rot2=rotation(2,((!dpi*ay/180.)))
rot3=rotation(3,((!dpi*az/180.)))

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This is my attempt to stabilize the image as we zoom in.
arcsec_per_cm=1./(7.2d+7)
;Set the plot scaling
PAD=max(res)*720d*1d5*2D0*3D0
counter=0
 for i=0ul,  n_folders-1ul do begin
     for j= 0ul,  n_grids-1ul do begin
         for k=0ul, n_runs-1ul do begin
             delvarx, map
             
             Current_folder=EXPERIMENT_DIR+'/'+ $
                            ALPHA_FOLDERS[i]+'/'+ $
                            GRID_FOLDERS[j]+'/'+$
                            RUN_FOLDERS[k]+'/'
             
             print, 'Now on folder '+Current_folder
             
             map_dir=Current_folder+$
                     'maps/'          
             spawn, 'mkdir '+map_dir
             
             files=file_search(Current_folder ,$
                               'patc*.loop', $
                               COUNT=N_loops, $
                               /FULLY_QUALIFY_PATH)
             ;files=files[1:*]
             
             for l=0ul, N_loops-1ul do begin
                 
                 restore, files[l]
                 old_loop=loop
                 loop.axis[0, *]=old_loop.axis[2, *]
                 loop.axis[2, *]=old_loop.axis[0, *]
                 loop.axis[2, *]+=1.0
                 old_loop=loop
                 ;loop.axis=rot2#loop.axis
                 
                 em=get_loop_em(loop)
                 vol=get_loop_vol(loop)
                 
                 xmx=max( loop.axis[0, *] ) + 10.*max( loop.rad )
                 xmn=min( loop.axis[0, *] ) - 10.*max( loop.rad )
                 ymx=max( loop.axis[1, *] ) + 10.*max( loop.rad )
                 ymn=min( loop.axis[1, *] ) - 10.*max( loop.rad )
                 
                 done=0ul
                 
;    while not done do begin
             
                 signal= get_xr_emiss(loop,nt_brems, $
                                      E_RANGE=E_RANGE,NT_ONLY=1)
                 goto, skip_cheat
;Cheat.Averaging from both sides to make an initial image.
                 n_vols=n_elements(signal)
                 half_point=n_vols/2
                 if n_vols mod 2 ne 0 then begin
                     temp_signal_1=signal[0:half_point-1]
;            temp_signal_2=signal[half_point+1:*]
                     signal[half_point+1:*]=reverse(temp_signal_1)
;            signal[half_point+1:*]=signal[half_point+1:*]+temp_signal_1
;            signal[0:half_point-1]=signal[0:half_point-1]+temp_signal_2
;            signal[half_point]=signal[half_point]+signal[half_point]
;            signal=signal/2d0
                 endif else begin
                     temp_signal_1=signal[0:half_point-1]
;            temp_signal_2=signal[half_point:*]
;            signal[half_point:*]=signal[half_point:*]+temp_signal_1
;            signal[0:half_point-1]=signal[0:half_point-1]+temp_signal_2
;            signal=signal/2d0
                     signal[half_point:*]=reverse(temp_signal_1)
             endelse
             skip_cheat:
             
                                ;help, signal
             for zz=0, 10 do signal=smooth(signal, 5)
             
             xmx=max( loop.axis[0, *] ) + 10.*max( loop.rad )
             xmn=min( loop.axis[0, *] ) - 10.*max( loop.rad )
             ymx=max( loop.axis[1, *] ) + 10.*max( loop.rad )
             ymn=min( loop.axis[1, *] ) - 10.*max( loop.rad )
             
             
             loop=old_loop
             
             junk=where(nt_beam.state eq 'NT')
             if junk[0] eq -1 then nt_brems[*].n_photons[*]=0d0
             res_in=res
             fwhm_in=fwhm
             brems_map=mk_loop_hxr_map(loop,nt_brems , $
                                       e_range=e_range, $
                                       exp=1, XC=0,$
                                       YC=0,$ res=res_in, $
                                       fwhm=fwhm_in,$
                                       start_hour=start_hour, $
                                       start_minute=start_minute,$
                                       XMN_CM=XMN,XMX_CM=XMX,$
                                       YMN_CM=YMN,YMX_CM=YMX, $
                                       X_CENTER=X_CENTER, $
                                       Y_CENTER=Y_CENTER,$
                                       NT_ONLY=NT_ONLY,$
                                       THERM_ONLY=THERM_ONLY)
             
             brems_map.id= map_id
             brems_map.time=string(loop.state.time, format='(I05)')

             if size(map, /TYPE) EQ 0 then $
               map=brems_map else $
               map=concat_struct(map, brems_map)
         endfor                 ; l loop


         filename= map_dir+map_name
         help, filename
         save,map , file=filename
         
     endfor                     ; k loop
 endfor                         ; j loop
endfor                          ;i loop
 
end

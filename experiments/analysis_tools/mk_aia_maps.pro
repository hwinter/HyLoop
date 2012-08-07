;


pro mk_aia_maps, $
   EXPERIMENT_DIR=EXPERIMENT_DIR, $
   ALPHA_FOLDERS=ALPHA_FOLDERS, $
   GRID_FOLDERS=GRID_FOLDERS, $
   RUN_FOLDERS=RUN_FOLDERS, $
   MAP_ID=MAP_ID, $
   MAP_NAME=MAP_NAME,$
   A94=A94, A131=A131,$
   A171=A171, $
   A194=A194, A211=A211, A335=A335

print, 'Running mk_aia_maps.'
  
if size(MAP_ID, /TYPE) ne 7 then $
map_id='AIA 171'

if size(MAP_NAME, /TYPE) ne 7 then $
  map_name='AIA_171.map'

if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
  EXPERIMENT_DIR='./';getenv('DATA')+'/PATC/runs/flare_exp_05'

if size(ALPHA_FOLDERS, /TYPE) ne 7 then $
  ALPHA_FOLDERS='./';'alpha=-4'

if size(GRID_FOLDERS, /TYPE) ne 7 then $
  GRID_FOLDERS='./';'699_25'

if size(RUN_FOLDERS, /TYPE) ne 7 then $
  RUN_FOLDERS=['run_01',$
               'run_02',$
               'run_03',$
               'run_04',$
               'run_05']
run_folders='./'
set_plot, 'z'
;NT_ONLY=1
;THERM_ONLY=1
;E_RANGE=[3., 6.]
fwhm=2
res=0.6

n_folders=n_elements(ALPHA_FOLDERS)
n_grids=n_elements(GRID_FOLDERS)
n_runs=n_elements(RUN_FOLDERS)

delvarx, signal, map


;Rotate to have a limb loop
ay=0.05
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

             map_dir=Current_folder[0]+$
                     'maps/'          
             spawn, 'mkdir '+map_dir

             files=file_search(Current_folder ,$
                                'patc*.loop', $
                           COUNT=N_loops, $
                           /FULLY_QUALIFY_PATH)
             help, files
        ; files=files[1:*]
         
             for l=0ul, N_loops-1ul do begin
                 
                 restore, files[l], /verb
                old_loop=loop
                loops=loop
                loop.axis[0, *]=old_loop.axis[2, *]
                loop.axis[2, *]=old_loop.axis[0, *]
                old_loop=loop
                loop.axis=rot2#loop.axis
                
                
                vol=get_loop_vol(loop)
             
             xmx=max( loop.axis[0, *] ) + 10.*max( loop.rad )
             xmn=min( loop.axis[0, *] ) - 10.*max( loop.rad )
             ymx=max( loop.axis[1, *] ) + 10.*max( loop.rad )
             ymn=min( loop.axis[1, *] ) - 10.*max( loop.rad )
             
             done=0ul
             
             
             loop=old_loop
             
             junk=where(nt_beam.state eq 'NT')
             res_in=res
             fwhm_in=fwhm

             brems_map=mk_loop_aia_map(loop, $
                                       RES=RES,PIXEL=PIXEL, STR=STR,$
                                       A94=A94, A131=A131,$
                                       A171=A171, $
                                       A194=A194, A211=A211, A335=A335,$
                                       EXP=EXP,$
                                       CADENCE=CADENCE, $
                                       XSIZE=XSIZE, YSIZE=YSIZE,$
                                       XRANGE=XRANGE, YRANGE=YRANGE, $
                                       XC=XC, YC=YC,$
                                       dxp0=dxp0,dyp0=dyp0 ,$
                                       FREQ_OUT=FREQ_OUT,title_add=title_add,$
                                       NO_PSF=NO_PSF, FWHM=FWHM,PLOT=PLOT,$
                                       specfile=specfile,$
                                       NO_CHROMO=NO_CHROMO,$
                                       ROT1=ROT1, ROT2=ROT2, ROT3=ROT3, DATE=DATE,$
                                       START_HOUR=START_HOUR, START_MINUTE=START_MINUTE,$
                                       PAD=PAD,NO_PAD=NO_PAD , OVER=OVER,$
                                       ID=ID,$
                                       XMN_CM=XMN_CM,XMX_CM=XMX_CM,$
                                       YMN_CM=YMN_CM,YMX_CM=YMX_CM, $
                                       X_CENTER=X_CENTER, Y_CENTER=Y_CENTER)
             
             brems_map.id=map_id
             brems_map.time=string(loop.state.time, format='(I05)')

             if size(map, /TYPE) EQ 0 then $
               map=brems_map else $
               map=concat_struct(map, brems_map)
         endfor; l loop

         filename= map_dir+map_name
         help, filename
         save,map , file=filename
     endfor; k loop

 endfor                         ; j loop
 endfor;i loop
 
end

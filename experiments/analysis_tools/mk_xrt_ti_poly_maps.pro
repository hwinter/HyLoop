;.r fe01_mk_xrt_ti_poly

pro mk_xrt_ti_poly_maps, $
   EXPERIMENT_DIR=EXPERIMENT_DIR, $
   ALPHA_FOLDERS=ALPHA_FOLDERS, $
   GRID_FOLDERS=GRID_FOLDERS, $
   RUN_FOLDERS=RUN_FOLDERS, $
   MAP_ID=MAP_ID, $
   MAP_NAME=MAP_NAME,NO_PSF=NO_PSF, $
   XMX=XMX, XMN= XMN , YMX=YMX, YMN=YMN

  if size(MAP_ID, /TYPE) ne 7 then $
     map_id='XRT Ti Poly'

  if size(MAP_NAME, /TYPE) ne 7 then $
     map_name='ti_poly.map'


  if size(EXPERIMENT_DIR, /TYPE) ne 7 then $
     EXPERIMENT_DIR=getenv('DATA')+'/PATC/runs/flare_exp_05'

  if size(ALPHA_FOLDERS, /TYPE) ne 7 then $
     ALPHA_FOLDERS=''

  if size(GRID_FOLDERS, /TYPE) ne 7 then $
     GRID_FOLDERS=''

  if size(RUN_FOLDERS, /TYPE) ne 7 then $
     RUN_FOLDERS=''

  n_folders=n_elements(ALPHA_FOLDERS)
  n_grids=n_elements(GRID_FOLDERS)
  n_runs=n_elements(RUN_FOLDERS)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  filter_index=3
;        keyword_set(Al_poly)  : filter_index=1 
;        keyword_set(Al_mesh)  : filter_index=0
;        keyword_set(C_poly)   : filter_index=2
;        keyword_set(Ti_poly)  : filter_index=3
;        keyword_set(Be_thin)  : filter_index=4
;        keyword_set(Be_med)   : filter_index=5
;        keyword_set(Al_med)   : filter_index=6
;        keyword_set(Al_thick) : filter_index=7
;        keyword_set(Be_thick) : filter_index=8
;        keyword_set(Al_p_Al_m): filter_index=9
;        keyword_set(Al_p_Ti_p): filter_index=10
;        keyword_set(Al_p_Al_t): filter_index=11
;        keyword_set(Al_p_Be_t): filter_index=12
;        keyword_set(C_p_Ti_p) : filter_index=13
;        keyword_set(C_p_Al_t) : filter_index=14

  set_plot, 'z'

  delvarx, signal, map
  apex_yrange=[-20,10]

;Rotate to have a limb loop
  ay= 2.
  az=0.
  rot2=rotation(2,((!dpi*ay/180.)))
  rot3=rotation(3,((!dpi*az/180.)))

  fwhm=2.
  res=1.02
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
           
           Current_folder=strcompress(EXPERIMENT_DIR+'/'+ $
                                      ALPHA_FOLDERS[i]+'/'+ $
                                      GRID_FOLDERS[j]+'/'+$
                                      RUN_FOLDERS[k]+'/',$
                                      /remove)
           
           
           map_dir=Current_folder+'maps/'
           spawn, 'mkdir '+map_dir
           print, map_dir
           
           files=file_search(Current_folder,$
                             'patc*.loop', $
                             COUNT=N_loops, $
                             /FULLY_QUALIFY_PATH)
           if n_loops le 0 then goto, end_k_jump
           for l=0ul, N_loops-1ul do begin
              
              restore, files[l]
              old_loop=loop
              loops=loop
              loop.axis[0, *]=old_loop.axis[2, *]
              loop.axis[2, *]=old_loop.axis[0, *]
              old_loop=loop
              loop.axis=rot2#loop.axis
              
              em=get_loop_em(loops)
              vol=get_loop_vol(loop)
              
              if not keyword_set( xmx) then $
                 xmx=max( loop.axis[0, *] ) + 10.*max( loop.rad )
              if not keyword_set( xmn) then $
                 xmn=min( loop.axis[0, *] ) - 10.*max( loop.rad )
              if not keyword_set( ymx) then $
                 ymx=max( loop.axis[1, *] ) + 10.*max( loop.rad )
              if not keyword_set( ymn) then $
                 ymn=min( loop.axis[1, *] ) - 10.*max( loop.rad )
              
              
              loop=old_loop
              fwhm_in=fwhm
              res_in=res
              filter_INDEX_in=filter_INDEX
              temp_map=mk_loop_xrt_map(loop,$
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
                                       /no_chr,NO_PSF=NO_PSF)
              temp_map.id= map_id
              temp_map.time=string(loop.state.time, format='(I05)')
              temp_map.xc=0.0
              temp_map.yc=0.0
              
              if size(map, /TYPE) EQ 0 then $
                 map=temp_map else $
                    map=concat_struct(map, temp_map)
           endfor               ;  l loop
           
           
           filename= map_dir+map_name
           save,map , file=filename
        endfor                  ; k loop
        end_k_jump:
     endfor                     ; j loop
     
  endfor                        ; i loop


END                             ;of Main

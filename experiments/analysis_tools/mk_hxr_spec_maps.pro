;.r mk_hxr_spec_maps.pro
;This script is designed to make a photon map in hte HXR with each map
;element representing a different photon energy.  This program will do
;it for each run listed. 

map_name='photon_map_test.map'
print, 'Running mk_hxr_spec_maps'

set_plot, 'z'
;NT_ONLY=1
;THERM_ONLY=1
Photon_keVs=dindgen(100)+1
fwhm=1
res=1;top_directory=getenv('DATA')+'/HyLoop/runs/flare_exp_05/alpha=-4/699_25/pa_alpha=-4_699_25_00003.pro'
top_directory='/data/jannah/hwinter/Data//HyLoop/runs/flare_exp_05/alpha=-4/699_25/'
l=3                             ;Index of the file to restore.  We are only doing one at a time
;
n_runs=99
RUN_FOLDERS='run_'+strcompress(string(indgen(n_runs)+1, FORMAT='(I02)'), /REMOVE)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This is my attempt to stabilize the image as we zoom in.
arcsec_per_cm=1./(7.2d+7)
;Padd some areas around the flare loop
PAD=max(res)*720d*1d5*2D0*3D0

;Rotate to have a limb loop
ay=0.05
az=0.
rot2=rotation(2,((!dpi*ay/180.)))
rot3=rotation(3,((!dpi*az/180.)))


for i=0ul,  n_runs-1ul do begin
   
   delvarx, signal, map

   Current_folder=top_directory+RUN_FOLDERS[i]+'/'
   
   print, 'Now on folder '+Current_folder
   
   map_dir=Current_folder[0]+$
           'maps/'      
   
   spawn, 'mkdir '+map_dir
   
   files=file_search(Current_folder ,$
                     'patc*.loop', $
                     COUNT=N_loops, $
                     /FULLY_QUALIFY_PATH)
   
   restore, files[l]
   old_loop=loop
   loop.axis[0, *]=old_loop.axis[2, *]
   loop.axis[2, *]=old_loop.axis[0, *]
   old_loop=loop
   loop.axis=rot2#loop.axis
                                ;loop.axis=rot2#loop.axis
   
   em=get_loop_em(loop)
   vol=get_loop_vol(loop)
   
   xmx=max( loop.axis[0, *] ) + 10.*max( loop.rad )
   xmn=min( loop.axis[0, *] ) - 10.*max( loop.rad )
   ymx=max( loop.axis[1, *] ) + 10.*max( loop.rad )
   ymn=min( loop.axis[1, *] ) - 10.*max( loop.rad )
   
   done=0ul
   for j=0ul, n_elements(Photon_keVs)-1ul do begin
      E_RANGE=[Photon_keVs[j], Photon_keVs[j]+1]
      
      signal= get_xr_emiss(loop,nt_brems, $
                           E_RANGE=E_RANGE)
      
                                ;help, signal
      for zz=0, 10 do signal=smooth(signal, 3)
      
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
                                Y_CENTER=Y_CENTER);,$
        ;                        NT_ONLY=NT_ONLY,$
        ;                        THERM_ONLY=THERM_ONLY)
      
      brems_map.id=strcompress(string(Photon_keVs[j]), /remove)+' keV'
      brems_map.time=string(loop.state.time, format='(I05)')
            
      if size(map, /TYPE) EQ 0 then $
         map=brems_map else map=concat_struct(map, brems_map)
   endfor                       ;j loop
   
   filename= map_dir+map_name
   help, filename
   save,map , file=filename
endfor                          ; i loop
end

;+
; NAME:
;	
;
; PURPOSE:
;	
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:	
;-

function mk_sarkar_walsh_heat_mono_loop, loop, flare_file=flare_file, save_file=save_file,$
                                         nano_fwhm=nano_fwhm, FRACTION_PART=FRACTION_PART

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check Keywords
  if not keyword_set(flare_file) then flare_file='s_w_nanoflare.sav'
  if not keyword_set(save_file) then save_file='s_w_heat_function.sav'
  if not keyword_set(FRACTION_PART) then FRACTION_PART=0
  if not keyword_set(nano_fwhm) then nano_fwhm=2d7 ;cm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  restore, flare_file, verbose=1

  e_h=dblarr(n_elements(loop.e_h), duration)
  index=get_loop_coronal_cells(loop)
  n_coronal_cells=n_elements(index)

  delta_s=loop.s_alt[index[n_coronal_cells-1]]-loop.s_alt[index[0]]

  current_time=0

  for iii=0, duration -1 do begin

     event_ind=where(nano_flares.start_time eq iii)
     
     if event_ind[0] ne -1 then begin
        for jjj=0, n_elements(event_ind)-1 do begin
           
;Position
           nano_s=loop.s_alt[index[0]]+nano_flares[event_ind[jjj]].relative_position*delta_s
           
           e_h_temp =get_nfe_gauss_dist(loop,nano_s , $
                                        nano_flares[event_ind[jjj]].energy*(1.0-FRACTION_PART),$
                                        nano_fwhm) ;[ergs cm^-3 !s^-1]
           
           if iii+nano_flares[event_ind[jjj]].duration le duration-1 then begin
              n_dims=size(e_h[*,iii: iii+nano_flares[event_ind[jjj]].duration])
              e_h_temp=rebin(e_h_temp,n_dims[1], n_dims[2])
              e_h[*,iii: iii+nano_flares[event_ind[jjj]].duration]+=e_h_temp 
           endif else begin
              n_dims=size(e_h[*,iii:*])
              e_h_temp=rebin(e_h_temp,n_dims[1], n_dims[2])
              e_h[*,iii:*]+=e_h_temp
           endelse
        endfor                  ;jjj
     endif
     
     
  endfor                        ;iii loop


  if keyword_set(SAVE_FILE) then  begin
     if type(SAVE_FILE) ne 7 then $
        save_file='s_w_nanoflare_e_h.sav'
     save , e_h, file=save_File
  endif
  
  return, e_h
END

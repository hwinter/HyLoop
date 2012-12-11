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


function get_sarkar_walsh_heat, LOOP, time, dt, nt_beam, nt_brems,$
   PATC_heating_rate, extra_flux, DELTA_MOMENTUM, flux, n_e_change, $
   TEST=TEST, ALL_THERM=ALL_THERM
  
  sz=size(!e_h_array)
  e_h_times=dblarr(sz[2])
  index=where(abs(time-e_h_times) eq min (abs(time-e_h_times)))
  
  e_h_temp=reform(!e_h_array[*, index[0]])


  return, e_h_temp
END

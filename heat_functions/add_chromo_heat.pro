;+
; NAME:
;	add_chromo_heat.pro
;
; PURPOSE:
;      Based on either a previously set system variable, !chromo_e_h,
;      or on the amount of heating necessary to keep the temperature
;      of the current chromospheric state at a temperature, of T0,
;      add a chromospheric heating to a heating array
;
; CATEGORY:
;      Heat_function	
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
; 	Written by:HDWII 2012-07-16

function add_chromo_heat, LOOP,e_h, $
                          ;Radloss settings
                          
                          SET_SYSV=SET_SYSV, SYSV_NAME=SYSV_NAME,$
                          UPDATE_LOOP=UPDATE_LOOP

version=0.1
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check input parameters
if size(e_h, /TYPE) eq 0 then e_h=LOOP.e_h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check optional keywords
if not keyword_set(SYSV_NAME) then SYSV_NAME_in='!chromo_e_h' $
else begin
   if  STRPOS( SYSV_NAME, '!') ne 0 then SYSV_NAME='!'+SYSV_NAME
   SYSV_NAME_in=SYSV_NAME
endelse


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get the indices of the chromosperic cells.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Case statement
Case 1 of
   keyword_set(SET_SYSV): begin
      defsysv, , [[e_h1],[e_h2]]
   end


abs(shrec_radloss(n_e_add[1:*],T0+dblarr(N_DEPTH_s-1)))


if keyword_set(UPDATE_LOOP) then loop.e_h=e_h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Return the heating function array with chromo heat added
END                             ; Of main

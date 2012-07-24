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
                          
                          SET_SYSV=SET_SYSV,$
                          UPDATE_LOOP=UPDATE_LOOP, $
                          ZERO_CORONA=ZERO_CORONA

  version=0.2
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check input parameters
  if size(e_h, /TYPE) eq 0 then e_h_in=LOOP[0].e_h else e_h_in=e_h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check optional keywords
  if keyword_set(ZERO_CORONA) then e_h_in*=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get the indices of the chromosperic cells.
  chrom_ind=get_loop_chromo_cells(loop, count=test_chromo_count)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Case statement
  temp_array=!shrec_T0+dblarr(test_chromo_count)
  if keyword_set(SET_SYSV) then begin
     defsysv, '!chromo_e_h', $
              [[abs(shrec_radloss(loop.state.n_e[chrom_ind[1:*,0]],$
                                  temp_array))],$
               [abs(shrec_radloss(loop.state.n_e[chrom_ind[0:(test_chromo_count/2)-2,1]],$
                                  temp_array))]]
     
        
     end
  
  e_h_in[0:Max(chrom_ind[*,0])-1]=!chromo_e_h[*,0]
  e_h_in[chrom_ind[0:(test_chromo_count/2)-2,1]]=!chromo_e_h[*,1]

  if keyword_set(UPDATE_LOOP) then loop.e_h=e_h_in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Return the heating function array with chromospheric heat added.
return, e_h_in
END                             ; Of main

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

function mk_sarkar_walsh_heat, loop



if not keyword_set(FLUX) then flux=4d5
if not keyword_set(duration) then duration=1.725e4
if not keyword_set(E_RANGE) then e_range=[1e23, 5e24]
if not keyword_set(TAU_RANGE) then tar_range=[50.,150.]
if not keyword_set(n_strands) then n_strands=1ul

e_h=dblarr(n_elements(loop.e_h), duration,n_strands)
index=get_loop_coronal_cells(loop)

For iii=0ul, duration-1 do begin
   loop_flux=total(e_h[*,iii,*])/loop.l
   
;For each itieration of the while loop add a nanoflare until the total
;flux for the global loop reached.
   while loop_flux lt FLUX do begin
      ;Position
      ;Energy
      ;Spread it out
      ;Duration

      loop_flux=total(e_h[*,iii,*])/loop.l
   endwhile ; loop_flux lt FLUX 
   


endfor ;iii loop




END









end

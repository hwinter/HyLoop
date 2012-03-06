
;+
; NAME:
;	compile_loop.pro
;
; PURPOSE:
;	To take many loop structures from many save files 
;          with different grid spacings and re-interpolate
;          them on a standard grid.
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

function compile_loop,loops, LOOP_TEMPLATE=LOOP_TEMPLATE, $
  S_GRID=S_GRID



if ((size(loop_template,/TYPE) eq 0) and (size(S_GRID,/TYPE) eq 0)) then begin
    Print, 'interpolate_loop.pro requires either an input loop' $
           +' structure or a grid to map upon.' 
    new_loops=-1
    goto, end_jump
endif


if not keyword_set(S_GRID) then S_GRID=loop_template.s
new_s_alt=msu_get_s_alt(S_GRID)    
num_new_s_alt=n_elements(new_s_alt)

new_loops=interpolate_loop( loops[0], loop_template,S_GRID=S_GRID)

N_LOOPS=n_elements(loops)
if N_LOOPS gt 1 then begin
    for i=1ul, N_LOOPS-1ul do $
      new_loops=[new_loops,$
               interpolate_loop( loops[i], loop_template,S_GRID=S_GRID)]

    
endif
end_jump:
return, new_loops
END;Of main




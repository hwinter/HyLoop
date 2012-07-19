;+
; NAME:
;	get_loop_chromo_cells.pro
;
; PURPOSE:
;	Given a loop structure with an N_depth tag, return an N_depth
;	array containing the indices of the volume elements in the
;	chromospheric portion of the loop. 
;
; CATEGORY:
;	HyLoop, loop, info_tools
;
; CALLING SEQUENCE:
;	coronal_ind=get_loop_chromo_cells(LOOP)
;
; INPUTS:
;	Loop structure
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	COUNT: Returns a variable with the number of coronal cells
;       SURF: Return the indices on the surface grid instead of the
;       default volume grid. 
;
; OUTPUTS:
;	An [N_depth, 2] array containing the indices of the
;	chromospheric portion of the loop on the volume array, or on
;	the surface array if the SURF keyword is set. The [N_depth, 0]
;	array is the "left" (origin-ward) chromospheric end. The
;	[N_depth, 1] array is the "right" (end-ward) chromospheric end.
;
; OPTIONAL OUTPUTS:
;
;
; COMMON BLOCKS:
;	None 
;
; SIDE EFFECTS:
;	None
;
; RESTRICTIONS:
;	Loop array must have the n_depth tag properly set.
;
; PROCEDURE:	
;
; EXAMPLE:
;	coronal_ind=get_loop_chromo_cells(LOOP)
;
; MODIFICATION HISTORY:
; 	Written by:Henry "Trae" D. Winter III 2012-07-19

function get_loop_chromo_cells, loop, COUNT=COUNT, SURF=SURF



  version=0.1
;-
  case 1 of
     keyword_set(SURF):begin

     end
     else: begin
        n_cells=n_elements(loop.s_alt)
        count=(loop.n_depth)-1
        
        chromo_ind=[[1+ULINDGEN(count)], [n_cells-loop.n_depth+ULINDGEN(count)]]

        end

  endcase

     
  return, chromo_ind
  
 

END

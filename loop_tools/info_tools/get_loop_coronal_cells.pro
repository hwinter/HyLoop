;+
; NAME:
;	get_loop_coronal_cells.pro
;
; PURPOSE:
;	Given a loop structure with an N_depth tag, return an N_depth
;	array containing the indices of the volume elements in the
;	coronal portion of the loop. 
;
; CATEGORY:
;	HyLoop, loop, info_tools
;
; CALLING SEQUENCE:
;	coronal_ind=get_loop_coronal_cells(LOOP)
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
;	An N_depth array containing the indices of the coronal
;	 portion of the loop on the volume array, or on the surface
;	 array if the SURF keyword is set.
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
;	coronal_ind=get_loop_coronal_cells(LOOP)
;
; MODIFICATION HISTORY:
; 	Written by:Henry "Trae" D. Winter III 2012-07-16
;       2012-07-19 (HDWIII) Corrected typos in header.


function get_loop_coronal_cells, loop, COUNT=COUNT, SURF=SURF

  version=0.1
;-
  case 1 of
     keyword_set(SURF):begin

     end
     loop.n_depth le 1:begin
        n_cells=n_elements(loop.s_alt)-2
        coronal_ind=1 + ULINDGEN(n_cells)
     end
     
     else: begin
        n_cells=n_elements(loop.s_alt)
        count=n_cells-(2*loop.n_depth)+2
        
        coronal_ind=loop.n_depth-1 + ULINDGEN(count)

        end

  endcase

     
  return, coronal_ind
  


END                             ;OF MAIN

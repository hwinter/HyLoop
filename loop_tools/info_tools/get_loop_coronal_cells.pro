;+
; NAME:
;	get_loop_coronal_cells.pro
;
; PURPOSE:
;	Given a loop structure with an N_depth tag, return an N_depth
;	array containing the indices of the 
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
;       SURF: Return the indices on the volume grid instead of the
;       default volume grid. 
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	Temperature along the loop (T)
;
; COMMON BLOCKS:
;	 An N_depth array containing the indices of the coronal
;	 portion of the loop on the volume array, or on the surface
;	 array if the SURF keyword is set.
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

version=0.1
;-

function get_loop_coronal_cells, loop, COUNT=COUNT, SURF=SURF



END                             ;OF MAIN

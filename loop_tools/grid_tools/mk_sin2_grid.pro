;+
; NAME:
;	REGRID_EXP
;
; PURPOSE:
;	Regrid a loop structure based on Characteristic Length Scales
;
; CATEGORY:
;	Loop tools
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
;	The tags of the loop structure will have a 
;       different number of elements than before.
;
; RESTRICTIONS:
;    Not fully vectorized
;    No exlicit effort is made here to conserve mass, momentum or energy!  
;    Use at your own risk.  However, it performs well in tests
	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:
;          Replaced all of the spline commands with interpol.  Spline,
;           as I should have remembered, can often give wild answers where
;           the gradients are steep.  A linear interpolation is good enough
;           and "should" always yields reasonable answers.
;-


function mk_sin2_grid, n_cells, length, min_step

;redistribute grid by picking minimum step 
;
;Set so that () is for functions and [] is for array indices  
compile_opt strictarr
old_except=!except
!except=2

n_surf=long(n_cells-1)

array=(sin(!dpi*dindgen(n_surf)/(n_surf-1)))^2
array=length*array/total(array)

s=total(array, /CUMULATIVE)



return, s
END




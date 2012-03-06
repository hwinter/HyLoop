;+
; NAME:
;	REGRID_EXP
;
; PURPOSE:
;	
;
; CATEGORY:
;	MSU Loop tools
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
;         
;-

;Needs a ton of work!
function mk_gauss_grid, n_cells, length, min_step, DS=DS, $
  SIGMA_FACTOR=SIGMA_FACTOR
if size(min_step, /TYPE) eq 0 then min_step=1d5 ;1 km
;
;Set so that () is for functions and [] is for array indices  
compile_opt strictarr
old_except=!except
!except=2
;
if not keyword_set(SIGMA_FACTOR) then SIGMA_FACTOR=3d0
n_surf=long(n_cells-2)

x=-100+200*dindgen(n_surf)/(n_surf-1)
sigma=100./sigma_factor
;sigma=1d-1

ds=(1./(sigma*sqrt(2.*!dpi)))* $
   exp(-1.*(x^2.)/(2.*sigma*sigma))
n=n_elements(ds)
;Force symmetry about the apex.
even_odd_test = n mod 2
case 1 of 
    (even_odd_test eq 1):begin
        ds[0:(n/2)-1ul]=$
          reverse(ds[(n/2)+1ul:*])
        
    end
    (even_odd_test eq 0):begin
        ds[0:(n/2)-1ul]=$
          reverse(ds[(n/2):*])
        
    end
endcase


ds=length*(ds/total(ds))
ds_old=ds
ds >=min_step

ds=length*(ds/total(ds))

s=total(ds, /CUMULATIVE)
s=[0,s]
max_s=max(s)
s=length*s/max_s


;plot, ds
;stop
!except=old_except
return, s
END




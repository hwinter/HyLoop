;+
; NAME: practice_distr.pro
;	
;
; PURPOSE: Given a loop file, creates and plots three distributions
; (distr1, distr2, and distr3) of locations along the loop axis, s. distr1
; has a higher probability density near the loop footprints, distr2 has a
; uniform density, and distr3 has a higher density near the loop apex.
;	
;
; CATEGORY:
;	
;
; CALLING SEQUENCE: practice_distr, "file"
;	
;
; INPUTS: file (string)
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS: Histogram plots of distr1, distr2, and distr3.
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
; 	Written by: Chester Curme
;-


pro practice_distr, file

restore, file

distr1 = (mk_distro6(-10)+1)*loop.s[n_elements(loop.s)-1]
distr2 = (mk_distro6(0)+1)*loop.s[n_elements(loop.s)-1]
distr3 = (mk_distro6(10)+1)*loop.s[n_elements(loop.s)-1]

!p.multi = [0,1,3]

plot_histo, distr1, XTITLE="s", YTITLE="# Particles", TITLE="distr1"
plot_histo, distr2, XTITLE="s", YTITLE="# Particles", TITLE="distr2"
plot_histo, distr3, XTITLE="s", YTITLE="# Particles", TITLE="distr3"

END

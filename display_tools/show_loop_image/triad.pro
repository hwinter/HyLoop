;+
; NAME:
;      triad
; PURPOSE
;      given a single vector e0 return a triad of
;      ortho-normal vectors
; USAGE:
;      triad,e0,e1,e2
;-


FUNCTION cross_pro, a, b

c = fltarr(3)

c(0) = a(1)*b(2) - a(2)*b(1)
c(1) = a(2)*b(0) - a(0)*b(2)
c(2) = a(0)*b(1) - a(1)*b(0) 

return,c
end

PRO triad, e0, e1, e2

normalize_3dvec, e0

mincomp = min(abs(e0),imin)
temp_vec = [0.0,0.0,0.0]
temp_vec(imin) = 1.0

e1 = cross_pro(temp_vec, e0)
normalize_3dvec, e1

e2 = cross_pro(e0,e1)
normalize_3dvec, e2

return 
end

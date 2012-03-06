;+
; NAME:
;      normalize_3dvec
; PURPOSE
;      normalize a 3d vector in place
; USAGE:
;      normalize_3dvec, v
;-

PRO normalize_3dvec, v

vmag =  sqrt( total( v^2 ) )
v =  v/vmag
  
return
end

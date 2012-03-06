;+
; NAME:
;      fl_view_xform
; PURPOSE
;      given a field line perfom the specified viewing transformation.
;      the field line is returned transformed.
; USAGE:
;      fl_view_xform, fl, view
;-
PRO fl_view_xform, fl, view

n = n_elements( fl(0, * ) )
FOR j=0, n-1 DO BEGIN
  v = ( view.mat ) # [ fl(0,j), fl(1,j), fl(2,j) ] + view.disp
  fl(0,j) = v(0)
  fl(1,j) = v(1)
  fl(2,j) = v(2)
ENDFOR

return
end

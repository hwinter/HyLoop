
;+
; NAME:
;      show_loop_skeleton
; PURPOSE
;      given a field line and a set of radii, draw a skeleton
;      consisting of rings around each point in the field line
; USAGE:
;      show_loop_skeleton, fl, rad
; KEYWORDS:
;      view = view: will transform according to transformation in
;             structure view.
;      threed: show field line in 3d
;      skip=skip: if set then only every skip ribs are rendered. [1]
;Restrictions: Requires FSC_color
;
;2012-01-20  HDW; Changed the colors to
;the FSC_color system.  That will break some code. Also added a color
;keyword to the c_struct structure
;-

PRO show_loop_skeleton, fl, rad, threed=threed, view=view, $
                        skip=skip, CIRC=CIRC, C_STRUCT=C_STRUCT,$
                        LINESTYLE=LINESTYLE,NO_PLOT=NO_PLOT,C_COLOR=C_COLOR, $
                        C_THICK=C_THICK

;if !d.name eq 'PS' then thick_factor=4 else  thick_factor=1
IF( NOT keyword_set(skip) ) THEN skip = 1
IF( NOT keyword_set(nth) ) THEN nth = 41
IF( NOT keyword_set(LINESTYLE)) THEN LINESTYLE=0
IF NOT keyword_set(C_COLOR) THEN begin
   if !p.background ne 0 then C_COLOR_in='black' $
   else  C_COLOR_in='white'
endif else C_COLOR_in=C_COLOR
;axis, zaxis=-1, xaxis=-1, yaxis=-1
nfl =  n_elements( fl(0, *) )
;Create an array that will define a 2d circle in a 3d plane
; with nth points on its rim
circ = fltarr( 3,  nth )
th =  2*!pi*findgen(nth)/float(nth-1)

r =  rad
IF( n_elements(rad) EQ 1 ) THEN r =  replicate( rad, nfl )

FOR i=0, nfl-1, skip DO BEGIN
    IF( i EQ 0 ) THEN BEGIN
        dx = reform( fl(*, 1) - fl(*, 0),  3 )
    ENDIF ELSE IF( i EQ nfl-1 ) THEN BEGIN 
        dx = reform( fl(*, nfl-1) - fl(*, nfl-2),  3 )
    ENDIF ELSE BEGIN
        dx =  reform( fl(*, i+1) - fl(*, i-1),  3 )
    ENDELSE

  ; the elements of the skeleton: circles
    triad, dx, e1, e2
    circ(0, *) = fl(0, i) + r(i)*( cos(th)*e1(0) + sin(th)*e2(0) )
    circ(1, *) = fl(1, i) + r(i)*( cos(th)*e1(1) + sin(th)*e2(1) )
    circ(2, *) = fl(2, i) + r(i)*( cos(th)*e1(2) + sin(th)*e2(2) )
    if not keyword_set(NO_PLOT) then begin
        IF( n_elements( view ) GT 0 ) THEN fl_view_xform, circ, view
        IF( keyword_set( threed ) ) THEN $
          plots, circ(0, *), circ(1, *), circ(2, *), $
                 /t3d ,LINESTYLE=LINESTYLE,COLOR=fsc_color(C_COLOR_in),$
                 THICK=C_THICK $
          ELSE BEGIN
            oplot, circ(0, *), circ(1, *),LINESTYLE=LINESTYLE,$
                   COLOR=fsc_color(C_COLOR_in), THICK=C_THICK
        ENDELSE
    endif
    if size(c_struct, /TYPE) ne 8 then  $
      c_struct={circ:circ, color:C_COLOR_in} else $
      c_struct=concat_struct(c_struct, {circ:circ, color:C_COLOR_in})
ENDFOR

return
end

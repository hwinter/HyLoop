;+
; NAME:
;      path_length
;
; PURPOSE:
;      Returns the distance of intersection between a line of sight 
;      parallel to the z-axis and a cylindrical object lying 
;      somewhere in 3-D cartesian space    
;     
; USAGE:
;      path_length(p1, p2, r, n1, n2, xp, yp)
;
; ARGUMENTS:
;      p1, p2 - vectors indicating the two points (the ends) on the axis 
;               of the cylindrical object
;      r - the radius of the cylinder
;      n1, n2 - normal vectors corresponding to p1 and p2 which indicate the 
;               orientation of the ends of the cylinder
;      xp, yp - the coordinates of the line of sight
;
; HISTORY:
;      Jeremy Nelson 9/99
;   
;      10/6/99-jln, modified for any cylindrical object, 
;                   ends need not be parallel
;      10/14/99-jln, completely re-written with the use of between_planes


FUNCTION path_length, p1, p2, r, n1, n2, xp, yp

z = FLTARR(4)

z_cyl = cyl_intsct(p1, p2, r, xp, yp)


IF ( (N_ELEMENTS(z_cyl) EQ 1) AND z_cyl(0) EQ -1.0 ) THEN RETURN, 0.0 ;line of sight misses the cylinder    

;cylinder intersections
z(0) = z_cyl(0)
z(1) = z_cyl(1)


;check to see if the line of sight intersects the cylinder between
;the two planes that define the ends...
;between_planes returns 1 if so, 0 if not

chk_bet_0 = between_planes(p1, p2, n1, n2, xp, yp, z(0))  ;check z(0)
chk_bet_1 = between_planes(p1, p2, n1, n2, xp, yp, z(1))  ;check z(1)

IF ( ( chk_bet_0 EQ 1 ) AND ( chk_bet_1 EQ 1 ) ) THEN RETURN, ( z(0) - z(1) )


;special cases, one or both of the planes are parallel to the line of sight:

;both:
IF ( n1(2) EQ 0.0 ) AND ( n2(2) EQ 0.0 ) THEN BEGIN
 IF ( ( chk_bet_0 EQ 1.0 ) AND ( chk_bet_1 EQ 1.0 ) ) THEN RETURN, ( z(0) - z(1) ) ELSE RETURN, 0.0 
ENDIF

;one or the other:
IF ( n1(2) EQ 0.0 ) THEN BEGIN
 z(3) = plane_intsct(p2, n2, xp, yp)
 IF ( ( chk_bet_0 EQ 1 ) AND ( chk_bet_1 EQ 0 ) ) THEN RETURN, ( z(0) - z(3) )
 IF ( ( chk_bet_0 EQ 0 ) AND ( chk_bet_1 EQ 1 ) ) THEN RETURN, ( z(3) - z(1) )
ENDIF

IF ( n2(2) EQ 0.0 ) THEN BEGIN
 z(2) = plane_intsct(p1, n1, xp, yp)
 IF ( ( chk_bet_0 EQ 1 ) AND ( chk_bet_1 EQ 0 ) ) THEN RETURN, ( z(0) - z(2) )
 IF ( ( chk_bet_0 EQ 0 ) AND ( chk_bet_1 EQ 1 ) ) THEN RETURN, ( z(2) - z(1) )
ENDIF


;plane intersections
z(2) = plane_intsct(p1, n1, xp, yp)
z(3) = plane_intsct(p2, n2, xp, yp)


zphigh = MAX([z(2),z(3)])
zplow = MIN([z(2),z(3)])


;in case the cylinder is parallel to the z-axis:
IF ( ( N_ELEMENTS(z_cyl) EQ 1.0 ) AND ( z_cyl(0) EQ -2.0 ) ) THEN RETURN, (zphigh - zplow)


IF ( ( chk_bet_0 EQ 0 ) AND ( chk_bet_1 EQ 0 ) ) THEN BEGIN	 
 IF ( ( z(0) GE zphigh ) AND ( zplow GE z(1) ) ) THEN RETURN, ( zphigh - zplow ) ELSE RETURN, 0.0
ENDIF

 
;for the program to make it to this point, the following must be true:
;a) either z(0) or z(1) is inside the planes (not both)
;b) neither of the planes are parallel to the line of sight

IF ( ( chk_bet_0 EQ 1 ) AND ( chk_bet_1 EQ 0 ) ) THEN BEGIN
 IF ( zplow EQ z(1) ) THEN RETURN, ( z(0) - z(1) )
 IF ( zphigh GE z(0) ) THEN RETURN, ( z(0) - zplow )
 IF ( z(0) GT zphigh ) THEN RETURN, ( z(0) - zphigh )
ENDIF

IF ( ( chk_bet_0 EQ 0 ) AND ( chk_bet_1 EQ 1 ) ) THEN BEGIN
 IF ( zphigh EQ z(0) ) THEN RETURN, ( z(0) - z(1) )
 IF ( zphigh GT z(0) ) THEN RETURN, ( zplow - z(1) )
 IF ( z(0) GT zphigh ) THEN RETURN, ( zphigh - z(1) ) 
ENDIF


print, 'trouble'
print, chk_bet_0
print, chk_bet_1
print, z
;print, p1 
;print, p2
;print, r
;print, n1
;print, n2
;print, xp
;print, yp



END








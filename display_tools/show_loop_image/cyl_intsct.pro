
; Returns a 2-element array containing the values of z where a line
; of sight intersects the cylinder.
; (or returns -1 if there is no intersection)
; p1, p2 are vectors indicating the ends of the cylinder
; r is the radius of the cylinder
; xpi, ypi designate the line of sight

FUNCTION cyl_intsct, p1, p2, r, xpi, ypi

xp = xpi-p1(0)
yp = ypi-p1(1)

e0i = p2 - p1                  ; define a vector along the axis of the cylinder
e0 = e0i/sqrt(total(e0i^2))    ; normalization


; The equation for the z-values of the intersection between the cylinder
; and the line of sight is a quadratic,
; a,b, and c are the standard coefficients in the equation.

a = 1 - (e0(2))^2 
b = -(xp*e0(0)*e0(2) + yp*e0(1)*e0(2) + xp*e0(2)*e0(0) + yp*e0(1)*e0(2))
c = (xp^2)*(1-e0(0)^2) + (yp^2)*(1-e0(1)^2) - 2*xp*yp*e0(0)*e0(1) - r^2


IF (a EQ 0.0) THEN RETURN, -2.0   ; the axis of the cylinder is parallel 
				   ; to the z-axis in this case

discrim = b^2 - 4*a*c
 
IF (discrim LT 0.0) THEN RETURN, -1.0 

z_top = (-b + sqrt(discrim))/(2.0 * a) + p1(2)
z_bottom = (-b - sqrt(discrim))/(2.0 * a) + p1(2)

RETURN, [z_top, z_bottom]

END




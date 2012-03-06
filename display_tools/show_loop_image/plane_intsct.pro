; Returns the z-value of the intersection between a plane
; defined by a normal vector (norm) and a line parallel to the 
; z-axis defined by xp and yp. 

;10/14/99, jln, commented out conditional statement,
;path_length was re-written so that planes that are parallel
;to the line of sight are dealt with before the call to
;plane_intsct.


FUNCTION plane_intsct, p, norm, xp, yp


;IF (norm(2) EQ 0) THEN RETURN, -1  ; if the z-component of norm is zero,
				   ; the axis of the cylinder is perpendicular
				   ; to the z-axis, and therefore any line
 				   ; parallel to the z-axis does not intersect
				   ; the ends of the cylinder  

z = p(2) - (norm(0)*(xp-p(0)) + norm(1)*(yp-p(1)))/norm(2)

RETURN, z

END
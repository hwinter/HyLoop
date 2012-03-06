
FUNCTION between_planes, p1, p2, n1, n2, x, y, z 

;use negative n2 since it points "into" the relevant segment
negn2 = -(n2)

intsct = [x,y,z] 	;designates cylinder intersection

a1 = intsct - p1
a2 = intsct - p2

a1_dot_n1 = a1(0)*n1(0) + a1(1)*n1(1) + a1(2)*n1(2)
a2_dot_negn2 = a2(0)*negn2(0) + a2(1)*negn2(1) + a2(2)*negn2(2)

result = 0

;condition for being "inside":
IF ( ( a1_dot_n1 GT 0 ) AND ( a2_dot_negn2 GT 0 ) ) THEN result = 1 
		 
RETURN, result

END









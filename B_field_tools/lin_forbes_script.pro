;+
; NAME:
;	lin_forbes_script
;
; PURPOSE:
;	
;
; CATEGORY:
;	
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
; 	Written by:	Henry (Trae) deG.Winter III 2010/07/13
;-

N=1001
resolve_routine, 'lin_forbes_field' , /IS_FUNCTION
genx_file='/home/hwinter/Desktop/Flare_input000.genx'
restgen, file=genx_file, struct=struct

p=struct.savegen0.P_VALUE
q=struct.savegen0.Q_VALUE
lambda=struct.savegen0.LAMBDA_CRITICAL
h=struct.savegen0.H_VALUE
A_0=struct.savegen0.A0_VALUE


x=-1.0*h+(4.0*h*dindgen(N)/(N-1))
y=h*dindgen(N)/(N-1)

b=lin_forbes_field( x,y,p,q,lambda,h, $
                           A_0=A_0,$
                           B_X=B_X, B_Y=B_Y, B_TOTAL=B_TOTAL)

end


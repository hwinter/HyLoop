;+
; NAME:
;	bungey_priest_field01
;
; PURPOSE:
;	To calculate the magnetic field as described by Bungey,
;	T.N. and Priest, E.R. 1995, A&A, 293,215-224
;       Same as bungey_priest_field but only does one point at a time
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
;	Currently onle does the potential field case.
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:	Henry (Trae) deG.Winter III 5/16/2006
;-


pro bungey_priest_field01, x,y,f,B_x, B_y,$
                         A=A,B_DRC=B_DRC,C=C,D=D,B0=B0, $
                         N_ELEM=N_ELEM, SCREEN=SCREEN, $
                         RANGE=RANGE,B_TOTAL=B_TOTAL
 ;Magnetic field [Gauss]
if not Keyword_set(B0) then B0=1D
if not Keyword_set(N_ELEM) then n_elem=50l
;min/max value of a symmetric 
if not Keyword_set(RANGE) then range=2d
;Positive real constant that moves the positions of the field points
if not Keyword_set(B_DRC) then b=0.5d else b= B_DRC

;Half length of the current sheet
if not Keyword_set(A) then a=1d
a_2=a*a

;Positive real constants 
if not Keyword_set(C) then c=0d
if not Keyword_set(D) then d=0d
;Components of the magnetic field [Gauss]
B_x=0d0
B_y=B_x
B_TOTAL=B_x

Z=0d0
df_dz=Z
f=z
Z_2=Z
sq_rt_z2_a2=z
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the complex variable Z as a function of x and y.
Z=complex(x,y)
Z_2=(Z*(Z))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This method can take the wrong branch cut and leave a discontinuity
;on the imaginary axis,
;        sq_rt_z2_a2=(Z_2-a_2)^(0.5d)
;Use this method, suggested by the lovely and talented Dr. Dana
;Longcope instead. (He may have done this once or twice)
sq_rt_z2_a2=sqrt(z-a)*sqrt(z+a)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Flux function from Bungey & Priest 1995 eq. 21
f=B0* $
  ( a_2*b*$
    alog((Z+sq_rt_z2_a2)/a) $
    +(2*a*c*sq_rt_z2_a2) $
    -(complex(0d,2*a*d)*Z) $
    -(.5d*Z*sq_rt_z2_a2))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Derivative of flux function from Bungey & Priest 1995 eq. 22
df_dz=B0* $
      ((($
         (b*a_2)+ $
         (2d*a*c*Z) $
         - z_2 $
         +(.5d*a_2))/$
         sq_rt_z2_a2)+ $
        complex(0d,2*a*d))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The magnetic field as defined by Bungey & Priest 1995 eq. 22         
B_y=real_part(-1d*df_dz)
B_x=imaginary(-1d*df_dz)
B_TOTAL=sqrt((b_y^2d)+(b_x^2d))

end;of Main



;+
; NAME:
;	bungey_priest_field
;
; PURPOSE:
;	To calculate the magnetic field as described by Bungey,
;	T.N. and Priest, E.R. 1995, A&A, 293,215-224
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
;	Currently only does the potential field case.
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


pro bungey_priest_field,B_x, B_y, x,y,f,$
                         A=A,B_DRC=B_DRC,C=C,D=D,B0=B0, $
                         N_ELEM=N_ELEM, SCREEN=SCREEN, $
                         RANGE=RANGE,B_TOTAL=B_TOTAL
 ;Magnetic field [Gauss]
if not Keyword_set(B0) then B0=1D
if not Keyword_set(N_ELEM) then n_elem=50l
;min/max value of a symmetric space 
if not Keyword_set(RANGE) then range=2d
;Define an x, y grid
x=2d*range*(dindgen(n_elem)/(n_elem-1l))-double(range)
y=x
;Positive real constant that moves the positions of the field points
if not Keyword_set(B_DRC) then b=0.5d else b= B_DRC

;Half length of the current sheet
if not Keyword_set(A) then a=1d
a_2=a*a

;Positive real constants 
if not Keyword_set(C) then c=0d
if not Keyword_set(D) then d=0d
;Components of the magnetic field [Gauss]
B_x=dblarr(n_elem,n_elem)
B_y=B_x
B_TOTAL=B_x

Z=DCOMPLEXARR(n_elem,n_elem)  
df_dz=Z
f=z
Z_2=Z
sq_rt_z2_a2=z
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find a way to do this without the loop!
;Step along each x
for i=0l,n_elem-1l do begin
;Step along each y
    for j=0l,n_elem-1l do begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the complex variable Z as a function of x and y.
        Z[i,j]=complex(x[i],y[j])
        Z_2[i,j]=(Z[i,j]*(Z[i,j]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This method can take the wrong branch cut and leave a discontinuity
;on the imaginary axis,
;        sq_rt_z2_a2[i,j]=(Z_2-a_2)^(0.5d)
;Use this method, suggested by the lovely and talented Dr. Dana
;Longcope instead. (He may have done this once or twice)
sq_rt_z2_a2[i,j]=sqrt(z[i,j]-a)*sqrt(z[i,j]+a)
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Flux function from Bungey & Priest 1995 eq. 21
        f[i,j]=B0* $
          ( a_2*b*$
            alog((Z[i,j]+sq_rt_z2_a2[i,j])/a) $
            +(2*a*c*sq_rt_z2_a2[i,j]) $
            -(complex(0d,2*a*d)*Z[i,j]) $
            -(.5d*Z[i,j]*sq_rt_z2_a2[i,j]))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Derivative of flux function from Bungey & Priest 1995 eq. 22
        df_dz[i,j]=B0* $
          ((($
              (b*a_2)+ $
              (2d*a*c*Z[i,j])$`
              -z_2[i,j] $
              +(.5d*a_2))/$
            sq_rt_z2_a2[i,j])+ $
           complex(0d,2*a*d))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;The magnetic field as defined by Bungey & Priest 1995 eq. 22         
        B_y[i,j]=real_part(-1d*df_dz[i,j])
        B_x[i,j]=imaginary(-1d*df_dz[i,j])
        B_TOTAL[i,j]=sqrt((b_y[i,j]^2d)+(b_x[i,j]^2d))
    endfor
endfor

if keyword_set(SCREEN) then begin
    window,/free
    contour,double(f),x,y,NLEVELS=60,/ISOTROPIC
    
    window,/free
    plot_field,b_x,b_y  ,/ISOTROPIC ;,$
         ;      YRANGE=[-RANGE,RANGE]
;,XRANGE=[-RANGE,RANGE],YRANGE=[-RANGE,RANGE]
;velOVECT,b_x,b_y,X,Y,LENGTH=1
endif

end;of Main



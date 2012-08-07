;+
; NAME:
;	lin_forbes_field
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
; 	Written by:	Henry (Trae) deG.Winter III 2010/06/23
;-


function lin_forbes_field, x,y,p,q,lambda,h, $
                           A_0=A_0,$
                           B_X=B_X, B_Y=B_Y, B_TOTAL=B_TOTAL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make sure all of the necessary parameters are set.
Case 0 of  
   size(x, /TYPE) : begin
      print, 'You must define a value for x for lin_forbes_field.pro.'
      stop
   end 
   size(y, /TYPE) : begin
      print, 'You must define a value for y for lin_forbes_field.pro.'
      stop
   end 
   size(p, /TYPE) : begin
      print, 'You must define a value for p for lin_forbes_field.pro.'
      stop
   end 
   size(q, /TYPE) : begin
      print, 'You must define a value for q for lin_forbes_field.pro.'
      stop
   end 
   size(lambda, /TYPE) : begin
      print, 'You must define a value for lambda for lin_forbes_field.pro.'
      stop
   end 
   size(h, /TYPE) : begin
      print, 'You must define a value for h for lin_forbes_field.pro.'
      stop
   end 
   else:
endcase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Keywords section
;Vector field source strength [Gauss cm]
if not Keyword_set(A_0) then A_0=3.9269909e+11

B_TOTAL=dblarr(n_elements(x),n_elements(y))
B_X=B_TOTAL
B_y=B_TOTAL

for i=0ul, n_elements(x)-1ul do begin
   for  j=0ul, n_elements(y)-1ul do begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the complex variable Zeta as a function of x and y.
      Zeta=dcomplex(x[i],y[j])
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Since most terms enter in the equations as a square, determine the
;squares once instead of 2-4 times
      Zeta_2=(Zeta*(Zeta))
      pp=p*p
      qq=q
      lambda_2=lambda*lambda
      hh=h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      two_i=dcomplex(0,2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the complex magnetic field as defined in Reeves & Forbes
;(2001) Eq (1)
;      Complex_B=-1 *($
;                two_i*A_0*lambda* $
;                (hh+lambda_2)*$
;                ((Zeta_2+pp)*(Zeta_2+qq))^0.5$
;      ) $
;         / $
;         ($
;         !dpi*(Zeta_2-lambda_2)$
;         *(Zeta_2+hh)*((lambda_2+pp)*(lambda_2+qq))^0.5$
;      )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the complex magnetic field as defined in Reeves & Forbes
;(2001) Eq (1)
Complex_B=($
          two_i*A_0*lambda* $
          (hh+lambda_2)*$
          sqrt((Zeta_2+pp)*(Zeta_2+qq))$
          ) $
          / $
          ($
          !dpi*((Zeta+lambda)*(Zeta-lambda))$
           *(Zeta_2+hh)*sqrt((lambda_2+pp)*(lambda_2+qq))$
          )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;        
      B_X[i,j]=imaginary(Complex_B)
      B_Y[i,j]=real_part(Complex_B)
      B_TOTAL[i,j]=sqrt((b_x[i]^2d)+(b_y[j]^2d))
   endfor
endfor
window, 0
contour, b_total, x,y;, /iso;,xrange=[-2,2], /xs
window, 1
velovect, B_X, B_y, x,y;, /iso;, xrange=[-3,3], yrange=[0, 100]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stop
return,[B_X, B_Y] 
end;of Main



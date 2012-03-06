
; martens_Loop_temp_profile; a program to render the analytical solution for the
; temperature structure in a constant pressure coronal loop, for
; a heating function 
;E_h = H_0 * P_0^BETA * T^ALPHA
;Alpha and beta are now switch to current meaning to the outside user.
; Analytical solution expressed in terms of incomplete Beta-function
; b = Beta parameter in heating function (ALPHA)

FUNCTION martens_Loop_temp_profile, s, ALPHA=ALPHA, BETA=BETA,$
                                    TMAX=TMAX, GAMMA=GAMMA,$
                                    DELTA=DELTA

min_A=min(loop.A)
max_A=max(loop.A)
case 1 of 
;Case of the keyword delta being set but the loop is of uniform thickness
   keyword_set(delta) and (min_A eq max_A):delta_in=0.0
;Case of the keyword delta being set and the loop is not of uniform thickness
   keyword_set(delta) and (min_A ne max_A):delta_in=delta
;Case of the keyword delta not being set and the loop is not of uniform thickness
   not(keyword_set(delta) and (min_A ne max_A):delta_in=1.0
else delta_in=0.0

endcase

n_points=n_elements(s)/2
;Martens (2009) eq. (45)
mu=(delta_in-(2d0+gamma))/(delta_in+7d0)
;Martens (2009) eq. (44)
nu=(2d0)*(ALPHA)/(7d0)


u=findgen(N)/(N-1)   ; interval [0,1]


k= (1.-2*alpha)/(2*(2.5+alpha))

z=u ; introduce vector z of same size as u

for i=0,N-1 do begin
    z(i)=ibeta(k+1,0.5,u(i)) ; normalised incomplete beta-function from IDL lib.

endfor
t=u^(1./(2.5+b))
t=[t,reverse(t)]
s2=[z/2,1.-reverse(z/2.)]
s2=s2/max(s2)


return, t
end

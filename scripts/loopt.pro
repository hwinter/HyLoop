; LOOPT.PRO; a program to render the analytical solution for the
; temperature structure in a constant pressure coronal loop, for
; a heating function E_h = H_0 * P_0^alpha * T^beta

; Analytical solution expressed in terms of incomplete Beta-function
; b=?  Beta parameter in heating function

PRO LOOPT

N=1001
u=findgen(N)/(N-1)   ; interval [0,1]

window,0,xsize=800,ysize=600
for j=0,12 do begin
b=-2.4+j/2.

k= (1.-2*b)/(2*(2.5+b))   ; parameter from analytical solution

z=u ; introduce vector z of same size as u

for i=0,N-1 do begin
z(i)=ibeta(k+1,0.5,u(i))  ; normalised incomplete beta-function from IDL lib.

t=u^(1./(2.5+b))  ; temperature profile
endfor

if j eq 0 then plot,z,t else oplot,z,t
endfor


window,1,xsize=800,ysize=600

for j=0,12 do begin
b=-2.4+j/2.

k= (1.-2*b)/(2*(2.5+b))

for i=0,N-1 do begin
z(i)=ibeta(k+1,0.5,u(i))  ; normalised incomplete beta-function from IDL lib.
endfor

t=u^(1./(2.5+b))
delta=0.1
h=(t+delta)^b  ; h is the heating function, offset by 0.1 from t=0 to avoid singularities
hmax=max(h)
h=h/hmax  ; normalized to unity

if j eq 0 then plot,z,h else oplot,z,h
endfor


end

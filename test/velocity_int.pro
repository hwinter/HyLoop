;.r velocity_int 
function derivs45, t,v

dvdt=v/2d0


end

interval=[0,2]

t=dindgen(150)/149
v1=dblarr(n_elements(t))
v1[0]=5
v2=dblarr(n_elements(t))

for i=1, n_elements(t)-2 do begin
    
    Dydx=derivs45(t[i], v1[i])
    v1[i+1] = RK4(v1[i] , Dydx, t[i], (t[1]-t[0]), 'Derivs45' , /DOUBLE ) 
 ;prinm   v2[i+1] = QROMO('Derivs45',t[i-1], t[i], /double)

endfor
plot, t,v1

end


n_e=1d8+((1d9)-1d8)*findgen(10)/9.
de_dt=n_e
b_d=de_dt
n_e[*]=1d8
t=  (1d6)+(3d6)*findgen(10)/9.
;t[*]=3d6
b_c=get_b_crit(15)
for i=0, 9 do begin

b_d[i]=sqrt((!msul_kb*t[i])/(!msul_qe*!msul_qe*n_e[i])) 
de_dt[i]=(-1.)*n_e[i]*alog(b_d[i]/b_c)
endfor

plot,t,  alog(b_d/b_c)

;End bad planning cleanup!
end

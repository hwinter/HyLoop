;.r new_delta_test

;ac=(Z_1*z_2*!msul_qe*!msul_qe)/(mu_rm*)




m_test= !msul_mp

mu_rm_p=(m_test*!msul_mp)/(m_test+!msul_mp)
mu_rm_e=(m_test*!msul_me)/(m_test+!msul_me)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;test the new formulation for the d/dt term
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print, 'KE=15 keV'
t=1d7

b_Debye=6.65*((T/n_e)^.5)
print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
print, (b_Debye*b_Debye)/(zeta_e*zeta_e), $
       (b_Debye*b_Debye)/(zeta_p*zeta_p)

;t=1d6

t=1d6
n_e=1d12
energy=15.
v=energy2vel(energy)
help, v

b_Debye=6.65*((T/n_e)^.5)

zeta_e=!msul_qe*!msul_qe/(mu_rm_e*v*v)
zeta_p=!msul_qe*!msul_qe/(mu_rm_p*v*v)
print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
print, (b_Debye*b_Debye)/(zeta_e*zeta_e), $
       (b_Debye*b_Debye)/(zeta_p*zeta_p)

t=1d4

b_Debye=6.65*((T/n_e)^.5)
print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
print, (b_Debye*b_Debye)/(zeta_e*zeta_e), $
       (b_Debye*b_Debye)/(zeta_p*zeta_p)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
energy=200
print, 'KE=200 keV'

v=energy2vel(energy)
help, v

b_Debye=6.65*((T/n_e)^.5)

b_Debye=6.65*((T/n_e)^.5)

zeta_e=!msul_qe*!msul_qe/(mu_rm_e*v*v)
zeta_p=!msul_qe*!msul_qe/(mu_rm_p*v*v)
print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
print, (b_Debye*b_Debye)/(zeta_e*zeta_e), $
       (b_Debye*b_Debye)/(zeta_p*zeta_p)

t=1d4

b_Debye=6.65*((T/n_e)^.5)
print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
print, (b_Debye*b_Debye)/(zeta_e*zeta_e), $
       (b_Debye*b_Debye)/(zeta_p*zeta_p)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
start=systime(1)
for i=0, 1000 do begin
    v_2=v*v*v*v
endfor
end_t=systime(1)
t1= end_t-start
start=systime(1)
for i=0, 1000 do begin
    v_2=v^4
endfor
end_t=systime(1)
t2= end_t-start

print, t1, t2, t1/t2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
print, ';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'

v_para=-0.098
v=[1.0, 0.0]
alpha_pa=!dpi/15.
transformation_matrix=[[cos(alpha_pa), sin(alpha_pa)], $
                       [-sin(alpha_pa),cos(alpha_pa) ]]

t_V=transformation_matrix#v

print, t_v
print, (cos(-alpha_pa)+sin(-alpha_pa)*v[1]), $
       (-sin(-alpha_pa)*v[0]+cos(-alpha_pa)*v[1])
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end

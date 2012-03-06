;.r tau_de_test
e=20.;kev
n_e=1d9
t_max=1d6
d=1d7
l=1d9
uniform=1
charge=1.*!msul_qe
m=!msul_me

loop=mk_loop_tube(d,l, $
  T_MAX=T_MAX,N_E=N_E ,$
  N_DEPTH=N_DEPTH,$
  TO=T0,UNIFORM=UNIFORM, $
  B=B,Q0=Q0,  nosave=nosave, $
  outname=outname,N_CELLS=N_CELLS,$
  X_SHIFT=X_SHIFT,Y_SHIFT=Y_SHIFT,$
  Z_SHIFT=Z_SHIFT, $
  SIGMA_FACTOR=SIGMA_FACTOR)

factor=exp(-1d0)
;factor=.9
E_FINAL=E*factor
t1=tau_de(E ,$
           E_FINAL=E_FINAL,t=t_max[0], dens=n_e[0],m=m,c=charge)


        ln_lambda=get_loop_coulomb_log( loop)
        print, 'ln lambda= ',ln_lambda[0]
        c=(2d0)*!dpi*(!msul_qe^4)*ln_lambda[0]
   ;     stop
;
;Analytic delta_e
        anal_de=(((-C*2d0*loop.state.n_e[0]*energy2vel(E)) $
                  /(E*!msul_keV_2_ergs))/!msul_keV_2_ergs)

t2=abs( (E_FINAL-e)/anal_de)
print,100.*(t1-t2)/t1
help, t1, t2
a=1.
b=1.
v_total=energy2vel(e)
dl=6.9010323*((T_max)/ $
              (n_e))^0.5d
help, dl[0]
de_dt=patc_de_dt(0 , [e,v_total], dl[0],n_e[0] ,m,charge,a,b)
help, de_dt[0]
help, anal_de
end

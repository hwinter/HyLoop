function shrec_static_atmos_chromo, loop, T0=T0

if not keyword_set(T0) then T0=1d4
;Interpolate the z axis on the volume grid
z_alt= shrec_get_s_alt(reform(loop.axis[2,*]), /GT0)

ind=where(z_alt le loop.depth)
max_ind=max(ind)
dz=z_alt[ind]-z_alt[max_ind+1]

P=get_loop_pressure(loop)
P_0=P[ind+1]

p_chromo1=P_0*(exp((-1d0*!shrec_mp*abs(loop.g[ind])*dz)/(!shrec_kB*T0)))
area_chromo1=loop.A[0] $
             *1d0/(exp((-1d0*!shrec_mp*abs(g_add1)*dz)/(!shrec_kB*T0)))



z_add_alt=shrec_get_s_alt(z_add2)
dz=z_add_alt-loop.axis[2,n_corona_surf-1]
p_chromo2=P[1]*(exp((-1d0*!shrec_mp*abs(g_add2)*dz)/(!shrec_kB*T0)))

;Remembering that n_p~n_e and P=nkT
n_e_add1=p_chromo1/(2d0*!shrec_kB*T0)
n_e_add2=p_chromo2/(2d0*!shrec_kB*T0)
;E=3/2*n*kb*T
E_add1=(3./2.) *2.*n_e_add1*!shrec_kB *T0     
E_add2=(3./2.) *2.*n_e_add2* !shrec_kB*T0




return, loop
END

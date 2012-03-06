function msu_speed_dist, T,V=V, M=M, N_ELEM=N_ELEM,$
  PLOT=PLOT, N_PART=N_PART, MPV=MPV

;Constants
kB = 1.38d-16 ;Boltzmann constant (erg/K)
me = 9.11d-28 ;electron mass (g)

if (not keyword_set(N_PART)) then N_PART=1d
if (not keyword_set(M)) then M=me
if (not keyword_set(N_ELEM)) then N_ELEM=100
;See Reif p. 266
;v_most_probable
MPV=sqrt((2d)*kB*T/M)
rms_width=sqrt(kB*T/M)

if (not keyword_set(V)) then $
    V=(MPV-1.1*rms_width) $
      +((dindgen(N_ELEM)/(N_ELEM-1.))*3*rms_width)
v>=0
v_2=V^2d
kT_times_2=2*kB*T


F=4.*!DPI*N_PART*((M/(kT_times_2*!DPI)))*v_2*exp((-1d)*M*v_2/kT_times_2)

normal_c=total(F)
f=N_PART*temporary(f)/normal_c


if keyword_set(PLOT) then $
  plot, v,f/N_PART
return, f


end


;.r distro_test_1
delta=3.
min_max=[15d0, 200d0]
delta_e=min_max[1]-min_max[0]
one_minus_delta=1d0-delta
A_0=one_minus_delta/((min_max[1]^(one_minus_delta))-(min_max[0]^(one_minus_delta)))
;A_1=abs(one_minus_delta
N_PART=2d5

energies=abs(randomu(seed,N_PART)*(one_minus_delta/A_0) )^(1d0/one_minus_delta)
MIN_E=(min(energies)-min_max[0])
energies=energies-MIN_E
done=0

while not done do begin
    junk=where(energies gt min_max[1])
    if junk[0] eq -1 then done =1 else begin
        n_junk=n_elements(junk)
        energies[junk]=abs(randomu(seed,n_junk)*(one_minus_delta/A_0) )^(1d0/one_minus_delta)
    endelse



endwhile

tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;energies=min_max[0]+abs(randomu(seed,N_PART)*one_minus_delta)^(1d0/one_minus_delta)
plot_histo, energies,steps, histo,DELTA=1,  /xlog, /ylog
;e_dist_plot,
es=min_max[0]+(min_max[1]-min_max[0])*dindgen(100)/99

scale1=max(histo)

f=es^(-delta)
f=scale1*(f/max(f))
oplot, es, f, thick=2, color=2
oplot, es, f, psym=5, color=2

pmm, energies
end

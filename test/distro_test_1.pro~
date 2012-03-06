;.r distro_test
zed=5d0-1d1*dindgen(10)/9.
zed=reverse(zed)
print, zed
N_PART=20000
window,5
for i=0,  n_elements(zed)-1ul do begin
    ;dist=mk_distro5(a[i], b[i])
    print, zed[i]
    ;mk_distro6,zed[i],dist
    
    dist=mk_distro6(zed[i], N_PART=N_PART)
    ;plot, dist
    wait, 5
    pa_cos=dist
    ;pa_cos=cos(dist)
    plot_histo, pa_cos
    less_than_zero=where(pa_cos lt 0)
    more_than_zero=where(pa_cos gt 0)
    help, less_than_zero,more_than_zero 

endfor

n_tries=100
ratio=dblarr(n_tries)
for i=0,n_tries-1ul do begin
    dist=mk_distro6(0, N_PART=N_PART)
    pa_cos=dist
    ;pa_cos=cos(dist)
    plot_histo, pa_cos
    less_than_zero=where(pa_cos lt 0)
    more_than_zero=where(pa_cos gt 0)
    ;help, less_than_zero,more_than_zero 
    ratio[i]=n_elements(less_than_zero)/n_elements(more_than_zero)

endfor

plot, ratio
print, avg(ratio)

end

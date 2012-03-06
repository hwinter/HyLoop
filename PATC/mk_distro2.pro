function mk_distro,N_PARTICLES=N_PARTICLES, N_BINS=N_BINS,$
                   MIN_MAX=MIN_MAX,SIN=SIN, ALPHA=ALPHA,$
                   BETA=BETA;,COS=COS,EXP=EXP
                   
;!except=2
IF not KEYWORD_SET(N_PARTICLES) then n_particles=1000l $
  else n_particles=long(n_particles)

IF not KEYWORD_SET(N_BINS) THEN begin
    n_bins=long(n_particles*.1)
    
    if n_bins le 1 then n_bins=long(n_particles/2)
endif
n_bins>=10
if (n_bins mod 2 eq 0) then n_bins=n_bins+1
help, n_bins
IF not KEYWORD_SET(ALPHA) then ALPHA=0d
IF not KEYWORD_SET(BETA) then BETA=0d
;n_bins=50;long(n_particles)

range=(!dpi)*dindgen(1000)/(1000-1l)
n=long(randomu(seed)*1000)
domain=MIN_MAX[0]+(dindgen(n)/(n-1l))*MIN_MAX[1]-MIN_MAX[0]
n_elem=SQRT(ABS(sin(range+ALPHA)^2)+BETA*abs(COS(range+ALPHA)^2))
c=total(n_elem);*N_PARTICLES)
;print,  total(n_elem)
n_elem=(n_elem)/c
help,n_elem
;print,  total(n_elem)
n_elem=congrid(n_elem,n_bins,/center)
c=total(n_elem);*N_PARTICLES)
;print,  total(n_elem)
n_elem=(n_elem*N_PARTICLES)/c

;print,  total(n_elem)

;print,''

;print,''


;print,''

;domain=MIN_MAX[0]+(dindgen(n_bins)/(n_bins-1l))*MIN_MAX[1]-MIN_MAX[0]
;domain=spline(N, domain, n_bins)
domain=congrid(domain,n_bins,/center)
;domain=domain+randomn(seed,n_bins)/3*domain
for i=0, n_elements(n_elem)-1l do begin
    N=round_off(n_elem[i],1)
    if n lt 1 then goto, skip_point
    pa_temp=dblarr(N)+domain[i]
    if n_elements(pa) gt 0 then pa=[pa,pa_temp] else $
      pa=pa_temp
    print, 1+round_off(n_elem[i],1),domain[i]
    skip_point:
endfor
;plot, domain, n_elem, title='domain, range,'
;plot_histo,pa
;stop
help, n_bins
;plot_histo, pa, steps, histo, delta=.01 
RETURN,PA

end

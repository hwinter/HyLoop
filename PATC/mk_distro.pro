;+
; NAME:
;	mk_distro
;
; PURPOSE:
;	Make a pitch angles for a nt_beam structure based on different distributions
;
; CATEGORY:
;	PaTC
;       Particle Tools
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	N_PARTICLES: Number of particles to creat a PA distribution for. 
;                 If not set then N_PARTICLES=1000
;       N_BINS: Number of bins for the PA distribution.  
;                 If not set then N_BINS=N_PARTICLES*.1
;       MIN_MAX: A two element vector containing the Minumum and maxiumum 
;                 value of the pitch angle
;       SIN: Use a sin(theta) distribution 
;       ALPHA: =ALPHA,$
;       BETA: =BETA,
;       GRR: I don't remember!  This is why you should document whil you write!
;            I think this is actually the gutteral sound of anger.  Used when the 
;            regular expression for n was not working.
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:	
;-

function mk_distro,N_PARTICLES=N_PARTICLES, N_BINS=N_BINS,$
                   MIN_MAX=MIN_MAX,SIN=SIN, ALPHA=ALPHA,$
                   BETA=BETA,grr=grr;,COS=COS,EXP=EXP
                   
;!except=2
IF not KEYWORD_SET(N_PARTICLES) then n_particles=1000l $
  else n_particles=long(n_particles)

IF not KEYWORD_SET(N_BINS) THEN begin
    n_bins=long(n_particles*.1)
    
    if n_bins le 1 then n_bins=long(n_particles/2)
endif
n_bins>=5d
if (n_bins mod 2 eq 0) then n_bins=n_bins+1
;help, n_bins


IF not KEYWORD_SET(ALPHA) then ALPHA=0d
IF not KEYWORD_SET(BETA) then BETA=0d
;n_bins=50;long(n_particles)

range=(!dpi)*dindgen(1000)/(1000-1l)
;n=long(randomu(seed)*1000)
n=1000
domain=MIN_MAX[0]+(dindgen(n)/(n-1l))*MIN_MAX[1]-MIN_MAX[0]
n_elem=SQRT(ABS(sin(range+ALPHA)^2)+BETA*abs(COS(range+ALPHA)^2))
if keyword_set(grr) then n_elem[*]=1d0
c=total(n_elem);*N_PARTICLES)
;print,  total(n_elem)
n_elem=(n_elem)/c
;help,n_elem
;print,  total(n_elem)
n_elem=congrid(n_elem,n_bins,/center)
c=total(n_elem);*N_PARTICLES)
;print,  total(n_elem)
n_elem=(n_elem*N_PARTICLES)/c

if keyword_set(grr) then begin 
    zz=n_particles/n_elements(n_elem)
endif

;domain=MIN_MAX[0]+(dindgen(n_bins)/(n_bins-1l))*MIN_MAX[1]-MIN_MAX[0]
;domain=spline(N, domain, n_bins)
domain=congrid(domain,n_bins,/center)
;domain=domain+randomn(seed,n_bins)/3*domain
for i=0, n_elements(n_elem)-1l do begin
    N=round_off(n_elem[i],1)
    if keyword_set(grr) then  n=zz
    ;print, n
    if n lt 1 then goto, skip_point
    pa_temp=dblarr(N)+(domain[i]+0.1*randomn(seed,N))
    if n_elements(pa) gt 0 then pa=[pa,pa_temp] else $
      pa=pa_temp
    ;print, 1+round_off(n_elem[i],1),domain[i]
    skip_point:
endfor
;plot, domain, n_elem, title='domain, range,'
;plot_histo,pa
;stop
;help, n_bins
;plot_histo, pa, steps, histo, delta=.01 
RETURN,PA

end

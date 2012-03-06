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
;       ALPHA:
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;	N_PARTICLES: Number of particles to creat a PA distribution for. 
;                 If not set then N_PARTICLES=1000
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

function  mk_distro6,alpha,  N_PART=N_PART,$
                     ;All keywords below this line are ignored.
                     N_BINS=N_BINS,$
                   MIN_MAX=MIN_MAX,SIN=SIN, $
                   grr=grr;,COS=COS,EXP=EXP
                   
 if not keyword_set(N_PART) then N_PARTICLES=1d4 $
 else N_PARTICLES=N_PART

;alpha=alpha_beta[0]
;beta=alpha_beta[1]
;domain=(0) +!dpi*dindgen(100)/99.
;p_x=alpha*(sin(domain) )+beta*(cos(domain+!dpi/2.)+1.)
;p_x=p_x/total(p_x)

x=-1D0+2D0*dindgen(100)/99. 

rand=randomu(seed,N_PARTICLES, /DOUBLE ) 
case 1 of 

    alpha gt 0:begin
    
        rand_x=-1D00+2D0*rand

        dist=sign(dblarr(n_particles)+1.,rand_x)$
             *(1./sqrt(alpha))*erfinv(rand_x)

        done=0
        while not done do begin
            zz=where(abs(dist) ge max(x))
            if zz[0] ne -1 then begin
                n_bad=n_elements(zz)
                rand=randomu(seed,n_bad, /DOUBLE ) 
                rand_x=-1d0+2.0*rand
                dist2=sign(dblarr(n_bad)+1.,rand_x)$
                      *(1./sqrt(alpha))*erfinv(rand_x)
                dist[zz]=dist2
            endif else done =1
            
            zz=where(abs(dist) ge max(x))
            if zz[0] eq -1 then done=1
        endwhile

    end
    alpha lt 0:begin
    
    
        rand_x=-1D0+2D0*rand
        rand_2=randomu(seed, N_PARTICLES, /DOUBLE)
        dist=( 1./sqrt(abs(alpha)))*erfinv(rand_x)-1d0
        index=where(rand_x gt 0)
        if index[0] ne -1 then $
          dist[index]=-1*(dist[index]);+2;rand_x[index]
        done=0
        while not done do begin
            zz=where(abs(dist) ge max(x))
            if zz[0] ne -1 then begin
                n_bad=n_elements(zz)
                rand=randomu(seed,n_bad, /DOUBLE ) 
                rand_2=randomu(seed,n_bad , /DOUBLE) 
                rand_x=-1.0+2.0*rand
                dist2=(1./sqrt(abs(alpha)))*erfinv(rand_x)-1d0
                index=where(rand_x gt 0)
                if index[0] ne -1 then $
                  dist2[index]=-1*(dist2[index])
                dist[zz]=dist2
            endif else done =1
            
            zz=where(abs(dist) ge  max(x))
            if zz[0] eq -1 then done=1
        endwhile
    end
    alpha eq  0:begin
        dist=-1D0+2D0*rand
    end
endcase


;p_x=abs((abs(x)^abs(zed)+sign(zed,zed)))
;stop
rand2=randomn(seed)
rand2=sign(1, rand2)
dist=dist*rand2
RETURN,dist

end

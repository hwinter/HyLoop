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

pro  mk_distro5,alpha, dist, N_PARTICLES=N_PARTICLES, N_BINS=N_BINS,$
                   MIN_MAX=MIN_MAX,SIN=SIN, $
                   grr=grr;,COS=COS,EXP=EXP
                   
 N_PARTICLES=1d4

;alpha=alpha_beta[0]
;beta=alpha_beta[1]
domain=(0) +!dpi*dindgen(100)/99.
if alpha gt 0 then begin
    p_x=1+alpha*(sin(domain) )
    p_x=p_x-min(p_x)
    
    
    p_x=p_x/total(p_x)

endif else begin
    
 p_x=(cos(abs(alpha)*domain+!dpi/2.)+1.)

endelse

    p_x=p_x/total(p_x)
    plot,domain,p_x  , xs=1

rand=randomu(seed, N_PARTICLES)

stop
;RETURN,PA

end

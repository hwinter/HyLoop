;+
; NAME:
;	
;
; PURPOSE:
;	
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
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
function get_mag_br_2, loop,nt_beam, $
                     S_HAT=S_HAT, OUT_TEST=OUT_TEST

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This version does the calculation in SI units, so all of the CGS
;units are converted to MKS and back again. These are the constants
;to do that, plus a few others

cm2meter=1d-2
g2kg=1d-3
Gauss2Tesla=1d-4
statcoul2Coul=(1.6022d-19)/(4.8032d-10)
;Permeability of free space/4pi, since we divide by 4pi later this
;saves us two calculations
mu_0=1d-7
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

n_part=n_elements(nt_beam)

good_index=where(strupcase(nt_beam.state) eq 'NT',$
                 n_alive_part)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If not set, provide a randomized unit vector that will point parallel
;or anti-parallel to the loop axis.
if n_elements(S_HAT) ne n_part then begin
   S_HAT=randomn(seed, n_part)
   
   repeat_point:
   lt_0=where(S_HAT lt 0., n_lt_0)
   gt_0=where(S_HAT gt 0., n_gt_0)
   eq_0=where(S_HAT eq 0., n_eq_0)

   if n_lt_0 ne 0 then S_HAT[lt_0]=-1.0
   if n_gt_0 ne 0 then S_HAT[gt_0]=1.0
   if n_eq_0 ne 0 then begin
      S_HAT[eq_0]=randomn(seed, n_eq_0)
      goto, repeat_point
   endif   
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pos_index=hdw_get_position_index(nt_beam.x, loop.s)

v_total=(energy2vel(nt_beam.KE_total))*cm2meter
v_perp=sin(nt_beam.pitch_angle)* v_total
v_perp_2=v_perp*v_perp

delta_b=loop.b*0.
;Convert B from Gauss to Tesla
B=loop.b*Gauss2Tesla

mass=nt_beam.mass*g2kg
gyrorad=(mass*v_perp)/(B[pos_index]*nt_beam.charge*statcoul2Coul)
;Need to do this as a matrix instead of one by one

dbout=dblarr(n_alive_part, n_elements(B))
ds=cm2meter*get_loop_ds(loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for i=0ul, n_alive_part-1ul do begin
   d=abs(nt_beam[good_index[i]].x-loop.s)*cm2meter

   d>=ds[(pos_index[good_index[i]]-1 >1)]/2.
   
   db=nt_beam[good_index[i]].scale_factor*$
      (mu_0)*$
      mass[good_index[i]] * v_perp_2[good_index[i]] * $
      (1.0/B[pos_index[good_index[i]]])* $
;      (1.0/(sqrt((gyrorad[good_index[i]]*gyrorad[good_index[i]])+(d*d))^3.0)) *$
      (d^(-3.0))*$
      S_HAT[good_index[i]]
   
   dbout[i,*]=db
   delta_b+=db 
   
endfor ; i loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

delta_b/=Gauss2Tesla
dbout/=Gauss2Tesla
;stop
out_test=dbout
return, delta_b

END




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
function get_mag_br, loop,nt_beam, $
                     S_HAT=S_HAT, OUT_TEST=OUT_TEST

n_part=n_elements(nt_beam)

good_index=where(strupcase(nt_beam.state) eq 'NT',$
                 n_alive_part)

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


;If not set, provide a randomized unit vector that will point parallel
;or anti-parallel to the loop axis.
C1=(nt_beam.scale_factor*!shrec_me*3d10)/(4*!dpi)

pos_index=hdw_get_position_index(nt_beam.x, loop.s)


v_total=energy2vel(nt_beam.KE_total)
v_perp=sin(nt_beam.pitch_angle)* v_total
v_perp_2=v_perp*v_perp
gyrorad=(nt_beam.mass*v_perp*3d10)/(loop.b[pos_index]*nt_beam.charge)
;Need to do this as a matrix instead of one by one
delta_b=loop.b*0.
for i=0, n_alive_part-1ul do begin
   d=abs(nt_beam[good_index[i]].x-loop.s)
   db=c1[good_index[i]]* $
      v_perp_2[good_index[i]] * $
      (1.0/loop.b[pos_index[good_index[i]]])* $
      (1.0/(sqrt((gyrorad[good_index[i]]*gyrorad[good_index[i]])+(d*d))^3.0))
   
   delta_b+=db
   
   
endfor

out_test=gyrorad
return, delta_b



END




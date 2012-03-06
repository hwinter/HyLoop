function mk_loop_aia_signal,loop, RES=RES, PIXEL=PIXEL, $
                            A94=A94, A131=A131,A171=A171, $
                            A194=A194, A211=A211, A335=A335,$
                            PER_VOL=PER_VOL, NO_CHROMO=NO_CHROMO

;Modified by HDWII 2011-10-27
;Units at time of writing are 'DN cm^5 s^-1 pix^-1'
  defsysv, '!AIA_tresp', exists=test
  if test lt 1 then begin
     data_dir=getenv('DATA')
     AIA_tresp=aia_get_response(/temp, /dn)
     defsysv, '!AIA_tresp',AIA_tresp
  endif 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords
  if not keyword_set(RES) then RES=0.6d0 ; [arcsec]
;Define Constants
;Pixel's extent in cm * Guestimate
  if not keyword_set(pixel) then pixel=.6d*750d*1d5 ; ~750 km/arcsec

;figure out grid size

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  EM=get_loop_em(loop, VOL=vol,T=loop_temp)
  n_vol=n_elements(VOL)
;Artificially kill the chromospheric signal if desired.;
  if keyword_set(NO_CHROMO) then begin
     em[0:loop.n_depth]=0d
     em[(n_vol-1-loop.n_depth):n_vol-1]=0d
  endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  n_volumes=n_elements(loop_temp)
  index=l64indgen(n_volumes)
  loop_temp=alog10(loop_temp)


  loop_temp<=max(!AIA_TRESP.logte)
  loop_temp>=min(!AIA_TRESP.logte)

  loop_index=sort(loop_temp,/L64)
  signal=dblarr(n_volumes)
  
  case 1 of 
     keyword_set(A94): channel=0
     keyword_set(A131):channel=1
     keyword_set(A171):channel=2
     keyword_set(A193):channel=3
     keyword_set(A211):channel=4
     keyword_set(A304):channel=5
     keyword_set(A335):channel=6
;Make A171 the default
     else:channel=2
  endcase
  

  signal[loop_index]=10^em[loop_index]* $
                     (spline(!AIA_TRESP.logte,$
                             !AIA_TRESP.ALL[*, channel], $
                             loop_temp[loop_index]))
  
  

  signal>=0.

;Artificially kill signals out of the temperature boundaries
  bad_index=where(loop_temp lt min(!AIA_TRESP.logte))
  if bad_index[0] ne -1 then $
     signal[bad_index]=0d0
  
  bad_index=where(loop_temp gt max(!AIA_TRESP.logte))
  if bad_index[0] ne -1 then $
     signal[bad_index]=0d0

;Signal is in units of 'DN cm^2 s^-1 pix^-1'

;If this keyword is set then signal is in units of 'DN cm^5 s^-1 pix^-1'
  if keyword_set(PER_VOL) THEN signal=signal/vol
;stop

  return, signal


end

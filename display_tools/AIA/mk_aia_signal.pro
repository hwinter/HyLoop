function mk_aia_signal,loop, RES=RES, PIXEL=PIXEL, $
                       A94=A94, A131=A131,A171=A171, $
                       A194=A194, A211=A211, A335=A335,$
                       PER_VOL=PER_VOL, NO_CHROMO=NO_CHROMO
defsysv, '!AIA_tresp', exists=test
if test lt 1 then begin
    data_dir=getenv('DATA')
    restgen,file=data_dir+'/AIA/AIA_DEM_TEST/demtest_tresp.genx',$
      str=AIA_tresp
    defsysv, '!AIA_tresp',AIA_tresp
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set keywords
if not keyword_set(RES) then RES=0.6d0; [arcsec]
;Define Constants
;Pixel's extent in cm * Guestimate
pixel=.6d*750d*1d5; ~750 km/arcsec

;figure out grid size

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EM=get_loop_em(loop, VOL=vol,T=loop_temp)
n_volumes=n_elements(loop_temp)
index=l64indgen(n_volumes)
loop_temp=alog10(loop_temp)
loop_index=sort(loop_temp,/L64)

resp_index=where( !AIA_TRESP.logte ge 0, $
                 resp_i_count)
    
signal=dblarr(n_volumes)
;UNITS !AIA_TRESP.xxx.TRESP         STRING    'phot cm^5 s^-1 pix^-1'

case 1 of 
    keyword_set(A94):begin
        
        signal[loop_index]=10^em[loop_index]* $
          (spline(!AIA_TRESP.logte[resp_index],$
                  !AIA_TRESP.A94.TRESP[resp_index], $
                  loop_temp[loop_index]))/(pixel^2)
    
        signal>=0.
        bad_index=where(loop_temp lt min(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
        
        bad_index=where(loop_temp gt max(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
    end
    
    keyword_set(A131):begin
        
        signal[loop_index]=10^em[loop_index]* $
          (spline(!AIA_TRESP.logte[resp_index],$
                  !AIA_TRESP.A131.TRESP[resp_index], $
                  loop_temp[loop_index]))/(pixel^2)
    
        signal>=0.
        bad_index=where(loop_temp lt min(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
        
        bad_index=where(loop_temp gt max(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
    end

    keyword_set(A171):begin
        signal[loop_index]=10^(em[loop_index])* $
          (spline(!AIA_TRESP.logte[resp_index],$
                  !AIA_TRESP.A171.TRESP[resp_index], $
                  loop_temp[loop_index]))/(pixel^2)
        signal>=0.
        bad_index=where(loop_temp lt min(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
        
        bad_index=where(loop_temp gt max(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
    end
    keyword_set(A194):begin
        signal[loop_index]=10^em[loop_index]* $
          (spline(!AIA_TRESP.logte[resp_index],$
                  !AIA_TRESP.A194.TRESP[resp_index], $
                  loop_temp[loop_index]))/(pixel^2)
    
        signal>=0.
        bad_index=where(loop_temp lt min(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
        
        bad_index=where(loop_temp gt max(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
    end
    keyword_set(A211):begin
        signal[loop_index]=10^em[loop_index]* $
          (spline(!AIA_TRESP.logte[resp_index],$
                  !AIA_TRESP.A211.TRESP[resp_index], $
                  loop_temp[loop_index]))/(pixel^2)
    
        signal>=0.
        bad_index=where(loop_temp lt min(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
        
        bad_index=where(loop_temp gt max(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
    end
    keyword_set(A335):begin
        signal[loop_index]=10^em[loop_index]* $
          (spline(!AIA_TRESP.logte[resp_index],$
                  !AIA_TRESP.A335.TRESP[resp_index], $
                  loop_temp[loop_index]))/(pixel^2.)
    
        signal>=0.
        bad_index=where(loop_temp lt min(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
        
        bad_index=where(loop_temp gt max(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
    end
;Make A171 the defaulte
    else:begin
        signal[loop_index]=10^em[loop_index]* $
          (spline(!AIA_TRESP.logte[resp_index],$
                  !AIA_TRESP.A171.TRESP[resp_index], $
                  loop_temp[loop_index]))/(pixel^2.)
    
        signal>=0.
        bad_index=where(loop_temp lt min(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
        
        bad_index=where(loop_temp gt max(!AIA_TRESP.logte[resp_index]))
        if bad_index[0] ne -1 then $
          signal[bad_index]=0d0
    end
endcase

if keyword_set(PER_VOL) THEN signal=signal/vol
;stop
return, signal


end

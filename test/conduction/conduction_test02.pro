;.r conduction_test02.pro
;
common loopmodel, ds1, ds2, A1, is

patc_dir=getenv('PATC')
test_dir=patc_dir+'/test/conduction/'
start_file=test_dir+'cond_test.loop'
eps_name='conduction_test_02.eps'
start_time=systime(1)
print, 'Run started at '+systime(/utc)
old_pmulti=!p.multi
;!p.multi=[0,1,3]
old_plot_state=!D.NAME
n_steps=1d3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
restore, start_file
temp_loop=loop[n_elements(loop)-1]
junk_loop=temp_loop
;useful temporary variable
state0=temp_loop.state 
state0.time=0
state=state0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;index of last volume gridpoint
is = n_elements(temp_loop.state.e)-1l 
;calculate grid spacing
;valid indices run from 0 to is-2 (volume grid), missing ends
ds1 = temp_loop.s[1:is-1]-temp_loop.s[0:is-2]
;ds1 interpolated onto the s grid, ends extrapolated.
ds2 = [ds1[0],(ds1[0:is-3] + ds1[1:is-2])/2.0, ds1[is-2]]
;A interpolated onto the e/n_e grid (missing ends)
A1 = (temp_loop.A[0:is-2] + temp_loop.A[1:is-1])/2.0
mu=0d0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NOVISC=1
NO_SAT=0
DEBUG=1
T0=1d4
dt0=1d-4
src=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get the old colors
tvlct,old_r, old_g, old_b, /GET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the new colors: 0 results in black, 1 in red, 2 in green, 
; and 3 in blue
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for i=0ul,n_steps-1ul do begin          
;.    
    heating=junk_loop.e_h
    T=get_loop_temp(junk_loop)
    ds0 = msu_dstate4(state, T, temp_loop.g, temp_loop.A,$
                      temp_loop.s, heating, dt0, T0, $
                      src, depth, safety, uri, fal, DEBUG=DEBUG,$
                      NOVISC=NOVISC,$
                      NO_SAT=NO_SAT, mu=mu, $
                      Coulomb_log=Coulomb_log, K2=K2,$
                      MFP=MFP,$
                      L_T=L_T)
  
;Put back in the >0.0 ala loop1003.pro  2008/APR/1 HDWIII
    state.e = (junk_loop.state.e + ds0.e) > 0.0
;Put back in the > 1.0e2 ala loop1003.pro  2008/APR/1 HDWIII
;+n_e_change
    state.n_e = (junk_loop.state.n_e + ds0.n_e  )> 1.0d2
;Here is where the viscosity gets added 
    state.v = junk_loop.state.v + ds0.v ;$
              ; +dv_patc*dt0                    
    junk_loop.state=state
    T=get_loop_temp(junk_loop)
    dummy=k2
    dummy=T
    ;dummy=alog10(junk_loop.state.n_e)
    ;dummy=mfp
    ;DUMMY=L_T
   ; dummy=get_loop_ds(junk_loop)
    n= n_elements(dummy)

    case 1 of 
        (n mod 2) eq 1 :begin
            plot,  dummy[0:(n/2)-1] , $
           ;         YRANGE=[8,12], YS=1,$
                   /NODATA
            oplot,  dummy[0:(n/2)-1] , $
                   COLOR=1, psym=1
            oplot, reverse(dummy[(n/2)+1:*]), $
                   COLOR=2, psym=1, symsize=1.5
        end
        else :begin
            plot,  dummy[0:(n/2)-1] ,$
            ;        YRANGE=[8,12], YS=1,$
                   /NODATA
            OPLOT, dummy[0:(n/2)-1] ,$
                   COLOR=1, psym=1
            oplot, reverse(dummy[(n/2):*]), $
                   COLOR=2, psym=1, symsize=1.5
        end
    endcase

 ;   stateplot3,junk_loop , /SCREEN
 ;   stop
endfor


;hdw_pretty_plot2, xy0,xy1, $
;                  label=annotation, right=1, box=0,$
;                  YTICKFORMAT=format, TITLE='Conduction',$
;                  XTITLE='!9'+STRING("321B")+'!3T [K cm!e-1!n] ',$
;                  YTITLE='Flux erg cm!e-2!n s!E-1N',$
;                  charsize=1.5, charthick=1.5,$
;                  yrange=yrange, lthick=1.8,EPS=EPS_name 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Clean up
set_plot,old_plot_state
!p.multi=old_pmulti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get the old colors
tvlct,old_r, old_g, old_b
end

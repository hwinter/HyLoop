;Units ergs cm^-3 s^-1 (Should double check)


;------ VAU radiative loss function (1979 ApJ 233:987) ------
;KEYWORD PARAMETERS:
;	T0 - minimum temperature threshold used with /src option.
;KEYWORD SWITCHES:
;	SRC - if set, engages the 'shiny red chromosphere'
;		feature: radiative loss rate at T < T0
;		is set to zero, producing a chromosphere
;		of uniform temperature.
;	FAL - Values from 1e4 K to 1e5 K based on fig. 2 of E. H. 
;		Avrett in _Mechanisms of Chromospheric and Coronal 
;		Heating_, P. Ulmschneider, E. R. Priest, & R. Rosner 
;		Eds., Springer Verlag (1991), pp.97-99. This is 
;		based on the FAL transition region model, including 
;		corrections for optical depth and ambipolar 
;		diffusion. [An added point at 1e3 K merely 
;		extrapolates the radiative loss to arbitrarily
;		low temperature.]
;	URI - Values above 1e5 K based on recalculation of the
;		Cook et al. (1989 ApJ 338:1176) radiative loss
;		using the Feldman (1992 Phys Scr 46:202-220) coronal
;		abundances.
;	DISP - Ignore n_e and T inputs, and plot a graph of the
;		radiative loss function. If DISP is set but not
;		one, then OPLOT procedure is used, and minus the
;		value of DISP is used for the psym keyword.
function shrec_radloss, n_e, T, T0=T0, src=src, uri=uri,$
                    fal=fal, disp=disp,SO=SO, PS=PS, TITLE=TITLE

COMPILE_OPT STRICTARR
defsysv, '!msul_rad_loss', EXISTS=TEST
IF TEST eq 0 then set_cck_radloss, /FAL
logt=!msul_rad_loss[*,0]
logl=!msul_rad_loss[*,1]

                old_state=!d.name	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Keywords
If not keyword_set(T0) then T0_in=1d4 else T0_in=T0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;DISP option
if keyword_set(disp) then begin
 

                	
   if keyword_set(TITLE) then TITLE_IN=TITLE else TITLE_IN='SHrEC Radiative Loss'
	if disp eq 1 then begin


          ;      tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
        	plot, 10^logT, 10^logL, psym=-1, xtitle = '!log T', $
                      ytitle = '!6Radiative loss, log !7K!3(T)!3',$; xrange=[4,8],$
                      symsize=!P.symsize,$ ;IDL !P.symsize doesn't work.
                      yrange=[1d-24, 1d-21], ystyle=1, /XLOG, /YLOG
	endif else begin
            oplot, logT, logL, psym=-disp, symsize=!P.symsize
            
        endelse
        t2=6.0+1.0*(dindgen(4)/3.)
        r2=alog10((10^(-18.8))*((10^t2)^(-0.5)))
        oplot, t2, r2, psym=1, color=2, symsize=2
           if keyword_set(ps) then begin
                FONT=0
                set_plot, 'ps'
                device, /LANDSCAPE, /EN, $
                        filename=PS ;,/COLOR,
                plot, logT, logL, psym=-1, xtitle = 'Log T', $
                      ytitle ='Log !7K!3(T)', $
                      xrange=[4,8],TITLE=title_in, $
                      symsize=4 , /NODATA ,thick=4.5,$
                      CHARSIZE=1.7, CHARTHICK=4.5, $
                      POSITION=[0.25, 0.15, .95, .9]
;IDL !P.symsize doesn't work.
                
                oplot, logT, logL,thick=9;, color=3;
                oplot, logT, logL, psym=4, symsize=3, thick=9;, color=3
                device,close=1
                set_plot, old_state
                
            endif


 
	return, 0
     endif

Tmax = max(10^logT)
Tmin = min(10^logT)
;Don't extrapolate past the temperature range.
logtemp = alog10(double(T >Tmin <Tmax))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculations performed on 2007_AUG_3 showed that just using interpolate was 
;orders of magnitude faster than the C codes or using findex.
;The following section is kept for historic purposes but commented
;out.

;new, zippy way
;n_tabulated = n_elements(logT)
	;new interpolator crashes when logtemp is out of range!
;n_logtemp = n_elements(logtemp)
;logLambda = make_array(n_logtemp, /double)

;if keyword_set(SO) then begin
;    case 1 of
;        size(so,/TYPE) eq 7 :SO=SO
;        SO eq 1:so =get_bnh_so(/init);Grab the proper shared object file
;        SO eq 2:so =get_bnh_so();Gra	    b the proper shared object file
;        ELSE:begin
;            print, 'Error in SO'
;            print, 'SO: ',so
;            help, so
;        end
;    endcase
;
;    foo = call_external(so, $        ; The SO
;                        'bnh_splint', $ ; The entry name
;                        n_tabulated, $  ; # of elements in x, f(x)
;                        logT, $         ; x
;                        logL, $         ; f(x)
;                        n_logtemp, $    ; # elements in thing-to-interpolate
;                        logtemp, $      ; thing-to-interpolate
;                        logLambda, $    ; where the answer goes
;                        /d_value, $     ; Double precision values
;                        value=[1,0,0,1,0,0], $ ;pass as (1) value (0) reference
;                        /auto_glue)            ;Use an auto-glue wrapper
;/cdecl) ;, $/ignore_exist,
;    Lambda = 10.^logLambda
;endif else $     

;old, inefficient way
;  Lambda = 10^interpolate(logL, findex(logT,logtemp ))

 Lambda = 10^interpol(logL, logT,logtemp , /SPLINE)

;2008-APR-HDWIII
;(3) Chromosphere 
if keyword_set(src) then begin
;Shiny Red Chromosphere feature
    ss = where(T lt T0_in)
    if ss[0] ne -1 then Lambda[ss] = 0.0
endif; else begin

;linear ramp for min < T <T0_in
;This is a more general form of McMullen's ramp. 
; intercept=10^logL[1]	;where logt=4.0
; here=where(t le T0_in, n_here)
; IF n_here gt 0 THEN BEGIN
;  ramp=(t[here] - min(t[here]))*(intercept)/500. 
;  lambda[here]=ramp >0.
;ENDIF

;endelse

result = n_e*n_e * Lambda

return, result

end


;------ Thermal conductivity ---------------------------------
;Based on Spitzer (1e-6 * T^(5/2)), with corrections inferred
;from Fontenla, Avrett & Loeser (1990 ApJ 355:700)
;1999-Jul-15 CCK added DISP keyword similar to radloss function
function kappa_t, T, disp=disp,SO=SO

;first tabulated point is a dummy point, in case T < 1e4.
logc = [2d, 2.00d, 1.12, 0.69, 0.22, 0.13, 0.10, 0.08, 0.00, 0.00, 0.00]
logT = [3d, 4.00d, 4.18, 4.30, 4.60, 4.78, 4.90, 5.00, 6.00, 7.00, 8.00]
Tmin = 10^min(logT)
Tmax = 10^max(logT)

;DISP option
if keyword_set(disp) then begin
	plot, logT, 2.5*logT+logC-6, psym=-1, xtitle = '!6log T', $
		ytitle = '!6Thermal conductivity, log [!7j!6T!U5/2!N]', $
		xrange=[4,5], yrange=[4,7], symsize=!P.symsize
		;Note that !P.symsize doesn't work unless it's
		;hooked in manually as above!
	oplot, logT, 2.5*logT-6, psym=-4, symsize=!P.symsize, $
		linestyle=2
	legend, ['New heat flux model','Spitzer (1962)'],$
		psym=[-1,-4],linestyle=[0,2],$
		symsize=[!P.symsize,!P.symsize], box=0
	return, 0
endif


;new, zippy way
n_tabulated = n_elements(logT)
logtemp = alog10(double(T >Tmin <Tmax))
;old, sluggish way
;correction = 10^interpolate(logc, findex(logT, logtemp))

	;new interpolator crashes if logtemp is out of range!
n_logtemp = n_elements(logtemp)
logcorr = make_array(n_logtemp, /double)
;Old way to call call_external.
;foo = call_external(so, $ ; The SO
;                  'bnh_splint', $      ; The entry name
;                   n_tabulated, $      ; # of elements in x, f(x)
;                   logT, $             ; x
;                   logc, $             ; f(x)
;                   n_logtemp, $        ; # elements in thing-to-interpolate
;                   logtemp, $          ; thing-to-interpolate
;                   logcorr)             ; where the answer goes

foo = call_external(so, $            ; The SO
                    'bnh_splint', $  ; The entry name
                    n_tabulated, $   ; # of elements in x, f(x)
                    logT, $ ; x
                    logc, $                  ; f(x)
                    n_logtemp, $            ; # elements in thing-to-interpolate
                    logtemp, $                     ; thing-to-interpolate
                    logcorr, $                      ; where the answer goes
                    /d_value, $ 
                    value=[1,0,0,1,0,0], $ 
                    /auto_glue,$
                    /cdecl)     ;, $/ignore_exist,

bad_elements=where(finite(logcorr) ne 1)
if bad_elements[0] ne -1 then Begin
    Print, 'Non-Finite corrections to the log correction function'
    Print, 'Errors at the following temperatures:'
    print, ' '+ logT[bad_elements]
    stop
endif
correction = 10^logcorr
bad_elements=where(finite(correction) ne 1)
if bad_elements[0] ne -1 then Begin
    Print, 'Non-Finite corrections to the log correction function'
    Print, 'Errors at the following temperatures:'
    print, ' '+ logT[bad_elements]
    stop
endif

return, (1.0e-6)*T^(2.5)*correction
end


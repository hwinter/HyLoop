
;------ Thermal conductivity ---------------------------------
;Based on Spitzer (1e-6 * T^(5/2)), with corrections inferred
;from Fontenla, Avrett & Loeser (1990 ApJ 355:700)
;1999-Jul-15 CCK added DISP keyword similar to radloss function
;2006-APR-01  This is the version that uses findex & interpolate
;2007-FEB-26
;2007-SEP: Now using interpol is faster and as accurate as the
;            C version (findex and binary ??? have been incorporated into
;            interpol.
;2008-MAR-21: Made to the correction and temperature arrays system variables 
;     to decrease runtime (slightly) 

function shrec_kappa, T, SHOWME=SHOWME,SO=SO,SPIT=SPIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Now defined as a system variable.
;first tabulated point is a dummy point, in case T < 1e4.
;logc = [2d, 2.00d, 1.12, 0.69, 0.22, 0.13, 0.10, 0.08, 0.00, 0.00, 0.00]
;logT = [3d, 4.00d, 4.18, 4.30, 4.60, 4.78, 4.90, 5.00, 6.00, 7.00, 8.00]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Force Tmin < logtemp < Tmax so that we interpolate, not extrapolate.
Tmin = 10^min(!shrec_kappa_logT)
Tmax = 10^max(!shrec_kappa_logT)
logtemp = alog10(T >Tmin <Tmax)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DISP option
if keyword_set(SHOWME) then begin
	plot, !shrec_kappa_logT,$
              2.5*!shrec_kappa_logT+!shrec_kappa_logc-6, psym=-1,$
              xtitle = '!6log T', $
		ytitle = '!6Thermal conductivity, log [!7j!6T!U5/2!N]', $
		xrange=[4,8],symsize=!P.symsize
		;Note that !P.symsize doesn't work unless it's
		;hooked in manually as above!
	oplot, !shrec_kappa_logT, 2.5*!shrec_kappa_logT-6,$
               psym=-4, symsize=!P.symsize, $
		linestyle=2
	legend, ['New heat flux model','Spitzer (1962)'],$
		psym=[-1,-4],linestyle=[0,2],$
		symsize=[!P.symsize,!P.symsize], box=0
	return, 0
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculations performed on 2007_AUG_3 showed that just using interpolate was 
;orders of magnitude faster than the C codes or using findex.
;The following section is kept for historic purposes but commented out.

;new, zippy way
;n_tabulated = n_elements(!shrec_kappa_logT)
;

;if keyword_set(SO) then begin
;    case 1 of
;        size(so,/TYPE) eq 7 :SO=SO
;        SO eq 1:so =get_bnh_so(/init);Grab the proper shared object file
;        SO eq 2:so =get_bnh_so();Grab the proper shared object file
;        ELSE:begin
;            print, 'Error in SO'
;            print, 'SO: ',so
;            help, so
;        end
;    endcase
;
;new interpolator crashes if logtemp is out of range!
;    n_logtemp = n_elements(logtemp)
;    logcorr = make_array(n_logtemp, /double);
;
;    foo = call_external(so, $        ; The SO
;                        'bnh_splint', $ ; The entry name
;                        n_tabulated, $  ; # of elements in x, f(x)
;                        !shrec_kappa_logT, $         ; x
;                        !shrec_kappa_logc, $         ; f(x)
;                        n_logtemp, $    ; # elements in thing-to-interpolate
;                        logtemp, $      ; thing-to-interpolate
;                        logcorr, $      ; where the answer goes
;                        /d_value, $ 
;                        value=[1,0,0,1,0,0], $ 
;                        /auto_glue,/cdecl) ;, $/ignore_exist,;
;
;
;    if n_elements(logcorr) ne total(finite(logcorr)) then stop;
;    correction = 10^logcorr
;    if n_elements(correction) ne total(finite(correction)) then stop
;   
;endif else correction = 10^interpolate(!shrec_kappa_logc, findex(!shrec_kappa_logT, logtemp))

;correction = 10^interpolate(!shrec_kappa_logc, findex(!shrec_kappa_logT, logtemp))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
correction = 10^interpol(!shrec_kappa_logc, !shrec_kappa_logT,$
                         logtemp, /SPLINE)

if not keyword_set(SPIT) then kappa=(1.0e-6)*T^(2.5)*correction $
else kappa=(1.0e-6)*T^(2.5)
return, kappa
end


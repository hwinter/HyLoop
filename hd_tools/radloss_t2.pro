


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
function radloss_t2, n_e, T, T0=T0, src=src, uri=uri,$
                    fal=fal, disp=disp,SO=SO

;(1) Transition region:
if keyword_set(FAL) then begin
	logT = [3.0d, 4.000, 4.165, 4.380, 4.520, 4.645, 4.905, 5.000]
        logL = [-28d,-23.54d,-22.79,-21.73,-21.36,-21.20,-21.31,-21.38]
endif else begin  ;VAU transition region
	logT = [3.0d, 4.0, 4.19, 4.50, 5.0]
        logL = [-28d, -23.03d, -21.65, -21.90, -21.19]
endelse


;(2) Append the Corona:
if keyword_set(Uri) then begin
	logT = [logT, 5.3d, 5.7, 6.0, 6.3, 6.7, 7.0]
        logL = [logL, -21.39, -20.99, -20.98, -21.64, -22.37, -22.27]
endif else begin  ;VAU corona
	logT = [logT, 5.40d, 5.80, 6.30, 7.50, 8.00]
        logL = [logL, -21.202d, -21.900, -21.939, -22.735,- 22.589]
endelse

;DISP option
if keyword_set(disp) then begin
	if disp eq 1 then begin
        	plot, logT, logL, psym=-1, xtitle = '!6log T', $
		ytitle = '!6Radiative loss, log !7K!6(T)', xrange=[4,7],$
		symsize=!P.symsize ;IDL !P.symsize doesn't work.
	endif else begin
        	oplot, logT, logL, psym=-disp, symsize=!P.symsize
        endelse
	return, 0
endif

Tmax = max(10^logT)
Tmin = min(10^logT)

;old, inefficient way
;Lambda = 10^interpolate(logL, findex(logT, alog10(T)))

;new, zippy way
n_tabulated = n_elements(logT)
logtemp = alog10(double(T >Tmin <Tmax))
	;new interpolator crashes when logtemp is out of range!
n_logtemp = n_elements(logtemp)
logLambda = make_array(n_logtemp, /double)
;old, inefficient way

if keyword_set(SO) then begin
    case 1 of
        SO eq 1:so =get_bnh_so(/init);Grab the proper shared object file
        SO eq 2:so =get_bnh_so();Grab the proper shared object file
        size(so,/TYPE) eq 7 :SO=SO
        ELSE:begin
            print, 'Error in SO'
            print, 'SO: ',so
            help, so
        end
    endcase

foo = call_external(so, $            ; The SO
                    'bnh_splint', $  ; The entry name
                    n_tabulated, $   ; # of elements in x, f(x)
                    logT, $          ; x
                    logL, $          ; f(x)
                    n_logtemp, $     ; # elements in thing-to-interpolate
                    logtemp, $       ; thing-to-interpolate
                    logLambda, $     ; where the answer goes
                    /d_value, $      ; Double precision values
                    value=[1,0,0,1,0,0], $ ;pass as (1) value (0) reference
                    /auto_glue)      ;Use an auto-glue wrapper
;/cdecl) ;, $/ignore_exist,
Lambda = 10^logLambda
endif else $
  Lambda = 10^interpolate(logL, findex(logT,logtemp ))

;stop
if keyword_set(src) then begin
	;Shiny Red Chromosphere feature
	ss = where(T lt T0)
	if ss[0] ne -1 then Lambda(ss) = 0.0
endif

result = n_e*n_e * Lambda

return, result

end

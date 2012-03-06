PRO start_loop, lhist, g,A,x, E_h, L, T_max, orig, n_depth, note,$
	q0=q0, power=power, nosave=nosave,$
	outname=outname, FILE=FILE
;
;PURPOSE:	generate file for input to evolve9 and loop1002 for xpb hydro code
;UPDATE 10/29/01 - Plan to run w/o toilet bowl chromosphere!
;extend last footpoint deep into the chromosphere
;04/30/02	RAM	fixed discontinuity in dx
;			changed to constant area in chromosphere
;UPDATE 10/29/01 - Use file 'xbp1_1020.sav', from data at 10:20UT
;UPDATE 04/17/03 - Stops taken out HDWIII
;UPDATE 11/28/04 - Stops taken out HDWIII



IF keyword_set(newfile) THEN BEGIN
restore,loop_file

a=(1e8*rad)^2*!pi
flux=max(b*a)                   ;1.8e15 maxwells
x=reform(l)*1e8
L=max(x)/2.
g0 =(2.74e4)
g=reform(g)*g0
N=n_elements(x)
dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
q0=0.0007          ;erg/x - number to yield t_max=9e5 K - RAM 10092002


ENDIF ELSE BEGIN

;************ open file and initialize structures **********
 restore,'../dana/rmcm.sav'
;Contains:
;L               FLOAT     = Array[199]
;B               FLOAT     = Array[199]
;AXIS            FLOAT     = Array[3, 199]
;G               FLOAT     = Array[199]


 flux=1.8e17 		;maxwells " p.73 --- MAGNETIC FLUX
 a=flux/b
 x=l
 L=max(x)/2.
 N=n_elements(x)
 dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))

ENDELSE

 IF n_elements(q0) eq 0 THEN BEGIN
  IF n_elements(power) eq 0 THEN power=1.5e22	;erg/s
  q0=power/total(dv) 	;was 7.e-4 erg/cm^3/s Kankelborg&Longcope, 1999 p.71
 ENDIF ELSE IF n_elements(power) eq 0 THEN  power=q0*total(dv)

 e_h=q0		;heat energy
 time=0.	;start time

;******* RTV SOLUTION ******************
;given e_h and L, get P(x), T(x), E(x)
 t_max=1.4e3*(e_h*(L^2.)/(9.8e4))^(2./7.)
 P=((T_max/1.4E3)^3)/L		;RTV eqn 4.3
 T = T_max * ( 4d * x/(2d*L) * (1d - x/(2d*L)) )^0.333333 ;CCK empirical
 T = T > 1e4	;put in footpt cutoff - don't allow temperatures too low.
 kB = 1.38e-16 ;Boltzmann constant (erg/K)
 n_e=0.5*(P/(kb*T))	;n_e=0.5*n=0.5*(P/kt) number density
 E=3./2. *2*n_e* Kb*T	;E=3/2 nkt=3/2 2n_e kt

;define this on the grid points
 orig={x:x, b:b, g:g, e:e, n_e:n_e, e_h:e_h, axis:axis, t:t, dv:dv, a:a}

;adjust array sizes for input to loop?.pro
 N = n_elements(x)
 x = 0.5*( x(0:N-2) + x(1:N-1) )
 N = n_elements(b)
 b = 0.5*( b(0:N-2) + b(1:N-1) )
 N = n_elements(g)
 g = 0.5*( g(0:N-2) + g(1:N-1) )
 IF NOT keyword_Set(newfile) THEN a = flux/b ELSE  a = 0.5*( a(0:N-2) + a(1:N-1) )

 N = n_elements(e)
 v = fltarr(N-1)
 e_h0=fltarr(N-2)+e_h

;***************** add on chromosphere ************
;UPDATE 10/29/01 - run w/o toilet bowl chromosphere!
;extend last footpoint deep into the chromosphere
;keep grid refined in TR

 x=x-x[0]	;get rid of leading space	04/30/02	RAM
 n_depth=101


;make a gravitationally stratified atmosphere
 T0=1.e4
 mp = 1.67e-24 ;proton mass (g)
 ne_addon=reverse(findgen(n_depth)*10^(alog10(n_e[0])+2)/(n_depth-1) + n_e[0] +n_e[0]-n_e[1])
 x_addon=alog(ne_addon-n_e[0])*kb*t[0]/(0.5*mp*g[0]) 
 x_addon=x_addon-x_addon[0]
 depth=max(x_addon)
 if NOT (x_addon[0] eq 0 and depth ne 0 ) THEN stop
 xstep=x[1]-x[0]
 x=[x_addon, depth+xstep+ x, 2*(depth+xstep)+max(x)- reverse(x_addon)]
 n_e= [ne_addon, n_e, reverse(ne_addon)]

IF 0 THEN BEGIN ;OLD WAY TO DO IT
 IF keyword_set(newfile) THEN x_addon= 1-exp(-findgen(n_depth)/(10.*n_depth)) ELSE $
 	x_addon= 1-exp(-findgen(n_depth)/(0.25*n_depth))
 scale=(x[1]-x[0])/(x_addon[n_depth-1]-x_addon[n_depth-2])
 x_addon=x_addon*scale
 dd=max(x_addon) 
 dx=x_addon[n_depth-1]-x_addon[n_depth-2]
 x = [x_addon, dd+dx+x, 2*dd+2*dx+max(x)-reverse(x_addon)]

;make a gravitationally stratified atmosphere
 T0=1.e4
 mp = 1.67e-24 ;proton mass (g)
 ne_addon=n_e[0]*exp(0.5*mp*g[0]*(x_addon-dd)/(kb*T0))	;p=p0 exp{-.5mgz/kT} note: g<0
 n_e=[ne_addon, n_e, reverse(ne_addon)]
 print, 'Chromosphere Depth: '+string((dd-x_addon[0])*g[0]/(-2.74e4)  )+'(cm)'
ENDIF
;assume constant t in the chromosphere
 E_addon=3./2. *2*ne_addon* Kb*T0	;E=3/2 nkt=3/2 2n_e kt
   e=[e_addon, e, reverse(e_addon)]

;04/30/02 - RAM - keep chromosphere area constant.
 a_addon=fltarr(n_depth) + a[0]	;*exp(-1.*(x_addon-dd-x[0])/sqrt(a[0])
    a=[a_addon, a, reverse(a_addon)]

;constant velocity, gravity and heating
  c0=fltarr(n_depth)+1
    v=[c0*v(0), v, c0*v(n_elements(v)-1)]
    g=[c0*g(0), g, c0*g(n_elements(g)-1)]
  e_h=[c0*0.+q0, e_h0, c0*0+q0]

;************* finish, check, save, exit ***********
 lhist={e:float(e), n_e:float(n_e), v:float(v), time:float(time)}
;(5/13/02) float everything.  Why save double stuff?  Is this bad?  

 sizecheck, lhist,g,A,x, E_h
;Don't know what this stop was for.  Asked Becca about it 
;04/01/2003
;stop
regrid4, lhist,g,a,x,e_h,/showme,/nosave
 sizecheck, lhist,g,A,x, E_h
 N=n_elements(x)
 dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
 junk=check_res( lhist, dv, n_depth, /noisy)

 IF keyword_set(outname) THEN outname=outname $
	ELSE outname='../data/xbp1_'+strcompress(power,/remove_all)+'.idl'

 IF keyword_set(nosave) THEN BEGIN
  print,'not saving' 
 ENDIF ELSE BEGIN
  note="Started with "+loop_file +","+ string(systime())
  print, 'saving file: "'+outname+'"'
  save, file=outname, lhist, g,A,x, E_h, L, T_max, orig, n_depth, note
 ENDELSE

RETURN
END








;+
; NAME:
;	shrec_get_heat
;
; PURPOSE:
;       Generate heat function for input to loopmodel	
;
; CATEGORY:
;	MSULOOP subroutine
;       hd_tools
;
; CALLING SEQUENCE:
;	msu_get_heat, a, x, n_do, delta_t, n_depth, energy=energy, q0=q0, $
;	s_form=s_form, t_form=t_form, bgheat=bgheat
;
; INPUTS:
;	a, x, n_do, delta_t, n_depth,
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;       ENERGY:  Total energy to dump into the corona [ergs]
;       Q0: Volumetric heating rate [ergs/cm^3/s]
;	S_FORM: Normalized distribution of heat in space
;       T_FORM: Normalized distribution of heat in time 
;       BGHEAT: additional background heating [ergs/cm^3/s] 
;       QUIET:  Supress text output
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


FUNCTION shrec_get_heat, a, x, n_do, delta_t, n_depth, ENERGY=ENERGY, Q0=Q0, $
	S_FORM=S_FORM, T_FORM=T_FORM, BGHEAT=BGHEAT, QUIET=QUIET
;OPTIONAL KEYWORDS:
;	 
;	t_form
;	s_form
;	energy
;	q0

space_size=n_elements(x)
time_size =n_do
dv=msu_get_volume(x,a) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DEFINE SPACE AND TIME HEATING STRUCTURE
IF n_elements(s_form) eq 0 THEN s_form=fltarr(space_size-1)+1.
IF n_elements(t_form) eq 0 THEN  t_form=fltarr(time_size )+1.
hot=s_form # t_form
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;RESCALE TO energy [erg] OR TO q0 [erg/cm^3/s], USE VOLUME OF CORONA
IF n_elements(q0) eq 1 THEN hot1=hot*q0 ELSE BEGIN
    IF n_elements(ENERGY) gt 0 THEN BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the corona
        corona=indgen(space_size-1)
        IF n_elements(n_depth) eq 2 THEN corona=corona[n_depth[0]+1:space_size-n_depth[1]-1] $
        ELSE corona=corona[n_depth+1:space_size-n_depth-1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Turn energy [ergs] into a volumetric heating rate [ergs/cm^3/s]
        scl= ENERGY/( delta_t * total((dv[corona]#(fltarr(n_do)+1.))* hot[corona, *] ))
        hot1=hot*scl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        E_corona=total( (hot1[corona, *]) *( dv[corona]#(fltarr(n_do)+1.))*delta_t )
        print,'Total Corona Energy: ',E_corona
        IF abs( ENERGY- E_corona) ge 0.1*ENERGY THEN BEGIN
            print,'Heat funciton is BOGUS!'
            STOP
        ENDIF
    ENDIF ELSE BEGIN            ;if energy & q0 both undefined, don't renormalize
        hot1=hot
        print,'Energy & q0 unspecified. Run with user-defined heat function.'
    ENDELSE
ENDELSE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BACKGROUND HEATING
IF n_elements(bgheat) eq 1 THEN bgheat=bgheat*(fltarr(space_size-1)+1.)
IF n_elements(bgheat) ne space_size-1 AND n_elements(bgheat) ne 0 THEN BEGIN
    print, 'User-defined background is wrong size.  Need '+string(fix(space_size-1))+' elements.'
    STOP
ENDIF
IF n_elements(bgheat) eq space_size-1 THEN BEGIN
    hot1 = hot1 + bgheat#(fltarr(time_size )+1.)
    if not keyword_set(QUIET) then $
      print,'User-defined background incorporated.'
ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;check output size
IF n_elements(hot1[*,0]) ne space_size-1 THEN BEGIN
    print, 'space resolution is off'
    stop
ENDIF 
IF n_elements(hot1[0,*]) ne time_size THEN BEGIN
    print, 'time resolution is off'
    stop
ENDIF 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Output if desired.
if not keyword_set(QUIET) then $
  print, 'min/max of heat function: (erg/s/cm^3)', min(hot1),'/', max(hot1)
RETURN, hot1                    ;variable is returned


END

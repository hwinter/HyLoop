;+
; NAME:
;	cc_heat_function2.pro
;
; PURPOSE:
;	Calculate a heating rate that accounts for both particle collisions
;	(using PATC) and heating due to thermal particle collisions.
;
; CATEGORY:
;      Heat_function	
;
; CALLING SEQUENCE:
	;
;
; INPUTS:
;	 LOOP, time, dt, nt_beam, nt_brems, PATC_heating_rate,
;	 DELTA_MOMENTUM,flux, n_e_change
; 

; NECESSARY SYSTEM VARIABLES:
;   For Heating Function: 
;      !e_h_thermal_array: Array of volumetric heating rates for a
;      given distribution of thermal particles.
;  For PaTC:
;      !beam_index: Current injected beam index
;      !next_beam_time:  Time that the next sub-beam will be injected
;      !injected_beam; The original series of beams.
;      !patc_dt:  The timestep to run PaTC,
;      !patc_next:  The next time PaTC will be run.
;      
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	Volumetric energy input into the loop as a function of volume
;	(N_v-2) position.
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
; 	Written by: HDWII
;       Modified by: Chester Curme
;-

function cc_therm_function, LOOP, time, dt, nt_beam, nt_brems,$
  PATC_heating_rate, extra_flux, DELTA_MOMENTUM, flux, n_e_change, $
  TEST=TEST, ALL_THERM=ALL_THERM



debug=0

all_therm=1

e_h=!e_h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PATC_heating_rate=0d0
volumes=get_loop_vol(loop)
N_E_CHANGE=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PATC Section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine if it is time to inject a new beam.
if keyword_set(TEST) then begin
   PATC_heating_rate=0d0
   e_h = 0*e_h
endif

if time ge !next_beam_time then begin
   nano_s=((mk_distro6(0,$
                       N_PART=!n_nano)+1)/2)*$
          loop.s[n_elements(loop.s)-1]
;Compute heating due to collisions w/o thermal particles
   e_h =get_nfe_gauss_dist(loop,nano_s , $
                                !heating_rate*(1.0)/!n_nano,$
                           !nano_fwhm) ;[ergs cm^-3 !s^-1]

 ;  injected_beam=beam_generator(loop,!E_min_max, $
 ;                               total_energy=!heating_rate*!PATC_dt, $
 ;                               SPEC_INDEX=!spec_index, $
 ;                               time=!PATC_dt, delta_t=!PATC_dt,$
 ;                               IP='z',n_PART=!n_part, $
 ;                               ALPHA=!dist_alpha,$
 ;                               FRACTION_PART=FRACTION_PART)
 ;  new_beam=injected_beam[0].nt_beam
 ;  new_beam.x=nano_s[0]
   
 ;  for i=1, !n_nano-1 do begin
 ;     injected_beam=beam_generator(loop,!E_min_max, $
 ;                                  total_energy=!heating_rate*!PATC_dt, $
 ;                                  SPEC_INDEX=!spec_index, $
 ;                                  time=!PATC_dt, delta_t=!PATC_dt,$
 ;                                  IP='z',n_PART=!n_part, $
 ;                                  ALPHA=!dist_alpha,$
 ;                                  FRACTION_PART=FRACTION_PART)
  ;    injected_beam[0].nt_beam.x=nano_s[i]
  ;    new_beam=[new_beam, injected_beam[0].nt_beam]
  ; endfor
 ;  Case 1 of    
;First beam case.
 ;      !beam_index eq 0: nt_beam=new_beam
 ;      else: nt_beam=concat_struct(nt_beam, $
 ;                                new_beam)
 ;  endcase

 ;   !beam_index++

;    Case 1 of    
;        !beam_index le n_elements(!injected_beam)-1 : $
;if NOT(keyword_set(TEST)) then !next_beam_time=loop.state.time+!PATC_dt  
;        else: !next_beam_time=1d36
;    endcase
!e_h=e_h

endif

if keyword_set(TEST) OR keyword_set(ALL_THERM) then goto, test_skip
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Decide if it is time to run PaTC
;If time ge !patc_next then begin

;Test the beam.
;    if size(nt_beam,/TYPE) EQ 8 then begin
;        alive_part=where(nt_beam.state eq 'NT')
;        help, alive_part
;All the particles have been thermalized.  Skip some steps. 
;        if alive_part [0] ne -1 then begin

;Remove thermalized particles from beam (for expediency)
;nt_beam=nt_beam[alive_part]
;            help, nt_beam
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Here is the actual call to PATC
;            patc, nt_beam,loop,!patc_dt, DELTA_E=DELTA_E,$
;                  DELTA_MOMENTUM=DELTA_MOMENTUM,NT_BREMS=NT_BREMS,$
;                  N_E_CHANGE=N_E_CHANGE
            
;   help, nt_beam (nt_beam changes in patc)
;Convert the keV lost by nt particles into ergs gained by the plasma.
;Convert to power [ergs/sec]              
;            PATC_heating_rate=abs(-1d*DELTA_E*!msul_keV_2_ergs)/(!patc_dt) ;(dt) 
;DELTA_E < 0



;Now convert to a volumetric heating rate and add it to the coronal heating
;            PATC_heating_rate=(PATC_heating_rate/volumes)   
;            !patc_heat= 0;PATC_heating_rate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;;             print,'Total energy from NT particles:',$
;;                   total(PATC_heating_rate*dt), ' ergs'
;;             print,'Total power from NT particles:', $
;;                   total(PATC_heating_rate), ' ergs s^-1'
;            
;            if total(PATC_heating_rate) le 0d then begin
;                if DEBUG gt 0 then print, 'Total(PATC_heating_rate) le 0d'
;            endif      
;End Cheat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;        endif else begin
;           PATC_heating_rate=0d
;           !patc_heat*=PATC_heating_rate
;           endelse
;     endif else begin
;    PATC_heating_rate=!patc_heat
;    e_h=!e_h

; endelse


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End PaTC Section
;endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

test_skip:
;stop
;help, PATC_heating_rate, e_h
return, (e_h) ;sum of contributions to heating rate
END

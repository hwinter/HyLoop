;+
; NAME:
;	cc_heat_function.pro
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

function cc_heat_function, LOOP, time, dt, nt_beam, nt_brems,$
  PATC_heating_rate, extra_flux, DELTA_MOMENTUM, flux, n_e_change, $
  TEST=TEST

debug=0

NO_BREMS=1

;For Test run ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set(TEST) then begin
   PATC_heating_rate=0d0
   e_h =0.
   volumes=get_loop_vol(loop)
   if time ge !next_beam_time then begin
       e_h = transpose(!e_h_thermal_array[*,!beam_index])#volumes
       !beam_index++
       !next_beam_time += dt
   endif
endif
if keyword_set(TEST) then goto, test_skip
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Remove thermalized particles from beam (for expediency)
nt_beam = nt_beam[where(nt_beam.state eq 'NT')]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PATC_heating_rate=0d0
volumes=get_loop_vol(loop)
N_E_CHANGE=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PATC Section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine if it is time to inject a new beam.
e_h = 0.
if time ge !next_beam_time then begin

;Compute heating due to collisions of thermal particles
   e_h = transpose(!e_h_thermal_array[*,!beam_index])#volumes ;[ergs s^-1]

    Case 1 of    
;First beam case.
       !beam_index eq 0 : begin
           nt_beam=!injected_beam[0].nt_beam
       end
       !beam_index le n_elements(!injected_beam)-1 : begin
           nt_beam=concat_struct(nt_beam, $
                                 !injected_beam[!beam_index].nt_beam)
       end
   endcase

    !beam_index++

    Case 1 of    
        !beam_index le n_elements(!injected_beam)-1 : $
          !next_beam_time=!injected_beam[!beam_index].time        
        else: !next_beam_time=1d36
    endcase

endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Decide if it is time to run PaTC
If time ge !patc_next then begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Test the beam.
    if size(nt_beam,/TYPE) EQ 8 then begin
        alive_part=where(nt_beam.state eq 'NT')
;        help, alive_part
;All the particles have been thermalized.  Skip some steps. 
        if alive_part [0] ne -1 then begin
;            help, nt_beam
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Here is the actual call to PATC
            patc, nt_beam,loop,!patc_dt, DELTA_E=DELTA_E,$
                  DELTA_MOMENTUM=DELTA_MOMENTUM,NT_BREMS=NT_BREMS,$
                  N_E_CHANGE=N_E_CHANGE
            
;   help, nt_beam (nt_beam changes in patc)
;Convert the keV lost by nt particles into ergs gained by the plasma.
;Convert to power [ergs/sec]              
            PATC_heating_rate=abs(-1d*DELTA_E*!msul_keV_2_ergs)/(!patc_dt) ;(dt) 
;DELTA_E < 0



;Now convert to a volumetric heating rate and add it to the coronal heating
            PATC_heating_rate=(PATC_heating_rate/volumes)    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;;             print,'Total energy from NT particles:',$
;;                   total(PATC_heating_rate*dt), ' ergs'
;;             print,'Total power from NT particles:', $
;;                   total(PATC_heating_rate), ' ergs s^-1'
            
            if total(PATC_heating_rate) le 0d then begin
                if DEBUG gt 0 then print, 'Total(PATC_heating_rate) le 0d'
            endif      
;End Cheat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        endif else PATC_heating_rate=0d0
    endif
    !patc_next=time+!patc_dt
endif 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End PaTC Section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

test_skip:
return, (PATC_heating_rate + e_h) ;sum of contributions to heating rate
END

;+
; NAME:
;      bg_with_patc_gaussian_apex_heating
;
; PURPOSE:
;	Add a previously save 
;
; CATEGORY:
;      Heat_function	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	 LOOP, time, dt,
; 

; NECESSARY SYSTEM VARIABLES:
;   For Heating Function:
;      !bg_heat: Background volumetric heating rate. [erg cm^-3 s^-1]
;  For PaTC:
;      !beam_index: Current injected beam index
;      !next_beam_time:  Time that the next sub-beam will be injected
;      !injected_beam; The original series of beams.
;      !patc_dt:  The timestep to run PaTC,
;      !patc_next:  The next time PaTC will be run.
;  For the thermal flare energy
;      !sigma: Gaussian sigma for the deposition of heat around the
;      loop apex. [cm]
;      
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	Heat: Volumetric energy input into the loop as a function of volume (N_v-2) position.
;             []  
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
; 	Written by:HDWII
;-

function bg_with_patc_gaussian_apex_heating, LOOP, time, dt, nt_beam, nt_brems,$
  PATC_heating_rate, extra_power, $
  DELTA_MOMENTUM,flux, n_e_change
debug=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PATC_heating_rate=0d0
volumes=get_loop_vol(loop)
N_E_CHANGE=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PATC Section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine if it is time to inject a new beam.
if time ge !next_beam_time then begin

    Case 1 of    
;First beam case.
       !beam_index eq 0 : begin
           nt_beam=!injected_beam[0].nt_beam 
           extra_power=!injected_beam[0].thermal_e $
                      /(total(volumes)*!patc_dt)
       end
       !beam_index le n_elements(!injected_beam)-1 : begin
           nt_beam=concat_struct(nt_beam, $
                                 !injected_beam[!beam_index].nt_beam)  
           extra_power=!injected_beam[!beam_index].thermal_e $
                      /(total(volumes)*!patc_dt)
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
            patc, nt_beam,loop[0],!patc_dt, DELTA_E=DELTA_E,$
                  DELTA_MOMENTUM=DELTA_MOMENTUM,NT_BREMS=NT_BREMS,$
                  N_E_CHANGE=N_E_CHANGE
            
;   help, nt_beam
;Convert the keV lost by nt particles into ergs gained by the plasma.
;Convert to power [ergs/sec]              
            PATC_heating_rate=abs(-1d*DELTA_E*!shrec_keV_2_ergs)/(!patc_dt) ;(dt) 

            ph_f=PATC_heating_rate
            for count=0ul,10ul do ph_f=smooth(ph_f, 3)

            ph_r=reverse(PATC_heating_rate)
            for count=0ul,10ul do ph_r=smooth(ph_r, 3)
            PATC_heating_rate=(ph_f+reverse(ph_r))/2d0

            for ii=0, 10 do N_E_CHANGE=smooth(N_E_CHANGE, 3)
  



;Now convert to a volumetric heating rate and add it to the coronal heating
            PATC_heating_rate=(PATC_heating_rate/volumes)    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;Cheat to force a symmetric heating profile
;            n_eh=n_elements(PATC_heating_rate)
;            even_odd_test= n_eh mod 2;
;
;            case 1 of 
;                (even_odd_test eq 1):begin
;                    temp1=PATC_heating_rate
;                    temp2=temp1
;                    temp1[0:(n_eh/2)-1ul]=$
;                      reverse(PATC_heating_rate[(n_eh/2)+1ul:*])
;                    temp2[(n_eh/2)+1ul:*]=
;                end
;                (even_odd_test eq 0):begin
;                    PATC_heating_rate[0:(n_eh/2)-1ul]=$
;                     reverse(PATC_heating_rate[(n_eh/2):*])
;
;                end
;            endcase
            print,'Total energy from NT particles:',$
                  total(PATC_heating_rate*dt), ' ergs'
            print,'Total power from NT particles:', $
                  total(PATC_heating_rate), ' ergs s^-1'
            
            if total(PATC_heating_rate) le 0d then begin
                if DEBUG gt 0 then print, 'Total(PATC_heating_rate) le 0d'
            endif      
;End Cheat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        endif else PATC_heating_rate=0d0
    endif
    !patc_next=time+!patc_dt
endif 

if time gt max(!injected_beam.time) then extra_power=0d0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;End PaTC Section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Begin the thermal flare energy distributed as a gaussian.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_cells=n_elements(loop.state.n_e)
f=exp(-(((loop.s_alt[1:n_cells-2]-loop.l_half)^2.0)/(2.0*(!sigma^2.0))))
f=f/total(f)
thermal_flare_heating=extra_power*f
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Add it all together for the final heating function.
heat=!bg_heat+PATC_heating_rate+thermal_flare_heating
;stop
return, heat
END

function get_xr_emiss, loop, nt_brems, $
  E_RANGE=E_RANGE,ENERGIES=ENERGIES, $
  NT_ONLY=NT_ONLY, THERM_ONLY=THERM_ONLY,$
  DT=DT, PER_VOL=PER_VOL

case 1 of 
    abs(not keyword_set(E_RANGE) and not keyword_set(ENERGIES)):begin
        energy_array=nt_brems[0].PH_ENERGIES
        N_ENERGIES=n_elements(energy_array)
    end
    abs(not keyword_set(ENERGIES)):begin
        N_ENERGIES=100.
        energy_array=E_RANGE[0]+$
                     (E_RANGE[1]-E_RANGE[0])*dindgen(N_ENERGIES)/(N_ENERGIES-1.)
    end

    else:begin
        energy_array=ENERGIES
        N_ENERGIES=n_elements(energy_array)
    endelse
endcase 
ENERGIES=energy_array

if not keyword_set(dt) then dt=1d0

;if  keyword_set(NOT_EARTH) then d_factor=4*!dpi else $
;  d_factor=4*!dpi*(1.496d13)*(1.496d13)
d_factor=4.*!dpi 

;low_index=where(abs(E_RANGE[0]-nt_brems.n_photons) $
;                eq min(abs(E_RANGE[0]-nt_brems.n_photons)))
;if low_index[0] eq -1 then low_index=0
;
;high_index=where(abs(E_RANGE[0]-nt_brems.n_photons) $
;                eq min(abs(E_RANGE[0]-nt_brems.n_photons)))
;if high_index[0] eq -1 then $
;cd sybc
high_index=n_elements(nt_brems[0].n_photons)-1u 

em=get_loop_em(loop, T=temp)
n_em=n_elements(em)
vol=get_loop_vol(loop)

if keyword_set(PER_VOL) then $
  vol=get_loop_vol(loop)  else $
  vol=dblarr(n_elements(em))+1d0

vol2=rebin(vol, n_em, N_ENERGIES)

case 1 of 
    keyword_set(nt_only):begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non-Thermal Part        
        signal_nt=dblarr(n_em, N_ENERGIES)
                                ;last_index=n_elements(loop.state.n_e)-2ul
        for i=0ul, n_em-1ul do begin
            photons=nt_brems[i].n_photons
            junk=where(finite(photons) ne 1)
            if junk[0] ne -1 then photons[junk]=0
 
;[photons s^-1]          
            signal_nt[i,*]=spline(nt_brems[i].PH_ENERGIES,photons , $
                                  energy_array)
            
;[photons s^-1 sr^-1 cm ^-3] 
            signal_nt[i,*]=signal_nt[i,*]/(d_factor*vol[i])
            
        endfor
        signal=signal_nt
    end

    keyword_set(THERM_ONLY):begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermal Part        
;Make an wavelength array to spline to.
;Convert keVs to Angstroms.      
        
        wave=reverse(kev2ang(energy_array))
        
;Get thermal spectrum [photons s^-1 sr^-1]
        signal_thermal=get_db_therm_spec(loop, wave)/(vol2)
;Now units are  [photons s^-1 sr^-1 cm ^-3] 
        signal_thermal=reverse(signal_thermal,2, /OVERWRITE)        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        signal=signal_thermal
        end
        else:begin
            signal_nt=dblarr(n_em, N_ENERGIES)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Thermal Part        
            signal_thermal=dblarr(n_em, N_ENERGIES)
;Make an wavelength array to spline to.
;Convert keVs to Angstroms.
            
            wave=reverse(kev2ang(energy_array))

;Get thermal spectrum[photons s^-1 sr^-1]
            signal_thermal=get_db_therm_spec(loop, wave)/(vol2)
;Now units are photons s^-1 sr^-1 cm ^-3
            signal_thermal=reverse(signal_thermal,2, /OVERWRITE)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non-Thermal Part        
        signal_nt=dblarr(n_em, N_ENERGIES)
        ;last_index=n_elements(loop.state.n_e)-2ul
        for i=0ul, n_em-1ul do begin
            photons=nt_brems[i].n_photons
            junk=where(finite(photons) ne 1)
            if junk[0] ne -1 then photons[junk]=0            
;[photons s^-1]          
            signal_nt[i,*]=spline(nt_brems[i].PH_ENERGIES,photons , $
                                  energy_array)
;[photons s^-1 sr^-1 cm ^-3] or Unit sphere
            signal_nt[i,*]=signal_nt[i,*]/(d_factor*vol[i])
        endfor   
        
        signal=signal_nt+signal_thermal
       
    end
endcase

;Output is Photons sec^-1 sr^-1 cm ^-3 
 signal>=0
return, signal                  ;
END



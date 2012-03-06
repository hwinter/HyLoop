
;Creates an array of the energies in each of the 499 loops
;created by Kathy's program by restoring each loop file and
;then putting the energy values from the files into an array
pro restore_kloop, loopnum, loop_energy


DEFSYSV, '!lf_loop_energy', EXISTS = test
IF test ne 1 THEN begin
   PRINT, 'Variable !lf_loop_energy does not exist'
   exit
   stop
   endif ELSE loop_energy=!lf_loop_energy
; path = '/home/nlarson/0.1MA_5.e9lam_25.Ic_2.1e16m0_0.1rn/hyloop_input/'
; files = find_files('*.genx',path)

;    restgen, file=files[loopnum], struct
;    loop_energy=struct.energy
   ; loop_dt[i]=struct.heating_width     

end



;Uses the formula f(x)=a*e^-((x-b)^2/2c^2) to plot a Gaussian
;distribution of energy over flare length
;a=height of peak parameter / scaling factor = total energy/sigma*sqrt(2pi) for this simulation
;b=max height position (1/2 max x value)
;c=FWHM/2sqrt(2ln2)=sigma
function gaussian_at_xVal, s

COMMON variables, sigma, total_energy, loop_length

; a=total_energy/(sigma*sqrt(2.0*!dpi))

 b=.5*loop_length
 c=sigma

 return, exp(-(((s-b)^2.0)/(2.0*(c^2.0))))

end

;Calculates the integral of the energy over space function, f(s) by
;calculating the integral of a Gaussian distribution of energy over the
;length of the loop*area along loop.
;Puts the distances from 0 on the loop into the array xVals (excludes
;the first and last s_alt loop volumes, which are boundary conditions) and gets
;yVals by using a Gaussian function.  Uses the int_tabulated IDL
;function to obtain the integral, given the x-values and the y-values *
;the coresponding areas of slices along the loop
function calc_energy_per_vol, loop, yVals = yVals

COMMON variables, sigma, total_energy, loop_length

;You must restore a loop file before running this program.  Use code
;similar to the code below to do this, or un-comment the code below
;and modify to restore a particular loop  
;path = '$DATA/learning/trae_old_data/'
;restore, path+'patc_test_'+STRTRIM(0,2)+STRTRIM(0,2)+STRTRIM(0,2)+STRTRIM(0,2)+STRTRIM(10,2)+'.loop'

 ;Number of volume segments
 salt =  n_elements(loop.s_alt)
 ;Array of distances from leftmost edge of loop or distance along the loop  
 xVals = loop.s_alt[1:salt-2]  

 ;Will become the array of energies at corresponding x values
 yVals = dblarr(salt-2)

 ;Fills yVals with energies at given lengths(xVals[i]) along the loop
 for i=0,salt-3 do begin
    yVals[i]=gaussian_at_xVal(xVals[i])
 endfor

 ;Takes the integral over all xVals and yVals*loop area
 integral_over_space = int_tabulated(xVals, yVals*loop.a)  

;The function returns the array of energy densities for the volume segments
 return, integral_over_space

end



;dt is the width of the entire triangle
;time is the x-value at which the percent heating in the loop
;(y-value) is obtained
function tri, time, dt
if time le dt then $ 
   num=abs(abs((dt/2.)-time)-(dt/2.))/(dt/2.) else $
      num=0d0
 return, num
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main function of program
; Give the function the loop number (from Kathy's loop
; directory), one of Trae's restored loops, a time and delta time
; 
; The function returns an array: the ergs per loop volume segment per
; second 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function e_flare_natalie_nt, loop, time, dt, nt_beam, nt_brems,PATC_heating_rate,$
                             extra_flux, DELTA_MOMENTUM, flux, n_e_change
  triangle_dt=40.
  DEFSYSV, '!loop_num', EXISTS = test
  IF test ne 1 THEN begin
     PRINT, 'Variable loop_num does not exist' 
     stop
  endif ELSE loopnum=!loop_num

;The fraction of the flare energy that goes into the creation of
;non-thermal particles.
  DEFSYSV, '!fraction_part', EXISTS = test
  IF test ne 1 THEN begin
     PRINT, 'Variable fraction_part does not exist' 
     stop
  endif 

; Creates an array of the energies in each of the 499 loops
; created by Kathy's program and gets values for lengths of time functions for loops (from Kathy's model). 
  restore_kloop, loopnum, loop_energy

;sigma=standard deviation
  COMMON variables, sigma, total_energy, loop_length
  sigma = 1d8
  total_energy = loop_energy

;This takes into account that the energy from the file is from an
;arcade 1d10 cm long and we only want the portion for a single loop.
  total_energy*=(2d0*(max(loop.rad)))/1d10
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Split the energy into thermal and nonthermal components.
  thermal_energy=(1.0-!fraction_part)*total_energy
  nt_energy_partition=!fraction_part*total_energy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Determine the non-normalized temporal fraction of the energy
  time_fraction=tri(time, triangle_dt)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;thermal section
  loop_length = loop.l

;gets the integral of the space function over the length of the loop;
;takes the area of the loop and the length along the loop into account
;Also gets the array of yVals in the space function, f(s)
  integral_over_space = calc_energy_per_vol(loop, yVals = f_of_s)
  
;since the height of the triangle function is 1, the area of the
;function = 1/2 * base * height of triangle = 1/2 * triangle_dt * 1 = 1/2 * triangle_dt
  integral_over_time = triangle_dt/2.


;This function comes from Reeves, Warren, Forbes paper and other
;previous work.  
  e_flare_value = thermal_energy/(integral_over_time*integral_over_space)

  ergs_per_cm3_s = e_flare_value*f_of_s*time_fraction

;This takes into account that the energy from the file is from an
;arcade 1d10 cm long and we only want the portion for a single loop.
  e_h=get_p_t_law_const_flux_heat(loop, time, dt, nt_beam, nt_brems, $
                                  PATC_heating_rate, extra_flux, $
                                  DELTA_MOMENTUM, flux, n_e_change)

;pmm, e_h
;pmm, ergs_per_cm3_s
;if max(ergs_per_cm3_s) gt 1 then stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Non-thermal section
  nt_energy=nt_energy_partition*(time_fraction/integral_over_time)
  if max(nt_energy) gt 0 then begin
;Fraction part is set to one because I am defining the total energy as
;the non-thermal energy partition. 
     injected_beam=beam_generator(loop,!E_min_max, $
                                  total_energy=nt_energy, $
                                  SPEC_INDEX=!spec_index, $
                                  time=!PATC_dt, delta_t=!PATC_dt,$
                                  IP='z',n_PART=!n_part, $
                                  ALPHA=!dist_alpha,$
                                  FRACTION_PART=1.0)
     n_beam=n_elements(nt_beam)
     if n_beam[0] le 0 then nt_beam=injected_beam[0].nt_beam $
     else $
        nt_beam=[nt_beam, injected_beam[0].nt_beam]
  endif

  n_beams=n_elements(nt_beam)
;
  if n_beams gt 0 then $
     alive_part=where(strlowcase(nt_beam.state) eq 'nt') $
  else alive_part=-1
;    
  if alive_part[0] ne -1 then begin
        
     patc, nt_beam,loop,dt, DELTA_E=DELTA_E,$
           DELTA_MOMENTUM=DELTA_MOMENTUM,NT_BREMS=NT_BREMS,$
           N_E_CHANGE=N_E_CHANGE, /NO_BREMS
     
     alive_part=where(strlowcase(nt_beam.state) eq 'nt')
     if alive_part[0] ne -1 then nt_beam=nt_beam[alive_part]
;   help, nt_beam (nt_beam changes in patc)
;Convert the keV lost by nt particles into ergs gained by the plasma.
;Convert to power [ergs/sec]              
     PATC_heating_rate=abs(-1d*DELTA_E*!shrec_keV_2_ergs/(!patc_dt)) ;(dt) 
     PATC_heating_rate/=get_loop_vol(loop)
        
  endif else PATC_heating_rate=0.0
 ;    help,  ergs_per_cm3_s
 ;    pmm, ergs_per_cm3_s
 ;    help, e_h
 ;    pmm, e_h
 ;    help, PATC_heating_rate
 ;    pmm, PATC_heating_rate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  return,  ergs_per_cm3_s+e_h+PATC_heating_rate


end






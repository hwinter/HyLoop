;+
; NAME:
;	nano_flare_const_flux_mk_heat.pro
;
; PURPOSE:
;
;
; CATEGORY:
;      Heat_function	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	 LOOP,  gamma, heat_flux
; 

; NECESSARY SYSTEM VARIABLES:
;      
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	fileVolumetric energy input into the loop as a function of volume
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

pro nano_flare_const_flux_mk_heat, loop, alpha, heat_flux, dt, total_time, $
                                   SPATIAL_FWHM=SPATIAL_FWHM, $
                                   E_LOW=E_LOW, E_HIGH=E_HIGH, FILE=FILE, $
                                   TAU_MIN=TAU_MIN, TAU_MAX=TAU_MAX, detailed_file=detailed_file
  
if min(loop.s) lt -1 then begin
   Loop.s+=abs(min(loop.s))
endif


;Heat flux erg cm^-2 s^-1
volumes=get_loop_vol(loop, TOTAL=total_volume)
n_volumes=n_elements(volumes)
Total_energy=heat_flux*total_volume*total_time ;Ergs
n_timesteps=ulong(total_time/dt)+1
times=dindgen(n_timesteps)
E_h=rebin(loop.e_h, n_volumes, n_timesteps)

min_s=loop.depth
max_s=loop.l-loop.depth
delta_s=max_s-min_s

one_minus_alpha=1d0-alpha
events=0d
events_s_center=events
events_time=events
event_tau=events
total_events=events

delta_tau=TAU_MAX-TAU_MIN

While total_events le Total_energy do begin
;Randomly pick an energy from E_LOW to E_HIGH based on a power law of
;index ALPHA.  Logic is based on the beam_generator.pro program and
;taken from the Numerical Recipes in C++ section on random deviates.   
   A_0=one_minus_alpha/((E_HIGH^(one_minus_alpha))-(E_LOW^(one_minus_alpha)))   
   new_event =abs(randomu(seed)*(one_minus_alpha/A_0) )^(1d0/one_minus_alpha)
   new_event<=E_HIGH
   new_event>=E_LOW
   
   
;Randomly define the center of the nano-flare event   
   nano_s=min_s+randomU(seed)*delta_s
;Convolve with a Gaussian   
   g_nano=gaussian(loop.s_alt[1:n_elements(loop.s_alt)-2ul],$
                   [1.0, nano_s, SPATIAL_FWHM/2.3548], /DOUBLE)
   
   g_nano=new_event*(g_nano/total(g_nano))

;Randomly choose a time to put the heating event.
   time_index=ulong(randomu(seed)*n_timesteps)
   time_index<=n_timesteps-1
  
;Randomly choose a lifetime of the heating event.
   tau=TAU_MIN+randomu(seed)*delta_tau
   tau>=TAU_MIN
   tau<=TAU_MAX
;Here we are assume a step function in time.  On then off.   
   g_nano=g_nano/tau


   n_steps_half=((tau/dt)/2.)
   
   time_low=(time_index-n_steps_half)
   time_high=(time_index+n_steps_half)

;If outside the time range just cut it off.
   time_low>=0
   time_high<=n_timesteps-1
   n_times=n_elements(times[time_low:time_high])
   E_h[*, time_low:time_high]+=rebin(g_nano, n_volumes, n_times)

  
;Update the arrays
   events=[events, new_event]
   events_s_center=[events_s_center, nano_s]
   events_time=[events_time, time_index*dt]
   total_events+=new_event
   
   
endwhile
;Get rid of the leading blank values
events=events[1:*]
events_s_center=events_s_center[1:*]
events_time=events_time[1:*]

;Save everything,
save, events, events_s_center,events_time, times, E_h, $
      file=detailed_file


;Save Only the parts needed for the heat function,
save, times, E_h, $
      file=file


END

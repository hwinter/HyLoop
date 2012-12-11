;+
; NAME:
;	
;
; PURPOSE:
;	
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function power_law_dist,SPEC_INDEX,  min_max,  N_PART= N_PART
  delta_e=min_max[1]-min_max[0]
  one_minus_delta=1d0-SPEC_INDEX
  if not keyword_set(N_PART) then  N_PART=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make the energy arrays
  A_0=one_minus_delta/((min_max[1]^(one_minus_delta))-(min_max[0]^(one_minus_delta)))
  
  energies=abs(randomu(seed,N_PART)*(one_minus_delta/A_0) )^(1d0/one_minus_delta)
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    if min(energies) lt min_max[0] then $
      MIN_E=(min(energies)-min_max[0]) else $
      MIN_E=0
    energies=energies-MIN_E
    done=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    while not done do begin
        junk=where(energies gt min_max[1])
        if junk[0] eq -1 then done =1 else begin
            n_junk=n_elements(junk)
            energies[junk]=abs(randomu(seed,n_junk)*(one_minus_delta/A_0) )^(1d0/one_minus_delta)
        endelse
     endwhile
  return, energies

END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function mk_sarkar_walsh_nano_flares, length, loop_vol, $
                                      FLUX=FLUX, DURATION=DURATION,$
                                      E_RANGE=E_RANGE, TAU_RANGE=TAU_RANGE, $
                                      N_STRANDS=N_STRANDS, DIST_ALPHA=DIST_ALPHA,$
                                      SPEC_INDEX=SPEC_INDEX,SAVE_FILE=SAVE_FILE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if not keyword_set(FLUX) then flux=4d5
if not keyword_set(DURATION) then duration=1.725e4
if not keyword_set(E_RANGE) then e_range=[1e23, 5e24]
if not keyword_set(TAU_RANGE) then tau_range=[50.,150.]
if not keyword_set(N_STRANDS) then n_strands=1ul
if not keyword_set(DIST_ALPHA) then dist_alpha=0
if not keyword_set(SPEC_INDEX) then SPEC_INDEX=2.29
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nano_flares={start_time:0.0, duration:0.0,Energy:0.0, $
             relative_position:0.0, strand_number:0ul }
total_energy=dblarr(duration)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
For iii=0ul, ulong(duration)-1 do begin
   loop_flux=total_energy[iii]*length/loop_vol
   
;For each itieration of the while loop add a nanoflare until the total
;flux for the global loop reached.
   while loop_flux le .95*FLUX do begin
      temp_struct=nano_flares[0]
;Start time
      temp_struct.start_time=iii;randomu(seed, 1)
;Duration
      temp_struct.duration=tau_range[0]+randomu(seed, 1)*(tau_range[1]-tau_range[0])
;Strand Number
      temp_struct.strand_number=ceil((randomu(seed, 1)*(n_strands))-1)
;Position
      temp_struct.relative_position=randomu(seed, 1)
;Energy
      temp_struct.energy=power_law_dist(SPEC_INDEX,  E_RANGE)/temp_struct.duration
      if iii+temp_struct.duration le duration-1 then $
         total_energy[iii: iii+temp_struct.duration]+=temp_struct.energy $
      else $
         total_energy[iii:*]+=temp_struct.energy
;recompute the flux
      loop_flux=(total_energy[iii]*length)/loop_vol
      if loop_flux le 1.15*FLUX then begin
         
         nano_flares=concat_struct(nano_flares, temp_struct)
         
      endif else begin

         if iii+temp_struct.duration le duration-1 then $
            total_energy[iii: iii+temp_struct.duration]-=temp_struct.energy $
         else $
            total_energy[iii:*]-=temp_struct.energy
         
      endelse

         ;print, loop_flux/FLUX
   endwhile ; loop_flux lt FLUX 
   
endfor ;iii loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nano_flares=nano_flares[1:*]
index=sort(nano_flares.start_time)
nano_flares=nano_flares[index]
nano_e_range=e_range
nano_DIST_ALPHA=DIST_ALPHA
nano_SPEC_INDEX=SPEC_INDEX

if  keyword_set(SAVE_FILE) then begin
   if type(SAVE_FILE) ne 7 then $
      save_file='s_w_nanoflare.sav'
   
   save, nano_flares,flux, duration ,nano_e_range, nano_DIST_ALPHA,$
         nano_SPEC_INDEX, N_STRANDS, FILE=SAVE_FILE
endif
;stop
return, nano_flares
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

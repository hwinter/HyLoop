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



pro mk_hxr_data, n_iterations, run_dirs, $
                 MIN_PHOTON=MIN_PHOTON, MAX_PHOTON=MAX_PHOTON,$ ;keV
                 PHOT_FROM_FILES=PHOT_FROM_FILES,$
                 FILE_PREFIX=FILE_PREFIX, $
                 FILE_EXT=FILE_EXT,$
                 OUTFILE=OUTFILE, OVERWRITE=OVERWRITE,$
                 MAX_FILES=MAX_FILE,$
                 total_energy=total_energy, $
                 SPEC_INDEX=SPEC_INDEX, $
                 ALPHA=ALPHA,$
                 FRACTION_PART=FRACTION_PART,$
                 BEAM_TIME=BEAM_TIME, Flare_energy=Flare_energy
                 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  if not keyword_set(MIN_PHOTON) then    MIN_PHOTON_in=1  else $ ;keV
     MIN_PHOTON_in=MIN_PHOTON
  if not keyword_set(MAX_PHOTON) then    MAX_PHOTON_in=100   else $ ;keV
     if not keyword_set(FILE_PREFIX) then FILE_PREFIX_in='*' else $
        FILE_PREFIX_in=FILE_PREFIX
  if not keyword_set(FILE_EXT) then FILE_EXT_in='loop' else $
     FILE_EXT_in=FILE_EXT
 if not keyword_set(OUTFILE) then OUTFILE_in='hxr_data.sav' else $
    OUTFILE_in=OUTFILE

;Time from one loop file to another 
  time_step=60.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  MAX_FILES=900
;Non_thermal particle properties
;Determine the flux of of particles in each energy bin
;Very hard energy spectrum here.
  delta_index=3d
  energies=[15d,200d]

;How long will the beam be injected?
  beam_dt=0.1; [sec]
  inj_time=beam_time
;Total beam energy in ergs
;1d30 is the energy determined by Sui et al. 2005 for 
; the 2002_APR_15 flare
  Flare_energy=1d+30

;Number of test particles per beam.
  num_test_particles=(1500d0)
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  if not keyword_set(MIN_PHOTON) then    MIN_PHOTON_in=1  else $ ;keV
     MIN_PHOTON_in=MIN_PHOTON
  if not keyword_set(MAX_PHOTON) then    MAX_PHOTON_in=100   else $ ;keV
     if not keyword_set(FILE_PREFIX) then FILE_PREFIX_in='*' else $
        FILE_PREFIX_in=FILE_PREFIX
  if not keyword_set(FILE_EXT) then FILE_EXT_in='loop' else $
     FILE_EXT_in=FILE_EXT

  n_runs=n_elements(run_dirs)
  
  files=file_search(run_dirs[0],FILE_PREFIX_in+'*'+FILE_EXT_in,$
                   /FULLY_QUALIFY_PATH)
  
  restore, files[0]
  vols=get_loop_vol(loop)
  n_vol=n_elements(vols)

  if keyword_set(PHOT_FROM_FILES) then begin
     MIN_PHOTON_in=min(nt_brems.PH_ENERGIES)
     MAX_PHOTON_in=(nt_brems.PH_ENERGIES)
     
  endif else begin
     ph_energies=MIN_PHOTON+dindgen(MAX_PHOTON-MIN_PHOTON+1d)
     n_ph_e_array=n_elements(ph_energies)
     n_photons=dblarr(n_ph_e_array)
  endelse

  nt_brems={ph_energies:ph_energies,$
            n_photons:n_photons}
  nt_brems_array=replicate(nt_brems,n_vol, n_iterations,MAX_FILES )
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;Randomly cycle through the available run folders  
  for i=0ul, n_iterations-1ul do begin
     
     random_index=fix(randomu(seed)*n_runs)
     random_index<=n_runs-1
     print, 'Using folder:'
     print, run_dirs[random_index]
     print, ''
;Find the files that meet the criteria
     files=file_search(run_dirs[random_index],$
                       FILE_PREFIX_in+'*'+FILE_EXT_in,$
                       count=file_count,/FULLY_QUALIFY_PATH)
     restore, files[0]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Generate the structure containing the injected beam
;Define the number of iterations you are going to
;   need for your electron beam.
        N_beam_iter=long(inj_time/beam_dt)
        E_min_max=[min(energies),max(energies)]
;
        injected_beam=beam_generator(loop,E_min_max, $
                                     total_energy=Flare_energy, $
                                     SPEC_INDEX=SPEC_INDEX, $
                                     time=beam_time, delta_t=beam_dt,$
                                     IP='z',n_PART=num_test_particles, $
                                     ALPHA=ALPHA,$
                                     FRACTION_PART=FRACTION_PART, $
                                     T_PROFILE='Gaussian')


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     for j=0UL, file_count-1UL do begin
        restore, files[j]     
        print, files[j]

        nt_brems=nt_brems_array[*,i,j]
        done=0
        time=0ul
        ii=0ul
        while not done do begin
           print, 'Time: '+string(time)
           if ii ne 0 then $
              nt_particles=[nt_particles, injected_beam[ii].nt_beam] $
           else nt_particles=injected_beam[ii].nt_beam
           
           patc, nt_particles,loop,beam_dt, $
                 OUT_BEAM=OUT_BEAM,$
                 MIN_PHOTON=MIN_PHOTON, MAX_PHOTON=MAX_PHOTON,$
                 NT_BREMS=NT_BREMS

;Increase the number of photons

           nt_brems_array[*,i,j].n_photons+=NT_BREMS.n_photons
           good_index=where(strlowcase(nt_particles.state) eq 'nt')
           if good_index[0] ne -1 then $
              nt_particles=nt_particles[good_index] 
;
           time+=beam_dt
           ii++

           case 1 of 
              time ge time_step : done =1
              (time gt inj_time) and (good_index[0] eq -1) :done =1
              else:
             
           endcase


        endwhile
     endfor

  endfor
  save, nt_brems_array, FILE=outfile_in
END

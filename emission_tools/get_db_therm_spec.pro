function get_db_therm_spec ,loop, wave, $
  SPEC_FOLDER=SPEC_FOLDER, units=units, NO_EM=NO_EM,$
  LAMBDA=LAMBDA

in_loop=loop[0]
if not keyword_set(SPEC_FOLDER) then $
  spec_folder=Getenv('DATA')+ $
              '/spectral_dbase/mazzotta_etal/sun_coronal/'

em=get_loop_em(in_loop, T=temp)
temp=alog10(temp)
n_vols=n_elements(em)

restore, spec_folder+ 'spec_files_index.sav'

if size(wave, /TYPE) eq 0 then begin
    restore,  spec_folder+spec_files[30,30]
    wave=lambda
endif

Wmin=min(wave)
Wmax=max(wave)


photons=dblarr(n_vols, n_elements(wave))

for i=0ul, n_elements(em)-1ul do begin
    n_e_index=where(abs(n_e-loop.state.n_e[i+1]) eq $
                    min(abs(n_e-loop.state.n_e[i+1])))
    T_index=where(abs(T-temp[i]) eq $
                    min(abs(T-temp[i])))
    spec_file=spec_files[t_index[0], n_e_index[0]]
    ;print, T[t_index[0]], n_e[n_e_index[0]]
    ;Units here are  photons cm^3 s^-1 sr^-1
    restore,  spec_folder+spec_file
    if spectrum[0] eq -1 then begin
        photons[i, *]=0d0  
      ;  print, 'Dang!' 
    endif else begin
        
        lmin=min(lambda)
        lmax=max(lambda)

        index=where(lambda ge Wmin and lambda le Wmax)
        if index[0] ne -1 then begin
          photons[i, *]=spline(lambda, spectrum, wave)
          if not keyword_set(NO_EM) then $
            p_index=where( photons[i, *] gt 0, complement=p_zeroes)
          if p_index[0] ne -1 then $
            photons[i,p_index ]=(10d0)^(alog10(photons[i,p_index ])+em[i])
          if p_zeroes[0]  ne -1 then $
            photons[i,p_zeroes ]=(10d0)^(alog10(photons[i,p_zeroes ])+em[i])
           
;Changing units here


          index=where(wave lt min(lambda) and  wave gt max(lambda) )
          
          if index[0] ne -1 then photons[i, index]=0d0
          index=where(wave lt .5)
          if index[0] ne -1 then photons[i, index]=0d0
        endif  else  photons[i, *]=0d0
 
    endelse

endfor

LAMBDA=WAVE
;If keyword set NO_EM then units are photons cm^3 s^-1 sr^-1
;Else units are  photons s^-1 sr^-1
return, photons

END ;Of main

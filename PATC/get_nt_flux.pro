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

function get_nt_flux,loop,nt_beam,$
                     time_step=time_step,PLOT=PLOT,$
                     DELTA_BIN=DELTA_BIN
IF NOT KEYWORD_SET(DELTA_BIN) THEN DELTA_BIN=20 
IF NOT KEYWORD_SET(time_step) THEN time_step=1d

max_e=max(nt_beam.ke_total)
min_e=min(nt_beam.ke_total)
n_e_bins=long(max_e-min_e)
if n_e_bins le 0 then n_e_bins=1
energy_array=long(min_e)+lindgen(n_e_bins)

s_alt=get_loop_s_alt(loop[0],/gt0)
s_alt=s_alt[1:n_elements(s_alt)-2l]
volumes=get_loop_vol(loop[0])
n_vols=n_elements(volumes)
n_part=n_elements(nt_beam)
position_index=lonarr(n_part)
scale_factor=nt_beam[0].scale_factor
for i=0,n_part-1 do begin
    position_index[i]=where(abs(nt_beam[i].x-s_alt) eq $
                            min(abs(nt_beam[i].x-s_alt)))
     
endfor

f_d_f={energies:energy_array, f_of_e:dblarr(n_e_bins)}
f_d_f=replicate(temporary(f_d_f),n_vols)

for i=0,n_vols-1 do begin
    indices=where(position_index eq i)
    if indices[0] ne -1 then nt_particles=nt_beam[indices] $
      else begin
        f_of_e=0
        energies=min_e
        goto, no_particles
    endelse
    if n_elements(nt_particles) eq 1 then begin
        energies=nt_particles.ke_total
        vels=kev2vel(energies)
        f_of_e=vels*scale_factor/volumes[i]
        
        goto, no_particles
    endif

    histo=histogram(nt_particles.ke_total,$
                    location=energies,bins=1)
    vels=kev2vel(energies)
    f_of_e=vels*histo*scale_factor/volumes[i]
    no_particles:
    f_of_e_ARRAY=dblarr(n_e_bins)
   
    for k=0, n_elements(energies)-1l do begin
        index=where(abs(energies[k]-energy_array) eq $
                    min(abs(energies[k]-energy_array)))
        f_of_e_ARRAY[index]=temporary(f_of_e_ARRAY[index])+ $
                         f_of_e[k]    
        
    endfor

    f_d_f[i].f_of_e=f_of_e_ARRAY
endfor



;stop
return,f_d_f
end

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

function  get_loop_nt_energy_dens, loop, nt_beam, $
  ERGS=ERGS

if  N_PARAMS() lt 2 then begin
    print, 'get_loop_nt_energy_dens requires a loop and nt_beam structure'
    energy_density=-1
    goto, final_jump
endif

;S_alt, mising the ends
s_alt2=loop.s_alt[1:N_ELEMENTS(loop.s_alt)-2]

volumes=get_loop_vol(loop)
n_vols=n_elements(volumes)

n_nt_particles=n_elements(nt_beam)

energy_density=dblarr(n_vols)

for i=0ul, n_nt_particles-1ul do begin

    position_index_vol=where(abs(nt_beam[i].x-s_alt2) eq $
                             min(abs(nt_beam[i].x-s_alt2)))

    energy_density[position_index_vol]+= $
      nt_beam[i].ke_total*nt_beam[i].scale_factor

endfor
if keyword_set(ERGS) then energy_density*=!msul_keV_2_ergs
energy_density/=volumes
energy_density=abs(energy_density)
for i=0, 10  do energy_density=smooth(energy_density, 3)
final_jump:
return, energy_density

END; of Main

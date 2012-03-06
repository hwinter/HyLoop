function mk_bremcross_array

    if not keyword_set(MIN_PHOTON) then MIN_PHOTON=0.1 ;keV
    if not keyword_set(MAX_PHOTON) then MAX_PHOTON=100. ;keV
    if not keyword_set(Z_AVG) then Z_AVG=1.4
    ph_energies=MIN_PHOTON+dindgen(MAX_PHOTON-MIN_PHOTON+1d)

e_min=1d0 ;keV
e_max=1d3;keV
step=.50
e_in=e_min
while e_in le e_max do begin

   Brm_BremCross,e_in,$
                 ph_energies, $
                 z_avg, cross_1 
;help, cross_1
                  ;                 z_avg, cross_1 
   junk=where(finite(cross_1) ne 1)
   if junk[0] ne -1 then cross_1[junk]=0d0
if n_elements(brems_cross_section) eq 0 then brems_cross_section = cross_1 else $
   brems_cross_section=[[ brems_cross_section], [cross_1]]
if n_elements(brems_part_e_array) eq 0 then brems_part_e_array = e_in else $
   brems_part_e_array=[brems_part_e_array,e_in]

;help, cross_section
e_in=e_in+step

endwhile

save,  brems_part_e_array, brems_cross_section,ph_energies, file='patc_brem_cross_sec.sav'

end

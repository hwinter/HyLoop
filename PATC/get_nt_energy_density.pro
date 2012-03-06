function get_nt_energy_density, loop,nt_beam, $
  KEV=KEV

s_alt=get_loop_s_alt(loop,/gt0)
s_alt2=s_alt[1:N_ELEMENTS(s_alt)-2]
vol=get_loop_vol(loop)

nt_de_dens=dblarr(n_elements(vol))

index=where(nt_beam.state eq 'NT')
if index[0] ne -1 then in_beam=nt_beam[index] $
  else goto,end_jump 

for i=0, n_elements(nt_beam) -1 do begin
    position_index_vol=where(abs(nt_beam[i].x-s_alt2) eq $
                             min(abs(nt_beam[i].x-s_alt2)))
    nt_de_dens[position_index_vol]+=$
      (nt_beam[i].scale_factor* nt_beam[i].ke_total)/vol[position_index_vol]

endfor


if not keyword_set(KEV) then nt_de_dens*=!msul_keV_2_ergs

end_jump:
return, nt_de_dens

end

function hdw_get_position_index_for_loop, particle_s, cell_s


n_particle_s=n_elements(particle_s)
n_cell_s=n_elements(cell_s)

position_index=dblarr(n_particle_s, /NOZERO)
for i=0ul,n_particle_s-1ul do begin
   position_index[i]=where(abs(particle_s[i]-cell_s) eq $
                               min(abs(particle_s[i]-cell_s)))
endfor

return, position_index
end

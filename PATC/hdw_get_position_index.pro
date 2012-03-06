function hdw_get_position_index, particle_s, cell_s


n_particle_s=n_elements(particle_s)
n_cell_s=n_elements(cell_s)

particle_pos_matrix=rebin(reform(particle_s,1,n_particle_s),$
                          n_cell_s,$
                          n_particle_s)

cell_matrix=rebin(cell_s, n_cell_s,n_particle_s)
junk=min(particle_pos_matrix-cell_matrix,$
         position_index, dim=1,/abs)
delvarx, particle_pos_matrix, cell_matrix, junk
;Change the absolute array position to an index that relates to 
; cell_s.  "I dare you to make less sense!" -Dean Venture
position_index=temporary(position_index) mod n_cell_s

return, position_index
end

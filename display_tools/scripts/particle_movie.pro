
file_1='/Users/winter/Data/PATC/runs/2006_SEP_26/argh.loop'

E_min=15
E_max=max(beam_struct[1].nt_beam.ke_total)
for i=0,n_elements(beam_struct)-1ul do begin
    NT_beam=beam_struct[i].nt_beam
    particle_display, loop[0],NT_beam,E_min=E_min,E_max=E_max
    x2gif,'./nt_movie_'+strcompress(string(i,format='(I05)'),/remove)
endfor

files=file_search('./','nt_movie_*')

image2movie,files,movie_name='nt_movie.gif',/gif_animate,$
             /loop



end

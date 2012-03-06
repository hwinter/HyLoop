n_e_array=dindgen(400)


structure={n_e:n_e_array}

t_start=systime(1)
For i=0, 100 do begin
   structure.N_e[10:50]=structure.N_e[10:50]*5

endfor
t1=systime(1)-t_start

t_start=systime(1)
For i=0, 100 do begin
   structure.N_e[10:50]*=5

endfor
t2=systime(1)-t_start

print, t1/t2

end







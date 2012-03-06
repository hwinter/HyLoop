n_e_array=dindgen(400)


structure={n_e:n_e_array}

t_start=systime(1)
For i=0, 100 do begin
   junk=structure.N_e[10:50]*5
   junk=structure.N_e[10:50]*structure.N_e[10:50]
   junk=structure.N_e*3

endfor
t1=systime(1)-t_start

t_start=systime(1)
   N_e_array=structure.N_e
For i=0, 100 do begin
   junk=N_e_array[10:50]*5
   junk=N_e_array[10:50]*N_e_array[10:50]
   junk=N_e_array*3

endfor
t2=systime(1)-t_start

print, 'Strcutures/Arrays',t1/t2

t_start=systime(1)
   N_e_ptr=ptr_new(structure.N_e)
For i=0, 100 do begin
   junk=(*N_e_ptr)[10:50]*5
   junk=(*N_e_ptr)[10:50]*((*N_e_ptr)[10:50])
   junk=*N_e_ptr*3
endfor
   ptr_free, N_e_ptr
t3=systime(1)-t_start

print, 'Structures/Pointers' ,t1/t3
print, 'Structures/Arrays', t2/t3

end







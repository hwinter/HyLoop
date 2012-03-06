n_cpu=4
n_elem=100
nt=dindgen(n_elem)
delta=n_elem/n_cpu
for i=0L, n_cpu-1l do begin
    start_i=i*delta
    end_i=((i+1L)*delta)+1l
    print, nt[start_i,end_i]

endfor






end



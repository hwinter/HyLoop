n_cpu=4
n_elem=103
nt=dindgen(n_elem)
delta=n_elem/n_cpu
if n_elem mod n_cpu gt 0 then n_do=n_cpu else n_do=n_cpu-1l
for i=0L, n_do do begin
    print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
    start_i=i*delta
    end_i=((i+1L)*delta)-1l
    if end_i gt n_elem-1l then $
      print, nt[start_i:*] else $
      print, nt[start_i:end_i]
    print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
endfor






end



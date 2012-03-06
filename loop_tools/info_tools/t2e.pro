;Convert temperatrue to internal energy density

function t2e,T, n_e

;If the is no desnity then n_e=1d+9
if size(n_e, /type) eq 0 then n_e=1d9
e=T*3d0*n_e*!shrec_kB
return, abs(e)

end

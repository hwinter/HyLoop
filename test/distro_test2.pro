; .r distro_test2
n=1000
alpha=0

n_runs=19
avgs=dblarr(n_runs)
print, ':::::::::::::::::::::::::::::::::::'
print, 'Alpha='+string(alpha)
for i=0, n_runs-1ul do begin
    

    dist=mk_distro6(ALPHA, N_PART=N)  
    avg_dist=moment(dist)
    print, avg_dist
    avgs[i]=avg_dist[0]
endfor

print, ':::::::::::::::::::::::::::::::::::'
print, moment(avgs)

print, ':::::::::::::::::::::::::::::::::::'
end


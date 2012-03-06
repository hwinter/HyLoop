;.r random_dist_test01


temps=get_loop_temp(loop)
index=reverse(sort(temps)) 
n_points=100
r_numbers=abs(randomn(Seed,n_points ))
TEmp_dist=3*temps[index]/Max(temps)

plot, TEmp_dist
p_temps=TEmp_dist-r_numbers
p_temps>=min(TEmp_dist)

for i=0ul,n_points-1ul  do begin
    point=where(abs(p_temps[i]-TEmp_dist) eq $
                min(abs(p_temps[i]-TEmp_dist)))
    
plots, point, TEmp_dist[point], psym=5
endfor

end

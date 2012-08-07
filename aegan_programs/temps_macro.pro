

temps=make_array(total_seconds+1, 699)
density=make_array(total_seconds+1, 699)
temp_dev=make_array(total_seconds+1,699)
dens_dev=make_array(total_seconds+1, 699)
variance=make_array(total_seconds+1, 699)
for t=0, total_seconds do begin
print, t
run_loops=loops[*,t]
temps[t,*]=get_loops_avg_temp(run_loops, std_dev=std_dev, variance=var)
temp_dev[t, *]=std_dev
density[t,*]=get_loops_avg_dens(run_loops, std_dev=std_dev)
dens_dev[t,*]=std_dev
endfor

END

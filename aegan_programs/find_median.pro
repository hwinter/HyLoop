; Find the median

function find_median, runs_emissions, MAD=mad,points=points
total_runs=65
total_seconds=900
medians=make_array(total_seconds+1)
points=make_array(total_runs)
MAD=make_array(total_seconds+1)


for time=0, total_seconds do begin
medians[time]=MEDIAN(runs_emissions[*,time], /DOUBLE)
for runs=0, total_runs-1 do begin
points[runs]=abs(medians[time]-runs_emissions[runs,time])
endfor
MAD[time]=median(points, /DOUBLE)
endfor
return, medians
END

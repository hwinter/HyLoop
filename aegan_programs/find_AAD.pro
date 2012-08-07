;find the absolute average deviation, from the median

function find_aad, runs_emissions, aad=aad

total_runs=65
total_seconds=900

medians=make_array(total_seconds+1)
points=make_array(total_runs)
AAD=make_array(total_seconds+1)


for time=0, total_seconds do begin
medians[time]=MEDIAN(runs_emissions[*,time], /DOUBLE)
for runs=0, total_runs-1 do begin
points[runs]=abs(medians[time]-runs_emissions[runs,time])
endfor
moment_array=moment(points, /DOUBLE)
AAD[time]=moment_array[0]
endfor
return, medians
END

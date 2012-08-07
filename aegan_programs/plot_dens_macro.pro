plot, time_array, alog10(density[0,*])
s=0
while s le 690 do begin
oplot, time_array, alog10(density[s,*])
s=s+5
endwhile
END

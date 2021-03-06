
;; In this example I found the FINDEX + INTERPOLATE combination
;; to be about 60 times faster then INTERPOL.
;
;Old x
u=double([0.0, 1.0,2.0, 3.0,4.0, 5.0])
;New x
v=randomu(iseed,20000)*5d ;& v=v[sort(v)]

;Old y 

y=sin((!dpi/2.)*(U/5.))*exp((2.5-u))

t=systime(1) & y1=interpolate(y,findex(u,v)) & findex_time=systime(1)-t
print,'Findex time',findex_time
t=systime(1) & y2=interpol(y,u,v) & no_findex_time=systime(1)-t
print,'No Findex time',no_findex_time

print, 'With Findex/Without Findex time ratio:', findex_time/no_findex_time

;Now to test with hd codes.

plot, u,y, psym=2

i=sort(v)
oplot, v[i], y1[i], line=1
oplot, v[i], y2[i], line=2
oplot, v[i], y3[i], line=3

end

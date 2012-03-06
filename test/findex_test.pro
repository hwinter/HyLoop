 ;.r findex_test
;Old x
u=randomu(iseed,200000) & u=u[sort(u)]
;New x
v=randomu(iseed,10)     & v=v[sort(v)]
;Old y
y=randomu(iseed,200000) & y=y[sort(y)]

t=systime(1) & y1=interpolate(y,findex(u,v)) & findex_time=systime(1)-t
print,'Findex time',findex_time
t=systime(1) & y2=interpol(y,u,v) & no_findex_time=systime(1)-t
print,'No Findex time',no_findex_time

print,''
;print,f='(3(a,10f7.4/))',$
;      'findex:     ',y1,$
;      'interpol:   ',y2,$
;      'diff(y1-y2):',y1-y2
;print,''
print, 'With Findex/Without Findex time ratio:', findex_time/no_findex_time

plot, u,y

oplot, v, y1, psym=1
oplot, v, y2, psym=2

end ;Of findex_test


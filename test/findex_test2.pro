
;; In this example I found the FINDEX + INTERPOLATE combination
;; to be about 60 times faster then INTERPOL.
;
;Old x
u=randomu(iseed,10) & u=u[sort(u)]
;New x
v=randomu(iseed,10000)     & v=v[sort(v)]
;Old y
y=randomu(iseed,10) & y=y[sort(y)]
;I'm going to test the c codes too, so...
so=get_bnh_so(/init)

t=systime(1) & y1=interpolate(y,findex(u,v)) & findex_time=systime(1)-t
print,'Findex time',findex_time
t=systime(1) & y2=interpol(y,u,v) & no_findex_time=systime(1)-t
print,'No Findex time',no_findex_time

;Now test the c codes
;Sef faults if values passed aren't doubles. 
t=systime(1)
n_tabulated=n_elements(u)
n_v=n_elements(v)
y3= make_array(n_v, /double)
foo = call_external(so, $               ; The SO
                    'bnh_splint', $     ; The entry name
                    n_tabulated, $      ; # of elements in x, f(x)
                    double(u), $             ; x
                    double(y), $             ; f(x)
                    n_v, $        ; # elements in thing-to-interpolate
                    double(v), $          ; thing-to-interpolate
                    y3, $          ; where the answer goes
                    /d_value, $ 
                    value=[1,0,0,1,0,0], $ 
                    /auto_glue,/cdecl) ;, $/ignore_exist,
c_time=systime(1)-t

print,'C time',c_time
print,''
;print,f='(5(a,10f7.4/))','findex:     ',y1,'interpol:   ',y2,$
;      'C codes:    ',y3,'diff(y1-y2):',y1-y2,$
;      'diff(y1-y3):',y1-y3;

print, 'With Findex/Without Findex time ratio:', findex_time/no_findex_time
print, 'C/With Findex time ratio:', c_time/findex_time
print, 'C/Without Findex time ratio:', c_time/no_findex_time

;Now to test with hd codes.


end

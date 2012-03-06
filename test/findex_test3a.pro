;.r findex_test3a
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

print, 'Interpol/Interpolate:', findex_time/no_findex_time

so =get_bnh_so()
so ='/Users/winter/programs/PATC/c_codes/dawntreader/bnh_splint.so'
n_tabulated=n_elements(u)
y3=y2*0d0
n_new_y=n_elements(y3)
t=systime(1)
foo = call_external(so, $               ; The SO
                    'bnh_splint', $     ; The entry name
                    n_tabulated, $      ; # of elements in x, f(x)
                    u, $             ; x
                    y, $             ; f(x)
                    n_new_y, $        ; # elements in thing-to-interpolate
                    v, $          ; thing-to-interpolate
                    y3, $        ; where the answer goes
                    /d_value, $         ; Double precision values
                    value=[1,0,0,1,0,0], $ ;pass as (1) value (0) reference
                        /auto_glue)     
bnh_time=systime(1)-t
print, 'BNH/Interpolate '+string((findex_time/no_findex_time)/bnh_time)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set the new colors: 0 results in black, 1 in red, 2 in green, 
; and 3 in blue
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]

set_plot, 'ps'
device, /landscape, /color, file='interpolator_test_3a.ps'
plot, u,y, psym=4, TITLE='Interpolator Test', font=0, $
      charsize=1.5, charthick=1.5

i=sort(v)

oplot, v[i], y1[i], line=0, color=1, thick=8
oplot, v[i], y2[i], line=0, color=2, thick=6
oplot, v[i], y3[i], line=0, color=3, thick=2
oplot, u,y, psym=2, symsize=4

legend, ['Interpolte', 'Interpol', 'BNH_splint'], $
        line=[0,0,0], color=[1,2,3], /RIGHT, font=0,$
        charsize=1.2, charthick=1.2

legend, ['Interpol/Interpolate Run Time:'+string(findex_time/no_findex_time), $
        'BNH/Interpolate  Run Time:'+string((findex_time/no_findex_time)/bnh_time)], $
         center=1, font=0,$
        charsize=.9, charthick=.9, /BOTTOM

device, /close
set_plot, 'x'

end; findex_test3a

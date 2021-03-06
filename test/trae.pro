
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make some settings to make use of IDL multithreading
;Most of the defaults are ok.
n_cpu=(!CPU.HW_NCPU)-1
n_cpu>=1

CPU ,TPOOL_MIN_ELTS = 1d6;,$
;     TPOOL_NTHREADS=n_cpu


ans = fltarr(4, 15)

FOR ib = 4UL, 14 DO BEGIN 
   n_e_array=dindgen(10^(ib/2.))
print, n_elements(n_e_array) 
   ans[0, ib] = n_elements(n_e_array) 
   
structure={n_e:n_e_array}

t_start=systime(1)
For i=0, 100 do begin
  junk=structure.N_e[10:50]*5
  junk=structure.N_e[10:50]*structure.N_e[10:50]
  junk=structure.N_e*3

endfor
t1=systime(1)-t_start

t_start=systime(1)
  N_e_array=structure.N_e
For i=0, 100 do begin
  junk=N_e_array[10:50]*5
  junk=N_e_array[10:50]*N_e_array[10:50]
  junk=N_e_array*3

endfor
t2=systime(1)-t_start

print, 'Strcutures/Arrays',t1/t2
ans[1, ib] = t1/t2

t_start=systime(1)
  N_e_ptr=ptr_new(structure.N_e)
For i=0, 100 do begin
  junk=(*N_e_ptr)[10:50]*5
  junk=(*N_e_ptr)[10:50]*((*N_e_ptr)[10:50])
  junk=*N_e_ptr*3
endfor
  ptr_free, N_e_ptr
t3=systime(1)-t_start

print, 'Structures/Pointers' ,t1/t3
print, 'Arrays/Pointers', t2/t3
ans[2, ib] = t1/t3
ans[3, ib] = t2/t3


ENDFOR 

plot, ans[0, *], ans[1, *], thick = 2, charsize = 1.5, color = fsc_color('black'), $
      back = fsc_color('white'), /xlog, xrange = [1e1, 1e8], /ynozero, yrange = [0, 2], $
      xtitle = 'Array size', ytitle = 'Speedup fraction', title='TPOOL_MIN_ELTS=1d6'
oplot, ans[0, *], ans[2, *], color = fsc_color('red'), thick = 2
oplot, ans[0, *], ans[3, *], color = fsc_color('blue'), thick = 2
oplot_horiz, 1, /log, color = fsc_color('black')

legend, thick = 2, color = [fsC_color('black'), fsc_color('red'), fsc_Color('blue')], $
        ['Strcutures/Arrays',  'Structures/Pointers', 'Arrays/Pointers'], linestyle = 0, $
        textcolors=[fsC_color('black'), fsc_color('red'), fsc_Color('blue')]

end


; IDL Version 6.1, Mac OS X (darwin ppc m32)
; Journal File for winter@Dawntreader.local
; Working directory: /Users/winter/PATC
; Date: Mon May 23 07:21:59 2005
;file1=dialog_pickfile()
;print, file1
set_plot,'x'
file1='/Users/winter/PATC/2005_05_20_exp_loop/hd_out.sav'
;file2=dialog_pickfile()
;print,file2
file2='/Users/winter/PATC/2005_05_20_exp_loop/full_test_1.sav'
restore, file1
restore, file2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate volumes of each bit
        n=n_elements(A)
        volumes= 0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
        

e_total=dblarr( n_elements(beam_struct))
for i=0, n_elements(beam_struct)-1 do e_total=e_total+ (beam_struct[i].ENERGY_PROFILE)
help,e_total
e_total=e_total*(-1d*keV_2_ergs*scale_factor)
plot, loop_struct[0].loop.x, e_total,thick=2, xtitle='Loop Length (cm))', ytitle='Energy Deposited (ergs)', Title='Total Energy Deposition', $
charthick=1.3,charsize=1.3
x2gif, 'energy_dep_plot.gif'


end

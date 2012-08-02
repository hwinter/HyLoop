function mk_loop_smoothed_ds, loop


ds=get_loop_ds(loop)

for iii=0, 50 do ds=smooth(ds,3)


s=[0,total(ds, /Cumulative)]

N_surf=n_elements(s)
n_vol=N_surf+1

tloop=mk_loop_struct(n_vol, s_array=s,$
                     T_MAX=loop.T_MAX,$
                     N_DEPTH=loop.N_DEPTH, $
                     START_FILE=loop.START_FILE,TIME=loop.TIME,$
                     DEPTH=loop.DEPTH, NOTES=loop.NOTES,$
                     SAFETY_GRID=loop.SAFETY_GRID, SAFETY_TIME=loop.SAFETY_TIME,$
                     CHROMO_MODEL=loop.CHROMO_MODEL )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;State Variables
tloop.state.e=spline(loop.s_alt, loop.state.e,tloop.s_alt,3)
tloop.state.n_e=spline(loop.s_alt, loop.state.n_e,tloop.s_alt,3)
tloop.state.v=spline(loop.s,loop.state.e,tloop.s_alt,3)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;axes
tloop.state.axis[0,*]=spline(loop.s, loop.state.axis[0,*],tloop.s,3)
tloop.state.axis[1,*]=spline(loop.s, loop.state.axis[1,*],tloop.s,3)
tloop.state.axis[2,*]=spline(loop.s, loop.state.axis[2,*],tloop.s,3)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Others
tloop.state.axis[2,*]=spline(loop.s, loop.state.axis[2,*],tloop.s,3)




stop
END

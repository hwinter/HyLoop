

patc_dir=getenv('PATC')
data_dir=getenv('DATA')
;start_file=data_dir+'/PATC/runs/2006_DEC_09_01/gcsm_loop.sav'
start_file=patc_dir+'/test/loop_data/gcsm_loop.sav'
outfile=patc_dir+'/test/regrid_test.loop'
restore,start_file
help,e_h
loop[0].state.v[*]=0d0
old_loop=loop[0]
N=n_elements(loop[0].s)
dv=get_loop_vol(loop[0],TOTAL=old_volume_total)
dv_old=dv

n_vol=n_elements(dv)
n_part_old=total(dv*loop[0].state.n_e[1:n_vol])
energy_total_old=total(dv*loop[0].state.e[1:n_vol])

window,0
n_lhist=n_elements(loop)
q0=0.007d
time_step=60d
stateplot2, loop.s,loop[0].state ,  /screen ;fname='after.ps'
WINDOW,5
regrid_step, loop,/showme,/nosave, $
             MAX_STEP=5d8,$
             PERCENT_DIIFERENCE=.1
help,loop.s,loop[0].state.e,loop[0].state .v

window,1
stateplot2, loop.s,loop[0].state ,  /screen ;fname='after.ps'


N=n_elements(x)
;loop=old_loop
dv=get_loop_vol(loop[0],TOTAL=new_volume_total)
n_vol=n_elements(dv)
n_part_new=total(dv*loop[0].state.n_e[1:n_vol])
energy_total_new=total(dv*loop[0].state.e[1:n_vol])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print,'Change in particle number:'+string(n_part_old-n_part_new)
print,'Change in particle number fractional difference:'+$
      string(abs(n_part_old-n_part_new)/n_part_new)

print,'Change in energy:'+string(energy_total_old-energy_total_new)
print,'Change in energy fractional difference:'+ $
      string(abs(energy_total_old-energy_total_new)/energy_total_new)

print,'Change in volume:'+string(old_volume_total-new_volume_total)
print,'Change in volume fractional difference:'+ $
      string(abs(old_volume_total-new_volume_total)/new_volume_total)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

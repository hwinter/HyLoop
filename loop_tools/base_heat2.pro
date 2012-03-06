
;base_heat.pro
patc_dir=get_environ('PATC')
data_dir=getenv('DATA')

in_file=patc_dir+'/loop_tools/loop_save1.0000000e+24.sav'
restore,in_file
computer='mithra'

break_file,in_file,disk,dir,filename,ext
outfile1=data_dir+'/AIA/base_loop/base_ramp_up2.sav'
outfile2=data_dir+'/AIA/base_loop/base_heat2.sav'
n_heating_cells=61
restore,in_file
power=1d24
corona_index= where(abs(min(axis[2,*])+axis[2,*]) eq $
                    min(abs(min(axis[2,*])+axis[2,*])))

;stop
power=power/2
N=n_elements(x)
dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
profile=exp(-1d*(dindgen(n_heating_cells)+1)/(n_heating_cells))
scale=(profile/power)
;power=scale*power
s_form=dblarr(N-1)              ; (erg/s/cm^3) heat input for grid,

s_form[0:n_heating_cells-1]=power/(dv[0:n_heating_cells-1])
s_form[(n_elements(s_form)-n_heating_cells): $
       n_elements(s_form)-1]=reverse(power)/$
  dv[(n_elements(s_form)-n_heating_cells): $
       n_elements(s_form)-1]

s_form=abs(s_form)
dt=5d*60d
time=60d*60d
;stop
;evolve11,in_file ,time ,dt, $
;  outfile=outfile1, $           ;
;  s_form=s_form, $              ;q0=q0,
;  computer=computer,AXIS=AXIS


dt=10d
time=60d*60d
evolve11,outfile2 ,time ,dt, $
  outfile=outfile2, $            ;
  s_form=s_form, $              ;q0=q0,
  computer=computer,AXIS=AXIS,q0=q0



end 

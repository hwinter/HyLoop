
;base_heat.pro
patc_dir=get_environ('PATC')
data_dir=getenv('DATA')

in_file=patc_dir+'/loop_tools/loop_save1.0000000e+24.sav'
restore,in_file
computer='mithra'

break_file,in_file,disk,dir,filename,ext
outfile1=data_dir+'/AIA/uniform_loop/uniform_ramp_up2.sav'
outfile2=data_dir+'/AIA/uniform_loop/uniform_heat2.sav'
mk_dir, data_dir+'/AIA/uniform_loop/'

restore,in_file
power=1d24

corona_index= where(abs(min(axis[2,*])+axis[2,*]) eq $
                    min(abs(min(axis[2,*])+axis[2,*])))

;stop

N=n_elements(x)
dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
;heating_index=[corona_index[0]+lindgen(3),corona_index[0]-lindgen(3)]
heating_index=[lindgen(5)+101l,n_elements(axis[2,*])-(lindgen(5)+102)]
s_form=dblarr(N-1)              ; (erg/s/cm^3) heat input for grid,
s_form=power/(dv)
s_form=abs(s_form)
dt=5d*60d
time=5d*60d*60d
evolve11,in_file ,time ,dt, $
  outfile=outfile1, $           ;
  s_form=s_form, $              ;q0=q0,
  computer=computer,AXIS=AXIS


dt=10d
time=10d*60d
evolve11,outfile1 ,time ,dt, $
  outfile=outfile2, $            ;
  s_form=s_form, $              ;q0=q0,
  computer=computer,AXIS=AXIS,q0=q0



end 

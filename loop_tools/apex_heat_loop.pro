
;apex_heat_loop.pro

patc_dir=get_environ('PATC')
data_dir=get_environ('DATA')


computer='mithra'

inname=patc_dir+'/loop_tools/loop_save1.0000000e+24.sav'
break_file,inname,disk,dir,filename,ext
outfile1=data_dir+'/AIA/apex_loop/apex_ramp_up_loop2.sav'
outfile1=data_dir+'/AIA/apex_loop/apex_heat_loop2.sav'

restore,inname
power=1d22/4.                  ;[ergs s-1]
n_heat_cells=41
profile=sin(!pi*dindgen(n_heat_cells)/49)*$
  sin(!pi*dindgen(n_heat_cells)/(n_heat_cells-1))

scale=total(profile)/power
power2=power*profile
scale=total(power2/power)
power=power2*scale

top_index=where(axis[2,*] eq max(axis[2,*] ))
junk=lindgen(2)+1

half=fix(n_heat_cells/2)
heat_locations=[(top_index[0]-half),(top_index[0]+half)]

N=n_elements(x)
dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))

s_form=dblarr(N-1)                ; (erg/s/cm^3) heat input for grid,
s_form[heat_locations[0]:heat_locations[1]]=$
  (power/(dv[heat_locations[0]:heat_locations[1]]))

s_form=abs(s_form)
print,x[heat_locations[1]]-x[heat_locations[0]]
;s_form=smooth(s_form,100)
;plot,s_form
;stop
dt=5d*60d
time=50d*60d
print,outfile1
evolve11,inname ,time ,dt, $
  outfile=outfile1, $            ;
  s_form=s_form, $              ;q0=q0,
  computer=computer,axis=axis

time=10d*60d
dt=1d
print,outfile2
evolve11,outfile1 ,time ,dt, $
  outfile=outfile2, $            ;
  s_form=s_form, $              ;q0=q0,
  computer=computer,axis=axis


end 


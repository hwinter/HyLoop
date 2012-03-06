

patc_dir=get_environ('PATC')
data_dir=getenv('DATA')
in_file=patc_dir+'/loop_tools/loop_save1.0000000e+24.sav'

computer='mithra'

break_file,in_file,disk,dir,filename,ext
outfile1=data_dir+'/random_loop/random_ramp_up.sav'
outfile2=data_dir+'/random_loop/random_heat.sav'

restore,in_file

flare_rate=9d;# of flares/sec
power=1d24/flare_rate


N=n_elements(x)
dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))

dt=10d
time=1d*60d*60d
outfile1=in_file
counter=long64(time/(dt))
for t=0,counter do begin
    
    heating_index=long64(flare_rate)
    heating_index=long64(n_elements(dv)*randomu(seed,9))
    s_form=dblarr(n_elements(dv))          ; (erg/s/cm^3) heat input for grid,
    s_form[heating_index]=dt*power/(dv[heating_index])
    

    evolve11,in_name ,dt ,dt, $
      outfile=outfile2, $       ;
      s_form=s_form, $          ;q0=q0,
      computer=computer,axis=axis
    t=t+dt
    outfile1=outfile2


endfor


end 

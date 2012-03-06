
function patc_de_dt_cc, t , e_n_vp, dl, dens,m,charge,a,b, delta_t

;This only works if the RK4 stepper is off
;stop
;print, '::::::::::::::::::::::::::::::::::'

command='/Users/hwinter/programs/HyLoop/c_codes/patc_de_dv_dt '
transfer_file='/Users/hwinter/programs/HyLoop/c_codes/de_dvp_file.txt'

spawn,command+ transfer_file+$
       string(e_n_vp[0])+$
       string(e_n_vp[1]) +$
       string(a)+$
       string(b)+$
       string(delta_t)+$
       string(dl)+$
       string(dens)+$
       string(m)+$
       string(charge)

readcol, transfer_file, de_dt, dvp_dt, skipline=0, $
         delim=':', /silent

return, [double(de_dt), double(dvp_dt)]
;stop
end

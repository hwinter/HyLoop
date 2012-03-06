
;random_heat_strands.pro
;journal, 'random_heat_strands.txt'
computer='mithra'
patc_dir=getenv('PATC')
data_dir=getenv('DATA')
save_dir=data_dir+'/AIA/random_strands/'
strand_files=file_search(data_dir+'/AIA/strand_start*',/FULLY_QUALIFY_PATH)
help, strand_files
N_strands=n_elements(strand_files)
help,N_strands
dt=5d*60d
dt1=10d
stable_time=(10d*60d)
movie_time=(5d*60d)
total_time=stable_time+movie_time
power=1d24            
flare_rate=9d;# of flares/sec
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;How are these loops to be heated???
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Stabilization heating         
n_flares=long64(flare_rate*dt)
power1=power/N_strands
power1=power1/n_flares
n_stable_while_loops=long64(stable_time/dt)+2l
N_flares_in_strand0=l64indgen(n_stable_while_loops,N_strands)

for h=0, n_stable_while_loops-1l do begin
    for i=0,n_flares-1l do begin
      ;  print,'rf_index'+string(rf_index)
;Compute the random flare index. Which strand will it be?
        rf_index=long64((N_strands-1l)*randomu(seed))
        N_flares_in_strand0[h,rf_index]= N_flares_in_strand0[rf_index]+1l
    endfor
endfor
;print,'N_flares_in_strand'+string(N_flares_in_strand)
;stop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Movie heating
n_flares=long64(flare_rate*dt1)
power2=power/N_strands
power2=power2/n_flares
n_movie_while_loops=long64(movie_time/dt1)+2l
N_flares_in_strand=l64indgen(n_movie_while_loops,N_strands)
for h=0, n_movie_while_loops-1l do begin
    for i=0,n_flares-1l do begin
       ; print,'rf_index'+string(rf_index)
                                ;Compute the random flare index
        rf_index=long64((N_strands-1l)*randomu(seed))
        N_flares_in_strand[h,rf_index]= N_flares_in_strand[rf_index]+1l
    endfor
endfor
;print,'N_flares_in_strand'+string(N_flares_in_strand)
;stop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;restore,strand_files[0]
 ;   window,0
    ;plot_3dbox,axis[0,*],axis[1,*],axis[2,*],AZ=-45
  ;  plot, axis[1,*],axis[2,*]

for i=0,N_strands-1l do begin
    
    break_file,strand_files[i],disk,dir,filename,ext
    outname1=save_dir+filename+'_initial_'+ext
    outname2=save_dir+filename+'_heated_'+ext
    print,'outname1: '+save_dir+filename+'_initial_'+ext
    print,'outname2: '+save_dir+filename+'_heated_'+ext

   ; print,'Working on file '+strand_files[i]
   ; plots,axis[0,*],axis[1,*],$
    ;      axis[2,*]
    ;wait,2

    restore,strand_files[i]
    N=n_elements(x)
    dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    x_alt = [2*x[0]-x[1],(x[0:N-3]+x[1:N-2])/2.0,2*x[N-2]-x[N-3]]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    junk=lindgen(2)+1
    
    ;
    sim_time=0d
    sim_counter=0l
;for strand_loop=0,N_strands-1l do begin
    while sim_time le stable_time do begin        
        sim_f_num= $
          N_flares_in_strand0[sim_counter,i]
        
        heating_index= $
          long64(n_elements(dv)* $ltr
                 randomu(seed,sim_f_num))
        s_form=dblarr(N-1)      ; (erg/s/cm^3) heat input for grid,
        s_form[heating_index]=power1/(dv[heating_index])
     

print,outname1
        evolve11,strand_files[i] ,stable_time ,dt, $
          outfile=outname1, $   ;
          s_form=s_form, $      ;q0=q0,
          computer=computer,axis=axis
        
        sim_time=sim_time+dt
        sim_counter= sim_counter+1l
    endwhile
endfor
    
strand_files=file_search(data_dir+ $
                         '/AIA/random_strands/strand_start*',$
                         /FULLY_QUALIFY_PATH)
sim_time=0d
sim_counter=0l
for i=0, n_elements(strand_files)-1l do begin
    
    break_file,strand_files[i],disk,dir,filename,ext
    outname2=save_dir+filename+'_heated_'+ext
    while sim_time le movie_time do begin  
    ;    print,'sim time',+string(sim_time)
        sim_f_num= $
          reform(N_flares_in_strand[sim_counter,i])
        if sim_f_num gt 0 then begin
            
            heating_index= $
              long64(n_elements(dv)* $
                     randomu(seed,sim_f_num[0]))
            s_form=dblarr(N-1)  ; (erg/s/cm^3) heat input for grid,
            s_form[heating_index]=power1/(dv[heating_index])
        endif else s_form=dblarr(N-1)

print,outname2
        evolve11,strand_files[i],movie_time ,dt, $
          outfile=outname2, $   ;
          s_form=s_form, $      ;q0=q0,
          computer=computer,axis=axis
        
        
        sim_time=sim_time+dt
        sim_counter= sim_counter+1l
    endwhile
endfor


;journal
end 


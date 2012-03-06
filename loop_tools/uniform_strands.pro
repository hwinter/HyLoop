
;base_heat_strands.pro

computer='mithra'
patc_dir=getenv('PATC')
data_dir=getenv('DATA')
save_dir=data_dir+'/AIA/base_strands/'
mk_dir,save_dir 
strand_files=file_search(data_dir+'/AIA/strand_start*',/FULLY_QUALIFY_PATH)
N_strands=n_elements(strand_files)

power=1d24                      ;[ergs s-1]

power=power/N_strands

for i=0,N_strands-1l do begin
    
    break_file,strand_files[i],disk,dir,filename,ext
    outname1=save_dir+filename+'_initial_'+ext
    outname2=save_dir+filename+'_heated_'+ext

    print,'outname1: '+save_dir+filename+'_initial_'+ext
    print,'outname2: '+save_dir+filename+'_heated_'+ext

    restore,strand_files[i]
    top_index=where(axis[2,*] eq max(axis[2,*] ))
    
    junk=lindgen(2)+1
    
    ;heat_locations=lindgen(5)
    heat_locations=[lindgen(5)+101l,n_elements(axis[2,*])-(lindgen(5)+102)]
    
    N=n_elements(x)
    dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
    
    s_form=dblarr(N-1)          ; (erg/s/cm^3) heat input for grid,
    s_form[heat_locations]=power/(dv[heat_locations])
    
    dt=5d*60d
    time=60d*60d
    evolve11,strand_files[i] ,time ,dt, $
      outfile=outname1, $       ;
      s_form=s_form, $          ;q0=q0,
      computer=computer
    
    time=10d*60d
    dt=10d
    evolve11,outname1 ,time ,dt, $
      outfile=outname2, $       ;
      s_form=s_form, $          ;q0=q0,
      computer=computer

endfor
end 


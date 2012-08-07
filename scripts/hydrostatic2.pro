print,'Running hydrostatic3.pro'


print,'stratified atmosphere '
print,systime(1)
dir='/disk/hl2/data/winter/data1/PATC/loop_data/'
!except=2
;start_file=dir+'const_b_test.start'
;outfile=dir+'const_b_test2.start'
start_file= "/disk/hl2/data/winter/data1/PATC/loop_data/const_b_test3.start"
outfile="/disk/hl2/data/winter/data1/PATC/loop_data/const_b_test4.sav"
restore,start_file
;window,0

n_lhist=n_elements(lhist)
;stateplot2, x,lhist[n_lhist-1] , /screen
q0=0.007d
time_step=10d
computer='mithra'

max_v=1d4 
delta_t=0d
done=0
n_lhist=1l
    
    ;regrid4,infile=start_file, outfile=outfile; , /SHOWME

while done le 0 do begin
    
    evolve_test,outfile ,time_step ,time_step, $
      outfile=outfile, $
      computer=computer,$
      q0=q0; ,/showme
    
    
    restore, outfile
    
    n_lhist=n_elements(lhist)
    
    ;window,0,xs=600,ys=600
    stateplot2, x,lhist[n_lhist-1] , /screen
    max_v=max(abs(lhist[n_lhist-1].v))
    delta_t=delta_t+time_step
    if max_v lt 1d2 then done=1
    if delta_t gt 10000d then done=1
    print, 'Maximum Velocity: '+strcompress(string(max_v),/remove)+' cm/s'
    ; regrid4,infile=outfile, outfile=outfile
endwhile
mk_hd_movie,file=outfile,gif_dir=dir
exit
end

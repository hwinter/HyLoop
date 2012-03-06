print,'Running hydrostatic.pro'
print,systime(1)
dir='/disk/hl2/data/winter/data1/PATC/'
!except=2
;start_file=dir+'const_b_test.start'
;outfile=dir+'const_b_test2.start'
start_file= '/disk/hl2/data/winter/data1/bp_sim/xbp1_eq.sav'
outfile="/disk/hl2/data/winter/data1/PATC/xbp1_eq.sav"
restore,start_file
window,0

n_lhist=n_elements(lhist)
stateplot2, x,lhist[n_lhist-1] , /screen
q0=0.007d
time_step=2d
computer='mithra'

max_v=1d4 
delta_t=0
done=0
while done le 0 do begin
   ; regrid6, lhist,g,a,x,e_h, /SHOWME,/NOSAVE
    evolve_test,start_file ,time_step ,time_step, $
      outfile=outfile, $
      computer=computer,$
      q0=q0 
    
    
    restore, outfile
    
    n_lhist=n_elements(lhist)
    
    window,3
    stateplot2, x,lhist[n_lhist-1] , /screen
    max_v=max(abs(lhist[n_lhist-1].v))
    delta_t=delta_t+time_step
    if max_v lt 1d2 then done=1
    if delta_t gt 500d*2d then done=1
    print, 'Maximum Velocity: '+string(max_v)
    start_file=outfile
endwhile
mk_hd_movie,file=outfile,gif_dir=dir
end

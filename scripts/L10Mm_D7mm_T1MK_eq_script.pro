;L10Mm_D7mm_T1MK_eq_script.pro
data_dir=getenv('DATA')
dir=data_dir+'/MSUloop/POCET/equil_test/semi_c_const_a/'
fname='L10Mm_D7mm_q00.0007'
fname2='L10Mm_D7mm_T1MK'
Journal, Dir+fname2+'.jrn'
start_time=systime(1)
print,'Running hydrostatic.pro'
print,systime()
print,'constant pressure'
print,'Working Directory: '+dir
print,'Working file: '+fname2

;Set to learn exact placement of mathematical errors
;Note: This slows down processor time
!except=2

;start_file=dir+'const_b_test.start'
;outfile=dir+'const_b_test2.start'
start_file= dir+fname+".start"
outfile= dir+"L10Mm_D7mm_T1MK_eq.sav"
restore,start_file

l=max(x)
;Just using this to get the proper heating for a 1d6 K loop
ttop=1d6
l=max(x)
heat = 9.14d-7 * Ttop^3.51d * (L/2d)^(-2d) ;scaling law


;window,0

n_lhist=n_elements(lhist)
;stateplot2, x,lhist[n_lhist-1] , /screen
q0=heat
time_step=10d
;computer='mithra'
computer='dawntreader'
so=get_bnh_so(computer)
max_v=1d4 
delta_t=0d
done=0
n_lhist=1l
    
    regrid4,infile=start_file, outfile=outfile , /SHOWME
counter=0
while done le 0 do begin
;   for i=0,10 do begin
    evolve10_t,outfile ,time_step ,time_step, $
      outfile=outfile, $
      computer=computer,$
      q0=q0,so=so,/showme
    
    
    restore, outfile
    
    n_lhist=n_elements(lhist)
    
    ;window,0,xs=600,ys=600
    if counter ge 50 then begin
        stateplot2, x,lhist[n_lhist-1], $
          fname=strcompress(string(delta_t),/remove)+'_snap.ps'
        counter=-1
        endif
    max_v=max(abs(lhist[n_lhist-1].v))
    delta_t=delta_t+time_step
    if max_v lt 1d2 then done=1
    if delta_t gt 10000d then done=1
    print, 'Maximum Velocity: '+strcompress(string(max_v),/remove)+' cm/s'
;     regrid4,infile=outfile, outfile=outfile
    counter=counter+1l
endwhile
;endfor
mk_hd_movie,file=outfile,gif_dir=dir
journal
exit
end

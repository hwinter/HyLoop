;pro mk_hxt_plot,loop,brems_struct,LOOPFILE=LOOPFILE,$
;                 BREMSFILE=BREMSFILE,OUTFILE=OUTFILE, $
;                 GIF_DIR=GIF_DIR,$
;                 RES=RES, STR=STR ;, MAP195=MAP195,$
                                ;MAP171=MAP171, EXP=EXP, CADENCE=CADENCE

if keyword_set(infile)then restore,infile
IF not keyword_set(OUTFILE) THEN OUTFILE='hxt_movie'
IF not keyword_set(GIF_DIR) then GIF_DIR='./'

IF not keyword_set(res) then res=5d ;HXT pixel res. arcsec
pixel=res*700d*1d5
XSIZE=400
YSIZE=600
$unlimit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define Constants
;One AU Squared in cm^2
AU_2=(1.5d13)^2
four_pi=4d*!dpi

denominator=1d/(AU_2*four_pi)
delvarx, l_signal, m1_signal, m2_signal

L_range=[14.,23.]
M1_range=[23.,33.]; Disputed
M2_rangE=[33.,53.]
IF not keyword_set(exp) then exp=3d

start_time=systime(/julian)
n_loop=n_elements(loop)
n_depth=loop[0].n_depth

n_vol=n_elements(loop[0].state.e)-2l
n_x=n_elements(loop[0].s)

n_images=loop[n_loop-1l].time/exp
n_brems=n_elements(brems_struct)
volumes=get_loop_vol(loop[0])
n_vol=n_elements(volumes)
L_signal=dblarr(n_vol)
M1_signal=dblarr(n_vol)
M2_signal=dblarr(n_vol)


 
i=0
axis=loop[i].axis
axis[0,*]=loop[i].axis[2,*]
axis[1,*]=loop[i].axis[1,*]
axis[2,*]=loop[i].axis[0,*]
;For the side tip
;axis=(rot3#axis)
rad=loop[i].rad
n_vol=n_elements(volumes)
times=brems_struct.time
for i=0, n_elements(brems_struct) -1l do begin
    L_index_low=where(brems_struct[i].nt_brems[0].ph_energies $
                      le L_range[0])
    L_index_low=L_index_low[n_elements(L_index_low)-1l]
    
    L_index_high=where(brems_struct[i].nt_brems[0].ph_energies $
                       ge L_range[1])
    L_index_high=L_index_high[0]
    
    
    M1_index_low=where(brems_struct[i].nt_brems[0].ph_energies $
                       le M1_range[0])
    M1_index_low=M1_index_low[n_elements(M1_index_low)-1l]
    
    M1_index_high=where(brems_struct[i].nt_brems[0].ph_energies $
                        ge M1_range[1])
    M1_index_high=M1_index_high[0]
    
    
    M2_index_low=where(brems_struct[i].nt_brems[0].ph_energies $
                   le M2_range[0])
    M2_index_low=M2_index_low[n_elements(M2_index_low)-1l]
    
    M2_index_high=where(brems_struct[i].nt_brems[0].ph_energies $
                        ge M2_range[1])
    M2_index_high=M2_index_high[0]
;    L_signal_temp=dblarr(n_vol)
;    M1_signal_temp=dblarr(n_vol)
;    M2_signal_temp=dblarr(n_vol)


    k=where(min(abs(loop.s-max(loop.s)*.5)) eq abs(loop.s-max(loop.s)*.5))    
   ; for k=0,n_vol-1l do begin
    L_signal_temp=denominator* $
                  total(brems_struct[i].nt_brems[k].n_photons[L_index_low:L_index_high])
    M1_signal_temp=denominator* $
                   total(brems_struct[i].nt_brems[k].n_photons[M1_index_low:M1_index_high])
    M2_signal_temp=denominator* $
                   total(brems_struct[i].nt_brems[k].n_photons[L_index_low:M2_index_high])
    
    if n_elements(L_signal) lt 1 then L_signal=L_signal_temp else L_signal=[L_signal,L_signal_temp]
    if n_elements(M1_signal) lt 1 then M1_signal=M1_signal_temp else M1_signal=[M1_signal,M1_signal_temp]
    if n_elements(M2_signal) lt 1 then M2_signal=M2_signal_temp else M2_signal=[M2_signal,M2_signal_temp]
   ; endfor
    
endfor

    plot, times, L_signal  

end

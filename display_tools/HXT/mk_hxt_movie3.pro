;pro mk_hxt_movie3,loop,brems_struct,LOOPFILE=LOOPFILE,$
;                 BREMSFILE=BREMSFILE,OUTFILE=OUTFILE, $
;                 GIF_DIR=GIF_DIR,$
;                 RES=RES, STR=STR ;, MAP195=MAP195,$
                                ;MAP171=MAP171, EXP=EXP, CADENCE=CADENCE

if keyword_set(infile)then restore,infile
IF not keyword_set(OUTFILE) THEN OUTFILE='hxt_movie'
IF not keyword_set(GIF_DIR) then GIF_DIR='./'

IF not keyword_set(res) then res=5d ;HXT pixel res. arcsec
pixel=res*700d*1d5
XSIZE=600
YSIZE=250
$unlimit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define Constants
;One AU Squared in cm^2
AU_2=(1.5d13)^2
four_pi=4d*!dpi

denominator=1d/(AU_2*four_pi)


L_range=[14.,23.]
M1_range=[23.,33.]; Disputed
M2_rangE=[33.,53.]
IF not keyword_set(exp) then exp=3d

start_time=systime(/julian)
n_loop=n_elements(loop)

window,0,xs=XSIZE,ys=YSIZE
window,1,xs=XSIZE,ys=YSIZE
window, 2, xs=XSIZE,ys=YSIZE
WINDOW,3, xs=3.*XSIZE,ys=YSIZE

n_depth=loop[0].n_depth

n_vol=n_elements(loop[0].state.e)-2l
n_x=n_elements(loop[0].s)

n_images=loop[n_loop-1l].time/exp
n_brems=n_elements(brems_struct)
volumes=get_loop_vol(loop[0].s, loop[0].a)
n_vol=n_elements(volumes)
L_signal=dblarr(n_vol)
M1_signal=dblarr(n_vol)
M2_signal=dblarr(n_vol)


 
i=0
axis=loop[i].axis
axis[0,*]=loop[i].axis[2,*]
axis[1,*]=loop[i].axis[0,*]
axis[2,*]=loop[i].axis[1,*]
;For the side tip
;axis=(rot3#axis)
image_L=1
image_M1=1
image_M2=1
rad=loop[i].rad
volumes=get_loop_vol(loop[i+1l].s,loop[i+1l].a)
n_vol=n_elements(volumes)

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

i=0

loadct,15,/silent
;for i=0,long(n_brems/1.5)-1l do begin


    axis=loop[i].axis

axis[0,*]=loop[i].axis[1,*]
axis[1,*]=loop[i].axis[2,*]
axis[2,*]=loop[i].axis[0,*]
;For the side tip
;axis=(rot3#axis)
    rad=loop[i].rad
    volumes=get_loop_vol(loop[i+1l].s,loop[i+1l].a)
    n_vol=n_elements(volumes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    L_signal_temp=dblarr(n_vol)
    M1_signal_temp=dblarr(n_vol)
    M2_signal_temp=dblarr(n_vol)
    
    for k=0,n_vol-1l do begin
        L_signal_temp[k]=total(safe_log10($
                                          brems_struct[*].nt_brems[k].n_photons[L_index_low:L_index_high]))
        M1_signal_temp[k]=total(safe_log10(brems_struct[*].nt_brems[k].n_photons[M1_index_low:M1_index_high]))
        M2_signal_temp[k]=total(safe_log10(brems_struct[*].nt_brems[k].n_photons[L_index_low:M2_index_high]))
        
    endfor
    
;    L_signal=[ [L_signal],[ L_signal_temp]]
;    M1_signal=[[M1_signal],[M1_signal_temp]]
;    M2_signal=[[M2_signal],[M2_signal_temp]]

    wset,0
    show_loop_image,axis,rad,$
                    L_signal_temp,pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_L;,/NOSCALE ;,/sqrt;
    wset,1
    show_loop_image,axis,rad,M1_signal_temp, $
                    pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_M1;,/NOSCALE ;,/sqrt
;
    wset,2
    show_loop_image,axis,rad,M2_signal_temp, $
                    pixel=pixel,win=win_num,$
                    dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=image_M2;,/NOSCALE ;,/sqrt
;
    temp_image_struct={image_L:image_L,image_M1:image_M1,image_M2:image_M2}
    
    if n_elements(image_struct) lt 1 then image_struct=temp_image_struct $
      else image_struct=[image_struct,temp_image_struct]

;endfor

;image_struct[0].image_171[0:42]=1d6

;max_l=max(image_struct.image_L)
;min_l=min(image_struct.image_L)
;scaleL=255/max_L

;max_M1=max(image_struct.image_M1)
;min_M1=min(image_struct.image_M1)
;scaleM1=255/max_M1

;max_M2=max(image_struct.image_M2)
;min_M2=min(image_struct.image_M2)
;scaleM2=255/max_M2

animate_index=0
print, 'Now making the maps'
gifs=''

images=dblarr(n_elements(image_struct[0].image_m2[*,0]),$
              n_elements(image_struct[0].image_m2[0,*]), $
              3)
delvarx,brem_struct
for i=0,n_elements(image_struct)-1 do begin
    print,'I=',i
    time=Strcompress(string(loop[i].state.time,format='(g5.3)'),$
                     /remove_all)
    print,'time'+time
    wset,0
    images[*,*,0]=image_struct[i].image_L;*scaleL
    images[*,*,1]=image_struct[i].image_M1;*scaleM1
    images[*,*,2]=image_struct[i].image_M2;*scaleM2

    gif_name=strcompress(gif_dir+'HXT_frame'+string(animate_index,FORMAT= $  
                                                     '(I5.5)')+'.gif')
    x2gif, gif_name
    gifs=[gifs,gif_name]
    window,2,xs=xs,ys=ys
    tvscl, images[*,*,0]
    x2gif,'HXT_L.gif'
    animate_index+=1
endfor

delvarx,loop
;stop
gifs=gifs[where(gifs ne '')]
image2movie,gifs,$
  movie_name=strcompress(gif_dir+'HXT_movie.gif',/REMOVE_ALL), $
  gif_animate=1,loop=1
end

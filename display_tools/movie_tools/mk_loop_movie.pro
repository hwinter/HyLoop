; IDL Version 6.2 (linux x86_64 m64)
; Journal File for winter@mithra
; Working directory: /disk/hl2/data/winter/data1/PATC/loop_tools
; Date: Sat Feb 11 00:45:35 2006
 
patc_dir=get_environ('PATC')
data_dir=get_environ('DATA')
;file='/Users/winter/Data/AIA/base_strands/strand_start_heated_.0004.sav'
file=dialog_pickfile(path=data_dir)
break_file,file,disk,dir,filename,ext
restore,file
n_lhist=n_elements(lhist)
gif_dir=dir+'/gifs/'
mk_dir,gif_dir
signals=mk_aia_signals(x,a,lhist[0])
sig_str={signals:signals}
sig_str=replicate(sig_str,n_lhist)

pixel=700d*.6*1d5
rad=sqrt(A/!dpi)
rot=rotation(3,!pi/2)
;Define Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
kB = 1.38e-16 	;Boltzmann constant (erg/K)
mp = 1.67e-24 	;proton mass (g)
gamma = 5.0/3.0 ;ratio of specific heats, Cp/Cv
gs = 2.74e4 	;solar surface gravity
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;figure out grid size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
N = n_elements(lhist[0].v) 
;x on the volume element grid (like e, n_e)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x_alt = [2*x[0]-x[1],(x[0:N-3]+x[1:N-2])/2.0,2*x[N-2]-x[N-3]]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;find midpoint along loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
midpt = max(x_alt)/2.0 
;Calculate the temperature 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
T = lhist.e/(3.0*lhist.n_e*kB)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;phi=t[1:400]

window,1
plot_3dbox,axis[0,*],axis[1,*],axis[2,*]
axis=matrix_multiply(rot,axis)
rot=rotation(1,!dpi/2) 
axis=matrix_multiply(rot,axis)
;rot=rotation(2,.1d*!dpi/2) 
;axis=matrix_multiply(rot,axis)
;rot=rotation(3,.1d*!dpi) 
;axis=matrix_multiply(rot,axis)
window,2
plot_3dbox,axis[0,*],axis[1,*],axis[2,*]
window,0
wset,0
loadct,3
;stop
loadct,3
IF keyword_set(GIF_DIR) eq 0 then GIF_DIR=get_env(DATA)
animate_index=1l
 for i=0,n_elements(lhist)-1l do begin
     
     sig_str[i].signals=mk_aia_signals(x,a,lhist[i])
     
     mx_A94=max(sig_str.signals.A94)/255
     mx_A131=max(sig_str.signals.A131)/255
     mx_A171=max(sig_str.signals.A171)/255
     mx_A194=max(sig_str.signals.A194)/255
     mx_A211=max(sig_str.signals.A211)/255
     mx_A335=max(sig_str.signals.A335)/255
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     T = lhist[i].e/(3.0*lhist[i].n_e*kB)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     phi=t[1:400]
     
     phi=sig_str[i].signals.A94/mx_A94
     show_loop_image,axis,rad,phi,pixel=pixel
     legend,['A94', 'Time:'+String(lhist[i].time)],$
             box=0,charsize=1.6,/center,/bottom
     x2gif,strcompress(gif_dir+'loop_mov_A94_frames'+$
                       string(animate_index,FORMAT=$
                              '(I5.5)')+'.gif')

     phi=sig_str[i].signals.A131/mx_A131
     show_loop_image,axis,rad,phi,pixel=pixel
     legend,['A131', 'Time:'+String(lhist[i].time)],$
             box=0,charsize=1.6,/center,/bottom
     x2gif,strcompress(gif_dir+'loop_mov_A131_frames'+$
                       string(animate_index,FORMAT=$
                              '(I5.5)')+'.gif')

     phi=sig_str[i].signals.A171/mx_A171
     show_loop_image,axis,rad,phi,pixel=pixel
     legend,['A171', 'Time:'+String(lhist[i].time)],$
             box=0,charsize=1.6,/center,/bottom
     x2gif,strcompress(gif_dir+'loop_mov_A171_frames'+$
                       string(animate_index,FORMAT=$
                              '(I5.5)')+'.gif')


     phi=sig_str[i].signals.A194/mx_A194
     show_loop_image,axis,rad,phi,pixel=pixel
     legend,['A194', 'Time:'+String(lhist[i].time)],$
             box=0,charsize=1.6,/center,/bottom
     x2gif,strcompress(gif_dir+'loop_mov_A94_frames'+$
                       string(animate_index,FORMAT=$
                              '(I5.5)')+'.gif')

     phi=sig_str[i].signals.A211/mx_A211
     show_loop_image,axis,rad,phi,pixel=pixel
     legend,['A211', 'Time:'+String(lhist[i].time)],$
             box=0,charsize=1.6,/center,/bottom
     x2gif,strcompress(gif_dir+'loop_mov_A211_frames'+$
                       string(animate_index,FORMAT=$
                              '(I5.5)')+'.gif')

     phi=sig_str[i].signals.A335/mx_A335
     show_loop_image,axis,rad,phi,pixel=pixel
     legend,['A335', 'Time:'+String(lhist[i].time)],$
             box=0,charsize=1.6,/center,/bottom
     x2gif,strcompress(gif_dir+'loop_mov_A335_frames'+$
                       string(animate_index,FORMAT=$
                              '(I5.5)')+'.gif')







     animate_index=animate_index+1l
     print,string(animate_index)

;print,tresponse;
 endfor
 
 gifs=findfile(strcompress(gif_dir+'loop_mov_A94_frames*.gif'))
 BREAK_FILE, gifs[0], DISK_LOG, DIR, FILNAM, EXT
 
 image2movie,gifs,$
   movie_name=strcompress(gif_dir+'_A94loop_movie.gif',/REMOVE_ALL), $
   gif_animate=1,loop=1


;junk=delete_file(gifs)


end

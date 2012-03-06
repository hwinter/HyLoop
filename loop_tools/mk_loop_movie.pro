; IDL Version 6.2 (linux x86_64 m64)
; Journal File for winter@mithra
; Working directory: /disk/hl2/data/winter/data1/PATC/loop_tools
; Date: Sat Feb 11 00:45:35 2006
 
patc_dir=get_environ('PATC')
restore,patc_dir+'/loop_tools/loop_save1.0000000e+24.sav'
data_dir=get_environ('DATA')
gif_dir=data_dir+'/AIA/heating_sim/'
state_file=patc_dir+'/loop_tools/apex_heat_loop.sav'
;      0.00000  1.40000e+10
;Total:        197028.06
;Core:         989.51002
;saving file: "./loop_save1.0000000e+24.sav"
; % SAVE: Undefined item not saved: NOTE.
pixel=700d*.6*1d5
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
N = n_elements(lhist.v) 
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
phi=t[1:400]
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
show_loop_image,axis,rad,phi,pixel=pixel
; % Program caused arithmetic error: Floating illegal operand

loadct,3
restore,state_file
IF keyword_set(GIF_DIR) eq 0 then GIF_DIR=get_env(DATA)
animate_index=1l
 for i=0,n_elements(lhist)-1l do begin
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     T = lhist[i].e/(3.0*lhist[i].n_e*kB)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     phi=t[1:400]
     show_loop_image,axis,rad,phi,pixel=pixel
     x2gif,strcompress(gif_dir+'loop_mov_temp'+string(animate_index,FORMAT=$
                                                      '(I5.5)')+'.gif')
     animate_index=animate_index+1l
     print,string(animate_index)
;print,tresponse;
 endfor
 
 gifs=findfile(strcompress(gif_dir+'*.gif'))
 BREAK_FILE, gifs[0], DISK_LOG, DIR, FILNAM, EXT
 
 image2movie,gifs,$
   movie_name=strcompress(gif_dir+'loop_movie.gif',/REMOVE_ALL), $
   gif_animate=1,loop=1
;junk=delete_file(gifs)


end

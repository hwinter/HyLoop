; IDL Version 6.2 (linux x86_64 m64)
; Journal File for winter@mithra
; Working directory: /disk/hl2/data/winter/data1/PATC/loop_tools
; Date: Sat Feb 11 00:45:35 2006
;plot_strands
patc_dir=getenv('PATC')
data_dir=getenv('DATA')
save_dir=data_dir+'/AIA/base_strands/gifs/'
mk_dir,save_dir
new_image=0
smooth_p=1
dxp0=1
dyp0=1
IMAGE_OUT=1
strand_files=file_search(data_dir+'/AIA/base_strands/strand_start_heated_*'$
                         ,/FULLY_QUALIFY_PATH)
device,retain=1
help, strand_files
N_strands=n_elements(strand_files)
loadct,3
    pixel=700d*.6*1d5
    ;rot1=rotation(3,!pi/2)
    rot1=rotation(2,!dpi/2) 
    rot2=rotation(3,!dpi/2)
animate_index=0
x_pix=280
y_pix=122

x_array=lindgen(x_pix)
y_array=lindgen(y_pix)

;img=lindgen(N_strands,x_pix,y_pix)
for i=0, N_strands-1l do begin
    break_file,strand_files[i],disk,dir,filename,ext
    restore,strand_files[i]
    n_lhist=n_elements(lhist)
    ;axis=(rot1#rot2#axis)
    axis=(rot2#rot1#axis)
   ; PLOT_3DBOX, AXIS[0,*],AXIS[1,*],AXIS[2,*]
    n_lhist=n_lhist-1l
    gif_dir=dir+'/gifs/'
    mk_dir,gif_dir
    signals=mk_aia_signals(x,a,lhist[n_lhist])
    rad=sqrt(A/!dpi)
    
;Define Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    kB = 1.38e-16               ;Boltzmann constant (erg/K)
    mp = 1.67e-24               ;proton mass (g)
    gamma = 5.0/3.0             ;ratio of specific heats, Cp/Cv
    gs = 2.74e4                 ;solar surface gravity
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;figure out grid size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    N = n_elements(lhist[n_lhist].v) 
;x on the volume element grid (like e, n_e)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    x_alt = [2*x[0]-x[1],(x[0:N-3]+x[1:N-2])/2.0,2*x[N-2]-x[N-3]]

    dv=0.5*(a(0:N-2) +a(1:N-1)) * (x(1:N-1) - x(0:N-2))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;find midpoint along loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    midpt = max(x_alt)/2.0 
;Calculate the temperature 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    T = lhist[n_lhist].e/(3.0*lhist[n_lhist].n_e*kB)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;phi=smooth(t[1:400],5)
    win_num=!D.Unit
    if i eq 0 then begin 
    
     ;  img[I,*,*]= loop_image( axis, rad, phi, x_array, y_array)
     ; tvscl,img
        show_loop_image,axis,rad,signals.a94/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        ;IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
       ; window,3
        wset,win_num 
        ;junk=where{
        print,'A94'
        pmm,IMAGE_OUT
        pmm,signals.a94
        print,'*****************************************'
        A94map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A94'}

        show_loop_image,axis,rad,signals.a131/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
        print,'A131'
        pmm,IMAGE_OUT
        pmm,signals.a131
        print,'*****************************************'
       ; window,3
        wset,win_num 
        A131map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A131'}

        show_loop_image,axis,rad,signals.a171/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        ;IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
        print,'A171'
        pmm,IMAGE_OUT
        pmm,signals.a171
        print,'*****************************************'
        
       ; window,3
        wset,win_num 
        A171map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A171'}
        show_loop_image,axis,rad,signals.a194/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        ;IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
        print,'A194'
        pmm,IMAGE_OUT
        pmm,signals.a194
        print,'*****************************************'

        
       ; window,3
        wset,win_num 
        show_loop_image,axis,rad,signals.a194/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        ;IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
        A194map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A194'}
        
       ; window,3
        wset,win_num 
        show_loop_image,axis,rad,signals.a211/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        A211map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A211'}
        ;IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
        print,'A211'
        pmm,IMAGE_OUT
        pmm,signals.a211
        print,'*****************************************'

         
        show_loop_image,axis,rad,signals.a335/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        
       ; window,3
        wset,win_num 
        A335map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A335'}
        print,'A335'
        pmm,IMAGE_OUT
        pmm,signals.a335
        print,'*******'

 
        ;plot_map,map
    endif else begin
      ;  new_image=new_image+img[I,*,*]
     ;   tvscl,new_image
        wset,win_num
        signals=mk_aia_signals(x,a,lhist[i])
    
     ;  img[I,*,*]= loop_image( axis, rad, phi, x_array, y_array)
     ; tvscl,img
        show_loop_image,axis,rad,signals.a94/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        IMAGE_OUT=CONGRID(IMAGE_OUT,$
                          N_ELEMENTS(A94map[0].DATA[*,0]),$
                          N_ELEMENTS(A94map[0].DATA[0,*]))
       ; IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
        print,'A94'
        pmm,IMAGE_OUT
        pmm,signals.a94
        print,'*****************************************'

        pmm,signals.a211
        print,'*****************************************'


       ; window,3
        wset,win_num 
        t_A94map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A94'}

        show_loop_image,axis,rad,signals.a131/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        IMAGE_OUT=CONGRID(IMAGE_OUT,$
                          N_ELEMENTS(A131map[0].DATA[*,0]),$
                          N_ELEMENTS(A131map[0].DATA[0,*]))

        ;IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
        print,'A131'
        pmm,IMAGE_OUT
        pmm,signals.a131
        print,'*****************************************'



        
       ; window,3
        wset,win_num 
        t_A131map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A131'}

        show_loop_image,axis,rad,signals.a171/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        IMAGE_OUT=CONGRID(IMAGE_OUT,$
                          N_ELEMENTS(A171map[0].DATA[*,0]),$
                          N_ELEMENTS(A171map[0].DATA[0,*]))
        ;IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
        print,'A171'
        pmm,IMAGE_OUT

        
       ; window,3
        wset,win_num 
        t_A171map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A171'}
        show_loop_image,axis,rad,signals.a194/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        IMAGE_OUT=CONGRID(IMAGE_OUT,$
                          N_ELEMENTS(A194map[0].DATA[*,0]),$
                          N_ELEMENTS(A194map[0].DATA[0,*]))
        ;IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
        print,'A171'
        pmm,IMAGE_OUT
        pmm,signals.a171
        print,'*****************************************'


        
       ; window,3
        wset,win_num 
        t_A194map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A194'}

        show_loop_image,axis,rad,signals.a211/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        IMAGE_OUT=CONGRID(IMAGE_OUT,$
                          N_ELEMENTS(A211map[0].DATA[*,0]),$
                          N_ELEMENTS(A211map[0].DATA[0,*]))
       ; IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
        print,'A211'
        pmm,IMAGE_OUT
        pmm,signals.a211
        print,'*****************************************'


        
       ; window,3
        wset,win_num 
        t_A211map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A211'}
        show_loop_image,axis,rad,signals.a335/(1d),pixel=pixel,win=win_num,$
                     dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        IMAGE_OUT=CONGRID(IMAGE_OUT,$
                          N_ELEMENTS(A335map[0].DATA[*,0]),$
                          N_ELEMENTS(A335map[0].DATA[0,*]))
        ;IMAGE_OUT=smooth(IMAGE_OUT,smooth_p)
        print,'A355'
        pmm,IMAGE_OUT
        pmm,signals.A335
        print,'*****************************************'



        
       ; window,3
        wset,win_num 
        t_A335map={data:IMAGE_OUT,$
                  xc:500,yc:-500,dx:pixel*(1d/(3600*700*1d5)),$
                  dy:pixel*(1d/(3600*700*1d5)),$
                  time:'17-Apr-2006 15:23:16.000',$
                  ID:'AIA: A335'}
   ;     print,string(i)

       ;show_loop_image,axis,rad,phi,pixel=pixel,add=1,win=win_num,$
        ;             dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
        ;img[I,*,*]=img[i-1l,*,*]+IMAGE_OUT
       ; wset,3
                                ; plots,axis[0,*],axis[1,*],axis[2,*]
        ;plot_map,map/OVER
        ;map=[map,temp_map]
        wset,win_num    
     A94map=[A94map, t_A94map]
     A131map=[A131map, t_A131map]
     A171map=[A171map, t_A171map]
     A194map=[A194map, t_A194map]
     A211map=[A211map, t_A211map]
     A335map=[A335map, t_A335map]



    endelse

    ; legend,['AIA Strands', 'Temp. Map'],$
     ;        box=0,charsize=1.6,/center,/bottom

     ;x2gif,strcompress(save_dir+'strands_frames'+$
   ;                    string(animate_index,FORMAT=$
    ;                          '(I5.5)')+'.gif')
      wset,win_num 



     animate_index=animate_index+1l
     print,string(animate_index)

;print,tresponse;
 endfor
 
; gifs=findfile(strcompress(gif_dir+'loop_mov_A94_frames*.gif'))
 ;BREAK_FILE, gifs[0], DISK_LOG, DIR, FILNAM, EXT
 
 ;image2movie,gifs,$
 ;  movie_name=strcompress(gif_dir+'_movie.gif',/REMOVE_ALL), $
 ;  mpeg=1                       ;gif_animate=1,loop=1
 

;junk=delete_file(gifs)

save,A94map,A131map,A171map, A194map,A211map,A335map,file='strands_map.sav'

plot_map,A335map[0],/grid
for i=1,n_elements(A335map) do begin 
    plot_map,A194map[i],/over,composite=2,/grid


    endfor

end

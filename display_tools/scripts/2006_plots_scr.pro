;signal=patc_nt_brem(loop,BEAM_STRUCT = in_beam,$
;   SCALE_FACTOR=beam_struct[0].SCALE_FActor,$
;  KEV_BAND=[12,20]);, PER_vol=1)
!p.multi=[0,0,0,0]
if !d.name ne 'Z' then DEVICE, SET_FONT='Times', /TT_FONT  
n_times=n_elements(beam_struct)
loadct,3
pixel=700d*.2*1d5
CHARSIZE=2.7
CHARTHICK=1.8
lthick=3

rot1=rotation(2,!dpi/2) 
rot2=rotation(3,!dpi/2)

axis=loop[0].axis
axis=(rot2#rot1#axis)
;axis=(rot1#axis)
rad=loop[0].rad

;volumes=get_loop_vol(loop[0].s,loop[0].a)
;signal=0.001+dv/volumes

;signal[0:loop[0].n_depth]=0
;signal[n_elements(loop[0].s)-1-loop[0].n_depth:n_elements(loop[0].s)-2]=0
;signal[0:45]=5*volumes[0:45]
;signal[46:80]=100*volumes[26]
;signal[81:120]=200*volumes[81:120]
;show_loop_image,axis,rad,signal,pixel=pixel,win=win_num,$
;                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=IMAGE_OUT
;x2gif,'3d_model.gif'
;dv_display_old, loop,dv,beam_struct[0].SCALE_FACTOR;, $

em=get_loop_em(loop[n_times-1].state,loop[n_times-1].s,loop[n_times-1].a)
max_em=max(em)
em1=dblarr(n_times,n_elements(em))
temp=get_loop_temp(loop[n_times-1].state)
temp=dblarr(n_times,n_elements(temp))
em_base=dblarr(n_times)
em_mid=dblarr(n_times)
em_apex=dblarr(n_times)


temp_base=dblarr(n_times)
temp_mid=dblarr(n_times)
temp_apex=dblarr(n_times)
;plot, loop[0].state.time,em,yrange=[1d20,max_em]

for i=0, n_times-1 do begin
    em1[i,*]=get_loop_em(loop[i].state,loop[i].s,loop[i].a)
    temp[i,*]=get_loop_temp(loop[i].state)
    em_base[i]=mean(em1[i,0:45])
    em_mid[i]=mean(em1[i,46:80])
    em_apex[i]=mean(em1[i,81:120])
    
    temp_base[i]=mean(temp[i,0:45])
    temp_mid[i]=mean(temp[i,46:80])
    temp_apex[i]=mean(temp[i,81:120])

    
endfor
max=max(em1)
window,0,xs=800,ys=800

max_plot=max( [em_base,em_mid,em_apex])
MIN_PLOT=MIN( [em_base,em_mid,em_apex])
P_STATE=!P.MULTI
LOADCT,0
!P.MULTI=[0,1,3]

LOADCT,0,/SILENT
plot, loop.state.time, em_apex, TITLE='Loop Apex',$
      ;YTITLE='Emission Measure [cm!e-3!n]',$
      ;XTITLE='Time [seconds]',$
      charsize=CHARSIZE,$
      charthick=CHARTHICK, background=255,color=0,$
      /nodata,/YLOG
;
tvlct,[0,255,0,0], [0,0,255,0], [0,0,0,255];defining colors

oplot,  loop.state.time,em_apex,COLOR=3,thick=lthick

LOADCT,0,/SILENT

plot, loop.state.time, em_MID, TITLE='Mid Loop',$
      YTITLE='Emission Measure [cm!e-3!n]',$
      ;XTITLE='Time [seconds]',$
      charsize=CHARSIZE,$
      charthick=CHARTHICK, background=255,color=0,$
      /nodata,/YLOG

tvlct,[0,255,0,0], [0,0,255,0], [0,0,0,255];defining colors

oplot,  loop.state.time, em_mid,COLOR=2,THICK=lthick

plot, loop.state.time, em_base, $;YRANGE=[MIN_PLOT,max_plot], $
      /YS, TITLE='Loop Base',$
      ;YTITLE='Emission Measure [cm!e-3!n]',$
      XTITLE='Time [seconds]',$
      charsize=CHARSIZE,$
      charthick=CHARTHICK, background=255,color=0,$
      /nodata,/YLOG

tvlct,[0,255,0,0], [0,0,255,0], [0,0,0,255];defining colors

oplot, loop.state.time, em_base, COLOR=1,THICK=lthick

x2gif,'em_plot.gif'

LOADCT,0
window,1,xs=800,ys=800

plot, loop.state.time, temp_apex, TITLE='Loop Apex',$
      ;YTITLE='Temperature [K]',$
      ;XTITLE='Time [seconds]',$
      charsize=CHARSIZE,$
      charthick=CHARTHICK, background=255,color=1,$
      /nodata;,/YLOG

tvlct,[0,255,0,0], [0,0,255,0], [0,0,0,255];defining colors

oplot, loop.state.time, temp_apex, COLOR=3,THICK=lthick
LOADCT,0,/SILENT

plot, loop.state.time, temp_MID, TITLE='Mid Loop',$
      YTITLE='Temperature [K]',$
      ;XTITLE='Time [seconds]',$
      charsize=CHARSIZE,$
      charthick=CHARTHICK, background=255,color=0,$
      /nodata;,/YLOG

tvlct,[0,255,0,0], [0,0,255,0], [0,0,0,255];defining colors

oplot,  loop.state.time, temp_mid,COLOR=2,THICK=lthick

LOADCT,0,/SILENT
plot, loop.state.time, temp_apex, TITLE='Loop Base',$
      ;YTITLE='Temperature [K]',$
      XTITLE='Time [seconds]',$
      charsize=CHARSIZE,$
      charthick=CHARTHICK, background=255,color=2,$
      /nodata;,/YLOG
;
tvlct,[0,255,0,0], [0,0,255,0], [0,0,0,255];defining colors

oplot,  loop.state.time,temp_base,COLOR=1,thick=lthick
x2gif,'temp_plot.gif'




LOADCT,0
!p.multi=p_state


window,0,xs=700,ys=700
window,1,xs=700,ys=700
window,2,xs=700,ys=700
window,3,xs=700,ys=700
window,4,xs=700,ys=700

window,4,xs=700,ys=700
res=2.48d ;SXT pixel res. arcsec
pixel=res*700d*1d5
start_time=systime(/julian)

n_vol=n_elements(loop[0].state.e)-2l
n_x=n_elements(loop[0].s)
loadct, 3,/sile


i=0

 rad=loop[i].rad
    volumes=get_loop_vol(loop[i].s,loop[i].a)
    signal=get_sxt_emiss(loop[i],/per)

    thin_al=1
    dag=1
    be=1
    thick_al=1
    mg=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Artificially kill the chromospheric signal;
    signal.thin_al[0:n_depth]=0d
    signal.thin_al[(n_vol-1-n_depth):n_vol-1]=0
    
    signal.dag[0:n_depth]=0d
    signal.dag[(n_vol-1-n_depth):n_vol-1]=0
   
    signal.be[0:n_depth]=0d
    signal.be[(n_vol-1-n_depth):n_vol-1]=0

    signal.thick_al[0:n_depth]=0d
    signal.thick_al[(n_vol-1-n_depth):n_vol-1]=0

    signal.mg[0:n_depth]=0d
    signal.mg[(n_vol-1-n_depth):n_vol-1]=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
   
window,0,xs=700,ys=700
window,1,xs=700,ys=700
window,2,xs=700,ys=700
window,3,xs=700,ys=700
window,4,xs=700,ys=700

wset,1
    show_loop_image,axis,rad,signal.dag,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=dag;,/sqrt;,/NOSCALE

    
    
    wset,3
    show_loop_image,axis,rad,signal.thick_al,pixel=pixel,win=win_num,$
                dxp0=dxp0, dyp0=dyp0,IMAGE_OUT=thick_al;,/sqrt;,/NOSCALE

  



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make a structure to contain the images before mapping
temp_image_struct={dag:dag,$
                   thick_al:thick_al}
    
   
    if n_elements(image_struct) lt 1 then image_struct=temp_image_struct $
      else image_struct=[image_struct,temp_image_struct]
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;       
endfor

scale_dag=255/max(image_struct.dag)
scale_thick_al=255/max(image_struct.thick_al)


animate_index=0
gifs_thin_al=''
gifs_dag=''
gifs_thick_al=''
gifs_be=''
gifs_mg=''


   time=' 16-JUN-2006 00:00:'+Strcompress(string(loop[i].state.time,format='(g5.3)'),/remove_all)
    print,'time'+time

 
     wset,1
                                ;tvscl,image_struct[i].image_171*scale171
     map={data:image_struct[i].dag*scale_dag,$
          xc:1000,yc:0,dx:res,$  ;pix1d/(3600*700*1d5)),$
          dy:res,$               ;:pixel*(/(700*1d5)),$
          time:(time),$
          ID:'SXT: DAG'}
  ;   if n_elements(DAG_map) lt 1 then  DAg_map=map $
  ;   else Dag_map=concat_struct(dag_map,map)

     plot_map,Map,XRANGE=[900,1200],YRANGE=[-250,250],$
              /limb_plot,lmthick=1,grid=50 
;,/nodata;;composite=1,/over,/average,/INTER

     gif_file=strcompress('dag_'+string(i)+'.gif')
     x2gif,gif_file

wset,3
                                ;tvscl,image_struct[i].image_171*scale171
     map={data:image_struct[i].thick_al*scale_thick_al,$
          xc:1000,yc:0,dx:res,$  
          dy:res,$               
          time:(time),$
          ID:'SXT: Thick Al'}
 ;    if n_elements(thick_al_map) lt 1 then  thick_al_map=map $
  ;   else thick_al_map=concat_struct(thick_al_map,map)

     plot_map,Map,XRANGE=[900,1200],YRANGE=[-250,250],$
              /limb_plot,lmthick=1,grid=50 
;,/nodata;;composite=1,/over,/average,/INTER

     gif_file=strcompress('thick_al_'+string(i)+'.gif')
     x2gif,gif_file




end

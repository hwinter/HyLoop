;.r rot_test1
folder_1=getenv('DATA')+'/PATC/runs/piet_scaling_laws/joule_heating_const_depth_big/n_depth=25_n_cells=500/'
folder_2=getenv('DATA')+'/PATC/runs/piet_scaling_laws/Const_flux_big/alpha=-1.5_beta=0.0/n_depth=25_n_cells=500/'
folder_3=getenv('DATA')+'/PATC/runs/piet_scaling_laws/Const_flux_big/alpha=-2.0_beta=0.0/n_depth=25_n_cells=500/'
folder_4=getenv('DATA')+'/PATC/runs/piet_scaling_laws/Const_flux_big/alpha=-1.0_beta=0.0/n_depth=25_n_cells=500/'

movie_name='prop_sim4'
save_file=['xrt_map4_2arcsec.sav','xrt_map4_.5arcsec.sav']
;shape_file=getenv('DATA')+'/PATC/runs/xbp.sav'
;restore, shape_file
;Data_dir=getenv('DATA')+'/PATC/runs/test/'
set_plot, 'x'
;device, SET_RESOLUTION=[800,800]
loadct,3
spawn, 'renice 4 -u winter' 
FONT=1
exp=2
OFFSET1=.4
freq_out=4
file_prefix='T*'
file_ext='.loop'
erase
gif_name_prefix='junk_'
start_hour_0=08
start_minute_0=00.
        loadct, 3
max_files=1200
frames_per_map=3
files1=file_search(folder_1, file_prefix+file_ext, COUNT=FILES1_COUNT)
files2=file_search(folder_2, file_prefix+file_ext, COUNT=FILES2_COUNT)
files3=file_search(folder_3, file_prefix+file_ext, COUNT=FILES3_COUNT)
files4=file_search(folder_4, file_prefix+file_ext, COUNT=FILES4_COUNT)

FILES_COUNT=min([files1_COUNT,files2_COUNT,files3_COUNT,files4_COUNT])
res=[2., .5]
fwhm=3.
FILES_COUNT<=max_files
;goto, just_movie
for i=0ul, 1ul do begin
    delvarx, temp_map,xrt_map, imap
    
    az=15
    ax=10
    ay=68
    rot11=rotation(1,((!dpi*ax)/180.))
    rot22=rotation(2,((!dpi*ay/180.)))
    rot33=rotation(3,((!dpi*az/180.)))
    
    rota=rot11#rot22#rot33
   

    start_hour=start_hour_0
    start_minute=start_minute_0
    xrt_map1=mk_loop_xrt_map(files4[0:FILES_COUNT-1],$
                             filter=0,rot1=rot11,rot2=rot22,rot3=rot33, $
                             exp=exp, XC=0.1, YC=5.0,$
                             xrange=[-80, 80],$
                             yrange=[-80,80], res=res[i],$
                             fwhm=fwhm,$
                             start_hour=start_hour, start_minute=start_minute  )
    
    
    az=20.
    ax=2
    ay=15
    rot11=rotation(1,((!dpi*ax)/180.))
    rot22=rotation(2,((!dpi*ay/180.)))
    rot33=rotation(3,((!dpi*az/180.)))
    rota=rot11#rot22#rot33
    
    start_hour=start_hour_0
    start_minute=start_minute_0
    xrt_map2=mk_loop_xrt_map(files4[0:FILES_COUNT-1],$
                        filter=0,rot1=rot11,rot2=rot22,rot3=rot33,  $
                        exp=exp, XC=0.1, YC=5.0,$
                        xrange=[-80, 80],$
                        yrange=[-80,80], res=res[i],$
                             fwhm=fwhm,$
                             start_hour=start_hour, start_minute=start_minute )


    az=5.
    ax=45
    ay=20
    rot11=rotation(1,((!dpi*ax)/180.))
    rot22=rotation(2,((!dpi*ay/180.)))
    rot33=rotation(3,((!dpi*az/180.)))
    rota=rot11#rot22#rot33
    
    start_hour=start_hour_0
    start_minute=start_minute_0
    xrt_map3=mk_loop_xrt_map(files4[0:FILES_COUNT-1],$
                        filter=0,rot1=rot11,rot2=rot22,rot3=rot33, $
                        exp=exp, XC=0.1, YC=5.0,$
                        xrange=[-80, 80],$
                        yrange=[-80,80], res=res[i],$
                             fwhm=fwhm,$
                             start_hour=start_hour, start_minute=start_minute )

    az=45.
    ax=25
    ay=25
    rot11=rotation(1,((!dpi*ax)/180.))
    rot22=rotation(2,((!dpi*ay/180.)))
    rot33=rotation(3,((!dpi*az/180.)))
    rota=rot11#rot22#rot33


    xrt_map4=mk_loop_xrt_map(files4[0:FILES_COUNT-1],$
                        filter=0,rot1=rot11,rot2=rot22,rot3=rot33, $
                        exp=exp, XC=0.1, YC=5.0,$
                        xrange=[-80, 80],$
                        yrange=[-80,80], res=res[i],$
                             start_hour=start_hour, start_minute=start_minute )
    

   
    az=10.
    ax=16
    ay=30
    rot11=rotation(1,((!dpi*ax)/180.))
    rot22=rotation(2,((!dpi*ay/180.))) 
    rot33=rotation(3,((!dpi*az/180.)))
    rota=rot11#rot22#rot33

    start_hour=start_hour_0
    start_minute=start_minute_0
    xrt_map5=mk_loop_xrt_map(files2[0:FILES_COUNT-1],$
                        filter=0,rot1=rot11,rot2=rot22,rot3=rot33, $
                        exp=exp, XC=0.1, YC=5.0,$
                        xrange=[-80, 80],$
                        yrange=[-80,80], res=res[i],$
                             fwhm=fwhm,$
                             start_hour=start_hour, start_minute=start_minute )
    az=5.
    ax=25
    ay=35
    rot11=rotation(1,((!dpi*ax)/180.))
    rot22=rotation(2,((!dpi*ay/180.)))
    rot33=rotation(3,((!dpi*az/180.)))
    rota=rot11#rot22#rot33

    start_hour=start_hour_0
    start_minute=start_minute_0
    xrt_map6=mk_loop_xrt_map(files2[0:FILES_COUNT-1],$
                        filter=0, rot1=rot11,rot2=rot22,rot3=rot33,$
                        exp=exp, XC=0.1, YC=5.0,$
                        xrange=[-80, 80],$
                        yrange=[-80,80], res=res[i],$
                             fwhm=fwhm,$
                             start_hour=start_hour, start_minute=start_minute )
    
    az=14.
    ax=52
    ay=45
    rot11=rotation(1,((!dpi*ax)/180.))
    rot22=rotation(2,((!dpi*ay/180.)))
    rot33=rotation(3,((!dpi*az/180.)))
    rota=rot11#rot22#rot33

    start_hour=start_hour_0
    start_minute=start_minute_0
    xrt_map7=mk_loop_xrt_map(files3[0:FILES_COUNT-1],$
                        filter=0,rot1=rot11,rot2=rot22,rot3=rot33, $
                        exp=exp, XC=0.1, YC=5.0,$
                        xrange=[-80, 80],$
                        yrange=[-80,80], res=res[i],$
                             fwhm=fwhm,$
                             start_hour=start_hour, start_minute=start_minute )
    
    
    az=14.
    ax=50
    ay=35
    rot11=rotation(1,((!dpi*ax)/180.))
    rot22=rotation(2,((!dpi*ay/180.)))
    rot33=rotation(3,((!dpi*az/180.)))
    rota=rot11#rot22#rot33

    start_hour=start_hour_0
    start_minute=start_minute_0
    xrt_map8=mk_loop_xrt_map(files3[0:FILES_COUNT-1],$
                        filter=0,rot1=rot11,rot2=rot22,rot3=rot33,  $
                        exp=exp, XC=0.1, YC=5.0,$
                        xrange=[-80, 80],$
                        yrange=[-80,80], res=res[i],$
                             fwhm=fwhm,$
                             start_hour=start_hour, start_minute=start_minute )
    az=22.
    ax=35
    ay=68
    rot11=rotation(1,((!dpi*ax)/180.))
    rot22=rotation(2,((!dpi*ay/180.)))
    rot33=rotation(3,((!dpi*az/180.)))
    rota=rot11#rot22#rot33

    start_hour=start_hour_0
    start_minute=start_minute_0
    xrt_map9=mk_loop_xrt_map(files4[0:FILES_COUNT-1],$
                        filter=0,rot1=rot11,rot2=rot22,rot3=rot33,  $
                        exp=exp, XC=0.1, YC=5.0,$
                        xrange=[-80, 80],$
                        yrange=[-80,80], res=res[i],$
                             fwhm=fwhm,$
                             start_hour=start_hour, start_minute=start_minute )

   

n_maps=min([n_elements(xrt_map1),n_elements(xrt_map2),$
           n_elements(xrt_map3),n_elements(xrt_map4),$
           n_elements(xrt_map5),n_elements(xrt_map6),$
           n_elements(xrt_map5),n_elements(xrt_map8),$
           n_elements(xrt_map9)])


for j=0ul, n_maps-1ul do begin
    imap=merge_map(xrt_map1[j], xrt_map2[j])
    imap=merge_map(imap, xrt_map3[j])
    imap=merge_map(imap, xrt_map4[j])
    imap=merge_map(imap, xrt_map5[j])
    imap=merge_map(imap, xrt_map6[j])
    imap=merge_map(imap, xrt_map7[j])
    imap=merge_map(imap, xrt_map8[j])
    imap=merge_map(imap, xrt_map9[j])

if size(xrt_map, /TYPE) EQ 0 then xrt_map=imap $
    else xrt_map=concat_struct(xrt_map,imap)
endfor

xrt_map.id='Res '+strcompress(string(res[i],format='(f05.2)'),/remove_all)+ ' arcsec Al-Poly'
save, xrt_map, file=save_file[i]
max_image=0
for j=0ul, n_elements(xrt_map)-1ul do begin
   if max(xrt_map.data) gt max_image then begin
       max_image=max(xrt_map.data)
       index=j
       endif
   endfor

gif_names=''
endfor
gif_names=''
j=0ul

just_movie:

restore, save_file[0]

max_scale1=0
for i=0ul, n_elements(xrt_map)-1ul do begin
    if max(xrt_map.data) gt max_scale1 then begin
        max_scale1=max(xrt_map.data)
        max_index1=i
    endif

        
endfor

for i=0ul, n_elements(xrt_map)-1ul do begin 
    for k=0, frames_per_map-1ul do begin
        temp_gif_name=gif_name_prefix+ $
          string(j,FORMAT= $  
                 '(I5.5)')+'.gif'
        gif_names=[gif_names,temp_gif_name]
        plot_map, xrt_map[i],/square,$
          /iso,$
          xrange=[-80, 80],$
          yrange=[-80,80]       ; , LAST_SCALE= xrt_map[max_index1]
                                ;z2gif, temp_gif_name
        x2gif, temp_gif_name
        j+=1
    endfor
endfor

map1=xrt_map

max_scale2=0
for i=0ul, n_elements(xrt_map)-1ul do begin
    if max(xrt_map.data) gt max_scale2 then begin
        max_scale2=max(xrt_map.data)
        max_index2=i
endif
endfor

restore, save_file[1]
old_multi=!p.multi
!p.multi=[0,2,1]
n=min([n_elements(map1), n_elements(xrt_map)])
for i=0ul, n-1ul do begin
    for k=0, frames_per_map-1ul do begin
        temp_gif_name=gif_name_prefix+ $
          string(j,FORMAT= $  
                 '(I5.5)')+'.gif'
        gif_names=[gif_names,temp_gif_name]
        plot_map, map1[i],/square,$
          /iso,$
          xrange=[-80, 80],$
          yrange=[-80,80]       ;, LAST_SCALE= xrt_map[max_index1]
                                ;z2gif, temp_gif_name
        plot_map, xrt_map[i],/square,$
          /iso,$
          xrange=[-80, 80],$
          yrange=[-80,80]       ;   , LAST_SCALE= xrt_map[max_index2]
                                ;z2gif, temp_gif_name
        x2gif, temp_gif_name
        j+=1
    endfor
endfor
!p.multi=old_multi
gif_names=gif_names[1:n_elements(gif_names)-1ul]
image2movie, gif_names, /mpeg, $
             movie_name=movie_name,$
             movie_dir='./',$
             scratch_dir='./'
set_plot, 'x'
pwd

end

;.r mk_xrt_movie3
;goto, just_movie
movie_name='prop_sim6'
save_file='xrt_zoom_map'

fwhm=3.
res=[2., .5]
exp=2
max_files=1200
frames_per_map=3
folders=[getenv('DATA')+'/PATC/runs/prop_movie/loop1/',$
            getenv('DATA')+'/PATC/runs/prop_movie/loop2/',$
            getenv('DATA')+'/PATC/runs/prop_movie/loop3/',$
            getenv('DATA')+'/PATC/runs/prop_movie/loop4/',$
            getenv('DATA')+'/PATC/runs/prop_movie/loop5/',$
            getenv('DATA')+'/PATC/runs/prop_movie/loop6/',$
            getenv('DATA')+'/PATC/runs/prop_movie/loop7/',$
            getenv('DATA')+'/PATC/runs/prop_movie/loop8/',$
            getenv('DATA')+'/PATC/runs/prop_movie/loop9/']


n_folders=n_elements(folders)
set_plot, 'x'
;device, SET_RESOLUTION=[800,800]
loadct,3
spawn, 'renice 4 -u winter' 
FONT=1
file_prefix='T*'
file_ext='.loop'
erase
gif_name_prefix='junk_'
start_hour_0=08
start_minute_0=00.
loadct, 3

FILES_COUNT=ulong(1d8)
for i=0ul, n_folders-1ul do begin
    files1=file_search(folders[i], file_prefix+file_ext, COUNT=FILES1_COUNT)
    if FILES1_COUNT lt FILES_COUNT then FILES_COUNT=FILES1_COUNT
endfor

FILES_COUNT<=max_files

files=strarr(FILES1_COUNT, n_folders)

for i=0ul, n_folders-1ul do begin
    temp_files=file_search(folders[i], file_prefix+file_ext)
    files[0,i]=temp_files[0:FILES_COUNT-1ul]

endfor
res_array=[max(res)+dblarr(2),$
          (max(res)-((max(res)-min(res))*(dindgen(100)/99))),$
          min(res)+dblarr(2)]
ii=0ul
step=ulong(exp)
done=0
jj=0ul
SAV_FILES=''
while not done do begin
    delvarx, temp_map,xrt_map, imap
    
    if jj le n_elements(res_array)-1ul then loop_res=res_array[jj] $
      else loop_res=res_array[ n_elements(res_array)-1ul]
    
    print, 'loop_res=', loop_res
    start_hour=start_hour_0
    start_minute=start_minute_0

    for j=0ul, n_folders-1ul do begin
        start_hour=start_hour_0
        start_minute=start_minute_0
        temp_map=mk_loop_xrt_map(files[ii:ii+step-1ul,j],$
                             filter=0, $
                             exp=exp, XC=0.0, YC=0.0,$
                             xrange=[-100, 100],$
                             yrange=[-100,100], res=loop_res,$
                             fwhm=fwhm,$
                             start_hour=start_hour, $
                             start_minute=start_minute , $
                             OVER=ii)
;This is a severe problem.
        if n_elements(temp_map) gt 1 then temp_map=temp_map[0]
        if size(xrt_map, /TYPE) EQ 0 then xrt_map=temp_map $
        else xrt_map=merge_map(xrt_map,temp_map )
        help, xrt_map
        dim=size(xrt_map.data,/dim)   
        disp=congrid(xrt_map.data, dim[0]*10, dim[1]*10)
        tvscl, disp
        ;plot_map, xrt_map
    endfor
    
    xrt_map[*].id='Res '+strcompress(string(loop_res,format='(f05.2)'),/remove_all)+ ' arcsec Al-Poly'

    
    FILENAME=save_file+'_'+strcompress(string(jj, format='(i5.5)'),/remove_all)+'.sav'
    SAV_FILES=[SAV_FILES,FILENAME]
    save, xrt_map, file=FILENAME
    
  ii+=step
  jj++
  if ii+step-1ul ge   FILES_COUNT-1ul then done=1
endwhile

SAV_FILES=SAV_FILES[1:n_elements(SAV_FILES)-1ul]
max_image=0
for j=0ul,n_elements(SAV_FILES)-1ul do begin
    restore, SAV_FILES[j]
    if max(xrt_map.data) gt max_image then begin
        max_image=max(xrt_map.data)
        scale_map=xrt_map
    endif
endfor



just_movie:
gif_names=''
j=0ul

for i=0ul, n_elements(SAV_FILES)-1ul do begin 
    
    restore, SAV_FILES[i]
    for k=0, frames_per_map-1ul do begin
        temp_gif_name=gif_name_prefix+ $
          string(j,FORMAT= $  
                 '(I5.5)')+'.gif'
        gif_names=[gif_names,temp_gif_name]
        plot_map, xrt_map[0],/square,$
          /iso,$
          xrange=[-80, 80],$
          yrange=[-80,80];       , LAST_SCALE= scale_map
                                ;z2gif, temp_gif_name
   ;     x2gif, temp_gif_name
        j+=1
    endfor

endfor

STOP


gif_names=gif_names[1:n_elements(gif_names)-1ul]
image2movie, gif_names, /mpeg, $
             movie_name=movie_name,$
             movie_dir='./',$
             scratch_dir='./'
set_plot, 'x'
pwd

end

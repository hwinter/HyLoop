;.r mk_xr_image_02a_fe_03.pro
;Average the runs 
;3-6 keV band
set_plot, 'z'

MAP1_NAME='25_50kev_7arc.map'
map1_index=7
MAP2_NAME= '3_6kev_7arc.map'
MAP2_therm_NAME='3_6kev_7arc_therm_only.map'
MAP2_nt_NAME='3_6kev_7arc_nt_only.map'


prefix='sjc'
TITLE='3-6 keV'
movie_name='avg_3_6'
web_name='sui_compare_java/'

XC=0.0
YC=900.
xr=[XC-10, XC+35]
yr=[YC-40, YC+40]
outs_y=30
outs_x=15.
cthick=5
n_images=120
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
data_dir=getenv('DATA')+'/PATC/runs/flare_exp_03/'
plots_dir=data_dir+'plots/'

spawn, 'mkdir '+plots_dir

image_name=['alpha_-4__hxr_3_6_']
;folders=['alpha=-4/',$
;         'alpha=-3/',$
;         'alpha=-2/',$
;         'alpha=-1/',$
;         'alpha=0/',$
;         'alpha=1/',$
;         'alpha=2/',$
;         'alpha=3/',$
;         'alpha=4/']
sub_folders=['699_25/run_01/',$
             '699_25/run_02/',$
             '699_25/run_03/',$
             '699_25/run_04/',$
             '699_25/run_05/',$
             '699_25/run_06/',$
             '699_25/run_07/',$
             '699_25/run_08/',$
             '699_25/run_09/',$
             '699_25/run_10/']
folders=['alpha=-4/']
;sub_folders=['699_25/run_01/']


n_folders=n_elements(folders)
n_runs=n_elements(sub_folders)
delvarx, signal
apex_yrange=[-20,10]

;Rotate to have a limb loop
ay= 2.
az=0.
rot2=rotation(2,((!dpi*ay/180.)))
rot3=rotation(3,((!dpi*az/180.)))

Title1='Modeled Emission'
max_files=2400
set_plot,'x'
;restore, file

!P.multi=[0,1,2]

for i=0ul,  n_folders-1ul do begin

         movie_dir=data_dir+folders[i]+'movies/'
         spawn, 'mkdir '+movie_dir
         gif_dir=data_dir+folders[i]+'gifs/'
         spawn, 'mkdir '+gif_dir
         plots_dir=data_dir+folders[i]+'plots/'
         spawn, 'mkdir '+plots_dir
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make averge map1
         k=1
     
         map_dir=data_dir+folders[i]+sub_folders[k]+'maps/'
         cd , map_dir
         restore, MAP1_NAME; , verbose=1
         map1=map;[7]
         map1[*].xc=XC
         map1[*].yc=yc
         n_maps0=n_elements(map1)
         
     for k=1ul, n_runs-1ul do begin         
         map_dir=data_dir+folders[i]+sub_folders[k]+'maps/'
         cd , map_dir
         restore, MAP1_NAME; , verbose=1
         n_maps=n_elements(map)
         map[*].xc=XC
         map[*].yc=YC
         
         for l=0, n_maps-1ul do begin
             map1[l].data+=map[l].data ;[7]
         endfor
     endfor

     map1[*].data/=n_runs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make averge map2
         k=1
     
         map_dir=data_dir+folders[i]+sub_folders[k]+'maps/'
         cd , map_dir
         restore, MAP2_NAME; , verbose=1
         map2=map;[7]
         map2[*].xc=XC
         map2[*].yc=YC
         n_maps0=n_elements(map2)
         
         therm_signal=dblarr(n_maps)
         nt_signal=dblarr(n_maps)
         
         
         restore,MAP2_therm_NAME
         therm_map=map
         restore,MAP2_nt_NAME
         nt_map=map
         for l=0, n_maps-1ul do begin
             
             therm_signal[l]+=total(therm_map[l].data)
             nt_signal[l]+=total(nt_map[l].data)
         ENDFOR
         
     for k=1ul, n_runs-1ul do begin         
         map_dir=data_dir+folders[i]+sub_folders[k]+'maps/'
         cd , map_dir
         restore,MAP2_therm_NAME
         therm_map=map
         restore,MAP2_nt_NAME
         nt_map=map

         restore, MAP2_NAME ;, verbose=1
         n_maps=n_elements(map)
         map[*].xc=XC
         map[*].yc=YC
         
         for l=0, n_maps-1ul do begin            
             therm_signal[l]+=total(therm_map[l].data)
             nt_signal[l]+=total(nt_map[l].data)
             map2[l].data+=map[l].data ;
         endfor
     endfor

     map2[*].data/=n_runs
             
     therm_signal[*]/=n_runs
     nt_signal[*]/=n_runs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         
         old_map2=map2
         gif_files=''
         
         n_maps=min([n_elements(map1),n_elements(map2)])
         if size(n_images,/TYPE) ne 0 then  n_maps<=n_images
         for l=0, n_maps-1ul do begin
;         for l=0ul, min([n_elements(map1),n_elements(map2)])-1ul do begin
             ps_name=plots_dir+prefix+string(map1[l].time,format='(I05)')+'.eps'
             gif_name=gif_dir+prefix+string(map1[l].time,format='(I05)')+'.gif'
             set_plot, 'ps'
             device, /portrait, file= ps_name , color=16, /enc
             loadct,3 
             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
             plot_map,map1[0] , $       ;/notitle, $
                      /iso,/square, $   ; _extra=gang_plot_pos(1,2,0), $
                      title=TITLE , $
                      charthick=0.9, charsize=0.9, $
                      /contour , /percent, levels=[80], $
                      c_color=1 ,$
                      font=0 ,  background=255, $   ;color=0, $
                      grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                      CTHICK= CTHICK,$
                      POSITION=[0.12, 0.43, .33, 9.8] ;, /noax
             loadct, 0
                                ; plot_map, map2,contour=1, /over, cthick=1,$
                                ;                NLEVELS=10         
                                ;
             
             tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
             plot_map, map2[l],$ ;/notitle, $
                       /iso,/square,  $   ;_extra=gang_plot_pos(1,2,1), $
                       title=title , $
                       charthick=1.2, charsize=1.2,$
                       font=0 ,   background=255, $ 
                       /contour ,c_color=2 ,$
                       grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                       levels =[ 40., 60., 80.] ,$
                       /percent, /border,CTHICK= CTHICK,$
                       /OVER    ;, cstyle=2
          ;   xyouts, outs_x, outs_y, 't='+map2[l].time+' sec', font =0,  $
          ;           charthick=.7, charsize=.9,color=3

             
             times=dindgen(n_maps)
             line=[min(0), 1.1*max(therm_signal+nt_signal)]

             plot, times, (therm_signal+nt_signal), /nodata, $
                   POSITION=[0.12, 0.15, .95, .3333],$
                   font=0,charthick=0.9, charsize=0.9,$
                   yTITLE="Arbitrary Units", XTITLE="seconds"
             oplot, times, (therm_signal+nt_signal), thick=4
             oplot, times, (therm_signal), line=1, color=1, thick=4
             oplot, times, (nt_signal), line=2, color=2, thick=4
             oplot, [times[l], times[l]], line, thick=4
             
      device, /close
      ;stop
      spawn, 'convert '+ ps_name+' '+gif_name
   ;     spawn, "convert  -rotate '-90' "+ $
    ;           gif_name+'  '+gif_name
      print, gif_name
      gif_files=[gif_files, gif_name]
  endfor

  gif_files=gif_files[1:N_ELEMENTS(gif_files)-1UL]
  print, movie_dir+movie_name
  image2movie,gif_files, $
              movie_name=movie_name+'.mpg',$
              movie_dir=movie_dir,$
              /mpeg,$                      ;/java,$
              scratchdir=gif_dir ,$  ;nothumbnail=1,$
              /nodelete
  image2movie,gif_files, $
              movie_name=movie_name+'.gif',$
              movie_dir=movie_dir,$
              /gif, $                      ;/java,$
              scratchdir=gif_dir ,$  ;nothumbnail=1,$
              /nodelete

  spawn,' mkdir '+movie_dir+web_name
  
  cd , movie_dir+web_name
  image2movie,gif_files, $
              movie_name=movie_name,$
              movie_dir='./',$
              /java,$                      ;/java,$
              scratchdir=gif_dir
    
endfor
;Folders


end

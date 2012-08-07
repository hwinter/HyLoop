;.r mk_xr_image_01_fe_03.pro

set_plot, 'z'

MAP1_NAME='25_50kev_7arc.map'
map1_index=7
MAP2_NAME= '3_6kev_7arc.map'
prefix='sjc'
TITLE='3-6 keV'
movie_name='sjc_1'
web_name='sui_compare_java/'

xr=[-10, 35]
yr=[-40, 40]
outs_y=40
cthick=5
n_images=100
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
             '699_25/run_05/']
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



 for i=0ul,  n_folders-1ul do begin
     for k=0ul, n_runs-1ul do begin
         movie_dir=data_dir+folders[i]+sub_folders[k]+'movies/'
         spawn, 'mkdir '+movie_dir
         gif_dir=data_dir+folders[i]+sub_folders[k]+'gifs/'
         spawn, 'mkdir '+gif_dir
         plots_dir=data_dir+folders[i]+sub_folders[k]+'plots/'
         spawn, 'mkdir '+plots_dir
         map_dir=data_dir+folders[i]+sub_folders[k]+'maps/'
         spawn, 'mkdir '+map_dir
         cd , map_dir
         restore, MAP1_NAME , verbose=1
         map1=map;[7]
         map1[*].xc=0.
         map1[*].yc=0.
         restore,MAP2_NAME, verbose=1
         map2=map
         
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
             plot_map,map1[l] , $       ;/notitle, $
                      /iso,/square, $   ; _extra=gang_plot_pos(1,2,0), $
                      title=TITLE , $
                      charthick=0.9, charsize=0.9, $
                      /contour , /percent, levels=[80], $
                      c_color=1 ,$
                      font=0 ,  background=255, $   ;color=0, $
                     grid=15 ,gcolor=0 ,xrange=xr, yrange=yr   ,$
                      CTHICK= CTHICK ;, /noax
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

 ;            plot_map, map2[l],$         ;/notitle, $
 ;                      /iso, $           ;_extra=gang_plot_pos(1,2,1), $
 ;                      title=map2[l].id  , $
 ;                      charthick=1.2, charsize=1.2,$
 ;                      font=0 , /over, /contour ,c_color=2 ,$
 ;                      levels =[ 50.] ,$
 ;                      /percent, /border,CTHICK= CTHICK ;, cstyle=2
 ;            plot_map, map2[l],$         ;/notitle, $
 ;                      /iso, $           ;_extra=gang_plot_pos(1,2,1), $
 ;                      title=map2_id , $
 ;                      charthick=1.2, charsize=1.2,$
 ;                      font=0 , /over, /contour ,c_color=3 ,$
 ;                      levels =[ 75.] ,$
 ;                      /percent, /border,CTHICK= CTHICK ;, cstyle=2
                                ;   ,xrange=[-40, 40], yrange=[-20, 20]      ;, /noax;, /noax
                                ;,  xr=[-10, 10],$ yrange=[-15, 10], 
                                ; plot_map, map2, /over, contour=1,  /iso
           ;  map2[l]=add_tag(map2[l], 0., 'ROLL')
           ;  map2[l]=add_tag(map2[l], 0., 'ROLL_ANGLE')
           ;  map2[l]=add_tag(map2[l], [0., 0.], 'ROLL_center')
            ; sub_map,map2[l],smap,xrange=[0, 20],yrange=apex_yrange ;
                                ;  plot_map, smap, /contour, /over , $
                                ;             levels =[5.,15., 25., 45., 65.,90.] ,$
                                ;            /percent;, cstyle=2
                                ;    plot_map, smap,  /over, /cont; border=2,/compos
             xyouts, map2[l].xc, outs_y, 't='+map2[l].time+' sec', font =0,  $
                     charthick=.7, charsize=.9,color=3
             ;sub_map,map2[l],smap1,xrange=[-5, -12],yrange=  [-50, -30]
             ;sub_map,map2[l],smap2,xrange=[-5, -12],yrange=  [25, 37]
                                ; plot_map, smap1,  /over, /cont;border=2;, /compos
      ;plot_map, smap2,  /over,/cont; border=2;,/compos
      ;legend, 
      device, /close
      ;stop
      spawn, 'convert '+ ps_name+' '+gif_name
   ;     spawn, "convert  -rotate '-90' "+ $
    ;           gif_name+'  '+gif_name
      print, gif_name
      gif_files=[gif_files, gif_name]
;      spawn, 'scp '+ image_name[i]+' filament.physics.montana.edu:/www/winter/loops/'
      
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
endfor

end

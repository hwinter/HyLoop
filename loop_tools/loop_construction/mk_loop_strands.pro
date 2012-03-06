



function mk_loop_constant_strands, STR_DIAM=STR_DIAM,$
                                   LOOP_DIAM=LOOP_DIAM,$
                                   LOOP_LENGTH=LOOP_LENGTH,B=B,$
                                   DIR=DIR



  if keyword_set(LOOP_DIAM) ne 1 then LOOP_DIAM =7d8

;[cm]
  if keyword_set(STR_DIAM) ne 1 then  STR_DIAM=LOOP_DIAM*.15d

;[cm]
;[cm]
  if keyword_set(LOOP_LENGTH) ne 1 then  LOOP_LENGTH =7d9
;[Gauss]
  loop_height=LOOP_LENGTH/!dpi
  if keyword_set(B) ne 1 then B =10

  data_dir=get_environ('DATA')


  if keyword_set(dir) then sav_file=dir+'/strand_start' $
  else sav_file=data_dir+'/AIA/strand_start'

  loop_radius=(.5d*LOOP_DIAM)
  strand_radius=(.5d*STR_DIAM)
  Loop_area=!dpi*(loop_radius)^2d

  strand_area=!dpi*(strand_radius)^2d
  xs=500
  ys=500
  window,25,xs=xs,ys=ys
  plot,[-1d*loop_radius,loop_radius],[-1d*loop_radius,loop_radius],/nodata,$
       XRANGE=[-1d*loop_radius,loop_radius],YRANGE=[-1d*loop_radius,loop_radius],$
       XSTYLE=4,YSTYLE=4
  window,0,xs=xs,ys=ys
  draw_circle,0 ,0 , loop_radius
  N_strands=long64(Loop_area/strand_area)
  N_rows=long64(LOOP_DIAM/STR_DIAM)+1l
  N_columns=L64INDGEN(N_rows)

  print,'N_strands',string(N_strands)
  npts=long64(1000)
  theta = lindgen(npts)*2*!pi / (npts-1l)

  xx = loop_radius * sin(theta) ; + loop_radius
  yy = loop_radius * cos(theta) ; + loop_radius
  for i=0,N_rows-1l do begin
     rc_y=loop_radius-strand_radius-STR_DIAM*double(i)
     index=where(abs(yy-rc_y) eq min(abs(yy-rc_y)))
                                ;print,string(index)+' index'
     help,index
     oplot,[-1d*loop_radius,loop_radius],[rc_y,rc_y],linestyle=1
                                ;plots,xx[index],yy[index],psym=4
     n_columns[i]=long64(2*abs(xx[index])/STR_DIAM)+1l
;    
     if n_columns[i] gt 0 then begin
        for k=0,n_columns[i]-1l do begin
           rc_x=abs(xx[index[0]])-strand_radius-STR_DIAM*double(k)
           plots,rc_x,rc_y,psym=4

           draw_circle,rc_x ,rc_y, strand_radius
           strand_height=loop_height+rc_x
           strand_length=2d*!dpi*strand_height
                                ;print,'rc_x'+string(rc_x)
                                ;x &y are switched in other coord.
           strand_temp={x:rc_y,y:rc_x,$
                        length:strand_length,$
                        diameter:STR_DIAM}
           if size(strand_struct,/TYPE) EQ 0 then $
              strand_struct=strand_temp else $
                 strand_struct=[strand_struct,strand_temp]
        endfor
     endif

     
  endfor

;stop
;window,15
;plot,
  b=(10d*!dpi*loop_radius^2d)/(!dpi*strand_radius^2d)
  power=1d24/n_elements(strand_struct)
  print,',n_elements(strand_struct'+string(n_elements(strand_struct))
;data_dir=
  for i=0,n_elements(strand_struct)-1l do begin
     
     mk_semi_circular_loop,strand_struct[i].diameter,$
                           strand_struct[i].length, B_Mag=B, $
                           T_MAX=T_max, orig, N_DEPTH=n_depth,$
                           power=power, /nosave, $
                           Y_SHIFT=strand_struct[i].y,x_SHIFT=strand_struct[i].x,$
                           LOOP=loop
     if size(loops, /TYPE) eq 0 then loops=loop else $
        loops=[loops, loop]
     
     if i eq 0 then begin
                                ;window,15
                                ; plot_3dbox,axis[0,*],axis[1,*],axis[2,*]
        window,16
        plot,loop.axis[1,*],loop.axis[2,*],yrange=[0,1d10],/zstyle
        midpt=where(loop.axis[2,*] eq max(loop.axis[2,*]))
        plots,axis[1,midpt],axis[2,midpt],psym=4
        wset,0
        pmm,loop.axis[2,*]
     endif else begin
        print,'test 1'
                                ; wset,15
                                ; plots, axis[0,*],axis[1,*],axis[2,*]
        wset,16
        midpt=where(loop.axis[2,*] eq max(loop.axis[2,*]))
        print,'Height= '+string(loop.axis[2,midpt])
        plots,loop.axis[1,midpt],loop.axis[2,midpt],psym=4
        plots,loop.axis[1,*],loop.axis[2,*],psym=4
        wset,0
     endelse

     save,loop, $
          file=strcompress(sav_file+'.'+string(i,format='(I4.4)' )+'.sav', $
                           /remove_all)
     print,'save_file',strcompress(sav_file+'.'+ $
                                   string(i,format='(I4.4)')+'.sav', $
                                   /remove_all)
     
  endfor
  return, loops

END

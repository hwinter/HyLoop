



function mk_loop_constant_strands, STR_DIAM=STR_DIAM,$
                                   LOOP_DIAM=LOOP_DIAM,$
                                   LOOP_LENGTH=LOOP_LENGTH,B=B,$
                                   DIR=DIR,N_CELLS=N_CELLS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Do some work with keywords & positional parameters
  if keyword_set(LOOP_DIAM) ne 1 then LOOP_DIAM =1d8

;[cm]
  if keyword_set(STR_DIAM) ne 1 then  STR_DIAM=LOOP_DIAM*.15d

;[cm]
;[cm]
  if keyword_set(LOOP_LENGTH) ne 1 then  LOOP_LENGTH =1d9
;[Gauss]
  N_DEPTH=50
  N_CELLS=750
  az=90
  AX=0


  xs=500
  ys=500
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  loop_height=LOOP_LENGTH/!dpi
  if keyword_set(B) ne 1 then B =10

  data_dir=get_environ('DATA')


  if keyword_set(dir) then sav_file=dir+'/strand_start' $
  else sav_file=data_dir+'/AIA/strand_start'

  loop_radius=(.5d*LOOP_DIAM)
  strand_radius=(.5d*STR_DIAM)
  Loop_area=!dpi*(loop_radius)^2d

  strand_area=!dpi*(strand_radius)^2d

  N_rows=long64(5.0*LOOP_DIAM/STR_DIAM)
  N_columns=L64INDGEN(N_rows)

  npts=long64(1000)
  theta = lindgen(npts)*2*!pi / (npts-1l)

  xx = loop_radius * sin(theta) ;
  yy = loop_radius * cos(theta) ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  for i=0,N_rows-1l do begin
     ;rc_x=X center of strand, rc_y=X center of strand
     rc_y=loop_radius-strand_radius-STR_DIAM*double(i)
     index=where(abs(yy-rc_y) eq min(abs(yy-rc_y)))
                 
     oplot,[-1d*loop_radius,loop_radius],[rc_y,rc_y],linestyle=1
                                
     n_columns[i]=long64(2*abs(xx[index[0]])/STR_DIAM)+1l
;    
     if n_columns[i] gt 0 then begin
        for k=0,n_columns[i]-1l do begin
           rc_x=abs(xx[index[0]])-strand_radius-STR_DIAM*double(k)
           strand_height=loop_height+rc_x
           strand_length=2d*!dpi*strand_height
                                ;print,'rc_x'+string(rc_x)
                                ;x &y are switched in other coord.
           strand_temp={x:rc_y,y:rc_x,$
                        length:strand_length,$
                        diameter:STR_DIAM, height:strand_height}

           distance_to_strand_center=sqrt((rc_x*rc_x)+(rc_y*rc_y))
           ;print, distance_to_strand_center/loop_radius

           Case 1 of
              distance_to_strand_center gt loop_radius :begin
                
              end

              size(strand_struct,/TYPE) EQ 0: strand_struct=strand_temp
              else: strand_struct=[strand_struct,strand_temp]
           endcase

        endfor ;K loop.  Columns
     endif ;Columns exist   
  endfor ;

n_strands=n_elements(strand_struct)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  window,0,xs=xs,ys=ys
;Dumb way to set the x and y ranges

  plot, strand_struct.x,  strand_struct.y,$
        XRANGE=[-1.1*loop_radius, 1.1*loop_radius], $
        YRANGE=[-1.1*loop_radius, 1.1*loop_radius],$
        /XS, /YS, /NODATA
  draw_circle,0 ,0 , loop_radius
  for i=0ul, n_strands-1l do begin
     plots,strand_struct[i].x,$
           strand_struct[i].y,psym=4
     draw_circle,strand_struct[i].x,$
                 strand_struct[i].y, strand_radius
     
  endfor
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  b=(10d*!dpi*loop_radius^2d)/(!dpi*strand_radius^2d)

;  print,',n_elements(strand_struct'+string(n_elements(strand_struct))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Create each strands' loop structure.
  for i=0ul,n_strands-1l do begin
 
     mk_semi_circular_loop,strand_struct[i].diameter,strand_struct[i].length, $
                          T_MAX=T_MAX, N_DEPTH=N_DEPTH,$
                          TO=T0,$
                          B_Mag=B,Q0=Q0,  NOSAVE=1, $
                          outname=outname,N_CELLS=N_CELLS,$
                          X_SHIFT=strand_struct[i].x,Y_SHIFT=strand_struct[i].y,$
                          LOOP=LOOP,$
                          DEPTH=DEPTH,$
                          ADD_CHROMO=ADD_CHROMO,$
                          SIGMA_FACTOR=SIGMA_FACTOR,$
                          PSL=PSL, ALPHA=ALPHA, BETA=BETA,$
                          HEAT_NAME=HEAT_NAME, TEST=TEST, $
                          NO_SAT=NO_SAT,$
                          NOVISC=NOVISC,$
                          CONSTANT_CHROMO=CONSTANT_CHROMO, $
                          SLIDE_CHROMO=SLIDE_CHROMO

         

     if size(loops, /TYPE) eq 0 then loops=loop else $
        loops=[loops, loop]
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;Save the strand   
     save,loop, $
          file=strcompress(sav_file+'.'+string(i,format='(I4.4)' )+'.loop', $
                           /remove_all)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     
     print,'save_file',strcompress(sav_file+'.'+ $
                                   string(i,format='(I4.4)')+'.loop', $
                                   /remove_all)
     
  endfor; of i loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     
  zrange=[0, 1.01*max(strand_struct.height)]
  yrange=[0.-(1.01*loop_radius), 1.01*loop_radius]
  xrange=[0.-(1.01*loop_radius), 1.01*loop_radius]
  window,16
  
 ; LOOPS.AXIS[0,*]+=6D8
  show_loop_tactical, loops[0], $
                      XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                      THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                      INITIAL=1, LOOP_LINE=2,$
                      SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                      NO_OPLOT=NO_OPLOT,$
                      C_SKIP=C_SKIP,C_COLOR=C_COLOR, rad_factor=rad_factor,$
                      NOAXIS=NOAXIS, $
                      _EXTRA=_EXTRA, $
                      BG_GRID=BG_GRID, LINE_COLOR=LINE_COLOR, $
                      C_STRUCT=C_STRUCT, ISOMORPHIC=1
  
  for i=1,n_elements(strand_struct)-1l do begin
     show_loop_tactical, loops[i], $
                         XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                         THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                         LOOP_LINE=2,$
                         SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                         NO_OPLOT=NO_OPLOT,$
                         C_SKIP=C_SKIP,C_COLOR=C_COLOR, rad_factor=rad_factor,$
                         NOAXIS=NOAXIS, $
                         _EXTRA=_EXTRA, $
                         BG_GRID=BG_GRID, LINE_COLOR=LINE_COLOR, $
                         C_STRUCT=C_STRUCT
  endfor

  
  return, loops
stop
END





function mk_loop_linear_taper_movie,gamma, STR_DIAM=STR_DIAM,$
                                      LOOP_DIAM=LOOP_DIAM,$
                                      LOOP_LENGTH=LOOP_LENGTH,B=B,$
                                      DIR=DIR,N_CELLS=N_CELLS, $
                                      ENVELOPE_LOOP=ENVELOPE_LOOP,$
                                      T_MAX=T_MAX, img_dir=img_dir

set_plot, 'x'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Do some work with keywords & positional parameters
  if keyword_set(LOOP_DIAM) ne 1 then LOOP_DIAM =1d8

;[cm]
  if keyword_set(STR_DIAM) ne 1 then  STR_DIAM=LOOP_DIAM/10
  
  if keyword_set(LOOP_LENGTH) ne 1 then  LOOP_LENGTH =1d9
;[Gauss]
  N_DEPTH=30
  AZ=0
  AX=90


  xs=500
  ys=500
  C_SKIP=10
  thick=4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  color_names=['Red', 'Blue', 'Green','Dark Red', 'Purple',  'Cyan', 'Lawn Green',$
               'Orange','Violet', 'Magenta', 'Cadet Blue', 'Navy', 'Orange Red', $
               'Aquamarine','Olive', 'Rose','Turquoise',  'Gold', $
               'Crimson', 'Powder Blue', 'Lime Green','Coral','Forest Green',$
               'Plum', 'Royal Blue', 'Salmon', 'Yellow', 'Violet Red','Sky Blue',$
               'Green Yellow', 'Steel Blue', 'Blue Violet','Dark Red', 'Sea Green', 'Tomato']


  n_color_names=n_elements(color_names)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if keyword_set(B) ne 1 then B =10

  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This won't change with the taper  
  loop_height=LOOP_LENGTH/!dpi
  loop_radius=(.5d*LOOP_DIAM)
;The base diameter and radius does change due  to the tapering.
  loop_base_diam=LOOP_DIAM/gamma
  loop_base_rad=loop_base_diam/2.0
  
  data_dir=get_environ('DATA')



  strand_base_diameter=STR_DIAM/gamma
;strand_base_radius is the cross-sectional radius of the loop strand.
  strand_base_radius=.5d*strand_base_diameter

;  Loop_area=!dpi*(loop_radius)^2d
;  strand_area=!dpi*(strand_radius)^2d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Define the Y centers of the rows
  N_rows=2*ulong64(loop_base_diam/strand_base_diameter)+1
  row_ycens=-loop_base_rad+strand_base_diameter*dindgen(N_rows)
  row_ycens=row_ycens[where(abs(row_ycens) le loop_base_rad )]
  row_ycens=row_ycens[sort(row_ycens)]
  N_rows=n_elements(row_ycens)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;Now define the X & Y centers for each strands
  i=0ul

  d=loop_base_rad*sin(acos(row_ycens[i]/loop_base_rad))
  N_columns_positive=ulong64(d/strand_base_diameter)+2  
  strand_xcens_temp=strand_base_diameter*$
                    dindgen(N_columns_positive)
  
;Make the left-hand side and avoid double counting the zero point
     strand_xcens_temp=[-strand_xcens_temp[1:*], strand_xcens_temp]
  strand_xcens_temp=strand_xcens_temp[where(abs(strand_xcens_temp) le d)]
;  
  strand_ycens_temp=row_ycens[i]+dblarr(n_elements(strand_xcens_temp))

;This is confusing. 
;strand_min_r is the minimum radius of the half-circle of the strand
;in the YZ plane.
;strand_base_radius is the cross-sectional radius of the loop strand.
  strand_min_r_temp=loop_height-strand_ycens_temp*gamma

;Add the temporary values to the arrays  
  strand_xcens=temporary(strand_xcens_temp)
  strand_ycens=temporary(strand_ycens_temp)
  strand_min_r=temporary(strand_min_r_temp)
     
  for i=1ul, N_rows-1 do begin


  d=loop_base_rad*sin(acos(row_ycens[i]/loop_base_rad))
  N_columns_positive=ulong64(d/strand_base_diameter)+2  
  strand_xcens_temp=strand_base_diameter*$
                    dindgen(N_columns_positive)
  
;Make the left-hand side and avoid double counting the zero point
     strand_xcens_temp=[-strand_xcens_temp[1:*], strand_xcens_temp]
  strand_xcens_temp=strand_xcens_temp[where(abs(strand_xcens_temp) le d)]
;  
  strand_ycens_temp=row_ycens[i]+dblarr(n_elements(strand_xcens_temp))

;Height
     strand_min_r_temp=loop_height-strand_ycens_temp*gamma
;Length based on height
     
  
;Add the temporary values to the arrays  
     strand_xcens=[strand_xcens,strand_xcens_temp]
     strand_ycens=[strand_ycens, strand_ycens_temp]     
     strand_min_r=[strand_min_r, strand_min_r_temp]
          
  endfor

  n_strands=n_elements(strand_ycens)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  While n_color_names lt n_strands do begin
     color_names=[color_names, color_names]    
     n_color_names=n_elements(color_names)
  endwhile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  colors=fsc_color(color_names)

  window,0,xs=xs,ys=ys

  for i=0ul, n_strands-1l do begin
     
     plot, strand_xcens,  strand_ycens,$
           XRANGE=[-1.1*loop_base_rad, 1.1*loop_base_rad], $
           YRANGE=[-1.1*loop_base_rad, 1.1*loop_base_rad],$
           /XS, /YS, /NODATA, thick=thick, color=fsc_color('white')

     draw_circle,0 ,0 , loop_base_rad,thick=thick
     for j=0ul, i do begin
        draw_circle,strand_xcens[j],$
                    strand_ycens[j], strand_base_radius,$
                    color=colors[j], thick=thick, $
                    /fill
     endfor
     file_name='strand_img_'+strcompress(string(i, format='(I04)'), /remove_all)+'.png'
     x2png, file_name
     pwd
     print, file_name
     
  endfor


END                             ; of Main

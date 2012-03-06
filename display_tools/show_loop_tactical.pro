;Restrictions: Requires FSC_color
;2012-01-20  HDW Added keyword CHROMO_COLOR.  Changed the colors to
;the FSC_color system.  That will break some code. Also added a color
;keyword to the c_struct structure


pro show_loop_tactical, loop, $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=INITIAL, LOOP_LINE=LOOP_LINE,$
                        SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                        NO_OPLOT=NO_OPLOT,$
                        C_SKIP=C_SKIP,C_COLOR=C_COLOR, rad_factor=rad_factor,$
                        NOAXIS=NOAXIS, $
                        _EXTRA=_EXTRA, $
                        BG_GRID=BG_GRID, LINE_COLOR=LINE_COLOR, $
                        C_STRUCT=C_STRUCT, ISOMORPHIC=ISOMORPHIC, $
                        C_THICK=C_THICK, CHROMO_COLOR=CHROMO_COLOR


XTITLE='X s [cm]'
YTITLE='Y s [cm]'
ZTITLE='Z s [cm]'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check keyword settings.
max_rad=max(loop.rad)
if not keyword_set(XRANGE) then $
  XRANGE=[MIN(LOOP.AXIS[0,*]-5.*max_rad),MAX(LOOP.AXIS[0,*]+5.*max_rad)]
if not keyword_set(YRANGE) then $
  YRANGE=[MIN(LOOP.AXIS[1,*]-5.*max_rad),MAX(LOOP.AXIS[1,*]+5.*max_rad)]
if not keyword_set(ZRANGE) then $
  ZRANGE=[MIN(LOOP.AXIS[2,*]),MAX(LOOP.AXIS[2,*])]
if not keyword_set(LOOP_LINE) then $
  LOOP_LINE=1
if not keyword_set(SURFACE_LINE) then $
  SURFACE_LINE=0
if not keyword_set(C_SKIP) then $
  C_SKIP=1
if keyword_set(FILL) then begin
    if n_elements(FILL) eq 1 then FILL=FILL+dblarr(n_elements(loop.s))
endif
if not keyword_set(NO_OPLOT) then NO_OPLOT=0
if not keyword_set(INITIAL) then  INITIAL=0
if not keyword_set(THICK) then thick = 3
if !d.name eq 'PS' then thick_factor=4 else  thick_factor=1


;stop
if keyword_set(BG_GRID) then begin
    case 1 of 
        BG_GRID eq 1:begin
            xticklen=1           
            yticklen=1
            zticklen=1
        end

        else:begin
            xticklen=1           
            yticklen=1
            zticklen=1
        endelse
    endcase


endif
If keyword_set(ISOMORPHIC) then begin
   min_x=MIN(LOOP.AXIS[0,*]+max(loop.rad))
   max_x=MAX(LOOP.AXIS[0,*])+max(loop.rad)
   
   XRANGE=[min_x,max_x]
   YRANGE=[MIN(LOOP.AXIS[1,*]),MAX(LOOP.AXIS[1,*])]
   ZRANGE=[MIN(LOOP.AXIS[2,*]),MAX(LOOP.AXIS[2,*])]
   range_min=min([XRANGE[0],YRANGE[0],ZRANGE[0]])
   range_max=max([XRANGE[1],YRANGE[1],ZRANGE[1]])
   delta_range=range_max-range_min
   yrange=[YRANGE[0],YRANGE[0]+delta_range]
   xrange=[XRANGE[0]-delta_range/2,XRANGE[0]+delta_range/2]
   zrange=[ZRANGE[0],ZRANGE[0]+delta_range]
   
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;If the INITIAL keyword is set then set up the axis with surface
if INITIAL gt 0 then $
  SURFACE, [[0,0], [0,0]], /NODATA, /SAVE,$ 
           XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE, $
           THICK=THICK*thick_factor, AX=AX, AZ=AZ,TITLE=TITLE,$
           XS=1,YS=1,ZS=1  ,$
           XTITLE=XTITLE,$
           YTITLE=YTITLE,$
           ZTITLE=ZTITLE,charsize=3.0, charthick=1.9,$
           XTICKLEN=XTICKLEN,YTICKLEN=YTICKLEN,ZTICKLEN=ZTICKLEN,$
           _EXTRA=_EXTRA;, ZAXIS=-1
          
     ;,/ISO
if keyword_set(NOAXIS) then erase

plots,LOOP.axis[0,*], LOOP.axis[1,*],LOOP.axis[2,*], $
      /t3d, line=LOOP_LINE, THICK=THICK*thick_factor, $
      COLOR=LINE_COLOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
if keyword_set(FILL) then begin
    if n_elements(fill) eq 1 then fill=fill+dindgen(n_elements(LOOP.axis)-1ul)
    show_loop_skeleton, LOOP.axis, loop.rad,CIRC=CIRC,$
                        C_STRUCT=C_STRUCT, /THREED, $
                        LINESTYLE=SURFACE_LINE, /NO_PLOT,$
                        SKIP=1,_EXTRA=_EXTRA, C_COLOR=C_COLOR
    
    n_struct=n_elements(C_STRUCT)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Loop to create a section if the area of the cylinder perpendicular to the axis.
;Each section will have four corners in 3d space 
    for i=0UL, n_struct-2UL do begin
  
;The indices i & j will correspond to the circles that define the surface of  
; the cylinder parallel to the axis
        j=i+1UL
    
        n_circ_points=n_elements(C_STRUCT[i].circ[0,*])
;The indices m & n correspond to the points along each circle.
        for m=0UL, n_circ_points-2UL do begin
            n=m+1UL
;Attach the last point to the first.
            if n ge n_circ_points then n=0UL
;Define the x coordinates of each corner of the current section. 
            x_array=[C_STRUCT[i].circ[0,m], $
                     C_STRUCT[j].circ[0,m], $
                     C_STRUCT[j].circ[0,n], $
                     C_STRUCT[i].circ[0,n]]
;Define the y coordinates of each corner of the current section. 
            y_array=[C_STRUCT[i].circ[1,m], $
                     C_STRUCT[j].circ[1,m], $
                     C_STRUCT[j].circ[1,n], $
                     C_STRUCT[i].circ[1,n]]
;Define the z coordinates of each corner of the current section. 
            z_array=[C_STRUCT[i].circ[2,m], $
                     C_STRUCT[j].circ[2,m], $
                     C_STRUCT[j].circ[2,n], $
                     C_STRUCT[i].circ[2,n]]

            polyfill, x_array, y_array,z_array, $
                      COLOR=FILL[i],/T3D, _EXTRA=_EXTRA;,/LINE_FILL,
        endfor
        ;help, fill
        
    endfor  

plots,LOOP.axis[0,*], LOOP.axis[1,*],LOOP.axis[2,*], $
      /t3d, line=LOOP_LINE ,_EXTRA=_EXTRA  
   
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (NO_OPLOT) le 0 then $
  show_loop_skeleton, loop.axis, loop.rad, $
                       /THREED, $
                      LINESTYLE=SURFACE_LINE,$
                      SKIP=C_SKIP,_EXTRA=_EXTRA,$
                      C_COLOR=C_COLOR, $
                      C_THICK=C_THICK,$
                      C_STRUCT=C_STRUCT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set(CHROMO_COLOR) then begin
   n_rad=n_elements(loop[0].rad)

   case 1 of
      loop.N_depth le 1 :indicies=[0, n_rad-1]

      else : begin
         chromo_axis=[loop.axis[0:loop.n_depth-1], loop.axis[n_rad-loop.n_depth+1:n_rad]]
         indicies=[indgen(loop.n_depth), n_rad-loop.n_depth+indgen(loop.n_depth)]
      end
   endcase

   for i=0, n_elements(indicies)-1 do begin
      
          plots, c_struct[indicies[i]].circ(0, *), c_struct[indicies[i]].circ(1, *),$
                 c_struct[indicies[i]].circ(2, *), $
                 /t3d ,LINESTYLE=LINESTYLE,COLOR=fsc_color(CHROMO_COLOR),$
                 THICK=C_THICK
          
   endfor
   

endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

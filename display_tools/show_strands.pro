;.r show_strands

pro show_strands, files, $
                  ENVELOPE_LOOP=ENVELOPE_LOOP,envelop_skip=envelop_skip , $
                  XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                  THICK=THICK, TITLE=TITLE, AX=AX, AZ=AZ,$
                  LOOP_LINE=LOOP_LINE,$
                  SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                  NO_OPLOT=NO_OPLOT,$
                  C_SKIP=C_SKIP, rad_factor=rad_factor,$
                  BG_GRID=BG_GRID, $
                  C_THICK=C_THICK,$
                  _EXTRA=_EXTRA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ISOMORPHIC=1
if not keyword_set(C_SKIP) then C_SKIP=5
if not keyword_set(envelop_skip) then envelop_skip=30

;print, strupcase(!D.NAME) 
;if strupcase(!D.NAME) eq 'PS' then begin
;   envelope_color='Red'
;   line_color='White'
;endif else begin  
   envelope_color='White'
   line_color='Black'
;endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
color_names=['Blue', 'Green','Dark Red', 'Purple',  'Cyan', 'Lawn Green',$
             'Orange','Violet', 'Magenta', 'Cadet Blue', 'Navy', 'Orange Red', $
             'Aquamarine','Olive', 'Rose','Turquoise',  'Gold', $
             'Crimson', 'Powder Blue', 'Lime Green','Coral','Forest Green',$
            'Plum', 'Royal Blue', 'Salmon', 'Yellow', 'Violet Red','Sky Blue',$
            'Green Yellow', 'Steel Blue', 'Blue Violet','Dark Red', 'Sea Green', 'Tomato']


;           Active            Almond     Antique White  Tomato                   Beige            Bisque
;             Black                                  Brown         Burlywood        
;          Charcoal        Chartreuse         Chocolate                Cornflower Blue          Cornsilk
;                             Dark Goldenrod         Dark Gray        Dark Green        Dark Khaki
;       Dark Orchid                Dark Salmon   Dark Slate Blue         Deep Pink       Dodger Blue
;              Edge              Face         Firebrick       Frame              
;         Goldenrod              Gray                            Highlight          Honeydew
;          Hot Pink        Indian Red             Ivory             Khaki          Lavender        
;       Light Coral        Light Cyan        Light Gray      Light Salmon   Light Sea Green      Light Yellow
;        Linen                       Maroon       Medium Gray     Medium Orchid
;          Moccasin                                   Olive Drab                   
;            Orchid    Pale Goldenrod        Pale Green            Papaya              Peru              Pink
;                                                           Rosy Brown
;              Saddle Brown            Salmon       Sandy Brown                  Seashell
;          Selected            Shadow            Sienna                Slate Blue        Slate Gray
;              Snow      Spring Green                      Tan              Teal              Text
;           Thistle                                                 Wheat
;             White            ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n_files=n_elements(files)
n_color_names=n_elements(color_names)

While n_color_names lt n_files do begin
   color_names=[color_names, color_names]
   
   n_color_names=n_elements(color_names)

endwhile

colors=fsc_color(color_names)

if keyword_set(ENVELOPE_LOOP) then begin
   show_loop_tactical, ENVELOPE_LOOP, $
                       XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                       THICK=THICK, TITLE=TITLE, AX=AX, AZ=AZ,$
                       INITIAL=1, LOOP_LINE=LOOP_LINE,$
                       SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                       NO_OPLOT=NO_OPLOT,$
                       C_SKIP=envelop_skip,C_COLOR=fsc_color(envelope_color), rad_factor=rad_factor,$
                       BG_GRID=BG_GRID, LINE_COLOR=fsc_color(line_color), $
                       C_STRUCT=C_STRUCT, ISOMORPHIC=ISOMORPHIC, $
                       C_THICK=5, /nodata, $
                       _EXTRA=_EXTRA
endif else begin
   
   i=0
   restore, files[i]
   show_loop_tactical, LOOP, $
                       XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                       THICK=THICK, TITLE=TITLE, AX=AX, AZ=AZ,$
                       INITIAL=1, LOOP_LINE=LOOP_LINE,$
                       SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                       NO_OPLOT=NO_OPLOT,$
                       C_SKIP=envelop_skip,C_COLOR=fsc_color(envelope_color), rad_factor=rad_factor,$
                       BG_GRID=BG_GRID, LINE_COLOR=fsc_color(line_color), $
                       C_STRUCT=C_STRUCT, ISOMORPHIC=ISOMORPHIC, $
                       C_THICK=3, /nodata , $
                       _EXTRA=_EXTRA

endelse
                          

for i=0ul, n_files-1ul do begin
   
   restore, files[i]
   
   
   show_loop_tactical, loop, $
                       XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                       THICK=3, AX=AX, AZ=AZ,TITLE=TITLE,$
                       INITIAL=0, LOOP_LINE=LOOP_LINE,$
                       SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                       NO_OPLOT=NO_OPLOT,$
                       C_SKIP=C_SKIP,C_COLOR=colors[i], rad_factor=rad_factor,$
                       NOAXIS=NOAXIS, $
                       _EXTRA=_EXTRA, $
                       BG_GRID=BG_GRID, LINE_COLOR=fsc_color(line_color), $
                       C_STRUCT=C_STRUCT, ISOMORPHIC=ISOMORPHIC
   


endfor


if keyword_set(ENVELOPE_LOOP) then $
   show_loop_tactical, ENVELOPE_LOOP, $
                        XRANGE=XRANGE, YRANGE=YRANGE,  ZRANGE=ZRANGE,$
                        THICK=THICK, AX=AX, AZ=AZ,TITLE=TITLE,$
                        INITIAL=0, LOOP_LINE=LOOP_LINE,$
                        SURFACE_LINE=SURFACE_LINE, FILL=FILL,$
                        NO_OPLOT=NO_OPLOT,$
                        C_SKIP=envelop_skip,C_COLOR=fsc_color(envelope_color), rad_factor=rad_factor,$
                        _EXTRA=_EXTRA, $
                        BG_GRID=BG_GRID, LINE_COLOR=fsc_color(line_color), $
                        C_STRUCT=C_STRUCT, ISOMORPHIC=ISOMORPHIC, $
                        C_THICK=3


END



pro plot_position_histo, nt_beam,nt_beam2,$
  ps_name=ps_name, GIF_NAME=GIF_NAME,$
  XTITLE=XTITLE,YTITLE=YTITLE, TITLE=TITLE,$
  CHARSIZE=charsize,CHARTHICK=charthick, $
  BCOLOR=BCOLOR,XSTYLE=XSTYLE,$
  YRANGE=YRANGE, YSTYLE=YSTYLE,$
  BACKGROUND =BACKGROUND , COLOR = COLOR ,$
  _EXTRA=EXTRA, L_ITEMS=L_ITEMS ; PS=PS

if not keyword_set(XTITLE) then $
  XTITLE_in='Cosine Pitch Angle' $
  else XTITLE_in=XTITLE
if not keyword_set(YTITLE) then $
  YTITLE_in= 'Number of Particles'$
  else YTITLE_in=YTITLE
if not keyword_set(TITLE) then $
  TITLE_in='Pitch Angle Distribution' $
            else TITLE_in=TITLE
;TITLE_in=TITLE
;YTITLE_in=YTITLE
;XTITLE_in=XTITLE

tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
if not keyword_set(CHARTHICK) then charthick=1.7
if not keyword_set(CHARSIZE) then charsize=1.7

test=size(nt_beam, /DIMENSION) 
if n_elements(test) gt 1 then begin
    for i=0ul, test[1]-1ul do begin
        if size(nt_beam_in, /TYPE) eq 0 then $
          nt_beam_in=nt_beam[*,i] else $
          nt_beam_in=concat_struct(nt_beam_in,nt_beam[*,i])
        
    endfor 
endif else nt_beam_in=nt_beam
  
good_index=where(nt_beam_in.state eq 'NT')
if good_index[0] ne -1 then  nt_beam_in=nt_beam_in[good_index]
set_plot, 'z'
plot_histo, nt_beam_in.x, steps,histo

histo=histo*nt_beam_in[0].scale_factor

ymin=min(histo)
ymax=max(histo)
if size(nt_beam2, /TYPE) ne 0 then begin
    good_index2=where(nt_beam2.state eq 'NT')
    if good_index2[0] ne -1 then  nt_beam2=nt_beam2[good_index2]


    plot_histo, nt_beam_in.x, steps2,histo2
    histo2=histo2*nt_beam2[0].scale_factor

   ymin=min([histo,histo2])
    ymax=max([histo,histo2])

endif


if not keyword_set(YRANGE) then YRANGE_in=[ymin, ymax] $
else YRANGE_in=YRANGE

font=1
gif_name=ps_name+'.tiff'
set_plot, 'ps'
print, ps_name
device, /portrait, file= ps_name , color=16, /enc

tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
;Plot the temperature array  with no axes on the right
                plot, steps,histo,  $
                     YRANGE=[.98*YRANGE_in[0],$
                         1.02*YRANGE_in[1]], $
                     YSTYLE=1, $
                     POSITION=[.2,.15, .85,.90], $
                     CHARTHICK=1.5, CHARSIZE=1.5, $
                                ;                 TITLE=TITLE, $
                     XTITLE='Position s',$
                     YTITLE='#',$
                     /NODATA, FONT=FONT,$
                     THICK=10, $
                      ;XRANGE=[min(ke_array) ,$
                      ;       max(ke_array)] ,$
                      XS=1,$
                      TITLE='Position Distribution'
                OPLOT,steps, histo , thick=8, COLOR=1,$
                      PSYM=10
   
                if size(nt_beam2, /TYPE) ne 0 then begin
                    OPLOT,steps2, histo2 , thick=8, COLOR=3,$
                          PSYM=10
                endif
            
                if keyword_set(l_items) then $
                  legend, l_items,$
                          line=[0,0],$ ;PSYM=[4,4],$
                          COLOR=[1,3], /RIGHT, BOX=0,$
                          FONT=0,CHARTHICK=1.3, CHARSIZE=1.3, THICK=6, $
                          /TOP

                device, /CLOSE
  ;              spawn, 'convert '+ ps_name+' '+gif_name
                print, gif_name   
set_plot, 'x'
;device,/CLOSE
; set_plot,'x'
;!X.CRANGE=old_x_range
end



pro pa_plot4, nt_beam, nt_beam2,GIF_NAME=GIF_NAME,$
              XTITLE=XTITLE,YTITLE=YTITLE, TITLE=TITLE,$
              CHARSIZE=charsize,CHARTHICK=charthick, $
              BCOLOR=BCOLOR,XSTYLE=XSTYLE,xrange=xrange$
              YRANGE=YRANGE, YSTYLE=YSTYLE,$
              BACKGROUND =BACKGROUND , COLOR = COLOR ,$
              _EXTRA=EXTRA, time=time,$
              L_ITEMS2= L_ITEMS2 ; PS=PS

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
frame_count=5ul
tvlct, [0,255,0,0], [0,0,255,0], [0,0,0,255]
if not keyword_set(CHARTHICK) then charthick=1.7
if not keyword_set(CHARSIZE) then charsize=1.7
charthick=1.7
charsize=1.5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test=size(nt_beam, /DIMENSION) 
;if n_elements(test) gt 1 then begin
;    for i=0ul, test[1]-1ul do begin
;        if size(nt_beam_in, /TYPE) eq 0 then $
;          nt_beam_in=nt_beam[*,i] else $
;          nt_beam_in=concat_struct(nt_beam_in,nt_beam[*,i])
;        
;    endfor 
;endif else 
nt_beam_in=nt_beam
  
good_index=where(nt_beam_in.state eq 'NT')
if good_index[0] ne -1 then  nt_beam_in=nt_beam_in[good_index]
;help, nt_beam_in
z=uniq(nt_beam_in.pitch_angle)


nt_p=nt_beam_in[sort(cos(nt_beam_in.pitch_angle))]
pa_indices=uniq(cos(nt_p.pitch_angle))
pas=cos(nt_p[pa_indices].pitch_angle)


min_pa=-1.0 ;min(pas)
max_pa= 1.0 ;max(pas)
delta=max_pa-min_pa
step=0.01
n_elem=long(.5+delta/step) >2

pa_array=min_pa+delta*dindgen(n_elem)/(n_elem-1ul)
n_array=dindgen(n_elem)

if good_index[0] ne -1 then begin
    for i=0ul, n_elem-1ul do begin
        z=where(cos(nt_beam_in.pitch_angle) le pa_array[i]+(step/2.) $
                and $
                cos(nt_beam_in.pitch_angle) ge pa_array[i] -(step/2.), count)
                                ;print, z
    ;print, count, pa_array[i]
        if z[0] ne -1 then $
          n_array[i]=total(nt_beam_in[z].scale_factor) $
          else n_array[i]=0.
                                ;stop
    endfor
endif else n_array[*]=0

;yrange=[0,ma
;s;et_plot, 'ps'
;device, landscape=1,color=8, file=ps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;test=size(nt_beam2, /DIMENSION) 
;if n_elements(test) gt 1 then begin
;    for i=0ul, test[1]-1ul do begin
;        if size(nt_beam_in, /TYPE) eq 0 then $
;          nt_beam_in=nt_beam2[*,i] else $
;          nt_beam_in=concat_struct(nt_beam_in,nt_beam2[*,i])
;        
;    endfor 
;endif else 
nt_beam_in=nt_beam2
  
good_index=where(nt_beam_in.state eq 'NT')
help, good_index
if good_index[0] ne -1 then  nt_beam_in=nt_beam_in[good_index]
;help, nt_beam_in
z=uniq(nt_beam_in.pitch_angle)


nt_p=nt_beam_in[sort(cos(nt_beam_in.pitch_angle))]
pa_indices=uniq(cos(nt_p.pitch_angle))
pas=cos(nt_p[pa_indices].pitch_angle)


min_pa=-1.0 ;min(pas)
max_pa= 1.0 ;max(pas)
delta=max_pa-min_pa
step=0.01
n_elem=long(.5+delta/step) >2

pa_array2=min_pa+delta*dindgen(n_elem)/(n_elem-1ul)
n_array2=dindgen(n_elem)

if good_index[0] ne -1 then begin
    for i=0ul, n_elem-1ul do begin
        z=where(cos(nt_beam_in.pitch_angle) le pa_array2[i]+(step/2.) $
                and $
                cos(nt_beam_in.pitch_angle) ge pa_array[i] -(step/2.), count)
                                ;print, z
    ;print, count, pa_array[i]
        if z[0] ne -1 then $
          n_array2[i]=total(nt_beam_in[z].scale_factor) $
          else n_array2[i]=0.
                                ;stop
    endfor
endif else n_array2[*]=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if not keyword_set(YRANGE)then begin
    ymin=.9*min([n_array, n_array2])
    ymax=1.1*max([n_array, n_array2])
    
endif else begin
     ymin=.9*yrange[0]
     ymax=1.1*yrange[1]
 endelse
if not keyword_set(XRANGE)then begin
    Xmin=.9*min([pa_array,pa_array2])
    Xmax=1.1*max([pa_array,pa_array2])
    
endif else begin
    Xmin=-11
    xmax=1
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
plot,pa_array,n_array,$         ;XSTYLE=1,$
     XTITLE=XTITLE_IN,YTITLE=YTITLE_IN,$
     XSTYLE=1,$
     CHARSIZE=1.5,CHARTHICK=2.0, $
                                ;BCOLOR=1,BACKGROUND = 255, COLOR = 0  ,$
     YRANGE=[ymin, ymax], YSTYLE=1,YTICKS=4,$
     XRANGE=[-1, 1],$
     POSITION=[.25,.2, .85,.90], $
     font=-1, nodata=1          ;, _EXTRA=EXTRA
xyouts, .25, .93, TITLE_IN, /normal,CHARSIZE=1.5,CHARTHICK=2.0,$
        font=-1
xyouts, .55, .93, time, /normal,CHARSIZE=1.5,CHARTHICK=2.0,$
        font=-1

oplot, pa_array,n_array, psym=10, color=1, thick=4
oplot, pa_array2,n_array2, psym=10, color=3, thick=4


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if keyword_set(L_ITEMS2) then begin
    legend, L_ITEMS2,$
            /right, /top, FONT=0,BOX=0, $
            line=[0,0], color=[1,3],CHARSIZE=1.0,CHARTHICK=1.2,$
            THICK=[4,4]
    
endif
IF KEYWORD_SET(GIF_NAME) THEN x2gif,'fig1.gif'
;device,/CLOSE
; set_plot,'x'
;!X.CRANGE=old_x_range
end



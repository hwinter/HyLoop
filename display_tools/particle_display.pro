 pro particle_display, loop,NT_beam,E_min=E_min,E_max=E_max, $
   WINDOW=WINDOW, $
   XSIZE=XSIZE, YSIZE=YSIZE, $
   GIF=GIF, PLOT_TITLE=PLOT_TITLE,$
   RUN_FOLDER=RUN_FOLDER, CHARSIZE=CHARSIZE ,$
   CHARTHICK=CHARTHICK,TIME=TIME,$
   DIVISIONS=DIVISIONS,VARY=VARY,$
   XY=XY, C_BAR_POS=C_BAR_POS, $
   REVERSE=REVERSE, SP_CELLS=SP_CELLS, $
   post=post, font=font,$
                       POSITION=   POSITION
   
n_loop=n_elements(loop) 
;CT=CT, MAX_C_OFFSET=MAX_C_OFFSET
IF not keyword_set(PLOT_TITLE) then plot_title='NT Particles'
IF not keyword_set(XSIZE) then xsize=600 
IF not keyword_set(YSIZE) then ysize=600 
IF not keyword_set(CHARSIZE) then CHARSIZE=1.5
IF not keyword_set(CHARTHICK) then CHARTHICK=1.5
IF not keyword_set(WINDOW) then WINDOW=0
IF not keyword_set(E_min) then E_min=1d
IF not keyword_set(E_max) then E_max=max(NT_beam.ke_total)
IF not keyword_set(DIVISIONS) then DIVISIONS=4
IF not keyword_set(TIME) then time=loop.state.time
;IF not keyword_set(title) then title=title else 
IF not keyword_set(VARY) then $
;  vary=dindgen(n_elements(NT_beam))/(n_elements(NT_beam))
vary=randomu(seed, n_elements(NT_beam))
IF keyword_set(XY) then begin
    x_axis=loop[n_loop-1l].axis[0,*]
    y_axis=loop[n_loop-1l].axis[1,*]
endif else begin
    x_axis=loop[n_loop-1l].axis[1,*]
    y_axis=loop[n_loop-1l].axis[2,*]
endelse
IF not keyword_set(C_BAR_POS) then $
  position=[0.40,0.22,0.72,0.33] else $
  position=C_BAR_POS
;IF not keyword_set(CT) then begin 
CT=39
MAX_C_OFFSET=41.
;endif

if keyword_set(post) then begin
    set_plot,'ps'
    device, color=16, file=post
    font=0
endif

if !d.name eq 'PS' then l_factor=1. else l_factor=1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Work out the color for each tracked particle.
;Also provide settings for the colorbar.
;Note: I haven't made this general for any color table
;For now we are only using CT=39 using the color table backwards.
color_offset=255.
color_factor=(MAX_C_OFFSET-color_offset)/(E_max-E_min)
color_const=MAX_C_OFFSET-(color_factor*E_max)
energies=fix(E_min+((E_max-E_min)*(indgen(DIVISIONS+1))/DIVISIONS))
Ticknames=temporary(string(energies, format='(I3.3)'))
;Ticknames=reverse(Ticknames)
cb_title='keV'
invertcolors=1

IF keyword_set(REVERSE) THEN x_axis=x_axis[REVERSE(x_axis)]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Make circle user symbols
circle_sym,  THICK=2, /FILL
NT_beam_old=NT_beam
;NT_beam=temporary(NT_beam[(sort(NT_beam.ke_total))])
;vary=temporary(ary[(sort(NT_beam.ke_total))])
LOADCT,0,/silent
plot,x_axis,y_axis+loop[n_loop-1l].rad,THICK=3.*l_factor , $
     XRANGE=[MIN(x_axis),MAX(x_axis)],/XSTYLE, FONT=font,$
     /ISO
oplot,x_axis,y_axis,$
      linestyle=2   ,THICK=3.*l_factor 
oplot,x_axis,y_axis-loop[n_loop-1l].rad,$
      linestyle=0,THICK=3 
if keyword_set(SP_CELLS) then begin

      theta=atan(abs(loop.axis[2,*]/loop.axis[1,*])) 
         for kk=0,n_elements(SP_CELLS)-1ul do begin
             ii=SP_CELLS[kk]
;           polyfill,[REFORM(loop.axis[1,ii]-cos(theta[ii])*loop.rad[ii]),$
;                     REFORM(loop.axis[1,ii]+cos(theta[ii])*loop.rad[ii]),$
;                    REFORM(loop.axis[1,ii+1]+cos(theta[ii+1])*loop.rad[ii+1]),$
;                   REFORM(loop.axis[1,ii+1]-cos(theta[ii+1])*loop.rad[ii+1])],$
;             [REFORM(loop.axis[2,ii]-sin(theta[ii])*loop.rad[ii]),$
;                REFORM(loop.axis[2,ii]+sin(theta[ii])*loop.rad[ii]),$
;                REFORM(loop.axis[2,ii+1]+sin(theta[ii+1])*loop.rad[ii+1]),$
;                  REFORM(loop.axis[2,ii+1]-sin(theta[ii+1])*loop.rad[ii+1])];,$
                ;color=T_color[ii]    
           polyfill,[REFORM(loop.axis[1,ii]-loop.rad[ii]),$
                     REFORM(loop.axis[1,ii]+loop.rad[ii]),$
                    REFORM(loop.axis[1,ii+1]+loop.rad[ii+1]),$
                   REFORM(loop.axis[1,ii+1]-loop.rad[ii+1])],$
             [REFORM(loop.axis[2,ii]-loop.rad[ii]),$
                REFORM(loop.axis[2,ii]+loop.rad[ii]),$
                REFORM(loop.axis[2,ii+1]+loop.rad[ii+1]),$
                  REFORM(loop.axis[2,ii+1]-loop.rad[ii+1])];,$
                ;color=T_color[ii] 
           endfor
endif

loadct,CT,/silent

COLORBAR, BOTTOM=MAX_C_OFFSET, CHARSIZE=1.1, $;charsize, $
          COLOR=color, DIVISIONS=divisions, $
          FORMAT=format, POSITION=position, $
          MAXRANGE=maxrange, MINRANGE=minrange, $
          NCOLORS=ncolors,TITLE=cb_title, $
          TOP=top, RIGHT=right, MINOR=minor, $
          RANGE=range, FONT=font, TICKLEN=ticklen, $
          _EXTRA=extra, INVERTCOLORS=invertcolors, $
          TICKNAMES=ticknames

;if keyword_set(time) then $
 ; legend,['Time= '+strcompress(string(time,format='(d08.2)'))+' sec'],$
 ;      box=0,/right,charsize=1.1,charthick=1.1, FONT=FONT
for beam_index=0l, n_elements(nt_beam)-1l do begin
    if nt_beam[beam_index].state eq 'NT' then begin
        symbol=8 
        symthick=2
    endif else begin
       goto, next_particle_jump
     endelse


    position_index=long(where(abs(nt_beam[beam_index].x-loop[n_loop-1l].s) eq $
                              min(abs(nt_beam[beam_index].x-loop[n_loop-1l].s))))
    if position_index[0] ne -1 then $
        plots,x_axis[position_index[0]] ,$
              vary[beam_index]*2d0* $
              loop[n_loop-1l].RAD[position_index[0]]+y_axis[position_index[0]] $
              -loop[n_loop-1l].RAD[position_index[0]], $
              psym=symbol, $
              color=color_const+(color_factor*nt_beam[beam_index].ke_total),$
              SYMSIZE=1,THICK=symthick;,POSITION=POSITION
    next_particle_jump:
endfor     

xyouts, !x.crange[0],$
        !y.crange[1]+(!y.crange[1]-!y.crange[0])*0.01,$
        plot_title,/DATA,CHARSIZE=CHARSIZE*2,$
        CHARTHICK= (CHARTHICK*2<1.9),$
        FONT=FONT        
       
xyouts, !x.crange[0]+(!x.crange[1]-!x.crange[0])*.70,$
        !y.crange[1]+(!y.crange[1]-!y.crange[0])*0.01,$
        'Time= '+strcompress(string(time,format='(d08.2)'))+' sec',$
        /DATA,CHARSIZE=CHARSIZE,CHARTHICK= CHARTHICK,$
        FONT=FONT  
                    ;
if keyword_set(post) then device, /close
end

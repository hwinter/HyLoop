;.run fix_plots4piet
;need to define:
;Folder
;TMK
;L
;Alpha
;Beta

LENGTH=L

cd , folder
file_prefix='T_*'

TMK=strcompress(string(TMK,FORMAT='(g10.2)'),/remove)
LENGTH=strcompress(string(LENGTH,FORMAT='(g10.2)'),/remove)
ALPHA_S=strcompress(string(ALPHA,FORMAT='(g10.2)'),/remove)
BETA_S=strcompress(string(BETA,FORMAT='(g10.2)'),/remove)

start_ps='T='+TMK+'MK_' + $
         'L='+LENGTH+'1E9cm_'+ $
         'Alpha='+ALPHA_S+'_Beta='+Beta_S

ps=start_ps+'_velocity_plot.ps'

FONT=0
mach=0
TITLE='Alpha='+ALPHA_S+' Beta='+Beta_S

max_velocity_display, folder, FILE_PREFIX=FILE_PREFIX, $
  EXT=EXT, PS=PS, TITLE=TITLE, MACH=MACH, EPS=EPS, FONT=FONT, $
  CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK, THICK=THICK,$
  LINESTYLE=LINESTYLE, TMK=TMK, LENGTH=LENGTH


;ps=start_ps+'_temp_compare.ps'
;temp_compare_plot, folder, FILE_PREFIX=FILE_PREFIX, $
;                   EXT=EXT, PS=PS, TITLE=TITLE, EPS=EPS, FONT=FONT, $
;                   CHARSIZE=CHARSIZE, CHARTHICK=CHARTHICK, THICK=THICK,$
;                   LINESTYLE=LINESTYLE, ALPHA=ALPHA, BETA=BETA,NO_CHR=NO_CHR,$
;                   TMK=TMK, LENGTH=LENGTH


end

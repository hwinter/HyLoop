
patc_dir=getenv('PATC')
restore,patc_dir+'initial_e_beam.sav'
run_folder=strcompress(patc_dir+'runs/2005_11_03c/')
;file1=strcompress(run_folder+'hd_out.sav',/REMOVE_ALL)
file2=strcompress(run_folder+'full_test_2.sav',/REMOVE_ALL)
;restore,file1
;restore,file2

loadct,0

save_type2='pa_dist' 
!p.multi=[0,0,0]

gif_dir=run_folder+'gifs/'   
animate_index=0    

 plot_histo,cos(e_beam.pitch_angle), 100,histo,xrange=[-1.,1],/xstyle,$
   XTITLE='Cosine Pitch Angle',YTITLE='Number of Particles',$
   TITLE='Pitch Angle Diffusion'

       x2gif,strcompress(gif_dir+'pa_dist'+string(animate_index,FORMAT='(I5.5)')+'.gif')

animate_index=1
for i=0, n_elements(beam_struct)-1 do begin
 index=where(beam_struct[i].e_beam.state eq'NT')
 plot_histo,cos(beam_struct[i].e_beam[index].pitch_angle), 100,histo,xrange=[-1.,1],/xstyle

       x2gif,strcompress(gif_dir+'pa_dist'+string(animate_index,FORMAT='(I5.5)')+'.gif')
animate_index=animate_index+1

endfor


save_type2='pa_dist'
gifs2=findfile(strcompress(gif_dir+save_type2+'*'))



image2movie, gifs2, movie_name=strcompress(gif_dir+save_type2+'_movie.gif'), $
  gif_animate=1,/nodelete,/loop

end




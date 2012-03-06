
        plot,x,s_form, Title='Power per Volume', $
            xtitle='loop length cm', ytitle= 'ergs cm ^-3 s^-1', $
          CHARSIZE=1.2,CHARTHICK=1.2 
        legend,['Time= '+string(animate_index*delta_time,format='(d8.3)')+' sec'],$
          box=0,/right,charsize=2,charthick=1.5
        
        x2gif,strcompress(gif_dir+'power_per_vol'+string(animate_index,FORMAT='(I5.5)')+'.gif')


       animate_index=animate_index+1

      
        beam_on_time=beam_on_time+time_step
        
       ; if beam_on_time le beam_time then begin
       ;     e_beam=concat_struct(e_beam,original_beam)
       ;     vary=[vary,vary]
        ;endif

    endwhile


end

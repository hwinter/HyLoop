
n_loop=n_elements(beam_struct)


if n_loop lt 1 then begin
    restore,'full_test_2.sav'
    n_loop=n_elements(beam_struct)
endif
 f_bar=dblarr(loop)
window,0
window,1
volumes=get_loop_vol(loop[0].s,loop[0].a)
volume=total(volumes)
for i=0, n_loop-1 do begin

    alive_ind=where(beam_struct[i].e_beam.state $
                                       eq 'NT')
    if  alive_ind[0] ne -1 then  begin
        beam=beam_struct[i].e_beam[alive_ind ]
        dens=get_loop_nt_dens(loop[i],beam, $
                              SCALE_FACTOR=beam_struct[i].scale_factor,$
                             /per)
    endif else dens=[0,0]
    plot,loop[i].s_alt,dens
    n_e_bar=mean(n_loop[i].state[1:n_elements((n_loop[i].state)-2l)
    f_bar[i]=(1d/(volume*n_e_bar))*
    ;wait,.5

endfor


END 



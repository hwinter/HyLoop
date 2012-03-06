function gt_loop_nt_dens, loop,nt_beam,SCALE_FACTOR=SCALE_FACTOR, $
  PER_KEV=PER_KEV

N_beam=n_elements(nt_beam)
volumes=get_loop_vol(loop)
n_volumes=n_elements(volumes)
s_alt=get_loop_s_alt(loop)
s_alt2=s_alt[1:n_volumes-1l]


dens=dblarr(n_volumes)
for i=0, N_beam-1 do begin
    index=where(abs(nt_beam[i].x- s_alt2) eq $
                min(abs(nt_beam[i].x- s_alt2)))


    dens[index]=dens[index]+1L*nt_beam[i].SCALE_FACTOR
    if keyword_set(PER_KEV) then $
      dens[index]=dens[index]/NT_beam[i].ke_total

endfor

return, dens

end

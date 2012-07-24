function get_loop_cs,loop, GAMMA=GAMMA, T=T, $
                     S_GRID=S_GRID, VOL_GRID=VOL_GRID

;ratio of specific heats, C_P/C_V
if not keyword_set(gamma) then gamma = 5d0/3.0d0 

if not keyword_set(T) then Temperature = get_loop_temp(loop) $
                                         else Temperature=T
cs = sqrt(3.0*gamma*!shrec_kB*Temperature/!shrec_mp)

if NOT keyword_set(VOL_GRID) then begin
    new_cs=spline(loop[0].s_alt, cs[*,0], $
                  loop[0].s,/DOUBLE)
    n_loops=n_elements(loop)
    if n_loops gt 1 then begin

        for i=1ul, n_loops-1 do $
          new_cs=[ $
                  [new_cs],$
                  [spline(loop[0].s_alt, cs[*,0], $
                          loop[0].s,/DOUBLE)]]
    endif


    cs=abs(temporary(new_cs))
endif


    return, cs

end

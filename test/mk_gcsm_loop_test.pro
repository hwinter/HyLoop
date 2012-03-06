
T_MAX=3.0d6
DEFSYSV, '!heat_Tmax',T_MAX
N_CELLS=700
N_DEPTH=25
;max_height=1d10
Area_0=!dpi*(5d8)^2d ;Footpoint area [cm^2]
TEST=1

loop=mk_green_field_loop(N_CELLS=N_CELLS,$
                         N_depth=N_depth,$) ;max_height=max_height,$
                         Area_0=Area_0, TEST=TEST)

vol=get_loop_vol(loop)
n_vol=n_elements(vol)
print, 'N particles= ',total(loop.state.n_e[1:n_vol]*vol)
end

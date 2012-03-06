
;surface_area=calc_loop_areas(x,a)
function calc_loop_areas, x,a


;Says it all
N=n_elements(x)
;change in length
dl=(x(1:N-1) - x(0:N-2))
;Average area of each cylinder
avg_a=(0.5*(a(0:N-2) +a(1:N-1)))

surface_area=2d*avg_a $
  + (2d*!dpi*sqrt(avg_a/!dpi)*dl) ;2 pi r x dl

return,surface_area

end

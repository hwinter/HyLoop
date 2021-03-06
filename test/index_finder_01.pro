;.r index_finder_01

array_sizes=[10,50, 1d2, 5d2, 1d3, 5d3, 1d4, 5d4]

cell_array=(findgen(100)*6.0)-3.

n_arrays=n_elements(array_sizes)-1ul
t1_array=dblarr(n_arrays, /NOZERO)
t2_array=t1_array

For i=0ul, n_arrays-1ul do begin
   positions=randomn(seed, array_sizes[i])

   t_start=systime(1)
   pos_index=hdw_get_position_index(positions, cell_array)
   t1_array[i]=systime(1)-t_start

   t_start=systime(1)
   pos_index=hdw_get_position_index_for_loop(positions, cell_array)
   t2_array[i]=systime(1)-t_start


endfor


set_plot, 'x'
window, /free
times=t2_array/t1_array
plot,array_sizes, times, thick = 2, charsize = 1.5, color = fsc_color('black'), $
      back = fsc_color('white'), /xlog, /ynozero, $
      xtitle = 'Array size', ytitle = 'Speedup fraction',$
     title='Vector Index finding Speedup',/nodata
oplot,array_sizes , times , color = fsc_color('red'), thick = 3
oplot, array_sizes , times , color = fsc_color('red'),psym=4, symsize=2.5

oplot_horiz, 1, /log, color = fsc_color('black')

legend, color = [ fsc_color('red')], $
        ['For Loop/Vector'], linestyle = 0, $
        textcolors=[fsC_color('black')], thick=3
end







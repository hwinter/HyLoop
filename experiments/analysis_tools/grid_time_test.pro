;grid_time_test

times=[12610.928d,$
       16181.712,$
       21154.682,$
       30789.594, $
       40546.935,$
       38089.657,$
       156340.64,$
       47941.744,$
       54707.629,$
       78653.016,$
       88659.060,$
       79844.007,$
       91461.738,$
       84380.773]

n_grids=[099ul,$
         199,$
         299,$
         399,$
         499,$
         599,$
         699,$
         799,$
         899,$
         999,$
         1099,$
         1199,$
         1299,$
         1399]



plot, 0.001* n_grids, 0.001*(times)

a=[1,1,1]
y=comfit(n_grids, times,a, /GEOMETRIC)
;y=LINFIT(n_grids, times)
MIN_Y=MIN(TIMES)

Y=MIN_Y*(times-times[0])*exp(n_grids)
y=alog10(MIN_Y)+alog10(times-times[0])+(0.001*n_grids)
oplot, n_grids[1:*], y[1:*], psym=4





END ;

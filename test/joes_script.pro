
npts=15.
xpts = (2*!pi)*findgen(npts)/(npts-1.)
new_x=(2*!pi)*findgen(npts-5)/(npts-5-1.)

ypts = sin(xpts)
print, 'Original ypts vector (sine evaluated from 0...2pi):'
print, ypts
print, 'Number of points to interpolate over, npts:'
print, npts
print, 'Interpolated points (interpol called here with npts as 2nd argument and /spline flag):'
new_y=interpol(ypts,xpts,new_x,/spline)
print,y

plot, xpts, ypts
oplot, new_x, new_y, psym=4, symsize=3


end

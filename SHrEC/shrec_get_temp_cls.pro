
;get_loop_temp_cls
;
function shrec_get_temp_cls, state,s_alt, ROOF=ROOF,S_GRID=S_GRID,$
  VOL_GRID=VOL_GRID,SMOOTH=SMOOTH, ITER_SMOOTH=ITER_SMOOTH,$
  NO_ENDS=NO_ENDS, T=T, FLOOR=FLOOR

if not keyword_set(ROOF) then ROOF=1d+22

if not keyword_set(T) then q=shrec_get_temp(state) else q=T

;grid=get_loop_s_alt(loop)
n_s=n_elements(s_alt)
grid=s_alt
;Take the derivative of the quantity with respect to the grid.
;dq_dx=deriv(grid,q)
dq=q[0ul:n_s-2ul]-q[1:n_s-1ul]
dx=grid[0ul:n_s-2ul]-grid[1:n_s-1ul]
dq_dx=dq/dx

;If the derivative is zero everywhere, make it a large value
test=where(dq_dx ne 0d)
if test[0] eq -1 then cls=dblarr(n_s)+ROOF else begin
;Zeroes can cause problems so make zeroes small numbers
    zeroes= where(dq_dx eq 0d)
    if zeroes[0] ne -1 then dq_dx[zeroes]=1d-30
    zeroes= where(q eq 0d)
    if zeroes[0] ne -1 then q[zeroes]=1d-30
;Define the charactersitic scale length
    cls=abs((dq_dx/q)^(-1d))
endelse

test=where(finite(cls) ne 1)
if test[0] ne -1 then cls[test]=roof
;If the keyword is set then spline it to the s grid
if keyword_set(S_GRID) then begin
    ;alt_grid=loop.s
   ; cls=spline(grid,cls,alt_grid)
    n_elem=size(cls,/dim)
    
    cls =(cls[0:n_elem[0]-2,*]+cls[1:n_elem[0]-1,*])/2d0
    
endif else if keyword_set(NO_ENDS) then $
      cls=temporary(cls[1:n_s-2])


;Smooth if desired.
if keyword_set(SMOOTH) then begin    
    if not keyword_set(ITER_SMOOTH) then ITER_SMOOTH=5
    if SMOOTH eq 1 then SMOOTH=3
    clsF=cls
    for j=0,ITER_SMOOTH do clsF=smooth(clsF, SMOOTH)
    clsR=reverse(cls)
    for j=0,ITER_SMOOTH do clsR=smooth(clsR, SMOOTH)
    cls=(clsF+reverse(clsR))/2d0

endif

test=where(finite(cls) ne 1)
if test[0] ne -1 then cls[test]=roof

IF KEYWORD_SET(FLOOR) THEN CLS>=FLOOR
return, abs(cls)

END

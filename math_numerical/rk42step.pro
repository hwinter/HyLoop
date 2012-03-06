;Inefficient.
function rk42step, Y, Dydx, X, H, Derivs , DOUBLE= DOUBLE

  y1=rk4(Y, Dydx, X, H/2.0, Derivs , DOUBLE=DOUBLE)
  y1=rk4(y1, Dydx, X+H/2.0, H/2.0, Derivs , DOUBLE=DOUBLE)

  y2=rk4(Y, Dydx, X, H, Derivs , DOUBLE=DOUBLE)

  delta=y2-y1

  new_y=y2+delta/15.

  return, new_y


end

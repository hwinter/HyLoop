;
; Program to wring out the bnh_splint CALL_EXTERNAL stuff.
;
; Modification History:
;    10-Feb-99 (BNH) - Written

x = dindgen(20)
y = x^2
;             0   1  2   3    4     5     6     7
x1 = double([1.5, 2, 4, 4.5, 7.85, 8.25, 9.15, 15.5])

n_x = n_elements(x)
n_y = n_elements(x1)

answer = make_array(n_y, /double)

a = call_external('bnh_splint.so','bnh_splint', $
                  n_x, x, y, n_y, x1, answer)

end

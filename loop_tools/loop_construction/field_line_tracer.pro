;field_line_tracer.pro
;bx & by need work

function field_line_tracer, x_init,y_int,delta_l, $
  BX=BX, BY=BY, BT=BT, $
  HALF_ONLY=HALF_ONLY

type_x=size(x_init, /TYPE)
type_y=size(y_init, /TYPE)
type_dl=size(delta_l, /TYPE)


case 1 of 
    type_x eq 1:x_init=double(x_init)
    type_x eq 2:x_init=double(x_init)
    type_x eq 3:x_init=double(x_init)
    type_x eq 4:x_init=double(x_init)
    else : x_init=0d0
endcase
    
case 1 of 
    type_y eq 1:y_init=double(y_init)
    type_y eq 2:y_init=double(y_init)
    type_y eq 3:y_init=double(y_init)
    type_y eq 4:y_init=double(y_init)
    else : y_init=-1.05d0
endcase
    
case 1 of 
    type_dl eq 1:delta_l=double(delta_l)
    type_dl eq 2:delta_l=double(delta_l)
    type_dl eq 3:delta_l=double(delta_l)
    type_dl eq 4:delta_l=double(delta_l)
    else :delta_l =1d-3
endcase
    

x_array=x_init
y_array=y_init
index=0ul
bx=0d0
by=bx
bt=bx
x=x_array[index]
y=y_array[index]
while max(abs(y)) lt 2. or max(abs(x))  lt 2. do begin 
    x=x_array[index]
    y=y_array[index]
    bungey_priest_field01, x,y,f,B_x, B_y,$
      A=A,B_DRC=B_DRC,C=C,D=D,B0=B0, $
      B_TOTAL=B_TOTAL

    delta_x=(b_x/B_TOTAL)*delta_l
    delta_y=(b_y/B_TOTAL)*delta_l
    x_array=[x_array, x+delta_x]
    y_array=[y_array, y+delta_y]
    bx=[bx, B_x]
    by=[by, B_y]
    bt=[bt, B_total]

    index+=1ul
end

x=x_array[n_elements(x_array)-1ul]
y=y_array[n_elements(x_array)-1ul]
bungey_priest_field01, x,y,f,B_x, B_y,$
  A=A,B_DRC=B_DRC,C=C,D=D,B0=B0, $
  B_TOTAL=B_TOTAL

bx=[bx, B_x]
by=[by, B_y]
bt=[bt, B_total]

bx=bx[1:*]
by=by[1:*]
bt=bt[1:*]

index=where(y_array gt -2.)
if index[0] ne -1 then begin
    x_array=x_array[index]
    y_array=y_array[index]
    bx=bx[index]
    by=by[index]
    bt=bt[index]    
endif

if not keyword_set(HALF_ONLY) then begin
    case 1 of 
        x_array[1] lt x_array[0] : begin
            x_array=[reverse(x_array),-1.0*(x_array)]
            y_array=[reverse(y_array),y_array]
            bt=[reverse(bt),bt]
            bx=[reverse(bx),bx]
            by=[reverse(by),-1.0*by]
            
        
            
        end
        else: begin
            x_array=[-1.0*(x_array),reverse(x_array)]
            y_array=[y_array, reverse(y_array)]
            bt=[bt, reverse(bt)]
            bx=[bx, reverse(bx)]
            by=[-1.0*by,reverse(by)]
            
        
            
        end
        
    endcase
endif else begin
    if   x_array[1] lt x_array[0] then begin
        x_array=reverse(x_array)
        y_array=reverse(y_array)
        bt=reverse(bt)
        bx=reverse(bx)
        by=reverse(by)
    endif

endelse


    return, [[x_array],[y_array]]
end

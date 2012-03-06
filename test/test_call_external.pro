Print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
Print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
Print, 'Command line test'
;Print, 'ssw_batch test'

computer='dawntreader';Identify the computer you are on

so =get_bnh_so(computer,/init);Grab the proper shared object file
print, so

s=[0.,1.1, 1.3,5,8,13,15,16, 22]
n_points=n_elements(s)
b_t=cos(s*(!dpi/(2*22)))
s2=1+21*dindgen(100)/99
b=dblarr(100)
n_2=n_elements(b)
foo = call_external(so, $            ; The Shared Object
                    'bnh_splint', $  ; The entry name
                    n_points, $   ; # of elements in x, f(x)
                    s, $            ; x
                    b_t, $           ; f(x)
                    n_2, $; # elements in thing-to-interpolate
                    s2, $          ; thing-to-interpolate
                    b, $             ; where the answer goes
                    /d_value, $ ;Return doulbe prec.
                    value=[1,0,0,1,0,0], $ ;0; pass via ref. 1 pass via value
                    /auto_glue,$ ;Automaticall write function to convert argc,argv
                    /ignore_exist) ;Ignore_existing glue functions,

plot, s,b_t
oplot, s2,b,psym=2
Print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
Print,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'
                ;    /cdecl,$;Standard for pushing arguments in sys. stack
end;

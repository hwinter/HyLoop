;A program to update a loop structure to the current standard,
;Written for Version 2.1


function update_loop, loop

;Need to use the following for error checking in future
;tags=tag_names(loop)



new_loop=mk_loop_struct( $
               S_ARRAY=loop.S, $
               STATE=loop.STATE,B=loop.B,$
               G=loop.G,AXIS=loop.AXIS, $
               RAD=loop.RAD,E_H=loop.E_H,T_MAX=loop.T_MAX,$
               N_DEPTH=loop.N_DEPTH,  $
               COPIES=COPIES,AREA=loop.A, $
               START_FILE=loop.START_FILE,TIME=loop.state.TIME,$
               DEPTH=loop.DEPTH, NOTES=loop.NOTES)


return, new_loop

end

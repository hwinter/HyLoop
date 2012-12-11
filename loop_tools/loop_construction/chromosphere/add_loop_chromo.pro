function add_loop_chromo, loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                          VERSION=VERSION, STARTNAME=STARTNAME,$
                          PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, $
                          chromo_model=chromo_model
  Version=2.0

  print, 'Add_loop_chromo All Done'

  Case 1 of 
     size(chromo_model, /TYPE) eq 0:begin
        
        new_loop= add_loop_chromo1( loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                                    VERSION=VERSION, STARTNAME=STARTNAME,$
                                    PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, CHROMO_NAME=CHROMO_NAME)
        
     end
     size(chromo_model, /TYPE) ne 7:begin
        
        new_loop= add_loop_chromo1( loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                                    VERSION=VERSION, STARTNAME=STARTNAME,$
                                    PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, CHROMO_NAME=CHROMO_NAME)
        
     end
     chromo_model eq 'add_loop_chromo1' :begin
        new_loop= add_loop_chromo1( loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                                    VERSION=VERSION, STARTNAME=STARTNAME,$
                                    PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, CHROMO_NAME=CHROMO_NAME)
        
     end
     
     chromo_model eq 'add_loop_chromo_funnel' :begin
        new_loop= add_loop_chromo_funnel( loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                                          VERSION=VERSION, STARTNAME=STARTNAME,$
                                          PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, CHROMO_NAME=CHROMO_NAME)
        
     end
     chromo_model eq  'add_loop_chromo_tube' :begin
        new_loop= add_loop_chromo_tube( loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                                        VERSION=VERSION, STARTNAME=STARTNAME,$
                                        PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, CHROMO_NAME=CHROMO_NAME)
        
     end
     chromo_model eq  'add_loop_chromo_tube_constant_pressure' :begin
        new_loop= add_loop_chromo_tube_constant_pressure( loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                                                          VERSION=VERSION, STARTNAME=STARTNAME,$
                                                          PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, CHROMO_NAME=CHROMO_NAME)
        
     end
     else:begin
        new_loop= add_loop_chromo1( loop, T0=T0, DEPTH=DEPTH, N_DEPTH=N_DEPTH, $
                                    VERSION=VERSION, STARTNAME=STARTNAME,$
                                    PERCENT_DIFFERENCE=PERCENT_DIFFERENCE, CHROMO_NAME=CHROMO_NAME)
        
     end
     
  endcase 
  
  return, new_loop
  
END                             ; Of main

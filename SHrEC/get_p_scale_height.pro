function get_p_scale_height, temperature
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Returns the pressure scale height in cm when given a temperature in
;Kelvin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Based on Aschwanden 2006 Physics of the solar corona page 69

return, (4.7d3)*temperature

END

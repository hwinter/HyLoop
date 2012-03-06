function patc_coll_frame2loop_frame, nt_particles, v_para_coll, v_perp_coll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Transform delta_v_parallel_1 to the loop frame
;Using sin(-A)=-sin(A) &  cos(-A)=cos(A) & 
; remembering that IDL is column major. 
;        rot_matrix=([[[cos(nt_particles.PITCH_ANGLE)], $
;                     [sin(nt_particles.PITCH_ANGLE)]], $
;                    [[-sin(nt_particles.PITCH_ANGLE)],$
;                     [cos(nt_particles.PITCH_ANGLE)]]])
        
v_parallel=cos(nt_particles.PITCH_ANGLE)*v_para_coll $
           +sin(nt_particles.PITCH_ANGLE)*v_perp_coll

v_perp=-sin(nt_particles.PITCH_ANGLE)*v_para_coll $
           +Cos(nt_particles.PITCH_ANGLE)*v_perp_coll





return, [[v_parallel], [v_perp]]

end

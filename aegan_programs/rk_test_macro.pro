
data_directory="/Volumes/Herschel/aegan/programs/HyLoop/aegan_programs/particles_programs/"
wdef,0, 1024, 1024

for i=0, 101 do begin
image_file=data_directory+'/video2/thousand_part_'+string(i,'(I04)')+'.png'
data_file=data_directory+"particle_out_"+string(i, '(I04)')+".txt"
readcol, data_file, x, y,z
plot_3dbox, x,y,z, /nodata, psym=3,xrange=[-15,15],yrange=[-15,15], zrange=[-15,80]
;write_png, image_file, tvrd(/TRUE)
endfor
END

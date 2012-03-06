

function time_bin_map, map, bin_size

bin_size_in=ulong(bin_size)

n_map_old=n_elements(map)

n_map_new=long(n_map_old/bin_size_in)

new_map=replicate(map[0], n_map_new)
counter=0ul

for i=0ul, n_map_new-1ul do begin
   if counter+(bin_size-1ul) gt n_map_old then goto, done
   COPY_TAG_VALUES,new_map[i],map[counter+(bin_size-1ul)]
   new_map[i].data=total(map[counter:counter+(bin_size-1ul)].data,3)

counter+=bin_size
endfor



done:

return, new_map

END

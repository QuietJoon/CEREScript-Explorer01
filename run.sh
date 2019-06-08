output=output/N$1-$2.log

repeatNum=256

for i in $(seq 1 $repeatNum); do
  stack exec CEREScript-Explorer01 -- +RTS -s -N$1 -RTS $2 2> >(rg Total) | rg Total | awk '{print $3, $5}' | sed 's/s//g' >> $output
done

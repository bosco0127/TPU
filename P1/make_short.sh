# !bin/bash

for foo in {0..15}
do
  one=$[$foo%10];
  ten=$[$foo/10];
  ./makeshort < ./data/ifmap$ten$one.hex > ./data/short_ifmap$ten$one.hex
  ./makeshort < ./data/ofmap$ten$one.hex > ./data/short_ofmap$ten$one.hex
done
exit 0

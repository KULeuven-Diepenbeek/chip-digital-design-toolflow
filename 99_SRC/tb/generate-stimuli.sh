#!/bin/bash

START=1
END=$1

i=$START
while [[ $i -le $END ]]; do
	#statements
#done
#for i in {1..$1}
#do
	PLAINTEXT=`echo "$(openssl rand -hex 16)"`
	KEY=`echo "$(openssl rand -hex 16)"`
	CIPHERTEXT=`echo 0: "$PLAINTEXT" | xxd -r | openssl enc -aes-128-ecb -K "$KEY" -nopad -nosalt | xxd | cut -c10-50 | tr -d ' '`

	LINE=`echo "check_cyphertext(x\""$PLAINTEXT"\", x\""$KEY"\", x\""$CIPHERTEXT"\")"`

	sed -i '/\[extra_tests]/a\\ \t\t'"$LINE"';' aes128_tb.vhd
	echo "$LINE"
	((i = i + 1))
done

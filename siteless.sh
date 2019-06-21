while IFS=$'\t' read -r -a myArray
do
 filename="${myArray[0]}"
 filecontent="${myArray[3]}"
 echo $filecontent >target/$filename
 sed -i -E 's/\\"/"/g' target/$filename
 cat target/$filename | jq -f filter.jq >target/$filename.tsv

 sed -i -E 's/\\t/\t/g' target/$filename.tsv
 sed -i -E 's/"(.*)"/\1/g' target/$filename.tsv

 #
 #> target/$filename
done < ./target/top.tsv





rm -r ./target

export DOC_DIR=docs/books
export INDEX_DOC=index.adoc

mkdir target
mkdir target/modules
mkdir target/modules/ROOT
mkdir target/modules/ROOT/pages


tar -c --exclude .git --exclude target . | tar -x -C target/modules/ROOT/pages

mv target/modules/ROOT/pages/modules target/modules/ROOT/pages/_partials

cp antora.yml target



# find and replace modules with {partialsdir} 
find ./target -type f -exec \
    perl -0pi -e 's/include::modules/include::{partialsdir}/g' {} +


# creat nav.adoc
yq r -d'*' -j _topic_map.yml > target/nav.json
cat target/nav.json | jq -f filter.jq > target/top.tsv

sed -i -E 's/"(.*)"/\1/g' target/top.tsv 
sed -i -E 's/\\t/\t/g' target/top.tsv 

./siteless.sh

q -t -H "select Dir,Name from target/top.tsv" > target/map.tsv

echo ""> target/nav.adoc

while IFS=$'\t' read -r -a myArray
do
 filename="${myArray[0]}"
 title="${myArray[1]}"
 echo "* $title" >>target/nav.adoc

  while IFS=$'\t' read -r -a myArray
  do
   subfilename="${myArray[1]}"
   subtitle="${myArray[2]}"
   echo "** xref:$filename/$subfilename.adoc[$subtitle]" >>target/nav.adoc

  done < ./target/$filename.tsv




 done < ./target/map.tsv

sed -i -E 's/.*File.adoc.*//g' target/nav.adoc 
sed -i -E 's/.*null.adoc.*//g' target/nav.adoc 


cp target/nav.adoc target/modules/ROOT


antora local-site.yml

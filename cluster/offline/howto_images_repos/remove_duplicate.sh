previous="" 
while IFS='' read -r f || [[ -n "$f" ]]; do
  #on trim f 
  f="$(echo -e "${f}" | tr -d '[[:space:]]')"
  if [ "$f" != "" ];
  then
        if [ "$previous" =  "" ]
        then 
          echo "preserve $f"
        else
          rm -rf $f          
        fi	
  fi
  previous=$f
done < duplicates.txt
  

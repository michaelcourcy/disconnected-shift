#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "###########################"
echo "pulling and saving images  "
echo "###########################"
echo " "

for list in `ls /vagrant/offline/images/*.list` 
do 	
	archive="${list%.list}.tar"
	if [[ ! -f $archive ]]
	then 
		echo "Creating $archive"
		images=""
		for image in `cat $list` 
		do 
			echo "Pulling image ${image}"
			image=$(echo -e "${image}" | sed -e 's/[[:space:]]*$//')
			docker pull $image
			images+=$image
			images+=" "		
		done
		#remove the last whitespace
		images=$(echo -e "${images}" | sed -e 's/[[:space:]]*$//')
		archive="${list%.list}.tar"
		echo "saving in archive $archive images : $images"
		#something strange on the whitespace I can't figure out 
		# running directly docker save -o /vagrant/offline/images/$archive $images
		# lead to an invalid reference/tag
		echo "docker save -o $archive $images" > save.sh
		sh save.sh #crappy todo find what's wrong 
		chmod 777 $archive
		echo ""
	else 
		echo "$archive already exist skipping"
	fi
done		

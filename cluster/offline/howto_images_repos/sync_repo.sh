for repoid in `cat repos.txt` 
do 
   reposync --gpgcheck -lm --repoid=$repoid --download_path=/repos
done

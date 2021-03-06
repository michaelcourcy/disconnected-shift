echo "add ansible.repo to have ansible version 2.4.3.0 or newer" 
cp /vagrant/offline/conf_to_copy/ansible.repo /etc/yum.repos.d
YUM_REPO_D=/vagrant/offline/conf_to_copy/yum.repos.d
for repo in  base updates extras centosplus centos-openshift-origin ansible 
do
  echo "Synchronize the repo ${repo} option -n only new packages"
  reposync -lmn --repoid=${repo} --download_path=/vagrant/offline/repos/
  createrepo -v /vagrant/offline/repos/${repo} -o /vagrant/offline/repos/${repo}
  #create the local.repo future file in the same time 
  echo ""													>> $YUM_REPO_D/${repo}.repo
  echo "[${repo}]" 											>> $YUM_REPO_D/${repo}.repo
  echo "name=${repo}" 										>> $YUM_REPO_D/${repo}.repo
  echo "baseurl=file:///vagrant/offline/repos/${repo}" 		>> $YUM_REPO_D/${repo}.repo
  echo "gpgcheck=0" 										>> $YUM_REPO_D/${repo}.repo
  echo "enabled=1" 											>> $YUM_REPO_D/${repo}.repo
  echo ""													>> $YUM_REPO_D/${repo}.repo 
done

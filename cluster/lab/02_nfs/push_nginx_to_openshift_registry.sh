echo "Push openshift-nginx image on nfs project, actually create an image stream referencing internally the image"
REGISTRY_HOST=$(oc get route docker-registry -n default --template='{{ .spec.host }}')
#we do not specify anything thus every image are latest
docker tag openshift-nginx $REGISTRY_HOST/nfs/openshift-nginx
docker push $REGISTRY_HOST/nfs/openshift-nginx

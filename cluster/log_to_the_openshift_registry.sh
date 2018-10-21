TOKEN=$(oc whoami -t)
if [[ $? -ne 0 ]]
then
  echo "You didn't connect yet (oc login ...)"
  exit 1
fi
REGISTRY_HOST=$(oc get route docker-registry -n default --template='{{ .spec.host }}')

#docker login -u $(oc whoami) -p $(oc whoami -t) $(oc get route docker-registry -n default --template='{{ .spec.host }}')

echo "log to the registry $REGISTRY_HOST with the token $TOKEN"
docker login -p $TOKEN -u unused $REGISTRY_HOST

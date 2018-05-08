TOKEN=$(oc whoami -t)
if [[ $? -ne 0 ]]
then
  echo "Vous ne vous êtes pas encore connecté (oc login ...)"
  exit 1
fi
REGISTRY_HOST=$(oc get route docker-registry -n default --template='{{ .spec.host }}')
echo "login à la registry $REGISTRY_HOST avec le token $TOKEN"
docker login -p $TOKEN -u unused $REGISTRY_HOST

oc get pod --all-namespaces | awk '$1 != "NAMESPACE" {print $1 " " $2}' | while read -r namespace pod ; do
    echo $(oc get pod --template='{{range .status.containerStatuses}}{{ .image }}{{end}}' $pod -n $namespace)
done

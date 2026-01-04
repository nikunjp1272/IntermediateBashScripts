# option 1: use "use-context" to use a context and you won't have to add --context in every command, but you will have to keep switching the context if you want to look at the other contexts at the same time.
# option 2: just copy paste below commands and replace all context names with the context you have set

kubectl config rename-context arn:aws:eks:eu-west-1:123456789:cluster/cluster-name lab
kubectl config use-context lab
kubectl config get-contexts
kubectl get pods -A --context common-rec
kubectl get pods -n <NAMESPACE> # works with or without context
kubectl logs <POD-NAME> -n <NAMESPACE> --context <CONTEXT-NAME>
kubectl describe pod <POD-NAME> -n <NAMESPACE>
kubectl get namespaces --context <CONTEXT-NAME>
kubectl get pods --all-namespaces --context <CONTEXT-NAME>
kubectl get pods --all-namespaces --watch --context <CONTEXT-NAME>
kubectl get deployments --all-namespaces --context <CONTEXT-NAME>
kubectl get deployment <DEPLOYMENT-NAME> -n <NAMESPACE> -o yaml > tmp.yaml --context <CONTEXT-NAME>
kubectl get deployments -n <NAMESPACE> --context <CONTEXT-NAME>
kubectl get daemonsets -n <NAMESPACE> --context <CONTEXT-NAME>
kubectl get svc -n <NAMESPACE> --context common-preprod
kubectl get configmaps -n <NAMESPACE> --context <CONTEXT-NAME>
kubectl api-resources --namespaced=true -o name --context <CONTEXT-NAME>
kubectl api-resources --namespaced=true --context <CONTEXT-NAME>
kubectl auth can-i --list -n <NAMESPACE> --context <CONTEXT-NAME>
kubectl get events -n <NAMESPACE> --sort-by=.metadata.creationTimestamp --context <CONTEXT-NAME>
kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded 
kubectl get cronjobs -A --context <CONTEXT-NAME>
k logs <POD-NAME> -n <NAMESPACE>| grep -iE "error|fail|shutdown|panic|exception|fatal"
kubectl exec -it -n wm-cristal <name-of-pod> -- bash
nikunj@WPW0H1VXG:~/.aws$ k logs wm-octasynccorrespondance-microservicesruntime-647f5f7cc7-lhn44 -n wm-octasynccorrespondance
k logs wm-octasynccorrespondance-microservicesruntime-647f5f7cc7-lhn44 -n wm-octasynccorrespondance | grep -iE "error|fail|shutdown|panic|exception|fatal"

# kubectl logs <POD-NAME> -c <container-name> -n <NAMESPACE>
# kubectl get namespaces
# kubectl get pods --all-namespaces
# 

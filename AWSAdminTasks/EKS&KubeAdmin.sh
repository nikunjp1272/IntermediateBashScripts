# run in clodushell or in the ubuntu env for a profile called LAB_P
aws eks update-kubeconfig --region eu-west-1 --name cluster-name --profile LAB_P
# run in clodushell or in the ubuntu env for a profile called DEV_PROFILE
aws eks update-kubeconfig --region us-east-1 --name dev-cluster --profile DEV_PROFILE
# to assume a role in AWS
aws sts assume-role --role-arn "arn:aws:iam::722052991222:role/engieit-bis-prod.PowerUserAccess" --role-session-name AWSCLI-Session
# to check current role for a certain profile
aws sts get-caller-identity --profile LAB_P
# to fetch token manually
aws eks get-token --region eu-west-1 --cluster-name common-lab --profile LAB_P
# list clusters in a region
aws eks list-clusters --region <region>
# get info about a cluster
aws eks describe-cluster --name <cluster-name> --region <region>

# login to the pod
kubectl exec -it -n wm-cristal <name-of-pod> -- bash

# to return all pods
kubectl get pods -A
# get pods of a particular namespace
kubectl get pods -n <NAMESPACE>
# get logs of a pod
kubectl logs <pod-name>
# get details of a pod
kubectl describe pod <pod-name>
# get all pods in all namespaces (with status)
kubectl get pods --all-namespaces
# watch pods in real-time
kubectl get pods --all-namespaces --watch
# describe a specific pod
kubectl describe pod <pod-name> -n <namespace>
# view pod logs
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -c <container-name> -n <namespace>
# view logs of previous pod instance (after crash)
kubectl logs <pod-name> -p -n <namespace>
# check pod resource usage
kubectl top pod -n <namespace>
kubectl get pods --all-namespaces --watch
watch kubectl get pods -A

# check health of kubernetes components
kubectl get componentstatuses

# view worker nodes
kubectl get nodes
# check nodes resource usages with metrics
kubectl top nodes
# detailed info per node
kubectl describe node <node-name>


# check available contexts
kubectl config get-contexts
# rename contexts
kubectl config rename-context arn:aws:eks:eu-west-1:123456789:cluster/cluster-name lab
kubectl config rename-context arn:aws:eks:us-east-1:987654321:cluster/clluster-name dev
# use contexts
kubectl config use-context lab
kubectl config use-context dev

# list all deployments in all namespaces
kubectl get deployments --all-namespaces
# Get resource as YAML
kubectl get deployment <DEPLOYMENT_NAME> -n <NAMESPACE> -o yaml > tmp.yaml
# get deployments and their statuses
kubectl get deployments -n <namespace>
# get deployments for all namespaces
kubectl get deployments --all-namespaces
# check rollout status of a deployment
kubectl rollout status deployment/<deployment-name> -n <namespace>

# get all namespaces
kubectl get namespaces

# get all events of a namespace
kubectl get events --all-namespaces

# get roles of a namespace
kubectl get roles -n <NAMESPACE>
# view cluster roles
kubectl get clusterroles
# view role bindings of all namespaces
kubectl get rolebindings --all-namespaces
# view cluster role bindings
kubectl get clusterrolebindings

# listing resources in a namespace
kubectl get pods -n <NAMESPACE>
kubectl get deployments -n <NAMESPACE>
kubectl get daemonsets -n <NAMESPACE>
kubectl get statefulsets -n <NAMESPACE>
kubectl get svc -n <NAMESPACE>
kubectl get configmaps -n <NAMESPACE>
kubectl get secrets -n <NAMESPACE>   # secrets are base64-encoded
kubectl get all -n <NAMESPACE>
kubectl get $(kubectl api-resources --namespaced=true -o name | tr '\n' ',' ) -n <NAMESPACE> #can be heavy
kubectl api-resources --namespaced=true

# extracting yamls
kubectl get deployment <DEPLOYMENT_NAME> -n <NAMESPACE> -o yaml
kubectl get pod <POD_NAME> -n <NAMESPACE> -o yaml

# check what can u do in a namespace
kubectl auth can-i --list -n <NAMESPACE>

# view recent events in a namespace
kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp

# list all failing pods
kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded

# get all CronJobs
kubectl get cronjobs -A

# get all DaemonSets
kubectl get daemonsets -A

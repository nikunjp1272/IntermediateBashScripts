# to run "exec" commands in a cluster session manager plugin needs to be installed, to install it follow the steps below
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
session-manager-plugin --version
rm session-manager-plugin.deb

# list clusters in ECS
aws ecs list-clusters --profile <PROFILE-NAME>

# describe service running in a cluster
 aws ecs describe-services --cluster <CLUSTER-NAME> --services <SERVICE-NAME>
 # list all services inside a cluster
 aws ecs list-services --cluster <CLUSTER-NAME> --profile <PROFILE-NAME>

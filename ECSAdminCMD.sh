# to run "exec" commands in a cluster session manager plugin needs to be installed, to install it follow the steps below
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
session-manager-plugin --version
rm session-manager-plugin.deb

# list clusters in ECS
aws ecs list-clusters --profile NOPROD_P

# describe service running in a cluster
 aws ecs describe-services --cluster <cluster-name> --services <service-name>

 # list all services inside a cluster
 aws ecs list-services --cluster clip-noprod-msr-cluster --profile NOPROD_P
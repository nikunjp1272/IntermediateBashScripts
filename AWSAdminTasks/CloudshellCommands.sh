# to list all tags of an ec2 with instance ID
aws ec2 describe-tags --filters "Name=resource-id,Values=i-xxxxxxxxxxxxxxxxx"
aws ec2 describe-tags --filters "Name=resource-id,Values=i-xxxxxxxxxxxxxxxxx" --output table
aws ec2 describe-tags --filters "Name=resource-id,Values=i-xxxxxxxxxxxxxxxxx" --query "Tags[*].{Key:Key,Value:Value}" --output table

# to describe load balancers
aws elbv2 describe-load-balancers --names <your-lb-name> --region <region>

# to describe listeners for a lb
aws elbv2 describe-listeners --load-balancer-arn <LB_ARN> --region <region>

# to describe rules of listener
aws elbv2 describe-rules --listener-arn <Listener_ARN> --region <region>

# to get tgs of a lb
aws elbv2 describe-target-groups --load-balancer-arn <LB_ARN> --region <region>

# to get health of tgs
aws elbv2 describe-target-groups --load-balancer-arn <LB_ARN> --region <region>

# to get the names of ec2s with their IDs
aws ec2 describe-instances --instance-ids  i-xxxxxxxxxxxxxx  --query 'Reservations[*].Instances[*].[InstanceId, Tags[?Key==`Name`].Value | [0]]'  --output text

# to take backup of a dashboard
aws cloudwatch get-dashboard --dashboard-name "YourDashboardName" > YourDashboardName.json

# to take backup of all dashboards
for name in $(aws cloudwatch list-dashboards --query "DashboardEntries[].DashboardName" --output text); do
    aws cloudwatch get-dashboard --dashboard-name "$name" \
        --query DashboardBody \
        --output text > "${name}.json"
done

# restoring dashboard from a json file
aws cloudwatch put-dashboard --dashboard-name MyCustomDashboard --dashboard-body file://my-dashboard-backup.json

# to view all dashboards
aws cloudwatch list-dashboards --output table

# to extract ssm param values
aws ssm get-parameters --name "/somewhere/something" --region "eu-west-1" --with-decryption --query "Parameters[*].{Value:Value}" --output text

# restoring backup from s3
aws s3api list-object-versions --bucket engieit-bis-noprod-backup --prefix sag107/rec/rock/eai/0/backup_Fix_5.tar.gz --query Versions[*].VersionId

# listing alarms excluding keyword "wm1015"
aws cloudwatch describe-alarms --state-value ALARM --query "MetricAlarms[?contains(AlarmName, 'wm1015') == \`false\`].[AlarmName]"  --region eu-west-1

# to check ec2 instances with certain amis
aws ec2 describe-instances --filters "Name=image-id,Values=ami-01,ami-02" --query 'Reservations[*].Instances[*].{InstanceID:InstanceId,OS:ImageId}' --output table

# list AMIs with specific details
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{InstanceID:InstanceId,OS:PlatformDetails,AMI:ImageId}' --filters Name=platform-details,Values="Red Hat Enterprise Linux*","CentOS*" --output table

# connecting to an ECS task
aws ecs execute-command --cluster NAME-OF-CLUSTER --task arn: <TASK ARN> --container NAME-OF-CONTAINER --interactive --command "/bin/sh" --region eu-west-1

# transfer all files from s3 to ec2 or cloudshell
aws s3 cp "s3://somewhere/somedir/" /home/ec2-user/ --recursive


# Get all tags for a specific asg
aws autoscaling describe-tags \
  --query "Tags[?starts_with(Key, 'abc') || starts_with(Key, 'xyz')].[ResourceId, Key, Value]" \
  --output text |
awk -v OFS=',' '{print $1, $2, $3}' > asg_tags.csv


# Check if an IP is tagged to an ENI or resource in AWS
aws ec2 describe-network-interfaces --query "NetworkInterfaces[?PrivateIpAddress=='10.10.10.10' || Association.PublicIp=='10.10.10.10']" --output table

# Check if IP exists or not (Replace <IP> with the IP you're checking)
aws ec2 describe-network-interfaces \
  --query "NetworkInterfaces[?PrivateIpAddresses[?PrivateIpAddress=='<IP>'] || Association.PublicIp=='<IP>'].[NetworkInterfaceId, PrivateIpAddresses[*].PrivateIpAddress, Association.PublicIp, Attachment.InstanceId]" \
  --output table

# check if IP is an elastic IP
aws ec2 describe-addresses --region eu-west-1 \
  --query "Addresses[?PublicIp=='10.131.237.109'].[PublicIp, AllocationId, InstanceId, NetworkInterfaceId]" \
  --output table

# to get the public IP of an ec2 server connecting outside of the AWS env
curl https://checkip.amazonaws.com

# to check a public IP in a NAT gateway
aws ec2 describe-nat-gateways --query "NatGateways[?NatGatewayAddresses[?PublicIp=='IP']].[NatGatewayId, NatGatewayAddresses[*].PublicIp, SubnetId, VpcId]" --output table

# to check a public IP in a NAT gateway with region
aws ec2 describe-nat-gateways --region eu-west-1 \
  --query "NatGateways[?NatGatewayAddresses[?PublicIp=='IP']].[NatGatewayId, SubnetId, VpcId, NatGatewayAddresses[*].PublicIp]" \
  --output table


# Find All NAT Gateways in All Regions
for region in $(aws ec2 describe-regions --query "Regions[].RegionName" --output text); do
  echo "Checking region: $region"
  aws ec2 describe-nat-gateways --region $region \
    --query "NatGateways[?NatGatewayAddresses[?PublicIp=='10.131.237.109']].[NatGatewayId, VpcId, SubnetId]" \
    --output table
done


  aws ec2 describe-network-interfaces \
  --query "NetworkInterfaces[?PrivateIpAddresses[?PrivateIpAddress=='10.131.237.109'] || Association.PublicIp=='10.131.237.109'].[NetworkInterfaceId, PrivateIpAddresses[*].PrivateIpAddress, Association.PublicIp, Attachment.InstanceId]" \
  --output table


# extracting a file with .tar.gz extension
tar -xzvf backup_Fix_8.tar.gz

# viewing the contents of the tar
tar -tzf backup_Fix_8.tar.gz

aws ec2 describe-nat-gateways --region eu-west-1 \
  --query "NatGateways[?NatGatewayAddresses[?PublicIp=='IP']].[NatGatewayId, SubnetId, VpcId, NatGatewayAddresses[*].PublicIp]" \
  --output table


ids="i-091908ca8927d96fb i-0fdfcd194359664bf i-09e3c70519598068a i-06b34d846c8a2c843 i-007a03648ed20ebc2 i-0de1f68ee61ef5c09 i-00791eb2f4e773ca2 i-02a728772d95deb7b i-08c3f75b53c6a352c i-020af2b47d52368a3 i-0007292665160e0e8 i-021a6ee58b15da797 i-092bfed00a67fda5c i-0ce03ff00c0c5d23b i-0193df558a2ce8dbb i-0a52f2123ad0cea50 i-085fe562ce927a6ce i-00b3a43de9b6b2a29 i-054a226767f6f9b2b i-0f58ca0bd73cfafed i-0b140dbb25c1720fb i-0d8f315e0b7373688 i-03367c1791722a6de i-099ee92c2d248f4b2 i-0c494b981ccd5be82 i-02b3c99cb49aa2757 i-0a2904fea9f1dc82c"
aws ec2 describe-instances --instance-ids $ids \
  --query 'Reservations[].Instances[].{ID: InstanceId, Name: Tags[?Key==`Name`]|[0].Value}' \
  --output table


# to know the creation date of any role
aws iam get-role --role-name WSSmyRedshiftRole --query "Role.CreateDate"

# to know when the iam role was last used
aws iam get-role --role-name WSSmyRedshiftRole --query "Role.RoleLastUsed"

aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=Username,AttributeValue=WSSmyRedshiftRole \
  --max-results 1 \
  --query "Events[0].EventTime"

# Run all commands with ec2-user
# Checking Status of amazon-cloudwatch-agent-ctl
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
# OR with systemd
sudo systemctl status amazon-cloudwatch-agent


# Checking config files of amazon-cloudwatch-agent-ctl
cd /opt/aws/amazon-cloudwatch-agent/etc/
ls -lrth


# Checking systemd config of amazon-cloudwatch-agent-ctl
sudo cat /etc/systemd/system/amazon-cloudwatch-agent.service


# Usually the default config file will be:
amazon-cloudwatch-agent.toml OR amazon-cloudwatch-agent.yaml

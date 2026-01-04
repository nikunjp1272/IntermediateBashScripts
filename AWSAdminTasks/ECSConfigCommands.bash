#to check config:
aws application-autoscaling describe-scheduled-actions --service-namespace ecs --resource-id service/octopus-preprod-apigwpriv-cluster/octopus-apigwpriv-service-preprod
aws application-autoscaling describe-scheduled-actions --service-namespace ecs --resource-id service/octopus-preprod-apigwpriv-cluster/octopus-apigwpriv-service-preprod


#to check tasks running on ECS
aws ecs list-tasks --cluster octopus-preprod-apigwpriv-cluster --service-name octopus-apigwpriv-service-preprod


#to check the task definitions and port mappings
aws ecs describe-task-definition --task-definition octopus-apigwpriv-task-preprod:58 --query "taskDefinition.containerDefinitions[0].portMappings"


#to get details of tasks from a service in a cluster
aws ecs describe-tasks --cluster octopus-preprod-apigwpriv-cluster --tasks $(aws ecs list-tasks --cluster octopus-preprod-apigwpriv-cluster --service-name octopus-apigwpriv-service-preprod --query "taskArns[]" --output text) --query "tasks[*].{Task:taskArn, Status:lastStatus, Health:healthStatus, Ports:containers[*].networkBindings, Image:containers[*].image, Started:startedAt}" --output table


#to save the task definition
aws ecs describe-task-definition --task-definition octopus-apigwpriv-task-preprod:58 --query "taskDefinition" > task-def.json


#to change config:
aws application-autoscaling put-scheduled-action \
  --service-namespace ecs \
  --scheduled-action-name octopus-prod-apigwpub-reduce-service \
  --resource-id service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod \
  --scalable-dimension ecs:service:DesiredCount \
  --schedule "cron(30 22 ? * * *)" \
  --timezone "Europe/Paris" \
  --scalable-target-action MinCapacity=2,MaxCapacity=2

aws application-autoscaling put-scheduled-action \
  --service-namespace ecs \
  --scheduled-action-name octopus-prod-apigwpub-reduce-service \
  --resource-id service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod \
  --scalable-dimension ecs:service:DesiredCount \
  --schedule "cron(30 22 ? * * *)" \
  --timezone "Europe/Paris" \
  --scalable-target-action MinCapacity=2,MaxCapacity=2





#OLD config apigwpriv octopus

~ $ aws application-autoscaling describe-scheduled-actions --service-namespace ecs --resource-id service/octopus-prod-apigwpriv-cluster/octopus-apigwpriv-service-prod
{
    "ScheduledActions": [
        {
            "ScheduledActionName": "octopus-prod-apigwpriv-start-service",
            "ScheduledActionARN": "arn:aws:autoscaling:eu-west-1:722052991222:scheduledAction:8324a09f-9a07-41f8-a4d9-f982b68de822:resource/ecs/service/octopus-prod-apigwpriv-cluster/octopus-apigwpriv-service-prod:scheduledActionName/octopus-prod-apigwpriv-start-service",
            "ServiceNamespace": "ecs",
            "Schedule": "cron(00 7 ? * * *)",
            "Timezone": "Europe/Paris",
            "ResourceId": "service/octopus-prod-apigwpriv-cluster/octopus-apigwpriv-service-prod",
            "ScalableDimension": "ecs:service:DesiredCount",
            "ScalableTargetAction": {
                "MinCapacity": 4,
                "MaxCapacity": 6
            },
            "CreationTime": "2024-10-14T14:40:29.973000+00:00"
        },
        {
            "ScheduledActionName": "octopus-prod-apigwpriv-reduce-service",
            "ScheduledActionARN": "arn:aws:autoscaling:eu-west-1:722052991222:scheduledAction:8324a09f-9a07-41f8-a4d9-f982b68de822:resource/ecs/service/octopus-prod-apigwpriv-cluster/octopus-apigwpriv-service-prod:scheduledActionName/octopus-prod-apigwpriv-reduce-service",
            "ServiceNamespace": "ecs",
            "Schedule": "cron(00 22 ? * * *)",
            "Timezone": "Europe/Paris",
            "ResourceId": "service/octopus-prod-apigwpriv-cluster/octopus-apigwpriv-service-prod",
            "ScalableDimension": "ecs:service:DesiredCount",
            "StartTime": "2025-04-17T20:00:00+00:00",
            "ScalableTargetAction": {
                "MinCapacity": 3,
                "MaxCapacity": 3
            },
            "CreationTime": "2024-10-14T14:40:29.965000+00:00"
        }
    ]
}




#NEW config apigwpriv octopus


~ $ aws application-autoscaling describe-scheduled-actions --service-namespace ecs --resource-id service/octopus-prod-apigwpriv-cluster/octopus-apigwpriv-service-prod{
    "ScheduledActions": [
        {
            "ScheduledActionName": "octopus-prod-apigwpriv-start-service",
            "ScheduledActionARN": "arn:aws:autoscaling:eu-west-1:722052991222:scheduledAction:8324a09f-9a07-41f8-a4d9-f982b68de822:resource/ecs/service/octopus-prod-apigwpriv-cluster/octopus-apigwpriv-service-prod:scheduledActionName/octopus-prod-apigwpriv-start-service",
            "ServiceNamespace": "ecs",
            "Schedule": "cron(00 7 ? * * *)",
            "Timezone": "Europe/Paris",
            "ResourceId": "service/octopus-prod-apigwpriv-cluster/octopus-apigwpriv-service-prod",
            "ScalableDimension": "ecs:service:DesiredCount",
            "ScalableTargetAction": {
                "MinCapacity": 4,
                "MaxCapacity": 6
            },
            "CreationTime": "2024-10-14T14:40:29.973000+00:00"
        },
        {
            "ScheduledActionName": "octopus-prod-apigwpriv-reduce-service",
            "ScheduledActionARN": "arn:aws:autoscaling:eu-west-1:722052991222:scheduledAction:8324a09f-9a07-41f8-a4d9-f982b68de822:resource/ecs/service/octopus-prod-apigwpriv-cluster/octopus-apigwpriv-service-prod:scheduledActionName/octopus-prod-apigwpriv-reduce-service",
            "ServiceNamespace": "ecs",
            "Schedule": "cron(00 22 ? * * *)",
            "Timezone": "Europe/Paris",
            "ResourceId": "service/octopus-prod-apigwpriv-cluster/octopus-apigwpriv-service-prod",
            "ScalableDimension": "ecs:service:DesiredCount",
            "ScalableTargetAction": {
                "MinCapacity": 4,
                "MaxCapacity": 6
            },
            "CreationTime": "2024-10-14T14:40:29.965000+00:00"
        }
    ]
}




OLD config apigwpub octopus

~ $ 
~ $ aws application-autoscaling describe-scheduled-actions --service-namespace ecs --resource-id service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod
{
    "ScheduledActions": [
        {
            "ScheduledActionName": "octopus-prod-apigwpub-reduce-service",
            "ScheduledActionARN": "arn:aws:autoscaling:eu-west-1:722052991222:scheduledAction:40454637-4925-47e9-8d98-923fac39d5be:resource/ecs/service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod:scheduledActionName/octopus-prod-apigwpub-reduce-service",
            "ServiceNamespace": "ecs",
            "Schedule": "cron(30 22 ? * * *)",
            "Timezone": "Europe/Paris",
            "ResourceId": "service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod",
            "ScalableDimension": "ecs:service:DesiredCount",
            "StartTime": "2025-04-17T20:30:00+00:00",
            "ScalableTargetAction": {
                "MinCapacity": 1,
                "MaxCapacity": 1
            },
            "CreationTime": "2024-10-15T15:13:48.310000+00:00"
        },
        {
            "ScheduledActionName": "octopus-prod-apigwpub-start-service",
            "ScheduledActionARN": "arn:aws:autoscaling:eu-west-1:722052991222:scheduledAction:40454637-4925-47e9-8d98-923fac39d5be:resource/ecs/service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod:scheduledActionName/octopus-prod-apigwpub-start-service",
            "ServiceNamespace": "ecs",
            "Schedule": "cron(00 23 ? * * *)",
            "Timezone": "Europe/Paris",
            "ResourceId": "service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod",
            "ScalableDimension": "ecs:service:DesiredCount",
            "ScalableTargetAction": {
                "MinCapacity": 2,
                "MaxCapacity": 2
            },
            "CreationTime": "2024-10-15T15:13:48.308000+00:00"
        }
    ]
}


NEW config apigwpub octopus

~ $ aws application-autoscaling describe-scheduled-actions --service-namespace ecs --resource-id service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod{
    "ScheduledActions": [
        {
            "ScheduledActionName": "octopus-prod-apigwpub-reduce-service",
            "ScheduledActionARN": "arn:aws:autoscaling:eu-west-1:722052991222:scheduledAction:40454637-4925-47e9-8d98-923fac39d5be:resource/ecs/service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod:scheduledActionName/octopus-prod-apigwpub-reduce-service",
            "ServiceNamespace": "ecs",
            "Schedule": "cron(30 22 ? * * *)",
            "Timezone": "Europe/Paris",
            "ResourceId": "service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod",
            "ScalableDimension": "ecs:service:DesiredCount",
            "ScalableTargetAction": {
                "MinCapacity": 2,
                "MaxCapacity": 2
            },
            "CreationTime": "2024-10-15T15:13:48.310000+00:00"
        },
        {
            "ScheduledActionName": "octopus-prod-apigwpub-start-service",
            "ScheduledActionARN": "arn:aws:autoscaling:eu-west-1:722052991222:scheduledAction:40454637-4925-47e9-8d98-923fac39d5be:resource/ecs/service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod:scheduledActionName/octopus-prod-apigwpub-start-service",
            "ServiceNamespace": "ecs",
            "Schedule": "cron(00 23 ? * * *)",
            "Timezone": "Europe/Paris",
            "ResourceId": "service/octopus-prod-apigwpub-cluster/octopus-apigwpub-service-prod",
            "ScalableDimension": "ecs:service:DesiredCount",
            "ScalableTargetAction": {
                "MinCapacity": 2,
                "MaxCapacity": 2
            },
            "CreationTime": "2024-10-15T15:13:48.308000+00:00"
        }
    ]
}

# Terraform


## Requirements

- docker
- azure account


## Steps

```
docker run -it -v .:/sandbox jrichardsz/azure-cli-terraform:apine-3.19.1-azcli-2.61.0

az login

terraform init

terraform plan && terraform apply -auto-approve
```

## :warning: Destroy :warning:

```
terraform apply -destroy  -auto-approve
```

## Get principal_id

https://stackoverflow.com/a/57605502/3957754

## References

- https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-get-connection-string
- http://k8s.anjikeesari.com/azure/16-event-hubs-part-2/#task-51-create-shared-access-policy-rule-for-listen
- https://learn.microsoft.com/en-us/answers/questions/1071173/where-can-i-find-storage-account-connection-string
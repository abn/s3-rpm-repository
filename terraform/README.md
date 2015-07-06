# Terraform: S3 YUM Repository

Terraform configuration that deploys an S3 bucket, related roles/policies and an instance with the policy attached. This is based on the write up in this [gist](https://gist.github.com/phrawzty/ca3453addc92a13a9c19).

```sh
terraform plan \
    -var 'access_key=<KEY_ID>' -var 'secret_key=<SECRET>' -var 'bucket=<BUCKET_NAME>'
terraform apply \
    -var 'access_key=<KEY_ID>' -var 'secret_key=<SECRET>' -var 'bucket=<BUCKET_NAME>'
```

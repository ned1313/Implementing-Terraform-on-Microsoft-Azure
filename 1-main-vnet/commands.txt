az account show
az account set --subscription SUB_NAME

terraform init
terraform plan -var resource_group_name=main-vnet -out vnet.tfplan
terraform apply "vnet.tfplan"
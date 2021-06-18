# Terraform 1.0 changes

* Updated the configurations to use the new provider syntax for Terraform 1.0. Added `required_providers` block in the `terraform` block and added the `features{}` block to the Azure provider instances.
* Updated the configurations to use version 2.0 of the Azure RM provider.
* Updated the vnet module to use version 2.X
* Replaced null_resource with local_file resource in 2-sec-vnet
* Created the zz-terraform-vm directory to replace the missing Terraform VM marketplace item (**HEAVY SIGH**)
* Updated the commands.txt files to include a LOT more information, because knowledge is power!
* Added YAML files to 6-azuredevops to run the pipeline with YAML definitions instead of using the classic builder (YAHOO for YAML!)
* Removed the null_resource in 8-app-remote-state to remove the need to use PowerShell, using local_file instead
* Updated the terraform_state data source to use a workspace explicitly
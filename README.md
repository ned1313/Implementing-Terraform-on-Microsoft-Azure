# Implementing-Terraform-on-Microsoft-Azure

Welcome to Implementing Terraform on Microsoft Azure. These exercise files are meant to accompany my course on [Pluralsight](https://app.pluralsight.com/library/courses/implementing-terraform-microsoft-azure/).  The course was developed using version 0.12.10 of Terraform.  As far as I know there are no coming changes that will significantly impact the validity of these exercise files.  But I also don't control all the plug-ins, providers, and modules used by the configurations.

**Update**: Well folks, version 1.0 of Terraform is out and naturally a bunch of stuff has changed since 0.12.10 that broke the configs. Weeeee! I have updated all the configurations to accomodate the changes, but the videos in the course have not yet been updated. What you see in the demo will diverge from what's in the exercise files, but the core concepts remain the same. The current plan is to overhaul the course in the second half of 2021. You can find the changes in the [CHANGELOG](./CHANGELOG.md) file.

## Using the files

Each folder follows in succession as the course progresses. In some cases, you will need to copy files from one directory to another. Assuming you are following along with the course, when to copy the files and where should be fairly obvious. Many of the folders include a `commands.txt` file that has example commands for that portion of the exercise. Other folders may include an example of a file you'll need, for instance the `9-app-deploy` folder has the `terraform.tfvars.example` file. Simply update the values in the file and rename it to `terraform.tfvars`.

Each module in the course builds on the infrastructure created by the previous module. Bearing that in mind, jumping around in the course will be difficult. When you complete a module, you might be tempted to run `terraform destroy` to delete the resources. You can do that, but remember that you will need to deploy the resources again for the next module.

## Terraform Marketplace Item

*Sigh*, the Terraform marketplace item I used in the course has been deprecated and you can't find it anymore. Grrr... You've got two options for that portion of the course.

1. Login to the Azure CLI as the security user on your local desktop and run the commands. This is the "easy" option.
1. I've added a new folder that will deploy the necessary resources using Terraform. It's called `zz-terraform-vm`. Using Terraform to deploy Terraform? Yes! Why not? Check out the `commands.txt` file in that directory for more information.

## Azure DevOps Pipelines Update

Since the release of this course, Azure DevOps Pipelines has moved to a YAML defined pipeline model. You can still build pipelines the "classic" way, but using YAML and storing the pipeline config in source control is preferred. I have created new files in `6-azuredevops` that include the whole pipeline config using the new YAML style.

Follow the directions in the `commands.txt` file in the same directory to follow the process of setting up the YAML based pipelines. It will be different than the video, which will be updated with the rest course in late 2021. I'm also going to add more steps for validation and formatting.

## Course Prerequisites

There are a few prerequisites for working with the course files.

### Visual Studio Code

You are going to want to use Visual Studio Code or a similar code editor. Personally I like VS Code because it's free and cross-platform, and it has source control built-in. But hey, that's just me. You do you.

### Azure Subscription(s)

This is a course all about using Terraform on Microsoft Azure. It is safe to assume you'll need at least one Azure subscription and the **Owner** or **Co-administrator** role on that subscription. The exercises use two subscriptions - one for networking and another for security - to demonstrate multiple instances of the AzureRM provider.

You don't have to use two separate subscriptions, instead you could use the same subscription for all the exercises. I haven't tested that, and some of the automatic role creation might fail. It's probably just as easy to create an extra subscription and delete it when you are done the course.

### Azure Active Directory Rights

The course includes use of the AzureAD provider, and it assumes that you have permissions to create Service Principals within the Azure AD tenant associated with your Azure subscriptions. Assuming you created subscriptions and an Azure AD tenant for this course, then you shouldn't have any problems.

### Azure DevOps Subscription

The course also makes use of Azure DevOps Repos and Pipelines. The basic Azure DevOps plan is free for up to five users. You will also need to add the [Terraform Build & Release Tasks](https://marketplace.visualstudio.com/items?itemName=charleszipp.azure-pipelines-tasks-terraform) extension from the Visual Studio Marketplace.


## MONEY!!!

A gentle reminder about cost. The course will have you creating resources in Azure.  Some of the resources are not going to be 100% free. I have tried to use free resources when possible, but Azure VMs, Azure Storage, and App Service all cost money. We're probably talking a couple dollars for the duration of the exercises, but it won't be zero.

Each module builds on the previous one to create a complete deployment for the Globomantics scenario. As I mentioned before, destroying the resources after each module will make things more difficult. For that reason, I waited until the last module to deploy any actual Azure VMs or App Services. Those are the things that will actually cost you money. Once you complete the course, I highly recommend tearing everything down with `terraform destroy` or by deleting the Resource Groups in Azure.

## Conclusion

I hope you enjoy taking this course as much as I did creating it.  I'd love to hear feedback and suggestions for revisions. Log an issue on this repo or hit me up on [Twitter](https://twitter.com/ned1313).

Thanks and happy automating!

Ned
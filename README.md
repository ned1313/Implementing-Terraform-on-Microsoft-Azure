# Implementing-Terraform-on-Microsoft-Azure

Welcome to Implementing Terraform on Microsoft Azure. These exercise files are meant to accompany my course on [Pluralsight](https://app.pluralsight.com/library/courses/implementing-terraform-microsoft-azure/).  The course was developed using version 0.12.10 of Terraform.  As far as I know there are no coming changes that will significantly impact the validity of these exercise files.  But I also don't control all the plug-ins, providers, and modules used by the configurations.

## Using the files

Each folder follows in succession as the course progresses. In some cases, you will need to copy files from one directory to another. Assuming you are following along with the course, when to copy the files and where should be fairly obvious. Many of the folders include a `commands.txt` file that has example commands for that portion of the exercise. Other folders may include an example of a file you'll need, for instance the `9-app-deploy` folder has the `terraform.tfvars.example` file. Simply update the values in the file and rename it to `terraform.tfvars`.

Each module in the course builds on the infrastructure created by the previous module. Bearing that in mind, jumping around in the course will be difficult. When you complete a module, you might be tempted to run `terraform destroy` to delete the resources. You can do that, but remember that you will need to deploy the resources again for the next module.

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

I hope you enjoy taking this course as much as I did creating it.  I'd love to hear feedback and suggestions for revisions. Log an issue on this repo or hit me up on Twitter.

Thanks and happy automating!

Ned
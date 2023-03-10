# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. **Create Policy** : Run command **az policy definition create az policy definition create --name 'your-policy-name' --description 'Your description' --subscription <Your subscription> --mode ALL --rules "{ Input your definition rule here}"** To create the policy. To know how to input format you can use command **az policy definition create --help**. After you finish create policy, run following command next **az policy assignment create --name 'policy-assignment-name' --policy 'your-policy-name'**.

2. **Building Packer Image**: Modify the server.json in the folder with your information include *client_id*, *client_secret* and *subcription_id*, remember to check the **location** and **vm_size** then run **packer build yourjsonfile.json**. When the building process finish, run **az image list** to verify image information 

3. **Deploy Infrastructure**: Create the folder for building infrastructure first, next create three files include **vars.tf** for specifing the variable, **main.tf** for specifying components of the infrastructure and **providers.tf** for specifying the providers. When you finish your work, run the following commands:
- terraform init (Initialize the workspace)
- terraform validate (Check the syntax)
- terraform plan -out yourfilename.plan (Check the components will be created before deploy)
- terraform apply yourfilename.plan (Deploy the plan you create)

**Note**: About the **vars.tf** file, this is the file where you can specified and customize your variable based on demand your infrastructure and that will apply to your configuration when running **terraform apply**. For example, if you want to increase or decrease the number of VM, you can change the variable **counts** into the number you want.

**Remember**  to run the command **terraform plan** before command **terraform apply** to make sure the component will be created correctly. 

### Output
#### After finish all these steps above:
1. Check the policy by go to the Portal then type "Policy" in search box 
2. Also the image, go to the Portal Azure then search Images and check out your result
3. Check all components of based on your configuration  


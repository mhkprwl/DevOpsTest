### 1) What are different artifacts you need to create - name of the artifacts and its purpose

        >> Build Pipeline should publish 1 artifact that would be having the Terraform files from the source directory.
        >> Purpose of these Artifact is to use the same terraform files (published from a approved build pipeline) while running the Release Pipeline.
        
### 2) List the tools you will to create and store the Terraform templates
        
        >> Terraform templates or the terraform files (*.tf/*.auto.tfvars) could be created using any IDE
        >> I would recommend to use Visual Studio Code

### 3) Explain the process and steps to create automated deployment pipeline
        
        Scenario : We want to publish a .Net Application to Azure WebApp
        
        >> CI Pipeline:

        1. Draft your application build pipeline using the required tasks ( Restore, Build, Test and Publish)
        2. Add a new task to Copy the Terraform Files to Artifacts staging directory.
        3. Add two new task - Terraform Init and Terraform Plan.
        3. Publish the Artifacts and it would cover both your .zip file and terraform files for source directory.

        >> CD Pipeline:

        1. Create a Release pipeline pointing to the Build pipeline created in above step. Hence it would take artifacts form build pipeline.
        2. Enable the Pre-Deployment Approvals, so that the Approver/s could check the build Pipleline output/artifacts and approves it he/she/they finds it perfect.
        3. Using Az CLI/Powershell task create resource group, storage account and container for storing the terraform state file (remote storage)
        4. Ensure that the build agents have terraform installed or install it by using terraform installer task.
        5. Add terraform init task to instantiate/download the required providers as mentioned in the .tf file.
        6. Add terraform plan task to check on the changes to be performed on cloud infrastructure.
        7. Add terrafrom apply task to create the infrastructure resources as mentioned in the .tf file.
        8. Use the Deploy WebApp task to create the deployment in Azure using the artifact (.zip) fetched from the build pipeline.
        
        Note: Authentication for Deploying the resources in Cloud from Azure Devops would be done using Service Connection.
        
### 4) Create a sample Terraform template you will use to deploy Below services: VNET - 2 Subnet - NSG to open port 80 and 443 - 1 Window VM in each subnet - 1 Storage account
       
       >> Check the Terraform Folder.

### 5) Explain how will you access the password stored in Key Vault and use it as Admin Password in the VM Terraform template
       
       >> Actual Flow:
          
          Password creation using random_string resource --> Pushing the Password as secret in AKV --> Referencing the Passowrd created by random_string resource in azurerm_windows_virtual_machine resource
          
          Referance :  admin_password      = random_string.webvmpassword.result
                       admin_password      = random_string.appvmpassword.result

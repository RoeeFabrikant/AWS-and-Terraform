1. fill the *.tfvars file

2. Run the following commandes from the 'Terraform' folder where *.tf and *.tfvars files are
    terraform init
    terraform validate
    terraform plan -out terafform_plan.tfplan -var-file="your_tfvars_file_name"
    terraform apply "terafform_plan"
    
3. to destroy the configuration run:
    terraform destroy -var-file="your_tfvars_file_name"

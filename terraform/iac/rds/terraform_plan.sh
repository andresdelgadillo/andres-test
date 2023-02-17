#!/bin/bash

# This script executes a terraform plan using the environment pass in the first parameter

# Make sure this script is executed from the folder "infrastructure/iac/instances/"
# Pass the environment values as a parameter, e.g: bash terraform_plan.sh dev

# This script will executes the following steps:
# - Execute terraform init command: terraform init -backend-config="backends/ENV.conf"
# - Select/create the CIL workspace: terraform workspace select dev
# - Execute the terraform plan: terraform plan -var-file="../env-vars/ENV.tfvars" -out pending-changes-ENV


initial_datetime=$(date)
echo "Process started at "$initial_datetime"..."

ENVIRONMENT=$1
ACCOUNT_ID="$(aws sts get-caller-identity --query "Account" --output text)"
echo "Account ID: "$ACCOUNT_ID

# Verify if the environment and AWS credentials were set correctly
if [ -z "$ENVIRONMENT" ] ; then
    echo "Environment not defined"
    exit 1
elif [ $ENVIRONMENT == 'sandbox' ] && [ $ACCOUNT_ID == '416572346136' ] ; then
    echo "Environment: "$ENVIRONMENT
elif [ $ENVIRONMENT == 'prod' ] && [ $ACCOUNT_ID == '111111111111' ] ; then
    echo "Environment: "$ENVIRONMENT
else
    echo "ERROR - Environment or AWS credentials are not valid. Environment used: "$ENVIRONMENT
    exit 1
fi


echo "`date +%Y-%m-%d-%H-%M-%S` - Setting up backend (terraform init)..."
terraform init -backend-config=backends/$ENVIRONMENT.conf -reconfigure

echo "`date +%Y-%m-%d-%H-%M-%S` - Select the Terraform Workspace: "$ENVIRONMENT
terraform workspace select $ENVIRONMENT  || terraform workspace new $ENVIRONMENT

echo "`date +%Y-%m-%d-%H-%M-%S` - Execute terraform plan for current workspace: "$ENVIRONMENT
terraform plan -var-file="../../env-vars/$ENVIRONMENT.tfvars" -out pending-changes-$ENVIRONMENT

finish_datetime=$(date)
echo "Process finished at "$finish_datetime"..."
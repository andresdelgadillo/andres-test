#!/bin/bash

# This script executes a terraform plan using the environment pass in the first parameter

# Make sure you meet the following two requirements
# - Switch to the branch cil-deployment
# - Enter in the folder infrastructure/iac/networking/

# This script will executes the following:
# - Execute terraform apply: terraform apply pending-changes-ENV

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

echo -e "`date +%Y-%m-%d-%H-%M-%S` - Execute terraform apply for current workspace: "$ENVIRONMENT"\n\n"
echo -e "WARNING - THIS WILL APPLY THE CHANGES DESCRIBED IN \"pending-changes-$ENVIRONMENT\"!!!\n\n"
while true; do
    read -p "Do you wish to continue? " yn
    case $yn in
        [Yy]* ) echo ""; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

terraform apply pending-changes-$ENVIRONMENT

finish_datetime=$(date)
echo "Process finished at "$finish_datetime"..."
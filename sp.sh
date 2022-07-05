#!/usr/bin/env bash
# Don't run this.  Just a reminder
az group create -n AzureDev -l australiaeast

RGID=$(az group show --name AzureDev --output tsv --query 'id')

az ad sp create-for-rbac --name githubSP --role contributor --scopes $RGID --sdk-auth

# az group delete --name AzureDev
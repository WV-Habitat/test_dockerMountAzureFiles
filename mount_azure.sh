RESOURCE_GROUP_NAME="HabitatNature-Prod"
STORAGE_ACCOUNT_NAME="hnatprojets"
FILE_SHARE_NAME="projet-et-database"

MNT_PATH="/root/data"

sudo mkdir -p $MNT_PATH

az login

# This command assumes you have logged in with az login
HTTP_ENDPOINT=$(az storage account show --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --query "primaryEndpoints.file" --output tsv | tr -d '"')
SMB_PATH=$(echo $HTTP_ENDPOINT | cut -c7-${#HTTP_ENDPOINT})$FILE_SHARE_NAME

STORAGE_ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv | tr -d '"')

sudo mount -t cifs $SMB_PATH $MNT_PATH -o vers=3.1.1,sec=ntlmsspi,username=$STORAGE_ACCOUNT_NAME,password=$STORAGE_ACCOUNT_KEY,serverino,nosharesock,actimeo=30,mfsymlinks

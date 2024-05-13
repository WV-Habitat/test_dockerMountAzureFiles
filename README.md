# Test mounting Azure file storage on Docker

This file describes the main outcomes from the exploration on how to mount the Azure File Storage in a Docker image.

## Build the Docker image

```bash
docker build -t testazure .
```

## Run the image

We have to run the image in `--privileged` mode to be able to mount the Azure File Storage:

```bash
docker run --privileged -it testazure bash
```

If the previous command worked, you should now be in the root of the Ubuntu Docker image.
To mount the Azure File Storage within the image, run the following script:

```bash
bash mount_azure.sh
```

Follow the steps to login with your Microsoft account, and the mounting process will automatically start after login.

## Error 115

Our attempt to mount a new disk gets the following error:

```bash
mount error(115): Operation now in progress
Refer to the mount.cifs(8) manual page (e.g. man mount.cifs) and kernel log messages (dmesg)
```

The description of this error from this [link](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-storage/files/connectivity/files-troubleshoot-smb-connectivity?tabs=linux#error115):

> **Cause**<br>
> Some Linux distributions don't yet support encryption features in SMB 3.x. Users might receive a "115" error message if they try to mount Azure Files by using SMB 3.x because of a missing feature. SMB 3.x with full encryption is supported only on the latest version of a Linux distro.<br>
> **Solution**<br>
> The encryption feature for SMB 3.x for Linux was introduced in the 4.11 kernel. This feature enables the mounting of an Azure file share from on-premises or a different Azure region. Some Linux distributions may have backported changes from the 4.11 kernel to older versions of the Linux kernel that they maintain. To help determine if your version of Linux supports SMB 3.x with encryption, consult with Use Azure Files with Linux.<br>
> If your Linux SMB client doesn't support encryption, mount Azure Files using SMB 2.1 from a Linux VM that's in the same Azure datacenter as the file share. Verify that the Secure transfer required setting is disabled on the storage account.

## Troubleshoot Azure Files

I will follow the steps described in this [link](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-storage/files/connectivity/files-troubleshoot?tabs=bash#error-53-error-67-or-error-87-when-you-mount-or-unmount-an-azure-file-share) to isolate the above issue.

### Check DNS resolution and connectivity to your Azure file share

Issue related to any of the SMB, NFS, and FileREST protocols.

```bash
nslookup hnatprojets.file.core.windows.net
```

The output seems correct.

### Check TCP connectivity

```bash
nc -zvw3 hnatprojets.file.core.windows.net 445
```

We get the following message:

```bash
nc: connect to hnatprojets.file.core.windows.net (20.38.121.136) port 445 (tcp) timed out: Operation now in progress
```

## AzFile diagnostics

I am running the diagnostic script from this [link](https://github.com/Azure-Samples/azure-files-samples/tree/master/AzFileDiagnostics/Linux).

```bash
curl https://raw.githubusercontent.com/Azure-Samples/azure-files-samples/master/AzFileDiagnostics/Linux/AzFileDiagnostics.sh -o azdiag.sh
sudo bash azdiag.sh -u //hnatprojets.file.core.windows.net/projet-et-database
```

The output from the diagnostics that gets stuck when testing the TCP port 445 connection is as follows:

```
2024-05-13T20:52:34.862Z Checking: Create a folder MSFileMountDiagLog to save the script output

2024-05-13T20:52:34.903Z Checking: Client running with Ubuntu version 22.04, kernel version is 5.15.146.1-microsoft-standard-WSL2

2024-05-13T20:52:34.910Z Checking: Check if the dependencies for this script are installed

2024-05-13T20:52:34.911Z Checking: All dependencies for the script are installed

2024-05-13T20:52:34.912Z Checking: Check if cifs-utils is installed
2024-05-13T20:52:34.915Z cifs-utils is already installed on this client

2024-05-13T20:52:34.916Z Checking: Check if keyutils is installed
2024-05-13T20:52:34.917Z Keyutils is already installed!

2024-05-13T20:52:34.918Z Checking: Check if client has at least SMB2.1 support
2024-05-13T20:52:34.919Z System supports SMB2.1

2024-05-13T20:52:34.920Z Checking: Check if client has SMB 3 Encryption support
2024-05-13T20:52:34.922Z System supports SMB version 3
2024-05-13T20:52:34.924Z System supports SMB version 3.1.1

2024-05-13T20:52:34.925Z Checking: Check if client has been patched with the recommended kernel update for idle timeout issue  
2024-05-13T20:52:34.927Z Kernel has been patched with the fixes that prevent idle timeout issues

2024-05-13T20:52:34.928Z Checking: Check if client has any connectivity issue with storage account

2024-05-13T20:52:34.929Z Storage account FQDN is hnatprojets.file.core.windows.net
2024-05-13T20:52:34.930Z Getting the Iptables policies
2024-05-13T20:52:34.934Z Test the storage account IP connectivity over TCP port 445
```

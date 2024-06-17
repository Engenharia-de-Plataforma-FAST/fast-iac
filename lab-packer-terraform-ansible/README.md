# FAST - Bootcamp de Enhenharia de Plataforma

- [FAST - Bootcamp de Enhenharia de Plataforma](#fast)
  - [1. Download GCP credentials](#1-download-gcp-credentials)
  - [2. Edit parameters](#2-edit-parameters)
  - [3. Allow SSH](#3-allow-ssh)
  - [4. Create the image](#4-create-the-image)
  - [5. Create the infrastructure](#5-create-the-infrastructure)
  - [6. Destroy the infrastructure](#6-destroy-the-infrastructure)
  - [7. Clean](#7-clean)

## 1. Download GCP credentials

Download the GCP service account key from your GCP project, rename it to `credential.json` and copy it to the `packer` and also `terraform` folders.

## 2. Edit parameters

Edit packer parameters within `packer/variables.pkrvars.hcl` with your public key hash and your private key path. Also, change your project ID (you can get it from GCP main dashboard).

Do the same within `terraform/input.tfvars`, but this time the project number is needed (you can also get it from GCP main dashboard).

## 3. Allow SSH

Since we will be using the `default` network, ensure the network has a firewall rule to allow SSH to your IP address or anyone (0.0.0.0/0). The rule should be created with network tag = `allow-ssh`.

## 4. Create the image

```
cd packer
./run.sh
```

## 5. Create the infrastructure

```
cd terraform
./deploy.sh
```

## 6. Destroy the infrastructure

After finishing the lab, remove the infra to avoid unnecessary costs.

```
cd terraform
./destroy.sh
```

Confirm with a `yes`.

## 7. Clean

Clean terraform files if you wish to start a fresh new lab. In case you will maintain the infra, DON'T do this, since the `tfstate` files will be remoevd.

```
cd terraform
./clean.sh
```

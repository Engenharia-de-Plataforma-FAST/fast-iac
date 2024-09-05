# FAST - Bootcamp de Enhenharia de Plataforma

- [FAST - Bootcamp de Enhenharia de Plataforma](#fast---bootcamp-de-enhenharia-de-plataforma)
  - [1. Download AWS credentials](#1-download-aws-credentials)
  - [2. Edit parameters](#2-edit-parameters)
  - [3. Create the image](#3-create-the-image)
  - [4. Create the infrastructure](#4-create-the-infrastructure)
  - [5. Destroy the infrastructure](#5-destroy-the-infrastructure)
  - [6. Clean](#6-clean)

## 1. Download AWS credentials

Create an IAM user and also the CLI secret and access keys. Then, run `aws configure --profile batatinha` to setup your access. Remember to install aws-cli into your laptop first.

## 2. Edit parameters

Edit packer parameters within `packer/variables.pkrvars.hcl` with your public key hash and your private key path.

Do the same within `terraform/variables.tf`.

## 3. Create the image

```shell
cd packer
./run.sh
```

## 4. Create the infrastructure

With the created AMI on step 3, change the `instance_ami` variable within the `terraform/variables.tf` file and then run:

```shell
cd terraform
./deploy.sh
```

## 5. Destroy the infrastructure

After finishing the lab, remove the infra to avoid unnecessary costs.

```shell
cd terraform
./destroy.sh
```

Confirm with a `yes`.

## 6. Clean

Clean terraform files if you wish to start a fresh new lab. In case you will maintain the infra, DON'T do this, since the `tfstate` files will be removed.

```shell
cd terraform
./clean.sh
```

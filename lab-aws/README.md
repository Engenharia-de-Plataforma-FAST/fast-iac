# FAST IaC Labs - Caminho de Aprendizado de Infraestrutura como Código

## Visão Geral

Laboratórios completos de Infraestrutura como Código usando Terraform, Packer e Ansible para construir e implantar infraestrutura AWS. Este repositório contém 5 laboratórios progressivos que ensinam práticas modernas de DevOps para provisionamento de infraestrutura, gerenciamento de configuração e construção de imagens.

## Pré-requisitos

Antes de iniciar os laboratórios, certifique-se de ter as seguintes ferramentas instaladas e configuradas:

### Instalação das Ferramentas Necessárias

#### AWS CLI
```bash
# macOS
brew install awscli

# Ubuntu/Debian
sudo apt update && sudo apt install awscli

# Ou usando pip
pip install awscli
```

#### Terraform (recomendado: usar tfenv)
```bash
# Instalar tfenv (gerenciador de versão do Terraform) - RECOMENDADO
# macOS
brew install tfenv

# Ubuntu/Debian
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Instalar e usar a versão mais recente do Terraform
tfenv install latest
tfenv use latest

# Alternativa: Instalação direta
# macOS
brew install terraform

# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Uso Rápido do tfenv:**
```bash
# Listar versões disponíveis
tfenv list-remote

# Instalar versão específica
tfenv install 1.12.0

# Trocar versões
tfenv use 1.12.0

# Instalar versão do arquivo .terraform-version
tfenv install
```

#### Ansible
```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt update && sudo apt install ansible

# CentOS/RHEL
sudo yum install ansible

# Ou usando pip
pip install ansible
```

#### Packer
```bash
# macOS
brew install packer

# Ubuntu/Debian
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update && sudo apt install packer

# Ou baixar de https://www.packer.io/downloads
```

### Configuração AWS

Configure suas credenciais AWS com perfis:
```bash
# Configurar AWS CLI com um perfil nomeado
aws configure --profile batatinha

# Digite quando solicitado:
# AWS Access Key ID: sua-chave-de-acesso
# AWS Secret Access Key: sua-chave-secreta
# Default region name: us-east-1
# Default output format: json

# Use o perfil nos comandos
aws s3 ls --profile batatinha
aws sts get-caller-identity --profile batatinha

# Ou defina como padrão para a sessão
export AWS_PROFILE=batatinha

# Alternativa: Definir variáveis de ambiente diretamente
export AWS_ACCESS_KEY_ID="sua-chave-de-acesso"
export AWS_SECRET_ACCESS_KEY="sua-chave-secreta"
export AWS_DEFAULT_REGION="us-east-1"
```

### Configuração de Chave SSH (Obrigatório apenas para Packer)

**Nota:** Chaves SSH são necessárias apenas para o Lab 3 (criação de AMI com Packer). O Terraform cria suas próprias chaves automaticamente para os Labs 1, 2, 4 e 5.

**Por que o Packer precisa de uma chave SSH:**
- O Packer usa SSH para conectar à instância EC2 temporária durante a construção da AMI
- O Ansible (via Packer) precisa de acesso SSH para configurar a instância
- Após a criação da AMI, a chave não é necessária para execução de instâncias

Gerar par de chaves SSH para Packer:
```bash
# Gerar chave ED25519 (recomendado)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519

# Ou chave RSA
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# A chave será usada no Lab 3 ao executar:
# cd packer && ./build.sh
```

### Verificação

Verifique se todas as ferramentas estão instaladas corretamente:
```bash
# Verificar versões
aws --version
terraform --version
ansible --version
packer --version

# Testar conectividade AWS com perfil
aws sts get-caller-identity --profile batatinha

# Ou se AWS_PROFILE estiver definido
export AWS_PROFILE=batatinha
aws sts get-caller-identity
```

## Estrutura do Projeto

```
lab-aws/
├── README.md                    # Documentação principal (este arquivo)
├── terraform/
│   ├── infra-01/                # Infraestrutura básica de EC2 única
│   │   ├── provision.sh         # Script de provisionamento de infraestrutura
│   │   ├── destroy.sh           # Script de limpeza
│   │   ├── clean.sh             # Script de limpeza de estado
│   │   ├── bootstrap.sh         # Script de user data do EC2
│   │   ├── main.tf              # Configuração principal do Terraform
│   │   ├── variables.tf         # Definições de variáveis
│   │   ├── outputs.tf           # Valores de saída
│   │   ├── network.tf           # VPC, subnets, configurações de gateway
│   │   ├── security.tf          # Grupos de segurança e regras
│   │   └── instance.tf          # Configuração da instância EC2
│   └── infra-02/                # Infraestrutura enterprise multi-AZ
│       ├── provision.sh         # Script de provisionamento de infraestrutura
│       ├── destroy.sh           # Script de limpeza
│       ├── clean.sh             # Script de limpeza de estado
│       ├── bootstrap.sh         # Script de user data do EC2
│       ├── main.tf              # Configuração principal do Terraform
│       ├── variables.tf         # Definições de variáveis
│       ├── outputs.tf           # Valores de saída
│       ├── network.tf           # VPC, subnets, gateways
│       ├── security.tf          # Grupos de segurança
│       ├── bastion.tf           # Configuração do bastion host
│       ├── private_instances.tf # Servidores web privados
│       └── load_balancer.tf     # Application Load Balancer
├── ansible/
│   ├── configure.sh             # Script de execução do Ansible
│   ├── inventory.ini            # Configuração do inventário de hosts
│   ├── requirements.yml         # Dependências de coleções do Ansible
│   ├── main.yml                 # Playbook principal
│   ├── config-server.yml        # Tarefas de configuração do servidor
│   ├── handlers/
│   │   └── main.yml             # Manipuladores de eventos
│   ├── templates/
│   │   ├── docker-compose.yml.j2  # Template do Docker Compose
│   │   └── index.html.j2        # Template do website
│   └── vars/
│       └── vars.yml             # Definições de variáveis
└── packer/
    ├── build.sh                 # Script de construção de AMI
    ├── main.pkr.hcl            # Configuração principal do Packer
    └── variables.pkr.hcl       # Definições de variáveis
```

## Lab 1: Provisionamento Básico de Infraestrutura

**Objetivo:** Implantar infraestrutura básica da AWS usando Terraform

**Duração:** 20-30 minutos  
**Custo:** Gratuito (usando AWS Free Tier)

### O que Você Vai Construir
- VPC com subnet pública (10.0.0.0/16)
- Instância EC2 (t2.micro) com Amazon Linux 2023
- Internet Gateway e roteamento
- Grupos de Segurança (SSH:22, HTTP:80)
- Par de chaves SSH para acesso

### Recursos Criados
- 1 VPC
- 1 Subnet Pública
- 1 Internet Gateway
- 1 Tabela de Rotas
- 1 Instância EC2
- 1 Grupo de Segurança
- 1 Par de Chaves SSH

### Instruções
```bash
cd terraform/infra-01
./provision.sh
# Siga os prompts para confirmar a criação da infraestrutura
```

### Verificação
```bash
# Obter IP da instância
terraform output instance_public_ip

# Testar conectividade
curl http://<INSTANCE_IP>
# Deve retornar: 403 Forbidden (esperado - ainda não há servidor web)
```

### Limpeza
```bash
./destroy.sh
```

## Lab 2: Configuração do Servidor com Ansible

**Objetivo:** Configurar a instância EC2 com Docker e implantar um website containerizado

**Duração:** 10-15 minutos  
**Pré-requisitos:** Lab 1 completo

### O que Você Vai Configurar
- Instalação do Docker Engine
- Configuração do Docker Compose v2
- Implantação de container Nginx
- Website customizado com informações do lab
- Monitoramento de saúde

### Serviços Implantados
- Daemon do Docker
- Servidor web Nginx (containerizado)
- Website HTML customizado
- Verificações de saúde do container

### Instruções
```bash
# Certifique-se de que a infraestrutura do Lab 1 esteja executando
cd terraform/infra-01
terraform output instance_public_ip

# Configurar o servidor
cd ../../ansible
# Editar inventory.ini com o IP da sua instância
./configure.sh
```

### Verificação
```bash
# Acessar o website
curl http://<INSTANCE_IP>
# Deve retornar: Página HTML customizada com informações do lab
```

## Lab 3: Criação de AMI Customizada com Packer

**Objetivo:** Criar uma AMI customizada com Docker e website pré-configurados usando Packer e Ansible

**Duração:** 15-20 minutos  
**Pré-requisitos:** Chave SSH disponível

### O que Você Vai Criar
- AMI customizada baseada no Amazon Linux 2023
- Docker e Docker Compose pré-instalados
- Implantação de website pré-configurada
- Otimizada para inicialização rápida de instâncias

### Processo de Construção
- Packer inicia instância EC2 temporária
- Ansible configura a instância (mesmo playbook do Lab 2)
- Packer cria snapshot da AMI
- Instância temporária é terminada

### Instruções
```bash
cd packer
./build.sh
# Digite o caminho da chave SSH quando solicitado (padrão: ~/.ssh/id_ed25519)
# Anote o ID da AMI da saída
```

### Saída
- Nome da AMI customizada (ex: fast-web-server-20250119123456)
- ID da AMI (ex: ami-0123456789abcdef0)
- AMI será marcada com informações do projeto
- Nota: Você usará o **nome** da AMI (não o ID) nos Labs 4 e 5

## Lab 4: Implantação com AMI Customizada (Básico)

**Objetivo:** Implantar infraestrutura básica usando a AMI customizada criada no Lab 3

**Duração:** 10-15 minutos  
**Pré-requisitos:** Lab 3 completo (AMI customizada criada)

### O que É Diferente
- Usa AMI customizada em vez do Amazon Linux padrão
- Website inicia automaticamente na inicialização
- Nenhuma configuração adicional necessária
- Tempo de implantação mais rápido

### Instruções
```bash
cd terraform/infra-01

# Usar AMI customizada por nome (não ID)
INSTANCE_AMI=fast-web-server-* AMI_OWNER=self ./provision.sh
# O wildcard (*) corresponde ao timestamp, encontrando sua AMI mais recente

# Ou especificar nome exato se você tiver múltiplas
INSTANCE_AMI=fast-web-server-20250119123456 AMI_OWNER=self ./provision.sh
```

### Verificação
```bash
# Obter IP da instância
terraform output instance_public_ip

# Testar website (deve estar disponível imediatamente)
curl http://<INSTANCE_IP>
# Deve retornar: Página HTML customizada sem configuração adicional
```

## Lab 5: Implantação Enterprise com AMI Customizada

**Objetivo:** Implantar infraestrutura de nível enterprise usando a AMI customizada com alta disponibilidade e segurança

**Duração:** 25-35 minutos  
**Custo:** ~$48/mês (destruir após o laboratório)  
**Pré-requisitos:** Lab 3 completo (AMI customizada criada)

### O que Você Vai Construir
- Arquitetura VPC multi-AZ (10.0.0.0/16)
- Subnets públicas: 10.0.1.0/24, 10.0.4.0/24
- Subnets privadas: 10.0.2.0/24, 10.0.3.0/24
- Application Load Balancer
- 2 servidores web em subnets privadas
- Bastion host para acesso seguro
- NAT Gateway para internet de saída

### Recursos Criados
- 1 VPC
- 4 Subnets (2 públicas, 2 privadas)
- 1 Internet Gateway
- 1 NAT Gateway
- 1 Application Load Balancer
- 3 Instâncias EC2 (2 servidores web + 1 bastion)
- 3 Grupos de Segurança
- Múltiplas tabelas de rotas

### Instruções
```bash
cd terraform/infra-02

# Usar AMI customizada por nome (não ID)
INSTANCE_AMI=fast-web-server-* AMI_OWNER=self ./provision.sh
# O wildcard (*) corresponde ao timestamp, encontrando sua AMI mais recente

# Ou especificar nome exato se você tiver múltiplas
INSTANCE_AMI=fast-web-server-20250119123456 AMI_OWNER=self ./provision.sh
```

### Padrões de Acesso
```bash
# Obter URL do load balancer
terraform output load_balancer_url

# Acessar website via load balancer
curl http://<ALB_DNS_NAME>

# SSH para bastion host
terraform output ssh_bastion_command

# SSH para servidores web via bastion
terraform output ssh_web_server_1_command
terraform output ssh_web_server_2_command
```

### Limpeza
```bash
./destroy.sh
# Importante: Destruir para evitar cobranças do NAT Gateway e Load Balancer
```

## Principais Resultados de Aprendizado

Após completar todos os laboratórios, você entenderá:

### Terraform
- Princípios de Infraestrutura como Código
- Dependências de recursos e gerenciamento de estado
- Configuração de variáveis e saídas
- Implantações multi-ambiente
- Configuração do provider AWS

### Ansible
- Automação de gerenciamento de configuração
- Estrutura de playbooks e tarefas
- Processamento de templates com Jinja2
- Gerenciamento de inventário
- Operações idempotentes

### Packer
- Fluxos de trabalho de criação de AMI customizada
- Construções multi-provisionador
- Integração com ferramentas de gerenciamento de configuração
- Estratégias de otimização de imagens

### Arquitetura AWS
- Design de VPC e networking
- Configurações de grupos de segurança
- Balanceamento de carga e alta disponibilidade
- Padrões de bastion host
- Estratégias de subnets públicas vs privadas

## Variáveis de Ambiente

Todos os scripts suportam customização por variáveis de ambiente:

```bash
# Configuração AWS com perfil
AWS_PROFILE=batatinha REGION=us-east-1 ./provision.sh

# Marcação de Recursos
AWS_PROFILE=batatinha ENVIRONMENT=prod OWNER="Minha Equipe" ./provision.sh

# Uso de AMI Customizada (usar padrão de nome, não ID da AMI)
AWS_PROFILE=batatinha INSTANCE_AMI=fast-web-server-* AMI_OWNER=self ./provision.sh

# Ou exportar perfil para todos os comandos
export AWS_PROFILE=batatinha
./provision.sh
```

## Solução de Problemas

### Problemas Comuns

**Conflitos de Estado do Terraform**
```bash
# Se o estado estiver bloqueado
terraform force-unlock <LOCK_ID>
```

**Problemas de Conexão SSH**
```bash
# Corrigir permissões da chave
chmod 400 ~/.ssh/id_ed25519

# Testar conectividade SSH
ssh -i caminho/para/chave ec2-user@<IP>
```

**Falhas na Construção do Packer**
```bash
# Garantir que a VPC padrão existe
aws ec2 create-default-vpc --profile batatinha

# Verificar se a chave SSH existe
ls -la ~/.ssh/id_ed25519*
```

**Problemas de Conexão do Ansible**
```bash
# Testar conectividade do ansible
ansible -i inventory.ini all -m ping

# Verificar configuração do inventário
cat inventory.ini
```

## Otimização de Custos

**Labs do Free Tier (1, 2, 4):**
- Use apenas instâncias t2.micro
- Mantenha-se dentro do limite de 750 horas/mês
- Destrua recursos quando não estiver usando

**Labs Pagos (5):**
- NAT Gateway: ~$32/mês
- Application Load Balancer: ~$16/mês
- Sempre destrua após a conclusão



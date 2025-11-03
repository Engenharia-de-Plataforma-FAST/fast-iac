# FAST IaC Labs - Caminho de Aprendizado de Infraestrutura como Código

## Visão Geral

Laboratórios completos de Infraestrutura como Código usando Terraform, Packer e Ansible para construir e implantar infraestrutura AWS. Este repositório contém 7 laboratórios progressivos que ensinam práticas modernas de DevOps para provisionamento de infraestrutura, gerenciamento de configuração e construção de imagens.

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
│   │   ├── bootstrap.sh         # Script de criação do bucket S3 para backend do Terraform
│   │   ├── provision.sh         # Script de provisionamento de infraestrutura
│   │   ├── destroy.sh           # Script de limpeza
│   │   ├── clean.sh             # Script de limpeza de estado
│   │   ├── main.tf              # Configuração principal do Terraform
│   │   ├── variables.tf         # Definições de variáveis
│   │   ├── outputs.tf           # Valores de saída
│   │   ├── network.tf           # VPC, subnets, configurações de gateway
│   │   ├── security.tf          # Grupos de segurança e regras
│   │   └── instance.tf          # Configuração da instância EC2
│   └── infra-02/                # Infraestrutura enterprise multi-AZ
│       ├── bootstrap.sh         # Script de criação do bucket S3 para backend do Terraform
│       ├── provision.sh         # Script de provisionamento de infraestrutura
│       ├── destroy.sh           # Script de limpeza
│       ├── clean.sh             # Script de limpeza de estado
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

### Passo 1: Configurar Backend S3 (Primeira Execução)

Antes de provisionar a infraestrutura, é necessário criar um bucket S3 para armazenar o estado do Terraform de forma remota e segura.

**O que o script bootstrap faz:**
- Cria bucket S3 privado com nome único
- Habilita versionamento para recuperação de estado
- Configura bloqueio de acesso público
- Prepara backend configurado para o Terraform

```bash
cd terraform/infra-01

# Opção 1: Usar variáveis de ambiente (recomendado)
BUCKET=fast-2025-iac-lab1 REGION=us-east-1 PROFILE=batatinha ./bootstrap.sh

# Opção 2: Modo interativo (será solicitado a digitar os valores)
./bootstrap.sh
```

**Nota:** Se o bucket já existir, o script informará e não fará alterações.

### Passo 2: Provisionar Infraestrutura

```bash
# Ainda em terraform/infra-01

# Opção 1: Usar as mesmas variáveis de ambiente (recomendado)
PROFILE=batatinha BUCKET=fast-2025-iac-lab1 REGION=us-east-1 ./provision.sh

# Opção 2: Se já exportou as variáveis, apenas execute
./provision.sh
# Siga os prompts para confirmar a criação da infraestrutura
```

### Verificação
```bash
# Verificar outputs da infraestrutura
terraform output

# Testar conectividade SSH (confirma que a instância está acessível)
eval "$(terraform output -raw ssh_connection_command)"
# Ou simplesmente copiar o comando exibido e executar manualmente:
# terraform output ssh_connection_command

# Testar porta HTTP (ainda não há servidor web, então falhará)
curl "http://$(terraform output -raw instance_public_ip)"
# Esperado: timeout ou "Failed to connect" - normal, pois não há servidor web ainda
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
- Nome da AMI customizada (ex: fast-20250119123456)
- ID da AMI (ex: ami-0123456789abcdef0)
- AMI será marcada com informações do projeto
- Nota: Você usará o **nome** da AMI (não o ID) nos Labs 4 e 5

## Lab 4: Implantação com AMI Customizada (Básico)

**Objetivo:** Implantar infraestrutura básica usando a AMI customizada criada no Lab 3

**Duração:** 10-15 minutos
**Pré-requisitos:** Lab 3 completo (AMI customizada criada)

### O que é diferente
- Usa AMI customizada em vez do Amazon Linux padrão
- Website inicia automaticamente na inicialização
- Nenhuma configuração adicional necessária
- Tempo de implantação mais rápido

### Instruções

**Nota:** Se você já executou o Lab 1, o bucket S3 backend já está configurado. Pule direto para o comando de provisionamento.

```bash
cd terraform/infra-01

# Se esta for sua primeira vez (não fez Lab 1), execute:
# BUCKET=fast-2025-iac-lab1 REGION=us-east-1 PROFILE=batatinha ./bootstrap.sh

# Provisionar com AMI customizada por nome (não ID)
PROFILE=batatinha BUCKET=fast-2025-iac-lab1 INSTANCE_AMI=fast-* AMI_OWNER=self ./provision.sh
# O wildcard (*) corresponde ao timestamp, encontrando sua AMI mais recente

# Ou especificar nome exato se você tiver múltiplas
PROFILE=batatinha BUCKET=fast-2025-iac-lab1 INSTANCE_AMI=fast-20250119123456 AMI_OWNER=self ./provision.sh
```

### Verificação
```bash
# Verificar outputs da infraestrutura
terraform output

# Testar website (deve estar disponível imediatamente)
curl "http://$(terraform output -raw instance_public_ip)"
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

### Passo 1: Configurar Backend S3 (Primeira Execução)

Antes de provisionar a infraestrutura enterprise, configure o backend S3 para gerenciar o estado do Terraform.

**Nota:** Este lab usa um bucket S3 **diferente** do Lab 1 (fast-2025-iac-lab2 vs fast-2025-iac-lab1) para manter os estados isolados.

```bash
cd terraform/infra-02

# Opção 1: Usar variáveis de ambiente (recomendado)
BUCKET=fast-2025-iac-lab2 REGION=us-east-1 PROFILE=batatinha ./bootstrap.sh

# Opção 2: Modo interativo (será solicitado a digitar os valores)
./bootstrap.sh
```

**Nota:** Se o bucket já existir, o script informará e não fará alterações.

### Passo 2: Provisionar Infraestrutura

```bash
# Ainda em terraform/infra-02

# Usar AMI customizada por nome (não ID)
PROFILE=batatinha BUCKET=fast-2025-iac-lab2 INSTANCE_AMI=fast-* AMI_OWNER=self ./provision.sh
# O wildcard (*) corresponde ao timestamp, encontrando sua AMI mais recente

# Ou especificar nome exato se você tiver múltiplas
PROFILE=batatinha BUCKET=fast-2025-iac-lab2 INSTANCE_AMI=fast-20250119123456 AMI_OWNER=self ./provision.sh
```

### Padrões de Acesso
```bash
# Verificar todos os outputs
terraform output

# Acessar website via load balancer
curl "$(terraform output -raw load_balancer_url)"

# SSH para bastion host
eval "$(terraform output -raw ssh_bastion_command)"

# SSH para servidor web 1 via bastion (em outra sessão de terminal)
eval "$(terraform output -raw ssh_web_server_1_command)"

# SSH para servidor web 2 via bastion (em outra sessão de terminal)
eval "$(terraform output -raw ssh_web_server_2_command)"
```

**Referência: Acesso SSH manual via bastion (ProxyCommand)**

Se preferir construir o comando manualmente ou entender como funciona:

```bash
# Obter IPs necessários
BASTION_IP=$(terraform output -raw bastion_public_ip)
WEB1_IP=$(terraform output -raw web_server_1_private_ip)
WEB2_IP=$(terraform output -raw web_server_2_private_ip)
KEY_PATH=$(terraform output -raw private_key_path)

# SSH para web server 1 usando bastion como proxy
ssh -o IdentitiesOnly=yes -i "$KEY_PATH" \
  -o ProxyCommand="ssh -o IdentitiesOnly=yes -i $KEY_PATH -W %h:%p ec2-user@$BASTION_IP" \
  ec2-user@$WEB1_IP

# SSH para web server 2 usando bastion como proxy
ssh -o IdentitiesOnly=yes -i "$KEY_PATH" \
  -o ProxyCommand="ssh -o IdentitiesOnly=yes -i $KEY_PATH -W %h:%p ec2-user@$BASTION_IP" \
  ec2-user@$WEB2_IP

# Explicação do ProxyCommand:
# -W %h:%p = Encaminha stdin/stdout para host:porta de destino
# %h = hostname do servidor web privado
# %p = porta SSH (22)
# O bastion atua como "ponte" para acessar servidores em subnets privadas
```

### Limpeza
```bash
./destroy.sh
# Importante: Destruir para evitar cobranças do NAT Gateway e Load Balancer
```

## Lab 6: Arquitetura Modular com Terraform

**Objetivo:** Refatorar a infraestrutura enterprise usando módulos do Terraform para melhor reutilização, manutenibilidade e organização

**Duração:** 30-40 minutos
**Custo:** ~$48/mês (destruir após o laboratório)
**Pré-requisitos:** Conhecimento dos Labs anteriores

### O que é diferente

Este lab demonstra as **melhores práticas de organização** usando módulos do Terraform:

- **Módulos reutilizáveis**: Cada componente (networking, security, compute, load-balancer) é um módulo independente
- **Separação de responsabilidades**: Código organizado por domínio funcional
- **Fácil manutenção**: Mudanças isoladas em módulos específicos
- **Reutilização**: Módulos podem ser usados em múltiplos ambientes
- **Composição**: main.tf apenas "conecta" os módulos

### Estrutura Modular

```
terraform/infra-03/
├── main.tf                    # Orquestra os módulos
├── variables.tf               # Variáveis da raiz
├── outputs.tf                 # Outputs da raiz
├── bootstrap.sh              # Script de configuração do backend S3
├── provision.sh              # Script de provisionamento
├── destroy.sh                # Script de limpeza
└── modules/
    ├── networking/           # Módulo: VPC, Subnets, Gateways
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security/             # Módulo: Security Groups
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── compute/              # Módulo: EC2 Instances
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── load-balancer/        # Módulo: ALB, Target Groups
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Vantagens da Abordagem Modular

**1. Reutilização**
- O mesmo módulo pode ser usado em múltiplos ambientes (dev, staging, prod)
- Exemplo: O módulo `networking` pode criar VPCs diferentes para cada ambiente
- Basta mudar as variáveis passadas para o módulo

**2. Testabilidade**
- Cada módulo pode ser testado independentemente
- Mudanças isoladas não afetam outros componentes
- Facilita identificar problemas específicos

**3. Manutenibilidade**
- Código menor e mais focado por arquivo (50-100 linhas vs 200+)
- Fácil localizar e modificar componentes específicos
- Separação clara de responsabilidades

**4. Composição**
- Módulos se comunicam através de outputs/inputs
- Dependências explícitas e claras entre componentes
- Fácil adicionar ou remover funcionalidades (ex: desabilitar bastion)

### Passo 1: Configurar Backend S3

```bash
cd terraform/infra-03

# Opção 1: Usar variáveis de ambiente (recomendado)
BUCKET=fast-2025-iac-lab3 REGION=us-east-1 PROFILE=batatinha ./bootstrap.sh

# Opção 2: Modo interativo
./bootstrap.sh
```

**Nota:** Este lab usa um bucket S3 **diferente** (fast-2025-iac-lab3) para manter os estados isolados.

### Passo 2: Provisionar Infraestrutura

```bash
# Ainda em terraform/infra-03

# Usar AMI customizada por nome (não ID)
PROFILE=batatinha BUCKET=fast-2025-iac-lab3 INSTANCE_AMI=fast-* AMI_OWNER=self ./provision.sh

# Ou especificar nome exato se você tiver múltiplas
PROFILE=batatinha BUCKET=fast-2025-iac-lab3 INSTANCE_AMI=fast-20250119123456 AMI_OWNER=self ./provision.sh
```

### Recursos Criados

Idênticos ao Lab 5, mas organizados em módulos:
- 1 VPC (módulo networking)
- 4 Subnets - 2 públicas, 2 privadas (módulo networking)
- 1 Internet Gateway + 1 NAT Gateway (módulo networking)
- 3 Security Groups (módulo security)
- 3 Instâncias EC2 - 2 web servers + 1 bastion (módulo compute)
- 1 Application Load Balancer (módulo load-balancer)

### Padrões de Acesso

```bash
# Verificar todos os outputs
terraform output

# Acessar website via load balancer
curl "$(terraform output -raw load_balancer_url)"

# SSH para bastion host
eval "$(terraform output -raw ssh_bastion_command)"

# SSH para servidores web via bastion (ver comandos disponíveis)
terraform output ssh_web_servers_commands

# Conectar ao servidor web 1 (copie o primeiro comando da lista acima e execute)
# Conectar ao servidor web 2 (copie o segundo comando da lista acima e execute)
```

**Referência: Acesso SSH manual via bastion (ProxyCommand)**

Se preferir construir o comando manualmente ou entender como funciona:

```bash
# Obter IPs necessários
BASTION_IP=$(terraform output -raw bastion_public_ip)
WEB_IPS=($(terraform output -json web_private_ips | jq -r '.[]'))
KEY_PATH=$(terraform output -raw private_key_path)

# SSH para web server 1 usando bastion como proxy
ssh -o IdentitiesOnly=yes -i "$KEY_PATH" \
  -o ProxyCommand="ssh -o IdentitiesOnly=yes -i $KEY_PATH -W %h:%p ec2-user@$BASTION_IP" \
  ec2-user@${WEB_IPS[0]}

# SSH para web server 2 usando bastion como proxy
ssh -o IdentitiesOnly=yes -i "$KEY_PATH" \
  -o ProxyCommand="ssh -o IdentitiesOnly=yes -i $KEY_PATH -W %h:%p ec2-user@$BASTION_IP" \
  ec2-user@${WEB_IPS[1]}

# Explicação do ProxyCommand:
# -W %h:%p = Encaminha stdin/stdout para host:porta de destino
# %h = hostname do servidor web privado
# %p = porta SSH (22)
# O bastion atua como "ponte" para acessar servidores em subnets privadas
```

### Exemplo: Customizando Módulos

**Mudar número de web servers:**
```bash
PROFILE=batatinha BUCKET=fast-2025-iac-lab3 INSTANCE_AMI=fast-* AMI_OWNER=self WEB_SERVER_COUNT=3 ./provision.sh
```

**Desabilitar NAT Gateway (economia de custos):**
```bash
PROFILE=batatinha BUCKET=fast-2025-iac-lab3 INSTANCE_AMI=fast-* AMI_OWNER=self ENABLE_NAT_GATEWAY=false ./provision.sh
# Nota: Sem NAT Gateway, os web servers não terão acesso à internet
```

**Criar sem bastion host:**
```bash
PROFILE=batatinha BUCKET=fast-2025-iac-lab3 INSTANCE_AMI=fast-* AMI_OWNER=self CREATE_BASTION=false ./provision.sh
# Nota: Sem bastion, você não conseguirá SSH nos web servers privados
```

### Comparação: Lab 5 vs Lab 6

| Aspecto | Lab 5 (Monolítico) | Lab 6 (Modular) |
|---------|-------------------|-----------------|
| **Arquivos** | 7 arquivos no root | 4 root + 12 em módulos |
| **Linhas por arquivo** | ~200 linhas | ~50-100 linhas |
| **Reutilização** | Difícil | Fácil (módulos isolados) |
| **Manutenção** | Arquivos grandes | Arquivos pequenos e focados |
| **Testes** | Tudo junto | Módulos individuais |
| **Composição** | Hardcoded | Flexível via módulos |

### Limpeza

```bash
./destroy.sh
# Importante: Destruir para evitar cobranças do NAT Gateway e Load Balancer
```

## Lab 7: Usando Módulos Oficiais da AWS

**Objetivo:** Construir a mesma infraestrutura enterprise usando módulos oficiais da comunidade Terraform (terraform-aws-modules)

**Duração:** 25-35 minutos
**Custo:** ~$48/mês (destruir após o laboratório)
**Pré-requisitos:** Lab 3 completo (AMI customizada criada)

### O que é diferente

Este lab demonstra como usar **módulos mantidos pela comunidade** em vez de escrever código próprio:

- **Módulos oficiais**: terraform-aws-modules/* do Terraform Registry
- **Manutenção**: Mantidos pela comunidade, atualizados regularmente
- **Melhores práticas**: Seguem padrões da AWS e Terraform
- **Menos código**: ~350 linhas vs ~500 linhas (Lab 6)
- **Produção-ready**: Testados em milhares de projetos

### Módulos Utilizados

| Componente | Módulo Oficial | Versão |
|------------|---------------|--------|
| **VPC** | terraform-aws-modules/vpc/aws | ~> 6.5 |
| **Security Groups** | terraform-aws-modules/security-group/aws | ~> 5.1 |
| **EC2 Instances** | terraform-aws-modules/ec2-instance/aws | ~> 6.1 |
| **Load Balancer** | terraform-aws-modules/alb/aws | ~> 9.11 |

### Estrutura do Projeto

```
terraform/infra-04/
├── main.tf           # ~350 linhas - usa módulos oficiais
├── variables.tf      # Variáveis de configuração
├── outputs.tf        # Outputs usando módulos
├── bootstrap.sh      # Script de configuração do backend S3
├── provision.sh      # Script de provisionamento
└── destroy.sh        # Script de limpeza
```

### Vantagens dos Módulos Oficiais

**1. Menos código para escrever**
- VPC Module: ~15 linhas vs ~200 linhas de código próprio
- Security Groups: ~30 linhas vs ~150 linhas
- Foco no "o que" ao invés de "como"

**2. Melhores práticas embutidas**
- Configurações padrão otimizadas
- Validações e verificações automáticas
- Suporte a features avançadas

**3. Manutenção pela comunidade**
- Atualizações regulares
- Correções de segurança
- Suporte a novas features da AWS

**4. Documentação extensa**
- Exemplos de uso no Terraform Registry
- Issues e Pull Requests no GitHub
- Comunidade ativa

### Passo 1: Configurar Backend S3

```bash
cd terraform/infra-04

# Opção 1: Usar variáveis de ambiente (recomendado)
BUCKET=fast-2025-iac-lab4 REGION=us-east-1 PROFILE=batatinha ./bootstrap.sh

# Opção 2: Modo interativo
./bootstrap.sh
```

**Nota:** Este lab usa um bucket S3 **diferente** (fast-2025-iac-lab4) para manter os estados isolados.

### Passo 2: Provisionar Infraestrutura

```bash
# Ainda em terraform/infra-04

# Usar AMI customizada por nome (não ID)
PROFILE=batatinha BUCKET=fast-2025-iac-lab4 INSTANCE_AMI=fast-* AMI_OWNER=self ./provision.sh

# Ou especificar nome exato se você tiver múltiplas
PROFILE=batatinha BUCKET=fast-2025-iac-lab4 INSTANCE_AMI=fast-20250119123456 AMI_OWNER=self ./provision.sh
```

### Recursos Criados

Idênticos aos Labs 5 e 6:
- 1 VPC (módulo terraform-aws-modules/vpc)
- 4 Subnets - 2 públicas, 2 privadas
- 1 Internet Gateway + 1 NAT Gateway
- 3 Security Groups (módulo terraform-aws-modules/security-group)
- 3 Instâncias EC2 (módulo terraform-aws-modules/ec2-instance)
- 1 Application Load Balancer (módulo terraform-aws-modules/alb)

### Padrões de Acesso

```bash
# Verificar todos os outputs
terraform output

# Acessar website via load balancer
curl "$(terraform output -raw load_balancer_url)"

# SSH para bastion host
eval "$(terraform output -raw ssh_bastion_command)"

# SSH para servidores web via bastion (ver comandos disponíveis)
terraform output ssh_web_servers_commands

# Conectar ao servidor web 1 (copie o primeiro comando da lista acima e execute)
# Conectar ao servidor web 2 (copie o segundo comando da lista acima e execute)
```

### Exemplo: Comparação de Código

**VPC - Código Próprio (Lab 6):**
```hcl
# ~200 linhas: resource "aws_vpc", "aws_subnet",
# "aws_internet_gateway", "aws_nat_gateway",
# "aws_route_table", "aws_route_table_association", etc.
```

**VPC - Módulo Oficial (Lab 7):**
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.4.0/24"]
  private_subnets = ["10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
# Apenas ~15 linhas!
```

### Comparação: Lab 6 vs Lab 7

| Aspecto | Lab 6 (Módulos Próprios) | Lab 7 (Módulos Oficiais) |
|---------|-------------------------|--------------------------|
| **Linhas de código** | ~500 linhas (módulos) | ~350 linhas (main.tf) |
| **Manutenção** | Você mantém | Comunidade mantém |
| **Atualizações** | Manual | `terraform init -upgrade` |
| **Documentação** | Você documenta | Registry + GitHub |
| **Testes** | Você testa | Testado pela comunidade |
| **Features** | O que você implementar | Todas disponíveis |
| **Complexidade** | Média-Alta | Baixa |
| **Customização** | Total | Via variáveis do módulo |

### Quando Usar Módulos Oficiais vs Próprios

**Use Módulos Oficiais quando:**
- ✅ Precisa de features comuns e bem estabelecidas
- ✅ Quer seguir melhores práticas da AWS
- ✅ Precisa de manutenção e atualizações automáticas
- ✅ Está começando um projeto novo

**Use Módulos Próprios quando:**
- ✅ Tem requisitos muito específicos/únicos
- ✅ Precisa de controle total sobre implementação
- ✅ Os módulos oficiais não atendem suas necessidades
- ✅ Quer aprender como as coisas funcionam internamente

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
- Backend remoto S3 para armazenamento de estado
- Configuração de variáveis e saídas
- **Módulos reutilizáveis e composição**
- Organização de código em arquitetura modular
- Uso de módulos oficiais da comunidade (terraform-aws-modules)
- Comparação: módulos próprios vs módulos oficiais
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

### Bootstrap (Configuração do Backend S3)
```bash
# Configurar backend S3 com variáveis de ambiente
BUCKET=fast-2025-iac-lab1 REGION=us-east-1 PROFILE=batatinha ./bootstrap.sh

# Ou definir como padrões de ambiente
export BUCKET=fast-2025-iac-lab1
export REGION=us-east-1
export PROFILE=batatinha
./bootstrap.sh
```

### Provision (Provisionamento de Infraestrutura)
```bash
# Configuração completa com perfil, bucket e região
PROFILE=batatinha BUCKET=fast-2025-iac-lab1 REGION=us-east-1 ./provision.sh

# Marcação de Recursos customizada
PROFILE=batatinha BUCKET=fast-2025-iac-lab1 ENVIRONMENT=prod OWNER="Minha Equipe" ./provision.sh

# Uso de AMI Customizada (usar padrão de nome, não ID da AMI)
PROFILE=batatinha BUCKET=fast-2025-iac-lab1 INSTANCE_AMI=fast-* AMI_OWNER=self ./provision.sh

# Ou exportar variáveis para todos os comandos
export PROFILE=batatinha
export BUCKET=fast-2025-iac-lab1
export REGION=us-east-1
./provision.sh
```

## Solução de Problemas

### Problemas Comuns

**Problemas com Bootstrap S3**
```bash
# Verificar se o bucket foi criado
aws s3 ls --profile batatinha | grep fast-2025-iac

# Verificar configuração do bucket
aws s3api get-bucket-versioning --bucket fast-2025-iac-lab1 --profile batatinha

# Se precisar recriar o bucket, primeiro remova o existente
aws s3 rb s3://fast-2025-iac-lab1 --force --profile batatinha
./bootstrap.sh
```

**Conflitos de Estado do Terraform**
```bash
# Se o estado estiver bloqueado
terraform force-unlock <LOCK_ID>

# Verificar estado remoto
terraform state list
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



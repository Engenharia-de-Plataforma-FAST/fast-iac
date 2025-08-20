# FAST - Bootcamp de Engenharia de Plataforma


### Módulo 3 - IaC e Automação


Bem-vindos aos laboratórios de Infraestrutura como Código e Automação do módulo 3. Aqui você terá acesso a toda a prática que é ensinada durante as aulas deste assunto. 

Pedimos clonem este repositório e pratiquem, mudem as configurações e evoluam este laboratório, pois só assim vocês poderam assimilar melhor todo o conteúde e práticas passadas durante as aulas, combinado? ;)

Para fazer o clone basta executar o comando abaixo no terminal:

``` bash
git clone git@github.com:Engenharia-de-Plataforma-FAST/fast-iac.git
```

Dentro deste repositório temos 3 laboratórios os quais são trabalhados dentro do módulo:

#### Laboratório 1: Vagrant + Ansible (Local)

Este laboratório utiliza Vagrant para provisionar uma máquina virtual CentOS 8 localmente no VirtualBox e Ansible para configurar automaticamente um ambiente completo de CI/CD. Você aprenderá a criar e gerenciar VMs de forma declarativa, além de implantar uma stack containerizada com Jenkins e SonarQube usando Docker Swarm. Ideal para desenvolvimento local e testes de automação. O código está disponível no diretório [lab-vagrant-ansible/](./lab-vagrant-ansible/).

#### Laboratório 2: Terraform + Ansible (GCP)

Este laboratório demonstra a integração entre Terraform e Ansible para provisionar e configurar infraestrutura no Google Cloud Platform. Você criará uma instância Compute Engine usando Terraform, que automaticamente executa playbooks Ansible para configurar um ambiente CI/CD com Jenkins e SonarQube. O laboratório ensina boas práticas de IaC incluindo gerenciamento de estado, variáveis e provisionamento remoto. O código está disponível no diretório [lab-terraform-ansible/](./lab-terraform-ansible/).

#### Laboratório 3: Packer + Terraform + Ansible (AWS)

Este laboratório combina as três principais ferramentas de IaC para criar uma solução completa de automação na AWS. Você aprenderá a criar AMIs customizadas com Packer, provisionar infraestrutura com Terraform e configurar servidores com Ansible, integrando todas as ferramentas em um fluxo de trabalho DevOps moderno. O laboratório inclui desde deployments básicos até arquiteturas enterprise com alta disponibilidade, load balancers e bastion hosts. Para instruções detalhadas e execução dos 5 labs progressivos, consulte a [documentação completa](./lab-aws/README.md).

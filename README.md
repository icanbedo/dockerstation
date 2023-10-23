# dockerstation
an all in one ubuntu docker host with terraform

## What's this?

A way to easily deploy a docker host, with portainer and ssl certificates

- Build your OS (this is based on Ubuntu)
- ensure you have ssh installed and enabled
- deploy terraform!
- login to portainer 
- profit

## What do I need?

- terraform
- private/public ssh key
- public domain name registered
- cloudflare account with DNS zone configured for public domain name
- cloudflare DNS API Token
<img src=".\cloudflare-api.png">
- email address for letsencrypt account and notifications
- populated variables files in each stack with a .tfvars extension; for required variables consult the variables.tf file, anything without a default value will require populating
- a single variables file template is included in the root dir and can be used across deployments by specifying the path and filename

e.g
```
-var-file ..\dockerstation.tfvars

or 

-var-file <path to vars>\dockerstation.tfvars
```

 variable files simply contain the variable name and value:

```
ip = 192.168.1.3

username = admin
```


## How to deploy

- deploy in this order
  - Setup
  - Letsencrypt
  - Portainer

These could be combined however as setup is a once only action and you may not want to update portainer on certificate renew

basic deployment is as follows:

```
in *each* deployment folder

> terraform init

> terraform plan
(confirm your deployment looks correct)

> terraform apply
(apply your deployment)

```

LetsEncrypt can be reused for other certificates by using the following process:

```
> terraform init

> terraform plan -out dockerstation.out -var-file dockerstation.tfvars -state dockerstation.tfstate

> terraform apply dockerstation.out -state dockerstation.tfstate

or

> terraform apply -var-file dockerstation.tfvars-state dockerstation.tfstate

to destroy:
> terraform destroy -state dockerstation.tfstate

```
change the tfstate and tfvars file names and contents where appropriate

to delete all resources 

```
terraform destroy
```

## Whats next?

Other containers can be deployed using terraform OR you can utilise portainers internal stack deployment (preferable) linked to a git repo!

## Caveats

- LetsEncrypt certificate renew (https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate#certificate-renewal) is performed using a terraform apply during the min_days_remaining period
  <br> "The minimum amount of days remaining on the expiration of a certificate before a renewal is attempted. The default is 30. A value of less than 0 means that the certificate will never be renewed."
  https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate#min_days_remaining


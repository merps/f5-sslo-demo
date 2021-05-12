# F5 BIG-IQ/BIG-IP Deployment Example for SSLO Automation

[![license](https://img.shields.io/github/license/merps/f5-sslo-demo)](LICENSE)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

This document covers the initial setup and configuration of the AWS BIG-IQ/BIG-IP SSLO demonstration deployment.

## Table of Contents

- [Security](#security)
- [Background](#background)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)
- [Credits](#credits)

## Security

This F5 AWS BIG-IP Demo exposes both the BIG-IP & BIG-IQ management interfaces with ElasticIP's to the public internet.


## Background

This example comes about based on previous work from F5 Development & Field, to provide automation examples leveraging
BIG-IQ Cloud Edition and BIG-IQ VE's Inline Tap deployment model.

## Additional Resources

To deploy the Terraform example both BIG-IQ and BIG-IP trial licenses are required.  To do this,
go to [F5 Trial](https://f5.com/products/trials/product-trials) and;

   * Select **BIG-IP VE and BIG-IQ**

To deploy within AWS using Terraform a valid AWS Subscription is also required, select 
Subscribe and accept the Terms and Conditions for these F5 products:

   * [F5 BIG-IQ Virtual Edition - (BYOL)](https://aws.amazon.com/marketplace/pp/B00KIZG6KA)

> **_NOTE:_** This architecture deploys two c4.2xlage PAYG BIG-IP Marketplace instances, it is 
recommended to perform a `terraform destroy` to not incur excessive usage costs outside of free tier.  
> BIG-IQ Evaulation/BYOL licenses are required for the externally called [terraform-aws-bigiq](https://github.com/merps/terraform-aws-bigiq)


## Prerequisites

To support this deployment pattern the following components are required:

* F5 BIG-IP PAYG Marketplace Active Subscription
* F5 BIG-IQ CloudEdition VE Licenses
* [Terraform CLI](https://www.terraform.io/docs/cli-index.html)
* [git](https://git-scm.com/)
* [AWS CLI](https://aws.amazon.com/cli/) access.
* [AWS Access Credentials](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)


## Installation 

![](images/aws-tap-deploy.png)

### *BIG-IQ, BIG-IP and AWS Infrastructure*

***a)*** First, clone the repo:
```
git clone https://github.com/merps/f5-sslo-demo.git
```

***b)*** Second, create a [tfvars](https://www.terraform.io/docs/configuration/variables.html) file in the following format to deploy the environment;

#### Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_vpc_parameters"></a> [aws\_vpc\_parameters](#input\_aws\_vpc\_parameters) | AWS VPC Input Parameters | <pre>object({<br>    cidr   = string<br>    region = string<br>  })</pre> | <pre>{<br>  "cidr": "10.0.0.0/16",<br>  "region": "ap-southeast-2"<br>}</pre> | no |
| <a name="input_cidr_offsets"></a> [cidr\_offsets](#input\_cidr\_offsets) | VPC CIDR Offsets for C Octet | <pre>object({<br>    management  = number<br>    external    = number<br>    internal    = number<br>    inspect_in  = number<br>    inspect_out = number<br>  })</pre> | <pre>{<br>  "external": 0,<br>  "inspect_in": 40,<br>  "inspect_out": 50,<br>  "internal": 20,<br>  "management": 10<br>}</pre> | no |
| <a name="input_ec2_public_key"></a> [ec2\_public\_key](#input\_ec2\_public\_key) | EC2 Keypair for provisioning | `any` | n/a | yes |
| <a name="input_licenses"></a> [licenses](#input\_licenses) | BIQ-IQ (CM/DCD) License Keys | <pre>object({<br>    cm_key = string<br>    dcd_key = string<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | AWS Tags | <pre>object({<br>    prefix      = string<br>    environment = string<br>  })</pre> | <pre>{<br>  "environment": "demo",<br>  "prefix": "f5-sslo"<br>}</pre> | no |

The minimum required variables are the BIG-IQ (CM/DCD) licenses.  This deployment defaults to what is currently defined in [variables.tf](https://github.com/merps/f5-sslo-demo/blob/master/src/variables.tf)

***c)*** Third, get and initialise the Terraform deployment as follows:
```commandline
cd src/
terraform get ; terraform init
```
This will download the required modules from both GitHub and the Terraform Registry.

***d)*** Validation of the default values and created variables file from the previous step can be performed as such;
```commandline
terraform validate 
```

***e)*** Plan the deployment;
```commandline
terraform plan -var-file=variables.tfvars
```
this will produce and display the deployment plan using the previously created `varibles.tfvars` file.

***d)*** Then finally to deploy the successfully plan;
```commandline
terraform apply -var-file=variables.tfvars --auto-approve
```

> **_NOTE:_** This architecture deploys two c4.2xlage PAYG BIG-IP Marketplace instances, it is 
recommended to perform a `terraform destroy` to not incur excessive usage costs outside of free tier.  

This deployment also covers the provisioning of the additional F5 prerequisite components so required for 
deployment example covered in the [F5 SSLO Demo](https://github.com/merps/f5-sslo-demo)

### Configuration

The example configuration for this deployment demonstration is as follows:

## TODO

List of task to make the process my automated;

- [ ] Workflow improvements for DO/AS3/TS
- [ ] Clear SSLO object errors on BIG-IQ
- [ ] Address automatic onboarding of CM/DCD as per [TF Module](https://github.com/merps/terraform-aws-bigiq)

## Contributing

See [the contributing file](CONTRIBUTING.md)!

PRs accepted.

## Filing issues

If you find an issue, we would love to hear about it. You have a choice when it comes to filing issues:

- Use the [Issues link](https://github.com/f5devcentral/f5-sslo-demo/issues) on the GitHub menu bar in this repository for items such as enhancement or feature requests and non-urgent bug fixes. Tell us as much as you can about what you found and how you found it.

### ChangeLog


## License

[Apache © merps.](../LICENSE)
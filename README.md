# AWS Experiments

## Background

This project serves as a location for samples implementing AWS services with documentation as to the function of various
services, configurations, pipelines, and IAC for onboarding to Amazon Web Services.

Using these directions will set up various AWS services, some of which will incur charges. Be aware of this
before deploying services, and be sure to tear down services that are no longer being used with `terraform destroy`
(explained in more detail later) to minimize unnecessary costs.

## Install

## Set Up AWS Account

Follow the directions [here](https://www.youtube.com/watch?v=CjKhQoYeR4Q) to set up your initial AWS Account.

## Install Terraform

Terraform is our Infrastructure as Code (IAC) tool. The primary function of Terraform and other IAC platforms is to
compare a declared and desired configuration against the actual state of the impacted resources in the cloud and
automatically determine sets of changes needed to reach the intended state as defined in the configuration files
(for Terraform, this is in YAML).It exists in a family of tools that also includes:

- [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
- [AWS CDK](https://aws.amazon.com/cdk/)
- [CloudFormation](https://aws.amazon.com/cloudformation/)
- [Serverless](https://www.serverless.com/)

This project will not include a discussion of the merits/drawbacks of each - we will use Terraform for all IAC.

**NOTE**: Deploying changes in Terraform and is performed with the command `terraform apply`.
Terraform will show a list of the changes to be made, and the user can specify whether or no to proceed. Type `yes`
to apply the changes. These steps apply to all Terraform modules described below.

### Windows

To install Terraform on Windows:

1. Install [Chocolatey](https://chocolatey.org/install)
2. Install Terraform via Chocolatey using the commands for `Chocolatey on Windows`
[here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### macOS

To install Terraform on macOS:

1. Install [Homebrew](https://brew.sh/)
2. Install Terraform via Homebrew, using the commands for `Homebrew on macOS`
[here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Install The AWS CLI

The AWS CLI allows developers to interact with AWS services directly using various command line interactions. While our
interactions with AWS will be primarily performed via Terraform, for Terraform to interact with AWS the user must have
an active session established and authenticated. The AWS CLI will allow us to establish this session.

Follow the directions [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) to install
the AWS CLI on Windows or macOS.

### Log In With AWS SSO

Once the AWS CLI is installed, the developer will need to authenticate to AWS using their IAM user. The best way to
do this is with Single Sign On (SSO). To do this, open a terminal and then:

- Enter the command `aws configure sso`
- Provide the `SSO session name` (suggest first initial last name dash dev, example `tparikka-dev`)
- Provide the `SSO start URL` found in the `AWS Access Portal` in the `Access Keys` section under the account / user dropdown
- Provide the `SSO region` (suggest the AWS region where development will happen, this repo uses `us-east-1`)
- Leave `SSO registration scopes` default
- The terminal will open your browser and ask you to confirm the 8 char code in the browser and your terminal match.
If they do, click `Confirm and Continue` and then `Allow Access`
- Set the `CLI default client` to the same as your `SSO region`
- Leave the `CLI default output format` default
- Either accept the default `CLI profile name` or set a new one, but be sure to note the profile name for future use

At this point, your terminal is authenticated and the session can be used by Terraform.

### Set The AWS_PROFILE Environment Variable

Setting the AWS_PROFILE environment variable will allow Terraform to use that profile across the board for all
interactions without requiring source code changes:

#### Windows

- At a Powershell terminal, use the command `$env:AWS_PROFILE=myprofilename`, substituting the profile name specified
at the last step of `Log In With AWS SSO`

#### macOS

- At a zsh or Bash terminal, use the command `EXPORT AWS_PROFILE=myprofilename`, substituting the profile name specified
at the last step of `Log In With AWS SSO`

### Common Modules

#### Landing Zone

In order to prevent multiple users from applying conflicting changes at the same time and to improve collaboration, it
is common to store both lock state (which prevents collisions) and current system state in a cloud resource of some
kind. In AWS, the lock state is stored in DynamoDB (a NoSQL database) and the system state is stored in
S3 (a file storage service). If these are not stored in the cloud, they must be instead stored locally on a
developer's laptop which is suboptimal.

For this to work the DynamoDB table and S3 storage bucket must exist, creating a "chicken and egg" situation. We address
this by creating a "landing zone" Terraform module that establishes the minimum possible assets required to support
IAC deployments. This module can be lives in `/iac/landing-zone`.

**NOTE**: Because S3 bucket names must be globally unique, in `s3.tf` the bucket name must be updated. Replace
`firstname-lastname` with the developer's first and last name to provide uniqueness. There is also a `provider.tf` in
each other module where the `bucket` name in the `backend` section must be updated to reflect this value in the
developer's fork.

#### Infrastructure

Once the landing zone has been deployed, other infrastructure can be deployed as needed. This can include resources like:

- [VPCs](https://aws.amazon.com/vpc/)
- [WAFs](https://aws.amazon.com/waf/)
- SSO / Federated Identity Resources

##### AWS / GitHub Connection

In this example, the only component at the infra level is a federated connection allowing GitHub / AWS interactions.
This allows [GitHub Actions](https://github.com/features/actions) to perform actions like deploying services
and container images to AWS. The repo includes defaults based on the maintainer's environment that can be overridden
at Terraform runtime like so:

`terraform apply -var="account_id=123456789" -var="github_repository=yourname/yourreponame" -var="idp_thumbprint=asdf"`

Alternately, if the repo is forked the user can replace the default with their own value. The variables can also be
supplied as part of a deployment pipeline, which is outside the current scope of this sample.

Related Links:

- https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/

### Sample Systems

The following sample systems are available for testing. They are system level modules that rely on the previously
described modules. They have their own README.md files. They include:

- [sample-sqs-lambda](./src/SampleSqsLambda/README.md)
- [sample-api-lambda](./src/SampleApiLambda/README.md)
- [sample-ecr]

## Usage

## Badges

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
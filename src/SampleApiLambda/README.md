# Sample API - API Gateway w/Lambda

## Background

This project demonstrates how to establish an REST-ful API with API Gateway and Lambda functions. This can be an
effective way to stand up an API that has inconsistent loads, is accessed infrequently, or does not have particularly
high performance requirements.

Using these directions will set up various AWS services, all of which have a free tier option:

- Lambda - 1 Million Free Requests Per Month
- API Gateway - 1 Million API Calls Per Month

Be aware of these limitations before deploying services, and be sure to tear down services that are no longer being
used with `terraform destroy` (explained in more detail later) to minimize unnecessary costs.

## Install

### Initial Setup

Follow the following sections in the main [README.md](../../README.md):

- Set Up AWS Account
- Install Terraform
- Install The AWS CLI
- Log In With AWS SSO
- Set The AWS_PROFILE Environment Variable
- Common Modules

If the SSO session has timed out, use `aws sso login -profile=my-profile-name` substituting the profile name selected
in general setup.

### Deploy SampleApiLambda

- Build the SampleApiLambda project in Release mode
- Navigate to the `iac/sample-api-lambda` directory
- Modify [provider.tf](../../iac/sample-api-lambda/provider.tf) and modify the s3 Terraform state bucket name to be unique
- Use `terraform apply` to deploy the system 

## Usage

Once the system is deployed:

- In the AWS Management Console, from the `Search` menu find `API Gateway` and open it
- Select the `Sample API Gateway` from the list of APIs
- Click the `Deploy API` button in the upper right hand corner
- Select the "staging" option from the `Stage` list and click `Deploy`
- Through the API Gateway stage tree, go to the `staging > / > /api > GET` path and copy the Invoke URL
- Use that URL to make a GET HTTP request with an HTTP client. `curl https://<youridentifier>.execute-api.us-east-1.amazonaws.com/staging/api`
is one way to accomplish this, as is the use of a client like Postman.

To clean up when done, run `terraform destroy`

## Badges

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
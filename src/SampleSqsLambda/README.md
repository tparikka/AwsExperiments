# Sample API - API Gateway w/Lambda

## Background

This project demonstrates how to establish an AWS Lambda that is triggered by a Simple Queue Service (SQS) message.
SQS is an AWS service that supports the ability to receive messages and events from various sources to be received
by other services. Amazon has an excellent document on [Event Driven Architecture](https://aws.amazon.com/event-driven-architecture)
that explains the concept further.

Using these directions will set up various AWS services, all of which have a free tier option:

- SQS - 1 Million Free Requests Per Month
- Lambda - 1 Million Free Requests Per Month

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

### Deploy SampleSqsLambda

- Build the SampleSqsApiLambda project in Release mode
- Navigate to the `iac/sample-api-lambda` directory
- Modify [provider.tf](../../iac/sample-sqs-lambda/provider.tf) and modify the s3 Terraform state bucket name to be unique
- Modify [messaging.tf](../../iac/sample-sqs-lambda/messaging.tf) and replace `first.last.nosuchemailexists@gmail.com` with
the developer's email address
- Use `terraform apply` to deploy the system
- Check the email inbox to confirm the subscription to SNS updates

## Usage

Once the system is deployed:

- In the AWS Management Console, from the `Search` menu find `Simple Queue Service` and open it
- Select the `sample-sqs-queue` from the list of queues
- Click the `Send and receive messages` button in the upper right hand corner
- Type a test message such as "test" in the `Message body`
- Click the `Send message` button in the upper right hand corner
- Monitor the developer's email address for an email with the test contents

Behind the scenes, the following is occurring:

- A message is published to the queue through the AWS Management Console
- The `aws_lambda_event_source_mapping` resource in [messaging.tf](../../iac/sample-sqs-lambda/messaging.tf) triggers
the Lambda to run with the specified message
- The Lambda function handler in [Function.cs](./Function.cs) picks up the message and publishes it to the SNS topic
defined in [messaging.tf](../../iac/sample-sqs-lambda/messaging.tf) where the topic subscription forwards it to the
developer

To clean up when done, run `terraform destroy`

## Badges

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
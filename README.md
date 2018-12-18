# --Work In Progress--

This repository is an example of setting up a Docker stack with JupyterLab for local development, with some helpful CloudFormation templates which allow you to execute a notebook *in the same enviroment* on an EC2 instance. There are many advantages to working in this way:

* local development is free
* your environment is consistent
* EC2 instances are very scalable
* CloudFormation allows programmatic control of all your AWS resources. Everything is deterministic and disposable.

## Setup

Some manual work is required to set up this workflow. The instructions here assume you are starting from scratch in AWS with a root account that currenty has no resources. 

**You run these templates entirely at your own risk, and you must accept responsibility for any costs incurred by doing so!**

First, apply the `CFN-IAMAdmin-EIP-InstanceRole.yaml` template using the console. This creates some an IAM user with admin powers, an Elastic ip, and an instance role we will reference in the other stack.

Once your IAM user has been created, use their access keys to set up a profile in `awscli` called 'DataScienceStack'

```bash
aws configure --profile DataScienceStack
```

Now tell Git to use AWS CodeCommit credential-helper:

```bash
git config --global credential.helper '!aws codecommit --profile DataScienceStack credential-helper $@'
```
```bash
git config --global credential.UseHttpPath true
```

Create a CodeCommit respository to hold your work, making a note of the value returned in the `cloneUrlHttp` field

```bash
aws codecommit --profile DataScienceStack create-repository --repository-name DataScienceStack
git remote set-url --add --push https://git-codecommit.eu-west-1.amazonaws.com/v1/repos/DataScienceStack
```

Push this repository to the CodeCommit repo:

```bash
git push <cloneUrlHttp> --all
```

Because of the instance role we set up in the first CloudFormation template, instances created by the second template will have read-only access to your CodeCommit repositories. This allows the instance to pull the repository and create the same Docker stack.


```bash
docker build -t <AWS Account ID>.dkr.ecr.eu-west-1.amazonaws.com/data-science-stack .
`aws ecr --profile DataScienceStack get-login --region eu-west-1 --no-include-email`
docker push <AWS Account ID>.dkr.ecr.eu-west-1.amazonaws.com/data-science-stack
```

## Normal Use

Stand up the EC2 stack using:

`aws cloudformation --profile DataScienceStack create-stack --stack-name EC2Test --template-body file://CFN-EC2-JupyterLab.yaml --parameters file://CFNParams-EC2-JupyterLab.json`

git push https://git-codecommit.eu-west-1.amazonaws.com/v1/repos/MyDemoRepo --all

This repo contains two cloudformation stacks which:

* set up an IAM admin user, an elastic ip, and an instance profile with restricted permissions
* stand up an EC2 instance which will run a notebook via papermill, push the output to S3 and delete it's own stack. The stack  has a timeout so that it will shutdown even if the job fails.

Things which must be done manually:

* Clone this repository into your own AWS CodeCommit repo. This is where the instance will pull the docker-compose file and any associated notebooks and libraries from
* Make a note of your IP to set the allowed incoming address range for the instance appropriately
* Create a keypar in the EC2 console
* Set up your `~/.ssh/config` file to use the private key you just generated for the elastic ip address reserved by the first stack

## AWS CloudFormation Templates

A collection of templates for setting up and managing a few things.

To find your external IP:
`dig TXT +short o-o.myaddr.l.google.com @ns1.google.com`

To stand up the jupyterlab stack:
```bash
aws cloudformation --profile personal create-stack --stack-name EC2Test --template-body file://EC2InstanceWithSecurityGroupSample.yaml --parameters file://EC2Parameters.json
```

To tear down the jupyterlab stack.
```bash
aws cloudformation --profile personal delete-stack --stack-name EC2Test
```

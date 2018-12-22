# Outline

This repository is a recipe for setting up a Docker stack with JupyterLab for local development, with some helpful scripts and CloudFormation templates which allow you to execute a Jupyter notebook *in the same enviroment* on an EC2 instance. The instance is associated with an ephemeral stack which will tear itself down after the job completes (or if it times out). There are many advantages to working in this way:

* local development is free
* EC2 instances are very scalable
* your environment is consistent
* CloudFormation allows tight control of your AWS resources

Some manual work is required to set up this workflow. You will need a basic understanding AWS services, terminal usage and Git. Many things will probably require tweaking to work on a Windows machine. If you make any improvements please submit a pull request!

![outline image](./docs/outline.svg)

# Setup

**You run these templates entirely at your own risk, and must accept responsibility for costs incurred by doing so!**

First, you will need an access key for an IAM user with admin powers. Specifically, this user needs permissions to:

* something
* something else

Configure your awscli to use this access key and id:

```bash
aws configure
```

You will also need to create an EC2 keypair and download the private key to your local machine. Once the key is downloaded, move it somewhere sensible and protect it:

```bash
mv ~/Downloads/aws-ec2.pem ~/.ssh/aws-ec2.pem && chmod 600 ~/.ssh/aws-ec2.pem
```

We will use this later to connect to our instances. Next, fork this repository and clone it to your local machine. 

You are now ready to apply the infrastructure CloudFormation stack. This stack creates resources which will be used by our remote jobs, specifically:

* An instance role to define the permissions given to the EC2 instance
* An S3 bucket to hold the output of the jobs
* An ECR repository to hold our environment image
* A CodeCommit repository which will mirror your local Git repository.

```bash
./create_infrastructure.sh
```

Note that if you are working on a Mac you will need to follow [these](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-unixes.html#setting-up-https-unixes-credential-helper) additional steps to stop your Keychain from storing the temporary password which the codecommit credential-helper provides to Git.

Now build the image we'll be using:

```bash
./run_build
```

# Usage

Now you're ready to use the environment.

For local development:

```bash
./run_local_server.sh
```

For remote development (remember to add your changes to the repository somehow):
```bash
./run_remote_server.sh
```

For running a job and pushing the output to S3:
```bash
./run_job relative-path-to-notebook
```

# Connecting to an Instance

The most basic way of checking on the status of your job is look at the progress of the stack creation in the CloudFormation Console. If this fails, then something is wrong with the template.

If this is fine, you may look at the instance itself in the EC2 console. This will tell you whether or not the instance exists and is running, but it gives no detail on what the instance is actually doing.

The best way to see what's going on is to SSH into the instance.

#### SSHing into an Instance

Set up your SSH config to use the private key we previously downloaded (`~/.ssh/aws-ec2.pem`) as the identity when connecting to the ip returned by one of the above scripts. The username should be `ec2-user`.

Once you are 'in', the most useful command is probably:

```bash
tail -f /var/log/cloud-init-output.log
```

------------------------

**Work in Progress**

------------------------


# Outline

This repository is a recipe for setting up a Docker stack with JupyterLab for local development, with some helpful scripts and CloudFormation templates which allow you to execute a Jupyter notebook *in the same enviroment* on an EC2 instance. The instance is associated with an ephemeral stack which will tear itself down after the job completes (or if it times out). There are many advantages to working in this way:

* local development is free
* EC2 instances are very scalable
* your environment is consistent
* CloudFormation allows tight control of your AWS resources

# Setup

**You run these templates entirely at your own risk, and must accept responsibility for costs incurred by doing so!**

First, you will need an access key for an IAM user with admin powers. Specifically, this user needs permissions to:

* something
* something else

Configure your awscli to use this access key and id:

```bash
aws configure
```

First, fork this repository and clone it to your local machine. 

You are now ready to apply the infrastructure CloudFormation stack. This stack creates resources which will be used by our remote jobs, specifically:

* An S3 bucket to hold the output of the jobs
* An ECR repository to hold our environment image
* A CodeCommit repository which will mirror your local Git repository.
* A key pair which will be used to SSH into instances, with the private key saved locally.

The script will also prompt you to create a password for remote jupyterlab access.

```bash
./create_infrastructure.sh
```

Note that if you are working on a Mac you will need to follow [these](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-unixes.html#setting-up-https-unixes-credential-helper) additional steps to stop your Keychain from storing the temporary password which the codecommit credential-helper provides to Git.

## Ephemeral Stack Parameters

Now to build the image you can run:

```bash
./run_build
```
This takes a basic jupterlab docker image and builds in a few extra packages and the .config file with your password created in the previous step. You must run this build script again whenever you make changes to the docker image which you want the remote environment to see - for example adding a package.

# Usage

Now you're ready to use the environment. 

For local development (you will need to wait for the image to download from ECR the first time you run this):

```bash
./run_local_server.sh
```

After creating a notebook locally you need to add it into the repository.

```bash
git add my-new-notebook
git commit -m 'a description of what it does'
git push origin master
git push codecommit master
```

For remote development:
```bash
./run_remote_server.sh
```

Remember that notebooks which you develop remotely do not exist in the repository unless you add them. Adding them from the remote machine is more difficult because the `notebooks` directory itself is not connected to git or codecommit. 

For running a job remotely from your local machine:
```bash
./run_job relative-path-to-notebook
```

Again, remember that the remote instance only has access to what is in the codecommit repository. Be sure to add any changes:

```bash
git add <changed file>; git commit -m 'description of change'; git push codecommit master; git push origin master
```

# Connecting to an Instance

The most basic way of checking on the status of your job is look at the progress of the stack creation in the CloudFormation Console. If this fails, then something is wrong with the template.

If this is fine, you may look at the instance itself in the EC2 console. This will tell you whether or not the instance exists and is running, but it gives no detail on what the instance is actually doing.

The best way to see what's going on is to SSH into the instance.

#### SSHing into an Instance

You can ssh into any of you instances using the private key created by `create_infrastructure.sh`.

```bash
ssh -i instance_key.pem ec2-user@<instance-ip>
```

Once you are 'in', the most useful command is probably:

```bash
tail -f /var/log/cloud-init-output.log
```

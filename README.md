# Outline

This repository is a recipe for setting up a Docker stack with JupyterLab for local development, with some helpful scripts and CloudFormation templates which allow you to execute a Jupyter notebook *in the same enviroment* on an EC2 instance. This instance exists in an ephemeral cloudformation stack which will tear itself down after the job completes (or if it times out). There are many advantages to working in this way:

* local development is free
* your environment is consistent
* EC2 instances are very scalable
* CloudFormation allows programmatic control of all your AWS resources

Some manual work is required to set up this workflow. The instructions here assume you are starting from scratch in AWS with a root account that currently has no resources. You will need a basic understanding of terminal usage, Git and Bash. Many things will probably require tweaking to work on a Windows machine. If you make any improvements to your forked version of the repository, please submit a pull request! [Guide for collaborators.]()

# Setup

**You run these templates entirely at your own risk, and must accept responsibility for costs incurred by doing so!**

**If things go wrong, go into the CloudFormation Console and delete any stacks to avoid paying for their resources.**

First, fork this repository so that you have your own copy. Clone it to your local machine and apply the `CFN-IAMAdmin-EIP-InstanceRole.yaml` template using the AWS Console in a browser. This creates an IAM user with admin powers, an ECR respository, an Elastic IP, a CodeCommit repository and an EC2 instance role we will reference in the other stack. The idea is that this stack creates all of the (mostly free) infrastructure we need to run the job, while the second ephemeral stack holds the expensive resources used for the job itself.

Once this CFN template has been succesfully created, go into the 'outputs' tab and make a note of the 'ProjectRepoAddress' field. This is the http address of the CodeCommit repository created by the template, which we will need later.

You also need to go into the EC2 Console and create an SSH keypair, making a note of the name you choose. You will be prompted to download the private key for this pair - do so, then move it to a sensible place and protect it. For example:

```bash
mv ~/Downloads/aws-ec2.pem ~/.ssh/aws-ec2.pem && chmod 600 ~/.ssh/aws-ec2.pem
```

We will use this later to connect to our instances.

Next, go into the IAM Console and create a fresh access key for your new IAM user. 

**Treat this key as a sensitive password**. You have delegated root powers of your AWS account to this IAM user. Misuse of the key could cost you a lot of money.

Configure your local `awscli` to use this access key ID and secret key :

```bash
aws configure --profile DataScienceStack
```

The key would now be associated with a profile called `DataScienceStack`. If this clashes with your existing configuration then you should change this name to something else. You will also be prompted for region and output format during the configuration. This guide was written with `eu-west-2` (London), and `json` in mind. Make sure that you are consistent with your region choice in the Console (upper right corner) when looking at resources online. 

Now tell your local Git installation to use the AWS CodeCommit credential-helper:

```bash
git config --global credential.helper '!aws codecommit --profile DataScienceStack credential-helper $@'
```
```bash
git config --global credential.UseHttpPath true
```

Add the CodeCommit repository as a push destination, using the address you noted previously:

```bash
git remote set-url --add --push origin <repository address>
```

Now any pushes for this repository will also go to CodeCommit. Let's do an initial push to see what happens:

```bash
git push origin master
```

Note that if you are working on a Mac you will need to follow [these](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-unixes.html#setting-up-https-unixes-credential-helper) additional steps to stop your Keychain from unhelpfully storing the temporary password which the credential-helper provides to Git.

Now we are 90% of the way there. We have all our infrastructure, and the code in your local Git repository is mirrored in CodeCommit. The first thing we will use this setup for is building the Docker image:


## Building the image

The first stack created an ECR repository which we will keep our image in. Other stacks are able to import the location of this repository, which allows instances in EC2 to get very quick access to the image. 

Pushing remotely to ECR can be slow, and building images on a local machine can be a pain. Let's use our stack to build the image for us with a disposable EC2 instance.

Running the `CFN-build-and-push.yaml` template will:

```bash
docker build -t <AWS Account ID>.dkr.ecr.eu-west-2.amazonaws.com/data-science-stack .
`aws ecr --profile DataScienceStack get-login --region eu-west-2 --no-include-email`
docker push <AWS Account ID>.dkr.ecr.eu-west-2.amazonaws.com/data-science-stack
```

* create an EC2 instance
* install Docker on that instance
* run Docker `build`
* `push` the resulting image to your ECR repository.
* shut down the instance

This may take 30 minutes or so. While this is running, let's go through some ways of checking on the status of the job.

## Connecting to an Instance

The most basic way of checking on the status of your job is look at the progress of the stack creation in the CloudFormation Console. If this fails, then something is wrong with the template.

If this is fine, you may look at the instance itself in the EC2 console. This will tell you whether or not the instance exists and is running happily, but it gives no detail on what the instance is actually doing.

The best way to see what's going on is to SSH into the instance.

#### SSHing into an Instance

Your instance should be associated with an Elastic IP created by the first stack. You can find the address for this IP in the Console in the outputs of the CloudFormation stack, or in the EC2 monitoring tab for the instance. Make a note of this addres and set up your SSH config to use the private key we previously downloaded (`~/.ssh/aws-ec2.pem`) as the identity when connecting to this host. The username should be `ec2-user`.

Once you are 'in', the most useful command is probably:

```bash
tail -f /var/log/cloud-init-output.log
```

This givs you the standard output created by the script (CloudFormation User Data) which installs docker then runs your job.

# Normal Use

Assuming the build went smoothly, we can now use this setup to run arbitrary notebooks from within the reopsitory! Let's finish by runnings the example notebook from this repository:

```bash
aws cloudformation --profile DataScienceStack create-stack --stack-name EC2Test --template-body file://CFN-EC2-JupyterLab.yaml --parameters file://CFNParams-EC2-JupyterLab.json`
```

You should see the output of this job in S3.


# Errata

Remember that the EC2 instances only have access to the version of the repository that is in CodeCommit; if you make changes locally or only push them to GitHub, the instance will not see them. 

Stand up the EC2 stack using:

`aws cloudformation --profile DataScienceStack create-stack --stack-name EC2Test --template-body file://CFN-EC2-JupyterLab.yaml --parameters file://CFNParams-EC2-JupyterLab.json`

git push https://git-codecommit.eu-west-2.amazonaws.com/v1/repos/MyDemoRepo --all

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

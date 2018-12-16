# --Work In Progress--

Tell Git to use AWS CodeCommit credential-helper:

`git config --global credential.helper '!aws codecommit --profile DataScienceStack credential-helper $@'`
`git config --global credential.UseHttpPath true`

Create a repository to use for this project:

`aws codecommit --profile DataScienceStack create-repository --repository-name DataScienceStack`

Make a note of the value returned in the `cloneUrlHttp` field.

Push this repository to the CloudCommit repo using:

`git push <cloneUrlHttp> --all`

Stand up the EC2 stack using:

`aws cloudformation --profile DataScienceStack create-stack --stack-name EC2Test --template-body file://CFN-EC2-JupyterLab.yaml --parameters file://CFNParams-EC2-JupyterLab.json`

git push https://git-codecommit.us-east-2.amazonaws.com/v1/repos/MyDemoRepo --all

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

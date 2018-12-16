# --Work In Progress--

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

[![Build Status](https://api.travis-ci.org/wallix/awless-templates.svg?branch=master)](https://travis-ci.org/wallix/awless-templates)

[Twitter](http://twitter.com/awlessCLI) | [Wiki](https://github.com/wallix/awless/wiki) | [Changelog](https://github.com/wallix/awless/blob/master/CHANGELOG.md#readme)

# awless templates

Repository to collect official, verified and runnable templates for the [awless CLI](https://github.com/wallix/awless)

**You need at least awless version v0.1.3 to run those examples**

Here are some non exhaustive [Examples](https://github.com/wallix/awless/wiki/Examples) of what you can do with templates. You can also read more about [awless templates](https://github.com/wallix/awless/wiki/Templates)

## Continuous Integration

On each change all templates are verified & compiled against the latest version of `awless`.

You can run the verification locally with:

    go get github.com/wallix/awless  # if needed
    go test -v

# Examples


* [ECS Autoscaling Cluster](#ecs-autoscaling-cluster)
* [Awless readonly group](#awless-readonly-group)
* [Pre-defined policies for awless users](#pre-defined-policies-for-awless-users)
* [Awless readwrite group](#awless-readwrite-group)
* [Create a postgres instance](#create-a-postgres-instance)
* [Group of instances scaling with CPU consumption](#group-of-instances-scaling-with-cpu-consumption)
* [Highly-available wordpress infrastructure](#highly-available-wordpress-infrastructure)
* [Install awless scheduler](#install-awless-scheduler)
* [Create an instance accessible with ssh with a new keypair](#create-an-instance-accessible-with-ssh-with-a-new-keypair)
* [Create an instance with preinstalled awless with completion](#create-an-instance-with-preinstalled-awless-with-completion)
* [Create an instance with preconfigured awless and awless-scheduler](#create-an-instance-with-preconfigured-awless-and-awless-scheduler)
* [Create an instance with tags and public IP](#create-an-instance-with-tags-and-public-ip)
* [Create a classic Kafka infra](#create-a-classic-kafka-infra)
* [Create VPC with a Linux host bastion](#create-vpc-with-a-linux-host-bastion)
* [Create a dbsubnetgroups](#create-a-dbsubnetgroups)
* [Attach usual readonly AWS policies (set of permissions) on group](#attach-usual-readonly-aws-policies-(set-of-permissions)-on-group)
* [Create a public network enabling routing from the Internet](#create-a-public-network-enabling-routing-from-the-internet)
* [Create a AWS role with usual readonly policies that applies on a resource](#create-a-aws-role-with-usual-readonly-policies-that-applies-on-a-resource)
* [Create a AWS role with usual readonly policies that applies on a user](#create-a-aws-role-with-usual-readonly-policies-that-applies-on-a-user)
* [Create a static website on S3](#create-a-static-website-on-s3)
* [Simple wordpress deployment](#simple-wordpress-deployment)
* [Upload Image from local file](#upload-image-from-local-file)
* [Create a user with its SDK/Shell access key and console password](#create-a-user-with-its-sdk/shell-access-key-and-console-password)
* [Create a VPC with its internet routing gateway](#create-a-vpc-with-its-internet-routing-gateway)
* [Create a VPC with 3 internal subnets](#create-a-vpc-with-3-internal-subnets)
* [Highly-available wordpress behind a loadbalancer, with a RDS database](#highly-available-wordpress-behind-a-loadbalancer,-with-a-rds-database)


### ECS Autoscaling Cluster


**-> Minimal awless version required: v0.1.3**



*Note that the AMI in this template is working only in eu-west-1 region*



**tags**: 
autoscaling, container, infra


(run it locally with: `awless run repo:ECS_autoscaling_cluster -v`)



**STEPS**

 First, create the ECS cluster with `awless create containercluster name={cluster.name}`.
 Then, create a policy to allow to connect to ECS

```sh
policy = create policy name=AWSEC2ContainerServiceforEC2Role effect=Allow resource="*" description="Access for ECS containers" action=[ecs:DeregisterContainerInstance,ecs:DiscoverPollEndpoint,ecs:Poll,ecs:RegisterContainerInstance,ecs:StartTelemetrySession,ecs:Submit*,ecr:GetAuthorizationToken,ecr:BatchCheckLayerAvailability,ecr:GetDownloadUrlForLayer,ecr:BatchGetImage,logs:CreateLogStream,logs:PutLogEvent]

```
 Set role name variable

```sh
roleName = AWSEC2ContainerServiceRole

```
 Create a AWS role that applies on a resource

```sh
create role name=$roleName principal-service="ec2.amazonaws.com" sleep-after=15

```
 Attach the policy to the role

```sh
attach policy arn=$policy role=$roleName

```
 Create the ECS instances launch configuration.
 The instances must be launched with a userdata file containing:
 ```sh
 !/bin/bash
 echo ECS_CLUSTER=ecs-cluster-name >> /etc/ecs/ecs.config
 ```

```sh
launchconfig = create launchconfiguration image=ami-95f8d2f3 keypair={instance.keypair} name=ECSClusterLaunchconfig type={instance.type} userdata={instance.userdata} role=$roleName

```
 Create the scalinggroup

```sh
create scalinggroup desired-capacity={scalinggroup.desired-capacity} launchconfiguration=$launchconfig max-size={scalinggroup.desired-capacity} min-size={scalinggroup.desired-capacity} name=ecsClusterScalingGroup subnets={instance.subnets}
```



### Awless readonly group







(run it locally with: `awless run repo:awless_readonly_group -v`)



**STEPS**

 Here we define a group that allow users in that group
 to use the `awless` CLI in a readonly mode (i.e. sync, listing).

 Create group name variable:

```sh
groupName = AwlessReadOnlyPermissionsGroup

```
 Create the group:

```sh
create group name=$groupName

```
 Attach corresponding readonly AWS policies (set of permissions) on group related to the `awless` services:

```sh
attach policy arn=arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/IAMReadOnlyAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AWSLambdaReadOnlyAccess group=$groupName
```



### Pre-defined policies for awless users


**-> Minimal awless version required: v0.1.3**



*Useful pre-defined readonly & readwrite policies for awless users*




(run it locally with: `awless run repo:awless_readonly_policies -v`)



**STEPS**

 Infra resources

```sh
create policy name=AwlessInfraReadonlyPolicy effect=Allow resource="*" description="Readonly access to infra resources" action=[ec2:Describe*,autoscaling:Describe*,elasticloadbalancing:Describe*]

```
 Access resources

```sh
create policy name=AwlessAccessReadonlyPolicy effect=Allow resource="*" description="Readonly access to access resources" action=[iam:GenerateCredentialReport,iam:GenerateServiceLastAccessedDetails,iam:Get*,iam:List*,sts:Get*]

```
 Storage resources

```sh
create policy name=AwlessStorageReadonlyPolicy effect=Allow resource="*" description="Readonly access to storage resources" action=[s3:Get*,s3:List*]

```
 Messaging resources

```sh
create policy name=AwlessMessagingReadonlyPolicy effect=Allow resource="*" description="Readonly access to notification and queueing for messaging resources" action=[sns:GetTopicAttributes,sns:List*,sqs:GetQueueAttributes,sqs:ListQueues]

```
 Lambda resources

```sh
create policy name=AwlessLambdaReadonlyPolicy effect=Allow resource="*" description="Readonly access to lambda resources" action=[cloudwatch:Describe*,cloudwatch:Get*,cloudwatch:List*,cognito-identity:ListIdentityPools,cognito-sync:GetCognitoEvents,dynamodb:BatchGetItem,dynamodb:DescribeStream,dynamodb:DescribeTable,dynamodb:GetItem,dynamodb:ListStreams,dynamodb:ListTables,dynamodb:Query,dynamodb:Scan,events:List*,events:Describe*,iam:ListRoles,kinesis:DescribeStream,kinesis:ListStreams,lambda:List*,lambda:Get*,logs:DescribeMetricFilters,logs:GetLogEvents,logs:DescribeLogGroups,logs:DescribeLogStreams,s3:Get*,s3:List*,sns:ListTopics,sns:ListSubscriptions,sns:ListSubscriptionsByTopic,sqs:ListQueues,tag:GetResources,kms:ListAliases,ec2:DescribeVpcs,ec2:DescribeSubnets,ec2:DescribeSecurityGroups,iot:GetTopicRules,iot:ListTopicRules,iot:ListPolicies,iot:ListThings,iot:DescribeEndpoint]

```
 DNS resources

```sh
create policy name=AwlessDNSReadonlyPolicy effect=Allow resource="*" description="Readonly access to DNS resources" action=[route53:Get*,route53:List*,route53:TestDNSAnswer,route53domains:Get*,route53domains:List*]

```
 Monitoring resources

```sh
create policy name=AwlessMonitoringReadonlyPolicy effect=Allow resource="*" description="Readonly access to monitoring resources" action=[autoscaling:Describe*,cloudwatch:Describe*,cloudwatch:Get*,cloudwatch:List*,logs:Get*,logs:Describe*,logs:TestMetricFilter,sns:Get*,sns:List*]

```
 CDN resources

```sh
create policy name=AwlessCDNReadonlyPolicy effect=Allow resource="*" description="Readonly access to CDN resources" action=[acm:ListCertificates,cloudfront:Get*,cloudfront:List*,iam:ListServerCertificates,route53:List*,waf:ListWebACLs,waf:GetWebACL]

```
 Cloud formation resources

```sh
create policy name=AwlessCloudFormationReadonlyPolicy effect=Allow resource="*" description="Readonly access to CloudFormation resources" action=[cloudformation:DescribeStacks,cloudformation:DescribeStackEvents,cloudformation:DescribeStackResource,cloudformation:DescribeStackResources,cloudformation:GetTemplate,cloudformation:List*]
```



### Awless readwrite group







(run it locally with: `awless run repo:awless_readwrite_group -v`)



**STEPS**

 Here we define a group that allow users in that group to use the `awless` CLI in write mode.

 Create group name variable:

```sh
groupName = AwlessReadWritePermissionsGroup

```
 Create the group:

```sh
create group name=$groupName

```
 Attach corresponding AWS policies (set of permissions) on group related to the `awless` services:

```sh
attach policy arn=arn:aws:iam::aws:policy/AmazonEC2FullAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonS3FullAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonSNSFullAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonSQSFullAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonVPCFullAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AutoScalingFullAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonRDSFullAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AmazonRoute53FullAccess group=$groupName
attach policy arn=arn:aws:iam::aws:policy/AWSLambdaFullAccess group=$groupName

```
 Note that we keep the IAM access readonly

```sh
attach policy arn=arn:aws:iam::aws:policy/IAMReadOnlyAccess group=$groupName
```



### Create a postgres instance


**-> Minimal awless version required: v0.1.7**



*Create a private basic postgres instance with firewall. As an example, instance has only basic required properties filled in*




(run it locally with: `awless run repo:db_postgres -v`)



**STEPS**

 Create a new VPC open to Internet to host the subnets

```sh
vpc = create vpc cidr=10.0.0.0/16 name=postgres-vpc
gateway = create internetgateway
attach internetgateway id=$gateway vpc=$vpc

```
 Create a route table for this network

```sh
rtable = create routetable vpc=$vpc

```
 Enable routing from the Internet

```sh
create route cidr=0.0.0.0/0 gateway=$gateway table=$rtable

```
 One public subnet to later deploy or host public applications or a bastion to access your private DBs

```sh
pubsubnet = create subnet cidr=10.0.128.0/20 vpc=$vpc name=public-subnet
update subnet id=$pubsubnet public=true

```
 Make the public subnet open to the Internet (through vpc that has an internetgateway)

```sh
attach routetable id=$rtable subnet=$pubsubnet

```
 Two private subnet to constitute the dbsubnetgroup hosting the DB

```sh
privsubnet1 = create subnet cidr=10.0.0.0/19 vpc=$vpc name=postgres-priv-subnet1 availabilityzone={availabilityzone.1}
privsubnet2 = create subnet cidr=10.0.32.0/19 vpc=$vpc name=postgres-priv-subnet2 availabilityzone={availabilityzone.2}
subnetgroup = create dbsubnetgroup subnets=[$privsubnet1, $privsubnet2] name=PostgresDBSubnetGroup description="DB subnet group hosting postgres instances"

```
 Firewall for the postgres instance

```sh
postgres_sg = create securitygroup name=postgres description='Postgres firewall access' vpc=$vpc
update securitygroup id=$postgres_sg inbound=authorize protocol=tcp portrange=5432 cidr=10.0.0.0/16

```
 Create the database and connect to it through: `psql --host=? --port=5432 --username=? --password --dbname=?`

```sh
create database engine=postgres id={database.identifier} subnetgroup=$subnetgroup  password={password.minimum8chars} dbname={database.name} size=5 type=db.t2.small username={database.username} vpcsecuritygroups=$postgres_sg

```
 Create a small jump instance in your public subnet to run command on your postgres DB
 and give SSH access to this instance with a SSH security group
 Run the CLI with: awless .... office.ip=$(awless whoami --ip-only)

```sh
sshsecgroup = create securitygroup vpc=$vpc description="SSH access from office IP only" name=ssh-from-office
update securitygroup id=$sshsecgroup inbound=authorize protocol=tcp cidr={office.ip}/32 portrange=22
create instance distro=debian keypair={my.keypair} name=jump subnet=$pubsubnet securitygroup=$sshsecgroup type=t2.micro

```
 Then to administrate your DB you can do:
 $ HOST=$(awless show production --values-for PublicDNS --local)
 $ awless ssh jump
 $ sudo apt-get update; sudo apt-get install -y postgresql-client-9.4
 $ psql --host={VALUE FROM HOST ABOVE} --port=5432 --username=... --password --dbname=...



### Group of instances scaling with CPU consumption




*Create an autoscaling group of instances and watch their CPU to dynamically allocate/delete instances when needed.*



**tags**: 
infra, autoscaling


(run it locally with: `awless run repo:dynamic_autoscaling_watching_CPU -v`)



**STEPS**

 Create the instances launch configuration

```sh
launchconfig = create launchconfiguration image={instance.image} keypair={instance.keypair} name=scalingLaunchConf type={instance.type}

```
 Create the scalinggroup

```sh
create scalinggroup desired-capacity=2 launchconfiguration=$launchconfig max-size={instance.max-number} min-size={instance.min-number} name=instancesScalingGroup subnets={instance.subnets}

```
 Create a scaling policy to add instances (scale-in) and a scaling policy to remove instances (scale-out)

```sh
adjustmentType = ChangeInCapacity
scalein = create scalingpolicy adjustment-scaling=1 adjustment-type=$adjustmentType name=policy-scaling-in scalinggroup=instancesScalingGroup
scaleout = create scalingpolicy adjustment-scaling=-1 adjustment-type=$adjustmentType name=policy-step-scaling-2 scalinggroup=instancesScalingGroup

```
 metrics statistic functions

```sh
statFunction = Average
alarmThreshold = 75
monitoredMetric = CPUUtilization

```
 Add a monitoring alarm to enable scalein when CPU load is above 75% during 2 * 5 min

```sh
create alarm namespace=AWS/EC2 dimensions=AutoScalingGroupName:instancesScalingGroup evaluation-periods=2 metric=$monitoredMetric name=scaleinAlarm operator=GreaterThanOrEqualToThreshold period=300 statistic-function=$statFunction threshold=$alarmThreshold
attach alarm name=scaleinAlarm action-arn=$scalein

```
 Add a monitoring alarm to enable scaleout when CPU load is below 75% during 2 * 5 min

```sh
create alarm namespace=AWS/EC2 dimensions=AutoScalingGroupName:instancesScalingGroup evaluation-periods=2 metric=$monitoredMetric name=scaleoutAlarm operator=LessThanOrEqualToThreshold period=300 statistic-function=$statFunction threshold=$alarmThreshold
attach alarm name=scaleoutAlarm action-arn=$scaleout
```



### Highly-available wordpress infrastructure


**-> Minimal awless version required: v0.1.7**





**tags**: 
infra


(run it locally with: `awless run repo:highly_available_wordpress_infra -v`)



**STEPS**

 1. Basic networking
 VPC and its Internet gateway

```sh
vpc = create vpc cidr=10.0.0.0/16 name=wordpress-ha-vpc
igw = create internetgateway
attach internetgateway id=$igw vpc=$vpc
pubSub1 = create subnet cidr=10.0.100.0/24 vpc=$vpc name=wordpress-ha-public-subnet-1 availabilityzone={availabilityzone.1}
update subnet id=$pubSub1 public=true
pubSub2 = create subnet cidr=10.0.101.0/24 vpc=$vpc name=wordpress-ha-public-subnet-2 availabilityzone={availabilityzone.2}
update subnet id=$pubSub2 public=true
rt = create routetable vpc=$vpc
create route table=$rt cidr=0.0.0.0/0 gateway=$igw
attach routetable id=$rt subnet=$pubSub1
attach routetable id=$rt subnet=$pubSub2

```
 2 private subnets in different AZs

```sh
privSub1 = create subnet cidr=10.0.10.0/24 vpc=$vpc name=wordpress-ha-private-subnet-1 availabilityzone={availabilityzone.1}
privSub2 = create subnet cidr=10.0.11.0/24 vpc=$vpc name=wordpress-ha-private-subnet-2 availabilityzone={availabilityzone.2}

```
 NAT Gateway in public subnet with a fixed IP

```sh
ip = create elasticip
natgw = create natgateway elasticip-id=$ip subnet=$pubSub1
check natgateway id=$natgw state=available timeout=180

```
 Routing between private subnets and NAT gateway

```sh
natgw_rtable = create routetable vpc=$vpc
attach routetable id=$natgw_rtable subnet=$privSub1
attach routetable id=$natgw_rtable subnet=$privSub2
create route cidr=0.0.0.0/0 gateway=$natgw table=$natgw_rtable

```
 2. Provision loadbalancer
 Create the load balancer security group

```sh
lbsecgroup = create securitygroup vpc=$vpc description="authorize HTTP from the internet" name=wordpress-ha-lb-securitygroup
update securitygroup id=$lbsecgroup inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=80

```
 Provision the load balancer listening in the public subnets, with its target group and HTTP listener

```sh
tg = create targetgroup name=wordpress-ha-workers port=80 protocol=HTTP vpc=$vpc
update targetgroup id=$tg stickiness=true
lb = create loadbalancer name=wordpress-ha-loadbalancer subnets=[$pubSub1,$pubSub2] securitygroups=$lbsecgroup
create listener actiontype=forward loadbalancer=$lb port=80 protocol=HTTP targetgroup=$tg

```
 3. Provision instances
 Create keypair and instance

```sh
keypair = create keypair name={keypair.name}
instSecGroup = create securitygroup vpc=$vpc description="HTTP + SSH within VPC" name=wordpress-ha-private-secgroup
update securitygroup id=$instSecGroup inbound=authorize cidr=10.0.0.0/16 portrange=22
update securitygroup id=$instSecGroup inbound=authorize cidr=10.0.0.0/16 portrange=80
launchconf = create launchconfiguration distro=amazonlinux keypair=$keypair name=wordpress-ha-launch-configuration type={instance.type} userdata=https://raw.githubusercontent.com/zn3zman/AWS-WordPress-Creation/master/WP-Setup.sh securitygroups=$instSecGroup
create scalinggroup desired-capacity=2 launchconfiguration=$launchconf max-size=2 min-size=2 name=wordpress-scalinggroup subnets=[$privSub1, $privSub2] targetgroups=$tg
```



### Install awless scheduler


**-> Minimal awless version required: v0.1.7**






(run it locally with: `awless run repo:install_awless_scheduler -v`)


*Full CLI example:*
```sh
awless run repo:install_awless_scheduler
```


**STEPS**

 Launch new instance running remote user data script installing awless

```sh
create instance name={instance.name} distro=canonical:ubuntu type=t2.nano keypair={ssh.keypair} userdata=https://raw.githubusercontent.com/wallix/awless-templates/master/userdata/ubuntu/install_awless_scheduler.sh role={role.name}
```



### Create an instance accessible with ssh with a new keypair






**tags**: 
infra, ssh


(run it locally with: `awless run repo:instance_ssh -v`)



**STEPS**

 Create a new security group for this instance

```sh
securitygroup = create securitygroup vpc={instance.vpc} description={securitygroup.description} name=ssh-from-internet

```
 Authorize access on port 22 to instances in this security group

```sh
update securitygroup id=$securitygroup inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=22

```
 Create a new keypair

```sh
keypair = create keypair name={keypair.name}

```
 Create an instance in this security group accessible with the new keypair

```sh
create instance subnet={instance.subnet} image={instance.image} type={instance.type} keypair=$keypair name={instance.name} count=1 securitygroup=$securitygroup
```



### Create an instance with preinstalled awless with completion






**tags**: 
infra, awless


(run it locally with: `awless run repo:instance_with_awless -v`)



**STEPS**

 role name variable

```sh
roleName = {awless.role-name}

```
 Create a AWS role that applies on a resource

```sh
create role name=$roleName principal-service="ec2.amazonaws.com" sleep-after=10

```
 Attach typical necessary awless readonly permissions to the role

```sh
attach policy role=$roleName service=ec2 access=readonly
attach policy role=$roleName service=s3 access=readonly
attach policy role=$roleName service=sns access=readonly
attach policy role=$roleName service=sqs access=readonly
attach policy role=$roleName service=vpc access=readonly
attach policy role=$roleName service=autoscaling access=readonly
attach policy role=$roleName service=iam access=readonly
attach policy role=$roleName service=rds access=readonly
attach policy role=$roleName service=route53 access=readonly
attach policy role=$roleName service=lambda access=readonly

```
 Launch new instance running remote user data script installing awless

```sh
create instance name=awless-commander type=t2.nano keypair={ssh.keypair} userdata=https://raw.githubusercontent.com/wallix/awless-templates/master/userdata/install_awless.yml role=$roleName
```



### Create an instance with preconfigured awless and awless-scheduler






**tags**: 
infra, awless, awless-scheduler


(run it locally with: `awless run repo:instance_with_awless_scheduler -v`)



**STEPS**

 Awless scheduler role variable

```sh
roleName = {awless-scheduler.role-name}

```
 First we define a role that an EC2 instance can assume to use awless/awless-scheduler (write mode)

```sh
create role name=$roleName principal-service="ec2.amazonaws.com" sleep-after=10

```
 Attach typical necessary awless permissions to the role

```sh
attach policy role=$roleName service=ec2 access=full
attach policy role=$roleName service=s3 access=full
attach policy role=$roleName service=sns access=full
attach policy role=$roleName service=sqs access=full
attach policy role=$roleName service=vpc access=full
attach policy role=$roleName service=autoscaling access=full
attach policy role=$roleName service=rds access=full
attach policy role=$roleName service=route53 access=full
attach policy role=$roleName service=lambda access=full

```
 We keep IAM on read only mode

```sh
attach policy role=$roleName service=iam access=readonly

```
 Launch new instance running remote user data script installing awless

```sh
create instance name=AwlessWithScheduler type=t2.nano keypair={ssh.keypair} userdata=https://raw.githubusercontent.com/wallix/awless-templates/master/userdata/install_awless_suite.yml role=$roleName
```



### Create an instance with tags and public IP




*Create an instance with mulitple tags and attach to it an elastic IP*




(run it locally with: `awless run repo:instance_with_tags_and_publicip -v`)



**STEPS**


```sh
inst = create instance subnet={instance.subnet} image={instance.image} type={instance.type} keypair={instance.keypair} name={instance.name} securitygroup={instance.securitygroup}

```
 Putting a tag on the instance

```sh
create tag resource=$inst key={instance.tagkey} value={instance.tagvalue}

```
 Creating a elastic IP

```sh
pubip = create elasticip domain=vpc

```
 Attaching the IP onto the instance

```sh
attach elasticip id=$pubip instance=$inst
```



### Create a classic Kafka infra


**-> Minimal awless version required: v0.1.7**



*Create a classic Kafka infra: brokers, 1 zookeeper instance*




(run it locally with: `awless run repo:kafka_infra -v`)


*Full CLI example:*
```sh
awless run repo:kafka_infra remote-access.cidr=$(awless whoami --ip-only)/32 broker.instance.type=t2.medium zookeeper.instance.type=t2.medium
```


**STEPS**

 Create the VPC and its internet gateway

```sh
vpc = create vpc cidr=10.0.0.0/16 name=kafka-vpc
igw = create internetgateway
attach internetgateway id=$igw vpc=$vpc

```
 Create a public subnet

```sh
subnet_cidr = 10.0.0.0/24
subnet = create subnet cidr=$subnet_cidr vpc=$vpc name=kafka-subnet
update subnet id=$subnet public=true
routetable = create routetable vpc=$vpc
attach routetable subnet=$subnet id=$routetable
create route cidr=0.0.0.0/0 gateway=$igw table=$routetable

```
 Create securitygroup for SSH: opening port 22 for all IPs

```sh
sshsecgroup = create securitygroup vpc=$vpc description=SSHSecurityGroup name=SSHSecurityGroup
update securitygroup id=$sshsecgroup inbound=authorize protocol=tcp cidr={remote-access.cidr} portrange=22

```
 Create securitygroup for Kafka instances (brokers & zookeeper)

```sh
kafkasecgroup = create securitygroup vpc=$vpc description=KafkaSecurityGroup name=KafkaSecurityGroup
update securitygroup id=$kafkasecgroup inbound=authorize protocol=tcp cidr=$subnet_cidr portrange=0-65535

```
 Create a role with policy for ec2 resources so that an instance can list other instances using a local `awless`

```sh
create role name=EC2ReadonlyRole principal-service="ec2.amazonaws.com" sleep-after=20
attach policy role=EC2ReadonlyRole service=ec2 access=readonly

```
 Create Zookeeper instance with security groups attached

```sh
zookeeper = create instance name=zookeeper distro=redhat type={zookeeper.instance.type} keypair={keypair.name} subnet=$subnet securitygroup=[$sshsecgroup,$kafkasecgroup] userdata=https://raw.githubusercontent.com/wallix/awless-templates/master/userdata/redhat/zookeeper.sh

```
 Wait the Zookeeper instance is up and running

```sh
check instance id=$zookeeper state=running timeout=180

```
 Create Kafka broker instances with role created above and security groups attached

```sh
broker_1 = create instance name=broker_1 distro=redhat type={broker.instance.type} keypair={keypair.name} subnet=$subnet role=EC2ReadonlyRole securitygroup=[$sshsecgroup,$kafkasecgroup] userdata=https://raw.githubusercontent.com/wallix/awless-templates/master/userdata/redhat/kafka.sh
broker_2 = create instance name=broker_2 distro=redhat type={broker.instance.type} keypair={keypair.name} subnet=$subnet role=EC2ReadonlyRole securitygroup=[$sshsecgroup,$kafkasecgroup] userdata=https://raw.githubusercontent.com/wallix/awless-templates/master/userdata/redhat/kafka.sh
broker_3 = create instance name=broker_3 distro=redhat type={broker.instance.type} keypair={keypair.name} subnet=$subnet role=EC2ReadonlyRole securitygroup=[$sshsecgroup,$kafkasecgroup] userdata=https://raw.githubusercontent.com/wallix/awless-templates/master/userdata/redhat/kafka.sh
```



### Create VPC with a Linux host bastion


**-> Minimal awless version required: v0.1.3**



*This template build this typical Linux bastion [architecture](http://docs.aws.amazon.com/quickstart/latest/linux-bastion/architecture.html) except it only deploys one host bastion on one public subnet*



**tags**: 
infra


(run it locally with: `awless run repo:linux_bastion -v`)



**STEPS**

 Create a new VPC and make it public with an internet gateway

```sh
vpc = create vpc cidr=10.0.0.0/16 name=BastionVpc
gateway = create internetgateway
attach internetgateway id=$gateway vpc=$vpc

```
 Create 2 private subnets each on a different availability zone
 That is where you will deploy resources only accessible through the bastion

```sh
create subnet cidr=10.0.0.0/19 name=PrivSubnet1 vpc=$vpc availabilityzone={availabilityzone.1}
create subnet cidr=10.0.32.0/19 name=PrivSubnet2 vpc=$vpc availabilityzone={availabilityzone.2}

```
 Create the the public subnet hosting the bastion

```sh
pubSubnet = create subnet cidr=10.0.128.0/20 name=PubSubnet1 vpc=$vpc availabilityzone={availabilityzone.1}
update subnet id=$pubSubnet public=true

```
 Create a route table (with routing only allowed within VPC by default)

```sh
rtable = create routetable vpc=$vpc

```
 Make the public subnet use the route table

```sh
attach routetable id=$rtable subnet=$pubSubnet
create route cidr=0.0.0.0/0 gateway=$gateway table=$rtable

```
 Create the firewall with the remote access CIDR applied on each bastion host

```sh
bastionSecGroup = create securitygroup vpc=$vpc description=BastionSecGroup name=bastion-secgroup
update securitygroup id=$bastionSecGroup inbound=authorize protocol=tcp cidr={remoteaccess-cidr} portrange=22
update securitygroup id=$bastionSecGroup inbound=authorize protocol=icmp cidr={remoteaccess-cidr} portrange=any

```
 Allow only a set of permitted actions for the 2 host bastions

```sh
create role name=BastionHostRole principal-service=ec2.amazonaws.com sleep-after=30
bastionEc2Policy = create policy name=BastionEc2Permissions action=[ec2:DescribeAddresses,ec2:AssociateAddress] resource="*" effect=Allow
attach policy role=BastionHostRole arn=$bastionEc2Policy

```
 Create one elastic IPs for that will be dynamically aasigned to the host bastion by the bootstrap script

```sh
create elasticip domain=vpc

```
 Create the autoscaling group

```sh
launchConfig = create launchconfiguration image={instance.image} keypair={keypair.name} securitygroups=$bastionSecGroup name=BastionHostsLaunchConfig type=t2.micro role=BastionHostRole userdata=https://raw.githubusercontent.com/wallix/awless-templates/master/userdata/prepare_bastion.yml
create scalinggroup desired-capacity=1 launchconfiguration=$launchConfig max-size=1 min-size=1 name=autoscaling-instances-group subnets=$pubSubnet
```



### Create a dbsubnetgroups




*Create 2 subnets on different availability zones to later on constitute the dbsubnet group*




(run it locally with: `awless run repo:new_dbsubnetgroup -v`)


*Full CLI example:*
```sh
run repo:new_dbsubnetgroup.draft first.subnet.cidr=10.0.0.0/25 first.subnet.availabilityzone=us-west-1a second.subnet.cidr=10.0.0.128/25 second.subnet.availabilityzone=us-west-1c vpc.cidr=10.0.0.0/24 vpc.name=myvpc
```


**STEPS**

 Create a new VPC open to Internet to host the subnets

```sh
vpc = create vpc cidr={vpc.cidr} name={vpc.name}
gateway = create internetgateway
attach internetgateway id=$gateway vpc=$vpc
firstsubnet = create subnet cidr={first.subnet.cidr} vpc=$vpc name={first.subnet.name} availabilityzone={first.subnet.availabilityzone}
update subnet id=$firstsubnet public=true
secondsubnet = create subnet cidr={second.subnet.cidr} vpc=$vpc name={second.subnet.name} availabilityzone={second.subnet.availabilityzone}
update subnet id=$secondsubnet public=true

```
 Create a route table for this network

```sh
rtable = create routetable vpc=$vpc

```
 Make the subnets open to the Internet (through vpc that has an internetgateway)

```sh
attach routetable id=$rtable subnet=$firstsubnet
attach routetable id=$rtable subnet=$secondsubnet
create dbsubnetgroup name={dbsubnetgroup.name} description={dbsubnetgroup.description} subnets=[$firstsubnet, $secondsubnet]
```



### Attach usual readonly AWS policies (set of permissions) on group




*When you want your users to have a set of permissions, instead of attaching permissions directly on users it is a good practice and simpler to define a group having those permissions and then adding/removing as needed users from those groups.*



**tags**: 
access, policy, role


(run it locally with: `awless run repo:policies_on_group -v`)



**STEPS**


```sh
attach policy service=ec2 access=readonly group={group-name}
attach policy service=s3 access=readonly group={group-name}
attach policy service=sns access=readonly group={group-name}
attach policy service=sqs access=readonly group={group-name}
attach policy service=vpc access=readonly group={group-name}
attach policy service=autoscaling access=readonly group={group-name}
attach policy service=iam access=readonly group={group-name}
attach policy service=rds access=readonly group={group-name}
attach policy service=route53 access=readonly group={group-name}
```



### Create a public network enabling routing from the Internet






**tags**: 
infra


(run it locally with: `awless run repo:public_subnet -v`)



**STEPS**

 Create the subnet

```sh
subnet = create subnet cidr={subnet.cidr} vpc={subnet.vpc} name={subnet.name}

```
 Allow instances in this network to have public IP addresses

```sh
update subnet id=$subnet public=true

```
 Create a route table for this network

```sh
rtable = create routetable vpc={subnet.vpc}
attach routetable id=$rtable subnet=$subnet

```
 Enable routing from the Internet to this subnet

```sh
create route cidr=0.0.0.0/0 gateway={vpc.internetgateway} table=$rtable
```



### Create a AWS role with usual readonly policies that applies on a resource




*Create a AWS role that applies on a resource (retrieve the account id with `awless whoami`)*



**tags**: 
access, policy, role


(run it locally with: `awless run repo:role_for_resource -v`)



**STEPS**


```sh
roleName = {role-name}
create role name=$roleName principal-service={aws-service}

```
 Attach policy (set of permissions) to the created role

```sh
attach policy role=$roleName service=ec2 access=readonly
attach policy role=$roleName service=s3 access=readonly
attach policy role=$roleName service=sns access=readonly
attach policy role=$roleName service=sqs access=readonly
attach policy role=$roleName service=vpc access=readonly
attach policy role=$roleName service=autoscaling access=readonly
attach policy role=$roleName service=iam access=readonly
attach policy role=$roleName service=rds access=readonly
attach policy role=$roleName service=route53 access=readonly
```



### Create a AWS role with usual readonly policies that applies on a user




*Create a AWS role that applies on a user (retrieve the id with `awless whoami`)*



**tags**: 
access, policy, user


(run it locally with: `awless run repo:role_for_user -v`)



**STEPS**


```sh
newRole = create role name={role-name} principal-account={aws-account-id}

```
 Attach policy (set of permissions) to the created role

```sh
attach policy role={role-name} service=ec2 access=readonly
attach policy role={role-name} service=s3 access=readonly
attach policy role={role-name} service=sns access=readonly
attach policy role={role-name} service=sqs access=readonly
attach policy role={role-name} service=vpc access=readonly
attach policy role={role-name} service=autoscaling access=readonly
attach policy role={role-name} service=iam access=readonly
attach policy role={role-name} service=rds access=readonly
attach policy role={role-name} service=route53 access=readonly

```
 Create a policy to allow user with this policy to assume only this role
 You can then attach this policy to a user via `awless attach policy arn=... user=jsmith`

```sh
create policy name={assume-policy-name} effect=Allow action=sts:AssumeRole resource=$newRole
```



### Create a static website on S3






**tags**: 
s3


(run it locally with: `awless run repo:s3website -v`)



**STEPS**

 Create the bucket where files will be stored

```sh
create bucket name={domain.name} acl=public-read

```
 Publish this s3bucket as a website

```sh
update bucket name={domain.name} public-website=true redirect-hostname={domain.name}

```
 Add files to the bucket with
 awless create s3object bucket={domain.name} file={input-file-path} acl=public-read



### Simple wordpress deployment






**tags**: 
infra


(run it locally with: `awless run repo:simple_wordpress_infra -v`)



**STEPS**

 VPC and its Internet gateway

```sh
vpc = create vpc cidr=10.0.0.0/16 name=wordpress-vpc
igw = create internetgateway
attach internetgateway id=$igw vpc=$vpc

```
 Subnet and its route table

```sh
subnet = create subnet cidr=10.0.0.0/24 vpc=$vpc name=wordpress-subnet
update subnet id=$subnet public=true
routetable = create routetable vpc=$vpc
attach routetable subnet=$subnet id=$routetable
create route cidr=0.0.0.0/0 gateway=$igw table=$routetable

```
 Create a security group and authorize accesses from the Internet for port 22 and 80

```sh
secgroup = create securitygroup vpc=$vpc description="authorize ssh and http from internet" name=wordpress-secgroup
update securitygroup id=$secgroup inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=22
update securitygroup id=$secgroup inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=80

```
 Create keypair and instance

```sh
keypair = create keypair name={keypair.name}
create instance name=wordpress-instance subnet=$subnet keypair=$keypair securitygroup=$secgroup userdata=https://raw.githubusercontent.com/zn3zman/AWS-WordPress-Creation/master/WP-Setup.sh
```



### Upload Image from local file




*This template uploads on s3 a local VM file (VHD, OVA, VMDK). Then it creates an AMI from the S3 object.*



**tags**: 
infra, s3


(run it locally with: `awless run repo:upload_image -v`)



**STEPS**

 Upload the image on s3

```sh
bucket = {image.bucket}
imageObject = create s3object bucket=$bucket file={image.filepath}

```
 Create the AMI from the object on S3

```sh
import image description={image.description} bucket=$bucket s3object=$imageObject
```



### Create a user with its SDK/Shell access key and console password






**tags**: 
access, user


(run it locally with: `awless run repo:user -v`)



**STEPS**


```sh
username = {user.name}

```
 Create user

```sh
create user name=$username

```
 Create AWS Console password

```sh
create loginprofile username=$username password={user.console-password}

```
 Create SDK/shell access key

```sh
create accesskey user=$username
```



### Create a VPC with its internet routing gateway






**tags**: 
infra, VPC


(run it locally with: `awless run repo:vpc -v`)



**STEPS**


```sh
vpc = create vpc cidr={vpc.cidr} name={vpc.name}
gateway = create internetgateway
attach internetgateway id=$gateway vpc=$vpc
```



### Create a VPC with 3 internal subnets







(run it locally with: `awless run repo:vpc_with_subnets -v`)



**STEPS**

 Create a new VPC with private subnets (no internet gateway)

```sh
vpc = create vpc cidr=10.0.0.0/16 name=vpc_10.0.0.0_16
create subnet cidr=10.0.0.0/24 vpc=$vpc name=sub_10.0.0.0_24 availabilityzone={subnet1.zone}
create subnet cidr=10.0.1.0/24 vpc=$vpc name=sub_10.0.1.0_24 availabilityzone={subnet2.zone}
```



### Highly-available wordpress behind a loadbalancer, with a RDS database


**-> Minimal awless version required: v0.1.1**





**tags**: 
infra, rds, autoscaling


(run it locally with: `awless run repo:wordpress_ha -v`)



**STEPS**


```sh
dbname={dbname}
dbhost={dbhost}
dbuser={dbuser}
dbpassword={dbpassword}

```
 Create the load balancer with its security group, target group and listener

```sh
lbsecgroup = create securitygroup vpc={wordpress.vpc} description="authorize HTTP from the Internet" name=wordpress-lb-securitygroup
update securitygroup id=$lbsecgroup inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=80
tg = create targetgroup name=wordpress-workers port=80 protocol=HTTP vpc={wordpress.vpc}
lb = create loadbalancer name=wordpress-loadbalancer subnets={wordpress.subnets} securitygroups=$lbsecgroup
create listener actiontype=forward loadbalancer=$lb port=80 protocol=HTTP targetgroup=$tg

```
 Create the launch configuration for the instances and start it in a scaling group, to ensure having always 2 instances running

```sh
launchconf = create launchconfiguration image={instance.image} keypair={wordpress.keypair} name=wordpress-launch-configuration type=t2.micro userdata=https://raw.githubusercontent.com/wallix/awless-templates/master/userdata/wordpress.sh securitygroups={instances.securitygroup}
create scalinggroup desired-capacity=2 launchconfiguration=$launchconf max-size=2 min-size=2 name=wordpress-scalinggroup subnets={wordpress.subnets} targetgroups=$tg
```



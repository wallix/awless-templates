[![Build Status](https://api.travis-ci.org/wallix/awless-templates.svg?branch=master)](https://travis-ci.org/wallix/awless-templates)

[Twitter](http://twitter.com/awlessCLI) | [Wiki](https://github.com/wallix/awless/wiki) | [Changelog](https://github.com/wallix/awless/blob/master/CHANGELOG.md#readme)

# awless templates

Repository to collect official, verified and runnable templates for the [awless CLI](https://github.com/wallix/awless)

Here are some non exhaustive [Examples](https://github.com/wallix/awless/wiki/Examples) of what you can do with templates. You can also read more about [awless templates](https://github.com/wallix/awless/wiki/Templates)

## Continuous Integration

On each change all templates are verified & compiled against the latest version of `awless`.

You can run the verification locally with:

    go get github.com/wallix/awless  # if needed
    go test verifyall_test.go -v

# Examples


* [Create ebs infra](#create-ebs-infra)
* [Create instance ssh](#create-instance-ssh)
* [Create private subnet](#create-private-subnet)
* [Create public subnet](#create-public-subnet)
* [Create readonly role for resource](#create-readonly-role-for-resource)
* [Create readonly role for user](#create-readonly-role-for-user)
* [Create simple infra](#create-simple-infra)
* [Create user](#create-user)
* [Create vpc](#create-vpc)
* [Instance with awless](#instance-with-awless)
* [Kafka infra](#kafka-infra)
* [Wordpress ha](#wordpress-ha)


### Create ebs infra

```sh
myvpc = create vpc cidr=10.0.0.0/24
mysubnet = create subnet cidr=10.0.0.0/25 vpc=$myvpc availabilityzone=eu-west-1a
update subnet id=$mysubnet public=true
create keypair name=demo-awless-keypair
create instance subnet=$mysubnet image={instance.image} type={instance.type} keypair=demo-awless-keypair name=demo-ebs count={instance.count}
create volume availabilityzone=eu-west-1a size=1
```

Run it locally with: `awless run repo:create_ebs_infra -v`

### Create instance ssh

```sh
securitygroup = create securitygroup vpc={instance.vpc} description={securitygroup.description} name=ssh-from-internet
update securitygroup id=$securitygroup inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=22
keypair = create keypair name={keypair.name}
create instance subnet={instance.subnet} image={instance.image} type={instance.type} keypair=$keypair name={instance.name} count=1 securitygroup=$securitygroup
```

Run it locally with: `awless run repo:create_instance_ssh -v`

### Create private subnet

```sh
create subnet cidr={subnet.cidr} vpc={subnet.vpc} name={subnet.name}
```

Run it locally with: `awless run repo:create_private_subnet -v`

### Create public subnet

```sh
subnet = create subnet cidr={subnet.cidr} vpc={subnet.vpc} name={subnet.name}
update subnet id=$subnet public=true
rtable = create routetable vpc={subnet.vpc}
attach routetable id=$rtable subnet=$subnet
create route cidr=0.0.0.0/0 gateway={vpc.gateway} table=$rtable
```

Run it locally with: `awless run repo:create_public_subnet -v`

### Create readonly role for resource
 Create a AWS role that applies on a resource
 (retrieve the account id with `awless whoami`)

```sh
create role name={role-name} principal-service={aws-service}

```
 Attach policy (set of permissions) to the created role

```sh
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/IAMReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess
```

Run it locally with: `awless run repo:create_readonly_role_for_resource -v`

### Create readonly role for user
 Create a AWS role that has a AWS account id as principal
 (retrieve the account id with `awless whoami`)

```sh
accountRole = create role name={role-name} principal-account={aws-account-id}

```
 Attach policy (set of permissions) to the created role

```sh
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/IAMReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess
attach policy role={role-name} arn=arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess

```
 Create a policy to allow user with this policy to assume only this role
 You can then attach this policy to a user via `awless attach policy arn=... user=jsmith`

```sh
create policy name={assume-policy-name} effect=Allow action=sts:AssumeRole resource=$accountRole
```

Run it locally with: `awless run repo:create_readonly_role_for_user -v`

### Create simple infra

```sh
myvpc = create vpc cidr={vpc.cidr} name={vpc.name}
mysubnet = create subnet cidr={subnet.cidr} vpc=$myvpc
create instance subnet=$mysubnet image={instance.image} type={instance.type} count={instance.count} name={instance.name}
```

Run it locally with: `awless run repo:create_simple_infra -v`

### Create user

```sh
create user name={user.name}
create accesskey user={user.name}
```

Run it locally with: `awless run repo:create_user -v`

### Create vpc

```sh
vpc = create vpc cidr={vpc.cidr} name={vpc.name}
gateway = create internetgateway
attach internetgateway id=$gateway vpc=$vpc
```

Run it locally with: `awless run repo:create_vpc -v`

### Instance with awless
 Create a AWS role that applies on a resource
 (retrieve the account id with `awless whoami`)

```sh
create role name=AwlessReadonlyRole principal-service="ec2.amazonaws.com"

```
 Attach typical necessary awless readonly permissions to the role

```sh
attach policy role=AwlessReadonlyRole arn=arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
attach policy role=AwlessReadonlyRole arn=arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
attach policy role=AwlessReadonlyRole arn=arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess
attach policy role=AwlessReadonlyRole arn=arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess
attach policy role=AwlessReadonlyRole arn=arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess
attach policy role=AwlessReadonlyRole arn=arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess
attach policy role=AwlessReadonlyRole arn=arn:aws:iam::aws:policy/IAMReadOnlyAccess
attach policy role=AwlessReadonlyRole arn=arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess
attach policy role=AwlessReadonlyRole arn=arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess

```
 Launch new instance running remote user data script installing awless

```sh
create instance name=awless-commander type=t2.nano keypair={ssh.keypair} userdata=https://raw.githubusercontent.com/wallix/awless-templates/master/userdata/install_awless.sh role=AwlessReadonlyRole
```

Run it locally with: `awless run repo:instance_with_awless -v`

### Kafka infra
 Create securitygroup for SSH: opening port 22 for all IPs

```sh
ssh-firewall = create securitygroup vpc={main.vpc} description=ssh-firewall name=ssh-firewall
update securitygroup id=$ssh-firewall inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=22

```
 Create securitygroup for Kafka instances: opening port 9092, 2181 for all IPs

```sh
kafka-firewall = create securitygroup vpc={main.vpc} description=kafka-firewall name=kafka-firewall
update securitygroup id=$kafka-firewall inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=2181
update securitygroup id=$kafka-firewall inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=9092

```
 Create securitygroup for API instances: opening port 80, 443 for all IPs

```sh
api-firewall = create securitygroup vpc={main.vpc} description=api-firewall name=api-firewall
update securitygroup id=$api-firewall inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=443
update securitygroup id=$api-firewall inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=80

```
 Create Kafka broker instances

```sh
broker_1 = create instance name=broker_1 image=ami-3f1bd150 keypair={keypair.name} subnet={main.subnet} securitygroup=$ssh-firewall userdata=https://gist.githubusercontent.com/simcap/360dffae4c6d76ab0e89621dd824a244/raw/521712fe118d7656a1d5757db1444bb7596ff5ae/launchinstance.sh
broker_2 = create instance name=broker_2 image=ami-3f1bd150 keypair={keypair.name} subnet={main.subnet} securitygroup=$ssh-firewall userdata=https://gist.githubusercontent.com/simcap/360dffae4c6d76ab0e89621dd824a244/raw/521712fe118d7656a1d5757db1444bb7596ff5ae/launchinstance.sh
broker_3 = create instance name=broker_3 image=ami-3f1bd150 keypair={keypair.name} subnet={main.subnet} securitygroup=$ssh-firewall userdata=https://gist.githubusercontent.com/simcap/360dffae4c6d76ab0e89621dd824a244/raw/521712fe118d7656a1d5757db1444bb7596ff5ae/launchinstance.sh

```
 Create Zookeeper instance

```sh
zookeeper = create instance name=zookeeper image=ami-3f1bd150 keypair={keypair.name} subnet={main.subnet} securitygroup=$ssh-firewall userdata=https://gist.githubusercontent.com/simcap/360dffae4c6d76ab0e89621dd824a244/raw/521712fe118d7656a1d5757db1444bb7596ff5ae/launchinstance.sh

```
 Create collector and consumer instance

```sh
collector = create instance name=collector image=ami-3f1bd150 keypair={keypair.name} subnet={main.subnet} securitygroup=$ssh-firewall userdata=https://gist.githubusercontent.com/simcap/360dffae4c6d76ab0e89621dd824a244/raw/521712fe118d7656a1d5757db1444bb7596ff5ae/launchinstance.sh
create instance name=consumers image=ami-3f1bd150 keypair={keypair.name} subnet={main.subnet} userdata=https://gist.githubusercontent.com/simcap/360dffae4c6d76ab0e89621dd824a244/raw/521712fe118d7656a1d5757db1444bb7596ff5ae/launchinstance.sh

```
 Update instances with corresponding securitygroups

```sh
attach securitygroup id=$kafka-firewall instance=$broker_1
attach securitygroup id=$kafka-firewall instance=$broker_2
attach securitygroup id=$kafka-firewall instance=$broker_3
attach securitygroup id=$kafka-firewall instance=$zookeeper
attach securitygroup id=$api-firewall instance=$collector
```

Run it locally with: `awless run repo:kafka_infra -v`

### Wordpress ha
 Loadbalancer
 Create the loadbalancer firewall

```sh
loadbalancerfw = create securitygroup vpc={wordpress.vpc} description=wordpress-loadbalancer-securitygroup name=wordpress-lb-securitygroup
update securitygroup id=$loadbalancerfw inbound=authorize protocol=tcp cidr=0.0.0.0/0 portrange=80

```
 Create the target group for EC2 wordpress servers

```sh
targetgroup = create targetgroup name=wordpress-workers port=80 protocol=HTTP vpc={wordpress.vpc}

```
 Create the application load balancer that will redirect flows to the servers

```sh
lb = create loadbalancer name=wordpress-loadbalancer subnets={wordpress.subnets} securitygroups=$loadbalancerfw
create listener actiontype=forward loadbalancer=$lb port=80 protocol=HTTP target=$targetgroup

```
 Wordpress application servers
 Create the wordpress servers

```sh
inst1 = create instance subnet={instance1.private.subnet} image=ami-3b36fe54 type={instance.type} count=1 name=wordpress-server-1 # AMI WordPress powered by Bitnami in eu-central-1
inst2 = create instance subnet={instance2.private.subnet} image=ami-3b36fe54 type={instance.type} count=1 name=wordpress-server-2

```
 Register the servers in the targetgroup

```sh
check instance id=$inst1 state=running timeout=180
check instance id=$inst2 state=running timeout=180
attach instance id=$inst1 targetgroup=$targetgroup
attach instance id=$inst2 targetgroup=$targetgroup
```

Run it locally with: `awless run repo:wordpress_ha -v`

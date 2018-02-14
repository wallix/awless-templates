# Agentless vulnerability scanner for Linux/FreeBSD

Install [Vuls](https://vuls.io/) with `awless` and scan Linux instances for vulnerabilities.

## Steps

#### Pre-requisites

1. Install [awless](https://github.com/wallix/awless#why-awless)

2. Get the Vuls template directory (i.e. awless template + corresponding userdata) locally by cloning this repository:

        cd  ~/tmp
        git clone https://github.com/wallix/awless-templates

#### Run

This step create an instance with Vuls using a dedicated `awless` template.

1. Verify you current AWS region/profile and switch to any necessary:

```sh
# display your current region and profile
awless switch      # or shorcut `awless sw`

# switch to any region/profile with
awless switch eu-west-2 admin
```

3. If you do not have a AWS keypair yet in this region to SSH to your instances, create one securely with:  `awless create keypair name=ANY_NAME`

4.  Run the template:

```sh
cd awless-templates/vuln_scanners
# then
awless run futurearchitect_vuls.aws
# or to install it on a specific Linux AMI
awless run futurearchitect_vuls.aws image=ami-123456     
```

You will be prompted with _smart completion_ for any missing info (ex: distro, etc.). Also, you will have time to review and confirm the compiled template before running anything.

5. After a successfull run, get an overview of what you created with:

```sh
awless ls instances
# and/or
awless show NAME_OF_MY_INSTANCE --local
```

(Note the `--local` (or `-l`) flag allows to look up cloud data synchronized locally by `awless` instead of fetching everything again remotely)

#### Play

You can now interact with the deployed instance.

Vuls on the instance will be fully operationnal when the install script finishes. **It can take a few minutes.** It is done when the fetch script has been created in the home directory.

Use `awless ssh NAME_OF_MY_INSTANCE` to SSH easily to the instance

Once on the instance:

1. Check that the `$HOME/config.toml` Vuls config file is valid with `vuls configtest`
2. Fetch all CVE, OVAL and NVD data by running the script `./fetch-nvd-oval-cve-data.sh`. It takes a few minutes to get all data up to date.
3. After running this script the prompt can act a but funky (due to a readline lib usage in the Go programs). Just log in and out again on the instance will solve the issue.

You can now:

* Scan the local machine with `sudo $(which vuls) scan`

To scan remote instance from this instance do the following:

1. Update the `$HOME/config.toml` accordingly (see an example in the toml file itself)
2. Copy the public key `$HOME/.ssh/id_rsa.pub` on the target to be scanned remotely under `$HOME/.ssh/authorized_keys`
3. From the Vuls instance run: `sudo $(which vuls) scan`

#### Tear down ... and stop paying!

When done, tear down the instance completely with:

        awless log                
        awless revert $(awless log -n1 --id-only)  # will revert last run template given its ID
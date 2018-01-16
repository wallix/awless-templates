# Multi-AZ CockroachDB insecure cluster

Create and take down a multi-AZ CockroachDB insecure cluster (3 nodes) with AWS TCP & HTTP load balancing. See https://www.cockroachlabs.com/docs/stable/deploy-cockroachdb-on-aws-insecure.html

You will be able to access each cluster nodes safely with `awless ssh` through a jump server 

## Steps

1. Install [awless](https://github.com/wallix/awless#why-awless)

2. Clone the `awless` template repository:

        cd  ~/tmp
        git clone https://github.com/wallix/awless-templates

3. Go into the CockroachDB template directory:

        cd awless-templates/cockroachdb

4. Verify where `awless` will deploy your infrastructure by displaying you current AWS region/profile with:

        awless switch

5. Run the template with `awless` 

    You will be prompted for any missing info and you will have time to review and confirm the template before running it:

        awless run cockroach_insecure_cluster.aws

6. Play with your infrastructure. In this case, you can for instance:

    Retrieve the loadbalancer public DNS with:
    
    `awless show cockroachdb-cluster --values-for publicdns`
    
    Then to connect to the cluster UI in a browser with http://{PUBLIC_DNS}:8080 
    
    Or connect using sql to the cluster with (you need to have install locally the cockroach binary): 
    
    `cockroach sql --insecure --host {PUBLIC_DNS}`

    Also you can use `awless ssh` and the jump server to go to specific nodes:

    `awless ssh cockroachdb-node-1 --through jump-server` 

7. When done, stop paying and remove it completely with:

        awless log                
        awless revert $(awless log -n1 --id-only)  # will revert last run template
# locust 

This recipe creates a locust cluster with golang based locust-agents deployed as docker images tied to systemd units.

Adjust the scripts to use whatever locust master/slave locust setup you'd like.

The master IP is guarded by an nsg.  You need to adjust the nsg to match your source IP.

The slaves are contained in a scale set.  There is a single master.

The scripts  install the systemd units:
- locust-master.service 
- locust-agents.service

The entire setup works with the ansible dynamic inventory created with azure_rm.

A yaml version of the azuredeployment is provided to ease editing.  I recommend changes to the yaml and generating the json as follows:

```
ruby -r yaml -r json -e 'puts JSON.pretty_generate(YAML.load(STDIN.read))' < locust/azuredeploy.yaml > locust/azuredeploy.json 
```


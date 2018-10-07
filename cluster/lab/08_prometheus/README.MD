# Prometheus

## What's Prometheus

Prometheus is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. 

It's features and components are better described in this [overview](https://prometheus.io/docs/introduction/overview/).

Prometheus is become the perfect fit with kubernetes (hence openshift). See the Their ![diagram](https://prometheus.io/assets/architecture.svg)

## Installing prometheus on disconnected shift

As usual the goal is to install prometheus in a disconnected env thus we fist have to download the required image and then execute the ansible playbooks with the right configuration.

Let's have a look in the playbook : if you look the readme in offline/conf_to_copy/openshift-ansible/roles/openshift_prometheus/README.md we can leave the default values as they are except this one we're going to integrate in the inventory file: 

- `openshift_prometheus_state`: present - install/update. absent - uninstall.

This flag let you choose between install and uninstall.

- `openshift_prometheus_<COMPONENT>_image_prefix`: specify image prefix for the component

- `openshift_prometheus_<COMPONENT>_image_version`: specify image version for the component

Those are the images we are going to import first. 

It's worth mentionning, even if we don't need it here 

- `openshift_hosted_prometheus_deploy` : true or false when you decide to add prometheus to the general install process see [components.yml] (offline/conf_to_copy/openshift-ansible/playbooks/common/private/components.yml)

### download the needed image 

We need this images  : 

In a "connected env" pull this images :

- docker.io/openshift/oauth-proxy:v1.0.0
- docker.io/openshift/prometheus:v2.2.1
- docker.io/openshift/prometheus-alert-buffer:v0.0.2
- docker.io/openshift/prometheus-alertmanager:v0.13.0
- docker.io/openshift/prometheus-node-exporter:v0.15.2

### Create an archive 








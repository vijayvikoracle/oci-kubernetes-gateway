# OCI Management Gateway HA on Kubernetes

### Pre-requisites

* OCI Management Gateway policies must be configured
* OCI Dynamic Groups, User Group and Policies.
  <details>
    <summary>Details</summary>
  
  * Create a dynamic group with the following sample rule for OCI Management Agent. Refer [Managing Dynamic Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm) for details.
    ```
    ALL {resource.type='managementagent', resource.compartment.id='OCI Management Agent Compartment OCID'}
    ```
  * Create a dynamic group with following sample rule for OKE Instances. 
    ```
    ALL {instance.compartment.id='OCI Management Agent Compartment OCID'}
    ```
  * Create a policy with following statements.
    * Policy Statement for providing necessary access to upload the metrics.
      ```
      Allow dynamic-group <OCI Management Agent Dynamic Group> to use metrics in compartment <Compartment Name> WHERE target.metrics.namespace = 'mgmtagent_kubernetes_metrics'
      ```
    * Policy Statement for providing necessary access to upload the logs and objects data.
      ```
      Allow dynamic-group <OKE Instances Dynamic Group> to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment <Compartment Name>
      ```
      OR
      ```
      Allow group <User Group> to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment <Compartment Name>
      ```
  </details>

### Installation instructions 

#### Helm

##### 0 Pre-requisites

* Workstation or OCI Cloud Shell with access configured to the target k8s cluster.
* Helm ([Installation instructions](https://helm.sh/docs/intro/install/)).

##### 1 Download helm chart

* [latest](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/releases/latest/download/helm-chart.tgz)
* Go to [releases](https://github.com/vijayvikoracle/oci-kubernetes-gateway/releases) for a specific version.

##### 2 Update values.yaml

* Create override_values.yaml, to override the minimum required variables in values.yaml.
  - override_values.yaml
    ```
    global:
      # -- OCID for OKE cluster or a unique ID for other Kubernetes clusters.
      kubernetesClusterID:
      # -- Provide a unique name for the cluster. This would help in uniquely identifying the logs and metrics data at OCI Logging Analytics and OCI Monitoring respectively.
      kubernetesClusterName:

    oci-onm-mgmt-agent:
      mgmtagent:
        # Provide the base64 encoded content of the Management Agent Install Key file
        installKeyFileContent: 
    ```
* **Refer to the oci-onm chart and sub-charts values.yaml for customising or modifying any other configuration.** It is recommended to not modify the values.yaml provided with the charts, instead use override_values.yaml to achieve the same.    
  
##### 3.a Install helm release

Use the following `helm install` command to the install the chart. Provide a desired release name, path to override_values.yaml and path to helm chart.
```
helm install <release-name> <path-to-helm-chart>
```
Refer [this](https://helm.sh/docs/helm/helm_install/) for further details on `helm install`.

##### 4 Uninstall

Use the following `helm uninstall` command to uninstall the chart. Provide the release name used when creating the chart.
```
helm uninstall <release-name>
```
Refer [this](https://helm.sh/docs/helm/helm_uninstall/) for further details on `helm uninstall`.
  
## Getting Help

#### [Ask a question](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/discussions/new?category=q-a)

## Resources

#### :question: [Frequently Asked Questions](./docs/FAQ.md)

#### [Custom Logs Configuration](./docs/custom-logs.md)

#### [Building Custom Container Images](./docs/custom-images.md)

## License

Copyright (c) 2023, Oracle and/or its affiliates.
Licensed under the Universal Permissive License v1.0 as shown at <https://oss.oracle.com/licenses/upl>.

## [Contributors][def]

[def]: https://github.com/vijayvikoracle/oci-kubernetes-gateway/graphs/contributors

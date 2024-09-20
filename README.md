# OCI Management Gateway HA on Kubernetes

### Pre-requisites

* OCI Management Gateway policies must be configured
* OCI Dynamic Groups, User Group and Policies.
  <details>
    <summary>Details</summary>
  
  * Create a dynamic group with the following sample rule for OCI Certificate Authority. Refer [Managing Dynamic Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm) for details.
    ```
    ALL  {resource.type='certificateauthority', resource.compartment.id='<>'}  
    ```
  * Create a dynamic group with following sample rule for Management Agent. 
    ```
    ALL {resource.type='managementagent', resource.compartment.id='<>'}
    ```
  * Create a policy with following statements.
      ```
      Allow DYNAMIC-GROUP Credential_Dynamic_Group to USE certificate-authority-delegates in compartment <>
      Allow DYNAMIC-GROUP Credential_Dynamic_Group to USE vaults in compartment <>
      Allow DYNAMIC-GROUP Credential_Dynamic_Group to USE keys in compartment <>
      Allow DYNAMIC-GROUP Management_Gateway_Dynamic_Group to READ certificate-authority-bundle in compartment <>
      Allow DYNAMIC-GROUP Management_Gateway_Dynamic_Group to READ leaf-certificate-bundle in compartment <>
      Allow DYNAMIC-GROUP Management_Gateway_Dynamic_Group to MANAGE certificate-authorities in compartment <> where  any{request.permission='CERTIFICATE_AUTHORITY_CREATE', request.permission='CERTIFICATE_AUTHORITY_INSPECT', request.permission='CERTIFICATE_AUTHORITY_READ'} 
      Allow DYNAMIC-GROUP Management_Gateway_Dynamic_Group to MANAGE leaf-certificates in compartment <> where  any{request.permission='CERTIFICATE_CREATE', request.permission='CERTIFICATE_INSPECT', request.permission ='CERTIFICATE_UPDATE', request.permission='CERTIFICATE_READ'}
      Allow DYNAMIC-GROUP Management_Gateway_Dynamic_Group to MANAGE vaults in compartment <> where any{request.permission='VAULT_CREATE', request.permission='VAULT_INSPECT', request.permission='VAULT_READ', request.permission='VAULT_CREATE_KEY', request.permission='VAULT_IMPORT_KEY', request.permission='VAULT_CREATE_SECRET'} 
      Allow DYNAMIC-GROUP Management_Gateway_Dynamic_Group to MANAGE keys in compartment <> where any{request.permission='KEY_CREATE', request.permission='KEY_INSPECT', request.permission='KEY_READ'} 
      Allow DYNAMIC-GROUP Management_Gateway_Dynamic_Group to USE certificate-authority-delegates in compartment <>
      Allow DYNAMIC-GROUP Management_Gateway_Dynamic_Group to USE key-delegate in compartment <> 
      Allow DYNAMIC-GROUP Management_Gateway_Dynamic_Group TO MANAGE leaf-certificates in compartment <> where all{request.permission='CERTIFICATE_DELETE', target.leaf-certificate.name=request.principal.id} 
      ```
  </details>

### Installation instructions 

#### Helm

##### 0 Pre-requisites

* Workstation or OCI Cloud Shell with access configured to the target k8s cluster.
* Helm ([Installation instructions](https://helm.sh/docs/intro/install/)).

##### 1 Download helm chart

* [latest](https://github.com/vijayvikoracle/oci-kubernetes-gateway/releases/download/oci-onm-mgmt-gateway-1.0.3/oci-onm-management-gateway-1.0.3.tgz)
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

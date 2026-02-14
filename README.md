# GitLab VMI Provisioner

This project contains the configuration and tools to provision a scalable, immutable, and GitOps-driven fleet of GitLab Runners using KubeVirt.

## Project Structure

- `packer/`: Packer templates and HCL configurations for building QCOW2 images.
- `ansible/`: Ansible Playbooks for configuring the OS, installing Docker/GitLab Runner, and setting up the reloader.
- `helm/`: Helm charts for deploying the VirtualMachineInstanceReplicaSet and associated resources.
- `.gitlab-ci.yml`: CI/CD pipeline definition for building and shipping the artifacts.

## Architecture

The project follows a **Bake-Ship-Run** lifecycle:

1.  **Bake**: Build a QCOW2 image with all dependencies pre-installed using Packer and Ansible.
2.  **Ship**: Package the QCOW2 image into a containerDisk image and push to a registry.
3.  **Run**: Deploy a fleet of GitLab Runners using a VirtualMachineInstanceReplicaSet via ArgoCD.

## Key Features

- **Immutable Infrastructure**: Configuration is baked into the image.
- **Live Configuration**: `virtiofs` mounts for `config.toml`.
- **Hot Reloading**: `inotify`-based reloader for zero-downtime updates.
- **GitOps Compliance**: All changes driven by Helm values and ArgoCD.

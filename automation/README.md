![Terraform](https://github.com/Dageus/homelab/blob/main/assets/Terraform-Logo.svg)
![Ansible](https://github.com/Dageus/homelab/blob/main/assets/Ansible-Logo.svg)

<div align="center">
  <h1>Proxmox Automation Toolkit</h1>
  <h3>Infrastructure as Code with Terraform and Configuration Management with Ansible</h3>
</div>

---

## Background

This all started when I wanted to start deploying a lot of services, and I found myself repeating the same tasks over and over again, only to then have forgotten every command I'd ran and had to investigate all over again (that's on me though, my memory is horrible).

But that's when I heard everyone in the Proxmox and Cloud community talking about DevOps and how they could automate everything with a simple push on git. What's this black magic everyone's talking about??

Then I started investigating, and all these keywords start appearing: IaC, CI, Ansible, Terraform, Pipelines, Jenkins; and people debating which CI tool is better and whatnot and now I'm here overwhelmed by 12 different technologies meant to do almost the same thing and funnily enough that's when I fell in love with DevOps. So many diverse and different ways to achieve the same result: from nothing to a deployed and configured system.

Then I took a DevOps course in college that bootstrapped my love for this area, which was developing and deploying a Cloud Microservice Application. And how fun it was to configure everything is something I really cherised.

## Introduction

For our Proxmox setup, we'll just have 3 phases of Automation:

- Provisioning ([Terraform](./terraform/README.md)): This is where you'll create the LXCs/VMs. You'll connect to Proxmox's API and make calls that generate machines with the specs you defined.

- Configuring ([Ansible](./ansible/README.md)): You want to turn that empty machine into something that can run what you want. Install packages, enable features, clean up space, all this is Ansible's playing field.

- Continuous Integration ([GitHub Actions](./git_hooks/README.md)): How are you going to turn this templated setup into a realized configuration on your server? Running it yourself? Shell scripts with cronjobs? We aren't about that life since we have GitOps. Everytime you push or merge, Github/Gitlab can run a set of instructions for you to deploy all your resources.

#### Sources

[https://pve.proxmox.com/wiki/Cloud-Init_Support](https://pve.proxmox.com/wiki/Cloud-Init_Support)

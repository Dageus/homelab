# Git Hooks

This is where the final process of automation sits. You can have Terraform and Ansible do everything for you, but you would still need to trigger the scrips each time you'd want to add a new machine. This is where GitHub Actions kicks in.

Each time you commit to the repo that has all your IaC, an action would be triggered to run all your playbooks and provisioning scripts, and since both Ansible and Terraform are idempotent, only the new machines would be created, truly making your setup autonomous and replicable.

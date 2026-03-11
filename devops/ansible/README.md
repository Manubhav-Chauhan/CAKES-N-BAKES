# Ansible Deployment

## Install requirements

```bash
cd devops/ansible
ansible-galaxy collection install -r requirements.yml
```

## Prepare inventory

```bash
cp inventory.ini.example inventory.ini
# edit public IP and key path
```

## Deploy

```bash
ansible-playbook -i inventory.ini deploy.yml
```

## Notes

- Replace `.env` values after first deployment for production.
- For secrets, use `ansible-vault` in real projects.

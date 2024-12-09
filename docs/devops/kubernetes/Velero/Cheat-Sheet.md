# Velero Cheat Sheet

```bash
# Installation
velero install --provider <provider> --bucket <bucket-name> --secret-file ./credentials

# Backup Management
velero backup create <backup-name>            # Create a Backup
velero backup get                             # List Backups
velero backup describe <backup-name>          # Describe Backup Details
velero backup delete <backup-name>            # Delete a Backup
velero backup logs <backup-name>              # View Backup Logs

# Restore Management
velero restore create --from-backup <backup-name>  # Create a Restore
velero restore get                                 # List Restores
velero restore describe <restore-name>             # Describe Restore Details
velero restore delete <restore-name>               # Delete a Restore
velero restore logs <restore-name>                 # View Restore Logs

# Schedule Management
velero schedule create <schedule-name> --schedule="*/5 * * * *"  # Create a Backup Schedule
velero schedule get                                              # List Schedules
velero schedule describe <schedule-name>                         # Describe Schedule Details
velero schedule delete <schedule-name>                           # Delete a Schedule

# Plugin Management
velero plugin get            # List Velero Plugins
```
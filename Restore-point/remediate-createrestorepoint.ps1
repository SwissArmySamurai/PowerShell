# Enable System Protection and create a restore point
Enable-ComputerRestore -Drive "C:\"
Checkpoint-Computer -Description "Pre-Windows11Upgrade" -RestorePointType "MODIFY_SETTINGS"
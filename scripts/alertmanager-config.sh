#!/bin/bash 
set -e 
echo "Downloading Alertmanager v0.27.0..." 
cd /tmp 
curl -LO https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux
amd64.tar.gz 
echo "Extracting Alertmanager..." 
tar -xvzf alertmanager-0.27.0.linux-amd64.tar.gz 
cd alertmanager-0.27.0.linux-amd64 
echo "Installing Alertmanager binaries..." 
sudo mv alertmanager amtool /usr/local/bin/ 
sudo chmod +x /usr/local/bin/alertmanager /usr/local/bin/amtool 
echo "Creating config directory..." 
sudo mkdir -p /etc/alertmanager 
echo "Creating default config file..." 
sudo tee /etc/alertmanager/config.yml > /dev/null <<EOF 
global: 
resolve_timeout: 5m 
route: 
receiver: 'email-notifications' 
receivers: - name: 'email-notifications' 
email_configs: - to: 'your-email@example.com' 
from: 'alertmanager@example.com' 
smarthost: 'smtp.example.com:587' 
auth_username: 'smtp-user' 
auth_password: 'smtp-password' 
require_tls: true 
EOF 
echo "Creating systemd service for Alertmanager..." 
sudo tee /etc/systemd/system/alertmanager.service > /dev/null <<EOF 
[Unit] 
Description=Prometheus Alertmanager 
Wants=network-online.target 
After=network-online.target 
[Service] 
User=prometheus 
ExecStart=/usr/local/bin/alertmanager --config.file=/etc/alertmanager/config.yml -
storage.path=/var/lib/alertmanager 
[Install] 
WantedBy=multi-user.target 
EOF 
echo "Creating directories and setting permissions..." 
sudo mkdir -p /var/lib/alertmanager 
sudo chown -R prometheus:prometheus /etc/alertmanager /var/lib/alertmanager 
echo "Reloading systemd daemon and starting Alertmanager service..." 
sudo systemctl daemon-reload 
sudo systemctl enable --now alertmanager 
echo "Alertmanager installed and running. Check status with: sudo systemctl status alertmanager" 

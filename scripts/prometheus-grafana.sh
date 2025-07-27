#!/bin/bash 
set -e 
echo "Updating system..." 
sudo apt update && sudo apt upgrade -y 
# ---- NODE EXPORTER ---- 
echo "Installing Node Exporter..." 
cd /tmp 
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux
amd64.tar.gz 
tar -xvzf node_exporter-1.8.1.linux-amd64.tar.gz 
sudo mv node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/ 
sudo chmod +x /usr/local/bin/node_exporter 
sudo useradd --no-create-home --shell /bin/false node_exporter || true 
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF 
[Unit] 
Description=Node Exporter 
After=network.target 
[Service] 
User=node_exporter 
ExecStart=/usr/local/bin/node_exporter 
[Install] 
WantedBy=multi-user.target 
EOF 
sudo systemctl daemon-reexec 
sudo systemctl enable --now node_exporter 
echo "Node Exporter installed and running on port 9100" 
# ---- PROMETHEUS ---- 
echo "Installing Prometheus..." 
cd /tmp 
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux
amd64.tar.gz 
tar -xvzf prometheus-2.52.0.linux-amd64.tar.gz 
cd prometheus-2.52.0.linux-amd64 
sudo useradd --no-create-home --shell /bin/false prometheus || true 
sudo mkdir -p /etc/prometheus /var/lib/prometheus 
sudo cp prometheus promtool /usr/local/bin/ 
sudo chmod +x /usr/local/bin/prometheus /usr/local/bin/promtool 
sudo cp -r consoles console_libraries /etc/prometheus/ 
sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF 
global: 
scrape_interval: 15s 
scrape_configs: - job_name: 'prometheus' 
static_configs: - targets: ['localhost:9090'] - job_name: 'node_exporter' 
static_configs: - targets: ['localhost:9100'] 
EOF 
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF 
[Unit] 
Description=Prometheus 
Wants=network-online.target 
After=network-online.target 
[Service] 
User=prometheus 
ExecStart=/usr/local/bin/prometheus \\ --config.file=/etc/prometheus/prometheus.yml \\ --storage.tsdb.path=/var/lib/prometheus \\ --web.listen-address=0.0.0.0:9090 
[Install] 
WantedBy=multi-user.target 
EOF 
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus 
sudo systemctl daemon-reload 
sudo systemctl enable --now prometheus 
echo "Prometheus installed and running on port 9090" 
# ---- GRAFANA ---- 
echo "Installing Grafana..." 
sudo apt install -y apt-transport-https software-properties-common wget gnupg 
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add - 
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list 
sudo apt update 
sudo apt install -y grafana 
sudo systemctl enable --now grafana-server 
echo "Grafana installed and running on port 3000" 
# ---- Output Info ---- 
echo "" 
echo "Monitoring stack installation completed." 
echo "Visit:" 
echo "  Prometheus: http://localhost:9090" 
echo "  Node Exporter: http://localhost:9100/metrics" 
echo "  Grafana: http://localhost:3000 (login: admin / admin)"

#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: community-scripts
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://openclaw.ai/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  git \
  ca-certificates \
  curl
msg_ok "Installed Dependencies"

NODE_VERSION="22" setup_nodejs

msg_info "Installing OpenClaw (Patience)"
cd /opt
$STD git clone https://github.com/openclaw/openclaw.git
cd /opt/openclaw
$STD npm install
msg_ok "Installed OpenClaw"

msg_info "Configuring OpenClaw"
cat <<EOF >/opt/openclaw/.env
# OpenClaw Configuration
# See https://openclaw.ai/ for documentation

# LLM Provider API Key (uncomment and set one)
# ANTHROPIC_API_KEY=your-api-key-here
# OPENAI_API_KEY=your-api-key-here

# Messaging Platform (uncomment and set one)
# TELEGRAM_BOT_TOKEN=your-bot-token-here
# DISCORD_BOT_TOKEN=your-bot-token-here

# Gateway Settings
OPENCLAW_HOST=0.0.0.0
OPENCLAW_PORT=18789
EOF
msg_ok "Configured OpenClaw"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/openclaw.service
[Unit]
Description=OpenClaw AI Agent
After=network.target

[Service]
WorkingDirectory=/opt/openclaw
EnvironmentFile=/opt/openclaw/.env
ExecStart=/usr/bin/node src/index.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now openclaw
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc

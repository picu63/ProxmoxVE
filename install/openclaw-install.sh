#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: community-scripts
# License: MIT | https://github.com/picu63/ProxmoxVE/raw/main/LICENSE
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
$STD npm install -g openclaw
msg_ok "Installed OpenClaw"

msg_info "Configuring OpenClaw"
mkdir -p /root/.openclaw
cat <<EOF >/root/.openclaw/.env
# OpenClaw Configuration
# See https://openclaw.ai/ for documentation

# LLM Provider API Key (uncomment and set one)
# ANTHROPIC_API_KEY=your-api-key-here
# OPENAI_API_KEY=your-api-key-here

# Messaging Platform (uncomment and set one)
# TELEGRAM_BOT_TOKEN=your-bot-token-here
# DISCORD_BOT_TOKEN=your-bot-token-here
EOF
msg_ok "Configured OpenClaw"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/openclaw.service
[Unit]
Description=OpenClaw AI Agent
After=network.target

[Service]
EnvironmentFile=/root/.openclaw/.env
ExecStart=/usr/bin/openclaw gateway --port 18789
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now openclaw
msg_ok "Created Service"

echo ""
echo "🦞 Starting OpenClaw onboarding wizard..."
echo ""
openclaw onboard

motd_ssh
customize
cleanup_lxc

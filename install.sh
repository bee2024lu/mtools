#!/usr/bin/env bash
set -e

echo "===================================================="
echo "  欢迎使用 小白的 SSH 硬化 & 工具箱 一键脚本"
echo "  作者：你的名字        时间：$(date +%F)"
echo "===================================================="

# 颜色输出
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m'

info() { echo -e "${GREEN}[信息]${NC} $*"; }
warn() { echo -e "${YELLOW}[警告]${NC} $*"; }
error() { echo -e "${RED}[错误]${NC} $*"; }

# 判断系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    error "不支持的系统"
    exit 1
fi

install_tools() {
    info "正在更新软件包并安装常用工具..."
    case $OS in
        ubuntu|debian)
            apt update -qq && apt install -y curl wget git vim htop net-tools tree unzip zip fail2ban
            ;;
        centos|rhel|rocky|alma*)
            yum install -y epel-release
            yum install -y curl wget git vim htop net-tools tree unzip zip fail2ban
            ;;
        *)
            warn "未适配的系统，尝试通用安装..."
            ;;
    esac
}

harden_ssh() {
    info "正在硬化 SSH 配置..."
    sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    echo "AllowUsers yourusername" >> /etc/ssh/sshd_config
    systemctl restart sshd
}

main() {
    [[ $EUID -ne 0 ]] && error "请用 root 权限运行此脚本" && exit 1
    install_tools
    harden_ssh
    info "全部完成！请用密钥登录，root 已被禁用密码登录"
}

main
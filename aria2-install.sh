#!/usr/bin/env bash
#
# Copyright (c) 2020-2021 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Aria2-Pro-Core
# File name: aria2-install.sh
# Description: Install latest version Aria2 Pro Core
# System Required: GNU/Linux
# Version: 2.0
#

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

# --- 字体颜色定义 ---
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
INFO="[${Green_font_prefix}INFO${Font_color_suffix}]"
ERROR="[${Red_font_prefix}ERROR${Font_color_suffix}]"

# --- 路径和项目定义 ---
PROJECT_NAME='Aria2 Pro Core'
# 改造后的基础下载 URL：使用您提供的 Raw 链接格式
GITHUB_RAW_URL_BASE='https://github.com/Cartagra/Aria2-Pro-Core/raw/refs/heads/master/' 
BIN_DIR='/usr/local/bin'
BIN_NAME='aria2c'
BIN_FILE="${BIN_DIR}/${BIN_NAME}"

# --- 环境检查 ---
if [[ $(uname -s) != Linux ]]; then
    echo -e "${ERROR} This operating system is not supported."
    exit 1
fi

if [[ $(id -u) != 0 ]]; then
    echo -e "${ERROR} This script must be run as root."
    exit 1
fi

# --- 获取 CPU 架构并确定下载关键字 ---
echo -e "${INFO} Get CPU architecture ..."
if [[ $(command -v apk) ]]; then
    PKGT='(apk)'
    OS_ARCH=$(apk --print-arch)
elif [[ $(command -v dpkg) ]]; then
    PKGT='(dpkg)'
    OS_ARCH=$(dpkg --print-architecture | awk -F- '{ print $NF }')
else
    OS_ARCH=$(uname -m)
fi
case ${OS_ARCH} in
*86)
    FILE_KEYWORD='i386'
    ;;
x86_64 | amd64)
    FILE_KEYWORD='amd64'
    ;;
aarch64 | arm64)
    FILE_KEYWORD='arm64'
    ;;
arm*)
    FILE_KEYWORD='armhf'
    ;;
*)
    echo -e "${ERROR} Unsupported architecture: ${OS_ARCH} ${PKGT}"
    exit 1
    ;;
esac
echo -e "${INFO} Architecture: ${OS_ARCH} ${PKGT}"

# --- 构造下载 URL (改造后的逻辑) ---
echo -e "${INFO} Get ${PROJECT_NAME} download URL from repository raw content ..."

# 核心改造点 A: 构造 tar.gz 压缩包的文件名
BINARY_ARCHIVE_NAME="aria2-static-linux-${FILE_KEYWORD}.tar.gz" 
DOWNLOAD_URL="${GITHUB_RAW_URL_BASE}${BINARY_ARCHIVE_NAME}"

echo -e "${INFO} Download URL: ${DOWNLOAD_URL}"

# --- 执行安装 (改造后的逻辑：下载并解压) ---
echo -e "${INFO} Installing ${PROJECT_NAME} by downloading and extracting ${BINARY_ARCHIVE_NAME} ..."

# 核心改造点 B: 使用 curl 下载并管道到 tar 解压
# -L: 跟随重定向, -S: 显示错误, xzC ${BIN_DIR}: 解压 XZ 压缩包到目标目录
curl -LS "${DOWNLOAD_URL}" | tar xzC ${BIN_DIR}

# 赋予执行权限
chmod +x ${BIN_FILE}

# 验证安装结果
if [[ -s ${BIN_FILE} && $(${BIN_NAME} -v) ]]; then
    echo -e "${INFO} Done. ${PROJECT_NAME} installed at ${BIN_FILE}"
else
    echo -e "${ERROR} ${PROJECT_NAME} installation failed !"
    # 失败时删除文件并退出
    rm -f ${BIN_FILE} 
    exit 1
fi

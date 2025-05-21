#!/usr/bin/env bash

# 等待1秒, 避免curl下载脚本的打印与脚本本身的显示冲突, 吃掉了提示用户按回车继续的信息
sleep 1

# 定义颜色
re="\033[0m"
red="\033[1;91m"
green="\e[1;32m"
yellow="\e[1;33m"
purple="\e[1;35m"
skybule="\e[1;36m"
red() { echo -e "\e[1;91m$1\033[0m"; }
green() { echo -e "\e[1;32m$1\033[0m"; }
yellow() { echo -e "\e[1;33m$1\033[0m"; }
purple() { echo -e "\e[1;35m$1\033[0m"; }
skyblue() { echo -e "\e[1;36m$1\033[0m"; }
reading() { read -p "$(red "$1")" "$2"; }

# 检查是否为root下运行
[[ $EUID -ne 0 ]] && red "请在root用户下运行脚本" && exit 1

# 首次安装脚本，显示欢迎界面艺术字
word_artistic() {
clear
if ! command -v tput >/dev/null 2>&1; then
    echo "     VLESS-Reality Installer"
    echo "<================================>
elif [ "$(tput cols)" -lt 62 ]; then
    echo "     VLESS-Reality Installer"
    echo "<================================>
elif [ "$(tput cols)" -lt 80 ]; then
    cat << 'EOF'
        _                                    _ _ _         
 __   _| | ___  ___ ___       _ __ ___  __ _| (_) |_ _   _ 
 \ \ / / |/ _ \/ __/ __|_____| '__/ _ \/ _` | | | __| | | |
  \ V /| |  __/\__ \__ \_____| | |  __/ (_| | | | |_| |_| |
   \_/ |_|\___||___/___/     |_|  \___|\__,_|_|_|\__|\__, |
                                                     |___/ 
<==========================================================>
EOF
elif [ "$(tput cols)" -lt 110 ]; then
    cat << 'EOF'
          _                         ____               _  _  _          
  __   __| |  ___  ___  ___        |  _ \  ___   __ _ | |(_)| |_  _   _ 
  \ \ / /| | / _ \/ __|/ __| _____ | |_) |/ _ \ / _` || || || __|| | | |
   \ V / | ||  __/\__ \\__ \|_____||  _ <|  __/| (_| || || || |_ | |_| |
    \_/  |_| \___||___/|___/       |_| \_\\___| \__,_||_||_| \__| \__, |
                                                                  |___/ 
<=======================================================================>
EOF
elif [ "$(tput cols)" -lt 135 ]; then
    cat << 'EOF'
            
  ██╗   ██╗██╗     ███████╗███████╗███████╗      ██████╗ ███████╗ █████╗ ██╗     ██╗████████╗██╗   ██╗
  ██║   ██║██║     ██╔════╝██╔════╝██╔════╝      ██╔══██╗██╔════╝██╔══██╗██║     ██║╚══██╔══╝╚██╗ ██╔╝
  ██║   ██║██║     █████╗  ███████╗███████╗█████╗██████╔╝█████╗  ███████║██║     ██║   ██║    ╚████╔╝ 
  ╚██╗ ██╔╝██║     ██╔══╝  ╚════██║╚════██║╚════╝██╔══██╗██╔══╝  ██╔══██║██║     ██║   ██║     ╚██╔╝  
   ╚████╔╝ ███████╗███████╗███████║███████║      ██║  ██║███████╗██║  ██║███████╗██║   ██║      ██║   
    ╚═══╝  ╚══════╝╚══════╝╚══════╝╚══════╝      ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝   
<=====================================================================================================>
EOF
else
    cat << 'EOF'
    
      $$\    $$\ $$\       $$$$$$$$\  $$$$$$\   $$$$$$\         $$$$$$$\                      $$\ $$\   $$\               
      $$ |   $$ |$$ |      $$  _____|$$  __$$\ $$  __$$\        $$  __$$\                     $$ |\__|  $$ |              
      $$ |   $$ |$$ |      $$ |      $$ /  \__|$$ /  \__|       $$ |  $$ | $$$$$$\   $$$$$$\  $$ |$$\ $$$$$$\   $$\   $$\ 
      \$$\  $$  |$$ |      $$$$$\    \$$$$$$\  \$$$$$$\ $$$$$$\ $$$$$$$  |$$  __$$\  \____$$\ $$ |$$ |\_$$  _|  $$ |  $$ |
       \$$\$$  / $$ |      $$  __|    \____$$\  \____$$\\______|$$  __$$< $$$$$$$$ | $$$$$$$ |$$ |$$ |  $$ |    $$ |  $$ |
        \$$$  /  $$ |      $$ |      $$\   $$ |$$\   $$ |       $$ |  $$ |$$   ____|$$  __$$ |$$ |$$ |  $$ |$$\ $$ |  $$ |
         \$  /   $$$$$$$$\ $$$$$$$$\ \$$$$$$  |\$$$$$$  |       $$ |  $$ |\$$$$$$$\ \$$$$$$$ |$$ |$$ |  \$$$$  |\$$$$$$$ |
          \_/    \________|\________| \______/  \______/        \__|  \__| \_______| \_______|\__|\__|   \____/  \____$$ |
                                                                                                                $$\   $$ |
                                                                                                                \$$$$$$  |
                                                                                                                 \______/ 
<=========================================================================================================================>
EOF
fi
}

# 创建快捷指令
create_shortcut() {
  cat > "$work_dir/r.sh" << EOF
#!/usr/bin/env bash

bash <(curl -Ls https://raw.githubusercontent.com/eooce/sing-box/main/sing-box.sh) \$1
EOF
  chmod +x "$work_dir/sb.sh"
  ln -sf "$work_dir/sb.sh" /usr/bin/sb
  if [ -s /usr/bin/sb ]; then
    green "\n快捷指令 r 创建成功\n"
  else
    red "\n快捷指令创建失败\n"
  fi
}

# 捕获 Ctrl+C 信号
trap 'red "已取消操作"; exit' INT

# 主循环
while true; do
   clear
   purple  "============Reality 管理脚本============"
   purple "   Xray 状态: ${check_singbox_status}
   purple "Reality 状态: ${check_argo_status}"
   purple "  Nginx 状态: ${check_nginx_status}\n"
   echo "1. 安装 Reality"
   green "2. 启动Xray服务"
   green "3. 停止Xray服务"
   green "4. 重启Xray服务\n"
   echo "5. 查看节点信息"
   skybule "6. 修改端口"
   skyblue "7. 修改伪装域名"
   skybule "8. 修改UUID"
   echo  "===================================="
   echo "0. 退出脚本"
   echo "===================================="
   reading "请输入选择(0-8): " choice
   echo ""
   case "${choice}" in
        1)  
            if [ ${check_singbox} -eq 0 ]; then
                yellow "sing-box 已经安装！"
            else
                fix_nginx
                manage_packages install nginx jq tar openssl iptables coreutils
                [ -n "$(curl -s --max-time 2 ipv6.ip.sb)" ] && manage_packages install ip6tables
                install_singbox

                if [ -x "$(command -v systemctl)" ]; then
                    main_systemd_services
                elif [ -x "$(command -v rc-update)" ]; then
                    alpine_openrc_services
                    change_hosts
                    rc-service sing-box restart
                    rc-service argo restart
                else
                    echo "Unsupported init system"
                    exit 1 
                fi

                sleep 5
                get_info
                add_nginx_conf
                create_shortcut
            fi
           ;;
        2) uninstall_singbox ;;
        3) manage_singbox ;;
        4) manage_argo ;;
        5) check_nodes ;;
        6) change_config ;;
        7) disable_open_sub ;;
        8)          
        0) exit 0 ;;
        *) red "无效的选项，请输入 0 到 8" ;; 
   esac
   read -n 1 -s -r -p $'\033[1;91m按任意键继续...\033[0m'
done

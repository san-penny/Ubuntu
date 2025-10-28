FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/vevc/ubuntu"

ENV TZ=Asia/Shanghai \
    SSH_USER=san \
    SSH_PASSWORD=new1025

# 拷贝入口脚本和重启脚本
COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot

# 安装必要的软件包
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y tzdata openssh-server sudo curl ca-certificates wget vim net-tools supervisor cron unzip iputils-ping telnet git iproute2 --no-install-recommends; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /var/run/sshd; \
    chmod +x /entrypoint.sh; \
    chmod +x /usr/local/sbin/reboot; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone

# 暴露22端口
EXPOSE 22

# 使用 entrypoint.sh 启动容器
ENTRYPOINT ["/entrypoint.sh"]

# 默认命令是启动 supervisord 和 sshd
CMD ["supervisord", "-c", "/home/san/boot/supervisord.conf"]

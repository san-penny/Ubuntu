# 基于 Ubuntu 24.04 LTS
FROM ubuntu:24.04

# 避免交互提示、设置时区
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 更改APT源为阿里云镜像源（如果在中国大陆）
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' /etc/apt/sources.list

# 更新APT包列表并安装工具和 Supervisor
RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    curl vim supervisor openssh-server \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# 设置时区
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

# 接收账号密码参数
ARG USER_NAME=san
ARG USER_PASS=san123
ENV USER_NAME=${USER_NAME}
ENV USER_PASS=${USER_PASS}

# 创建用户
RUN id -u ${USER_NAME} &>/dev/null || \
    (echo "Creating user ${USER_NAME}..." && \
     useradd -ms /bin/bash ${USER_NAME} && \
     echo "${USER_NAME}:${USER_PASS}" | chpasswd && \
     usermod -aG sudo ${USER_NAME})

# 切换回 root，确保可以创建配置文件
USER root

# 创建 boot 目录并设置权限
RUN mkdir -p /home/${USER_NAME}/boot \
    && chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/boot

# 默认 supervisord.conf 路径
ENV SUPERVISOR_CONF=/home/${USER_NAME}/boot/supervisord.conf

# 启动逻辑：如果 supervisord.conf 不存在，则生成默认配置
RUN if [ ! -f $SUPERVISOR_CONF ]; then \
        echo '[supervisord]' > $SUPERVISOR_CONF && \
        echo 'nodaemon=true' >> $SUPERVISOR_CONF && \
        echo 'logfile=/home/${USER_NAME}/boot/supervisord.log' >> $SUPERVISOR_CONF && \
        echo '' >> $SUPERVISOR_CONF && \
        echo '[program:bash]' >> $SUPERVISOR_CONF && \
        echo 'command=/bin/bash' >> $SUPERVISOR_CONF && \
        echo 'autostart=true' >> $SUPERVISOR_CONF && \
        echo 'autorestart=true' >> $SUPERVISOR_CONF && \
        echo 'user=${USER_NAME}' >> $SUPERVISOR_CONF && \
        echo 'stdout_logfile=/home/${USER_NAME}/boot/bash.log' >> $SUPERVISOR_CONF && \
        echo 'stderr_logfile=/home/${USER_NAME}/boot/bash_err.log' >> $SUPERVISOR_CONF; \
    fi

# 切换为普通用户执行
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# 暴露 SSH 端口
EXPOSE 22

# 默认启动 Supervisor
CMD ["/usr/bin/supervisord", "-c", "/home/san/boot/supervisord.conf"]

# 基于 Ubuntu 24.04 LTS
FROM ubuntu:24.04

# 避免交互提示、设置时区
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 安装工具和 Supervisor
RUN apt-get update \
 && apt-get -y upgrade \
 && apt-get -y dist-upgrade \
 && apt-get install -y --no-install-recommends \
    curl vim git htop sudo wget unzip python3 python3-pip supervisor openssh-server \
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
RUN useradd -ms /bin/bash ${USER_NAME} \
 && echo "${USER_NAME}:${USER_PASS}" | chpasswd \
 && usermod -aG sudo ${USER_NAME}

# 挂载目录
VOLUME ["/home/${USER_NAME}"]

# 暴露 SSH 端口
EXPOSE 22

# 切换默认用户
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# 确保挂载目录权限
RUN sudo chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME} || true

# 通过环境变量传入 Supervisor 配置路径
ENV SUPERVISOR_CONF=/home/${USER_NAME}/boot/supervisord.conf

# 启动 Supervisor，读取环境变量 SUPERVISOR_CONF
CMD ["/bin/bash", "-c", "/usr/bin/supervisord -c $SUPERVISOR_CONF"]

# 基于 Ubuntu 24.04 LTS
FROM ubuntu:24.04

# 避免交互提示、设置时区
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 更新系统 & 安装工具
RUN apt-get update \
 && apt-get -y upgrade \
 && apt-get -y dist-upgrade \
 && apt-get install -y --no-install-recommends \
    curl vim git htop sudo wget unzip python3 python3-pip supervisor \
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

# 挂载目录（你宿主机会挂载到 /home/san）
VOLUME ["/home/${USER_NAME}"]

# Supervisor 配置文件路径可传入
# 默认在 /home/san/supervisord.conf
ENV SUPERVISOR_CONF=/home/${USER_NAME}/supervisord.conf

# 切换默认用户
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# 启动 Supervisor，读取挂载目录里的配置文件
CMD ["/bin/bash", "-c", "/usr/bin/supervisord -c $SUPERVISOR_CONF"]

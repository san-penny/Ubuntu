# 使用 Ubuntu 基础镜像
FROM ubuntu:22.04

# 安装必要软件
RUN apt-get update && apt-get install -y supervisor sudo bash && rm -rf /var/lib/apt/lists/*

# 默认用户和密码（可以在运行时改）
ENV USER_NAME=san
ENV PASSWORD=san

# 创建用户并赋予sudo权限
RUN useradd -m ${USER_NAME} && echo "${USER_NAME}:${PASSWORD}" | chpasswd && adduser ${USER_NAME} sudo

# 创建目录
RUN mkdir -p /home/${USER_NAME}/boot

# 设置挂载点（宿主机会挂载到这里）
VOLUME ["/home/san"]

# 在启动时检查supervisord.conf是否存在，如果不存在就自动创建
ENTRYPOINT ["/bin/bash", "-c", "\
  if [ ! -f /home/${USER_NAME}/boot/supervisord.conf ]; then \
    echo '[supervisord]' > /home/${USER_NAME}/boot/supervisord.conf && \
    echo 'nodaemon=true' >> /home/${USER_NAME}/boot/supervisord.conf && \
    echo 'logfile=/home/${USER_NAME}/boot/supervisord.log' >> /home/${USER_NAME}/boot/supervisord.conf && \
    echo '' >> /home/${USER_NAME}/boot/supervisord.conf && \
    echo '[program:dummy]' >> /home/${USER_NAME}/boot/supervisord.conf && \
    echo 'command=/bin/bash -c \"while true; do echo Running...; sleep 3600; done\"' >> /home/${USER_NAME}/boot/supervisord.conf; \
  fi; \
  exec supervisord -c /home/${USER_NAME}/boot/supervisord.conf"]

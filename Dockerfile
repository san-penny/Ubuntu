# 如果你希望固定为 LTS，可改为 ubuntu:24.04
FROM ubuntu:24.04

# 避免交互提示、设置时区（可选）
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 更新源、升级系统到最新、安装必要工具并清理缓存
RUN apt-get update \
 && apt-get -y upgrade \
 && apt-get -y dist-upgrade \
 && apt-get install -y --no-install-recommends curl vim \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

CMD ["bash"]

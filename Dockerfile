# 使用基础镜像
FROM node:16

# 安装必需的工具
RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制项目代码
COPY . /app

# 安装 Node.js 依赖
RUN npm install

# 暴露端口
EXPOSE 80

# 启动 Node.js 进程管理器（假设使用 Express.js）
CMD ["node", "proxy.js"]
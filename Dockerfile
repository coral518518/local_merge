# --- Stage 1: Build the Go application ---
FROM golang:1.23-alpine AS go-builder

# 配置 Alpine 和 Go proxy 使用阿里云和国内镜像，解决网络不通导致构建失败的问题
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --no-cache git
ENV GOPROXY=https://goproxy.cn,direct

WORKDIR /build
# 单独拷贝 Go 程序以利用缓存构建
COPY CLIProxyAPI-main/ ./CLIProxyAPI-main/

RUN cd CLIProxyAPI-main && \
    go mod tidy && \
    go build -o ./CLIProxyAPI ./cmd/server/


# --- Stage 2: Final Runtime Environment ---
FROM node:20-bookworm-slim

# 替换 Debian apt 源为阿里云镜像，解决 Exit Code 100
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources 2>/dev/null || \
    sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list 2>/dev/null

# 安装 Python 和必需工具
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv (Python 包管理器)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app

# 将整个项目拷贝进来
COPY . /app

# 注入刚才第一阶段编译好的 Go 二进制可执行文件
COPY --from=go-builder /build/CLIProxyAPI-main/CLIProxyAPI /app/CLIProxyAPI-main/CLIProxyAPI

# 安装 Node 依赖 (使用淘宝镜像源)
RUN npm install --registry=https://registry.npmmirror.com

# 初始化 grok2api 依赖
RUN cd /app/grok2api-main && uv sync

# 赋予执行权限
RUN chmod +x /app/start.sh

# 暴露端口
EXPOSE 8080 8317 8000

CMD ["/app/start.sh"]
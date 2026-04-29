# --- 第一阶段：构建阶段 ---
FROM node:22-bullseye AS builder

WORKDIR /app

# 使用阿里云镜像加速 apt-get
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY package*.json ./

# 使用淘宝镜像加速 npm 安装
RUN npm config set registry https://registry.npmmirror.com && \
    npm install

# 复制项目文件并构建
COPY . .
RUN npm run build

# --- 第二阶段：运行阶段 ---
FROM node:22-bullseye-slim

WORKDIR /app

# 运行环境安装 tsx
RUN npm config set registry https://registry.npmmirror.com && \
    npm install -g tsx

# 从构建阶段复制产物
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server.ts ./
COPY --from=builder /app/public ./public 2>/dev/null || true

# 创建持久化数据目录
RUN mkdir -p /app/data

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["tsx", "server.ts"]

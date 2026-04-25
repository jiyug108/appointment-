# 使用 Node.js 20 官方镜像作为基础
FROM node:20-slim as builder

WORKDIR /app

# 安装依赖
COPY package*.json ./
RUN npm install

# 复制源代码并构建
COPY . .
RUN npm run build

# 运行环境
FROM node:20-slim

WORKDIR /app

# 只需要生产环境依赖
COPY package*.json ./
RUN npm install --production

# 从构建阶段复制打包好的文件和 server.ts
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server.ts ./

# 安装 tsx 用于运行 server.ts (或者您可以修改服务器启动方式)
RUN npm install -g tsx

# 暴露端口
EXPOSE 3000

# 启动命令
CMD ["tsx", "server.ts"]

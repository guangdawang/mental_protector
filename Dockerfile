# 多阶段构建 - 构建阶段
FROM cirrusci/flutter:stable AS builder

WORKDIR /app

# 复制依赖文件
COPY pubspec.yaml pubspec.lock ./

# 下载依赖
RUN flutter pub get

# 复制源代码
COPY . .

# 构建Web应用
RUN flutter build web --release

# 生产阶段 - 使用Nginx提供静态文件
FROM nginx:alpine

# 复制构建产物到Nginx
COPY --from=builder /app/build/web /usr/share/nginx/html

# 复制自定义Nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露80端口
EXPOSE 80

# 启动Nginx
CMD ["nginx", "-g", "daemon off;"]

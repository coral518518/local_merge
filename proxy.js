const express = require('express');
const httpProxy = require('http-proxy');
const app = express();
const proxy = httpProxy.createProxyServer();

// 路由配置：根据路径将请求转发到不同的项目容器

// 项目1（Node.js 容器，监听 8317
app.use('/CLIProxyAPI-main', (req, res) => {
    proxy.web(req, res, { target: 'http://localhost:8317' });
});

// 项目2（Node.js 容器，监听 8000
app.use('/grok2api-main', (req, res) => {
    proxy.web(req, res, { target: 'http://localhost:8000' });
});

// 启动代理服务，统一监听 8080 端口
app.listen(8080, () => {
    console.log('Proxy server running on port 80');
});
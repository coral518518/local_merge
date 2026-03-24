const express = require('express');
const httpProxy = require('http-proxy');

const app = express();
const proxy = httpProxy.createProxyServer({});

proxy.on('error', (err, req, res) => {
  console.error('Proxy error:', err.message);
  if (!res.headersSent) {
    res.writeHead(502, { 'Content-Type': 'text/plain; charset=utf-8' });
  }
  res.end('Bad gateway');
});

function forward(prefix, target) {
  app.use(prefix, (req, res) => {
    req.url = req.url.replace(new RegExp(`^${prefix}`), '') || '/';
    proxy.web(req, res, { target, changeOrigin: true });
  });
}

forward('/CLIProxyAPI-main', 'http://127.0.0.1:8317');
forward('/grok2api-main', 'http://127.0.0.1:8000');

app.get('/', (req, res) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.end(`
    <h2>Services Running</h2>
    <ul>
      <li><a href="/CLIProxyAPI-main">CLIProxyAPI-main</a></li>
      <li><a href="/grok2api-main">grok2api-main</a></li>
    </ul>
  `);
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Proxy server running on port ${PORT}`);
});
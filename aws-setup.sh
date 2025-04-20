#!/bin/bash

echo "🚀 Starting Phantomcorex++ Deployment..."

# -----------------------------
# 1. SYSTEM UPDATE & ESSENTIALS
# -----------------------------
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl ufw build-essential

# -----------------------------
# 2. INSTALL NODE.JS (LTS)
# -----------------------------
echo "🧠 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v

# -----------------------------
# 3. INSTALL MONGODB
# -----------------------------
echo "🗄️ Installing MongoDB..."
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl enable mongod
sudo systemctl start mongod

# -----------------------------
# 4. INSTALL PM2
# -----------------------------
echo "⚙️ Installing PM2..."
sudo npm install -g pm2

# -----------------------------
# 5. CLONE OR COPY YOUR APP
# -----------------------------
echo "📁 Setting up Phantomcorex++ app..."
# If your app is on GitHub:
 git clone https://github.com/Gagan2021/phantomcorex.git
 cd phantomcorex

# -----------------------------
# 6. INSTALL DEPENDENCIES
# -----------------------------
echo "📦 Installing npm dependencies..."
npm install

# -----------------------------
# 8. START SERVER WITH PM2
# -----------------------------
echo "🚀 Starting Phantomcorex++ server..."
pm2 start server.js --name phantomcorex
pm2 save
pm2 startup
echo "✅ PM2 running your app!"

# -----------------------------
# 9. INSTALL & CONFIGURE NGINX
# -----------------------------
echo "🌐 Installing Nginx..."
sudo apt install -y nginx

echo "🌐 Configuring Nginx reverse proxy..."
sudo tee /etc/nginx/sites-available/phantomcorex > /dev/null <<EOF
server {
    listen 80;
    server_name phantomcorex.space;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/phantomcorex /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

# -----------------------------
# 10. HTTPS (Let's Encrypt)
# -----------------------------
echo "🔐 Setting up HTTPS with Let's Encrypt..."
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx

# -----------------------------
# 11. FIREWALL
# -----------------------------
echo "🛡️ Setting up UFW firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# -----------------------------
# 12. DONE
# -----------------------------
echo "🎉 Deployment complete!"
echo "🌐 Visit your app at: http://phantomcorex.space or http://<your-server-ip>"


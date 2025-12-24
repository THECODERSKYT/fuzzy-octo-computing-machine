#!/bin/bash
# -----------------------------
# Fully Automated Minecraft Bot + Fake Webserver Setup
# Author: Sunny (for personal use)
# -----------------------------

# Update & install required packages
echo "[*] Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo "[*] Installing curl, git, build-essential..."
sudo apt install -y curl git build-essential

# Node.js install (v20)
if ! command -v node &> /dev/null
then
    echo "[*] Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
else
    echo "[*] Node.js already installed."
fi

# PM2 install
if ! command -v pm2 &> /dev/null
then
    echo "[*] Installing PM2..."
    sudo npm install -g pm2
else
    echo "[*] PM2 already installed."
fi

# Create project folder
BOT_DIR="$HOME/mc-bots"
mkdir -p $BOT_DIR
cd $BOT_DIR

# Initialize project
if [ ! -f package.json ]; then
    echo "[*] Initializing Node.js project..."
    npm init -y
fi

# Install dependencies
echo "[*] Installing Mineflayer and Express..."
npm install mineflayer express

# Create index.js
cat > index.js <<EOL
const mineflayer = require('mineflayer');
const express = require('express');

const HOST = 'blazexnode.falixsrv.me';
const PORT_MC = 25565;
const BOT_COUNT = 3;
const WEB_PORT = 8080;

// --- Fake Webserver ---
const app = express();
app.get('/', (req, res) => {
  res.send(\`<h1>Welcome to our Fake Webserver!</h1><p>Server is running...</p>\`);
});
app.listen(WEB_PORT, () => {
  console.log(\`HTTP server running on port \${WEB_PORT}\`);
});

// --- Minecraft Bots ---
function randomName() {
  return 'Bot_' + Math.random().toString(36).substring(2, 8);
}

function createBot() {
  const bot = mineflayer.createBot({
    host: HOST,
    port: PORT_MC,
    username: randomName(),
    auth: 'offline'
  });

  bot.on('spawn', () => {
    console.log(bot.username + ' joined the server');
    setInterval(() => {
      bot.setControlState('jump', true);
      setTimeout(() => bot.setControlState('jump', false), 200);
    }, 1000);
  });

  bot.on('end', () => {
    console.log(bot.username + ' disconnected, rejoining...');
    setTimeout(createBot, 3000);
  });

  bot.on('error', err => {
    console.log(bot.username + ' error:', err.message);
  });
}

// Launch multiple bots
for (let i = 0; i < BOT_COUNT; i++) {
  setTimeout(createBot, i * 2000);
}
EOL

# Start with PM2
pm2 start index.js --name mc-bots
pm2 save
pm2 startup

echo "[✅] Setup complete!"
echo "Bots running in background, HTTP server on port 8080"
echo "Use: pm2 logs mc-bots   to see output"

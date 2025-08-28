#!/bin/bash
# Automate scaffolding the Quant Crypto Trading Platform structure and files.

set -e

# Create directory structure
mkdir -p backend/src frontend/src ml/src infra

# Create README.md in repo root
cat << 'EOF' > README.md
# Quant Crypto Trading Platform

This repo scaffolds a full-stack AI-powered crypto quant trading platform.

## Structure

- **backend/**: Node.js/TypeScript Express APIs, exchange/wallet integration, WebSocket, PostgreSQL, Redis, RabbitMQ.
- **frontend/**: React/TypeScript UI, Tailwind CSS, wallet connectors, TradingView/Chart.js widgets.
- **ml/**: TensorFlow.js ML microservice (expandable to Python).
- **infra/**: Infrastructure & deployment (Docker Compose, K8s).

## Local Development

1. Install [Docker](https://www.docker.com/)
2. `docker compose up --build`
3. Frontend at `http://localhost:3000`
4. Backend API at `http://localhost:4000/api`
5. ML service at `http://localhost:5000`

## Quick Start

- Configure API keys in `.env` files in `backend/` and `frontend/`
- See each service's README for further instructions

## Tech Stack

- **Backend**: Node.js, Express, TypeScript, PostgreSQL, Redis, RabbitMQ, WebSocket
- **Frontend**: React, TypeScript, Tailwind CSS, TradingView/Chart.js, Phantom/MetaMask/WalletConnect
- **ML**: TensorFlow.js (starter), REST API for predictions/signals
- **Infra**: Docker Compose, ready for K8s
EOF

# Create infra/docker-compose.yml
cat << 'EOF' > infra/docker-compose.yml
version: '3.8'
services:
  backend:
    build: ../backend
    ports:
      - "4000:4000"
    depends_on:
      - postgres
      - redis
      - rabbitmq
    environment:
      DATABASE_URL: postgres://quant:quant@postgres:5432/quant
      REDIS_URL: redis://redis:6379
      RABBITMQ_URL: amqp://rabbitmq
    volumes:
      - ../backend:/app
  frontend:
    build: ../frontend
    ports:
      - "3000:3000"
    environment:
      REACT_APP_BACKEND_URL: http://localhost:4000/api
      REACT_APP_ML_URL: http://localhost:5000
    volumes:
      - ../frontend:/app
  ml:
    build: ../ml
    ports:
      - "5000:5000"
    volumes:
      - ../ml:/app
  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: quant
      POSTGRES_PASSWORD: quant
      POSTGRES_DB: quant
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
  redis:
    image: redis:6
    ports:
      - "6379:6379"
  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "5672:5672"
      - "15672:15672"
volumes:
  pgdata:
EOF

# Create backend files
cat << 'EOF' > backend/package.json
{
  "name": "quant-crypto-backend",
  "version": "0.1.0",
  "description": "Node.js/TypeScript backend for Quant Crypto Trading Platform",
  "main": "dist/index.js",
  "scripts": {
    "dev": "ts-node-dev src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "ws": "^8.13.0",
    "pg": "^8.11.3",
    "redis": "^4.6.7",
    "amqplib": "^0.10.3",
    "dotenv": "^16.4.5",
    "cors": "^2.8.5",
    "jsonwebtoken": "^9.0.2",
    "bcrypt": "^5.1.1"
  },
  "devDependencies": {
    "typescript": "^5.4.5",
    "ts-node-dev": "^2.0.0",
    "@types/express": "^4.17.21",
    "@types/ws": "^8.5.8",
    "@types/node": "^20.11.25"
  }
}
EOF

cat << 'EOF' > backend/tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "CommonJS",
    "lib": ["ES2022"],
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
EOF

cat << 'EOF' > backend/Dockerfile
# Node.js TypeScript backend Dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

EXPOSE 4000

CMD ["npm", "start"]
EOF

cat << 'EOF' > backend/.env.example
PORT=4000
DATABASE_URL=postgres://quant:quant@postgres:5432/quant
REDIS_URL=redis://redis:6379
RABBITMQ_URL=amqp://rabbitmq
JWT_SECRET=your-secret-key
EOF

cat << 'EOF' > backend/src/index.ts
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { createServer } from "http";
import { Server as WebSocketServer } from "ws";

// Load env variables
dotenv.config();

const app = express();
const httpServer = createServer(app);

// Middlewares
app.use(cors());
app.use(express.json());

// Sample route
app.get("/api/health", (req, res) => {
  res.json({ status: "ok", timestamp: Date.now() });
});

// Placeholder for future exchange/wallet routes
app.get("/api/info", (req, res) => {
  res.json({
    name: "Quant Crypto Trading Backend",
    version: "0.1.0",
    exchanges: ["Binance", "Coinbase", "Kraken"],
    wallets: ["Phantom", "MetaMask"],
  });
});

// WebSocket server for live updates
const wss = new WebSocketServer({ server: httpServer });

wss.on("connection", (ws) => {
  ws.send(JSON.stringify({ message: "WebSocket connected.", timestamp: Date.now() }));
  ws.on("message", (msg) => {
    // Echo for now
    ws.send(msg.toString());
  });
});

// Start server
const PORT = process.env.PORT || 4000;
httpServer.listen(PORT, () => {
  console.log(`Backend API listening on port ${PORT}`);
});
EOF

cat << 'EOF' > backend/README.md
# Backend Service

Node.js/TypeScript Express backend for Quant Crypto Trading Platform.

## Features
- REST API (`/api/health`, `/api/info`)
- WebSocket server for live updates
- Ready for PostgreSQL, Redis, RabbitMQ integration

## Local Dev

\`\`\`bash
npm install
npm run dev
\`\`\`

## Docker

\`\`\`bash
docker build -t quant-backend .
docker run -p 4000:4000 quant-backend
\`\`\`
EOF

# Create frontend files
cat << 'EOF' > frontend/package.json
{
  "name": "quant-crypto-frontend",
  "version": "0.1.0",
  "description": "React/TypeScript frontend for Quant Crypto Trading Platform",
  "main": "src/index.tsx",
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "^5.0.1",
    "typescript": "^5.4.5",
    "tailwindcss": "^3.4.1",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.31",
    "recharts": "^2.8.0",
    "lucide-react": "^0.293.0",
    "web3": "^1.10.0",
    "@walletconnect/web3-provider": "^1.8.0",
    "@solana/web3.js": "^1.94.2"
  },
  "devDependencies": {
    "@types/react": "^18.2.17",
    "@types/react-dom": "^18.2.7"
  }
}
EOF

cat << 'EOF' > frontend/tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["DOM", "ES2022"],
    "jsx": "react-jsx",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
EOF

cat << 'EOF' > frontend/Dockerfile
# React frontend Dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOF

cat << 'EOF' > frontend/.env.example
REACT_APP_BACKEND_URL=http://localhost:4000/api
REACT_APP_ML_URL=http://localhost:5000
EOF

cat << 'EOF' > frontend/src/App.tsx
import React, { useState, useEffect } from "react";

const API_URL = process.env.REACT_APP_BACKEND_URL || "http://localhost:4000/api";

function App() {
  const [health, setHealth] = useState<any>(null);

  useEffect(() => {
    fetch(`${API_URL}/health`)
      .then((res) => res.json())
      .then(setHealth)
      .catch(() => setHealth(null));
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900 text-white flex flex-col items-center justify-center">
      <div className="max-w-xl w-full px-6 py-8 bg-gray-800 rounded-xl shadow-lg">
        <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent mb-4">
          Quant Crypto Trading Platform
        </h1>
        <p className="mb-6 text-gray-300">AI-powered quant trading for crypto assets.</p>
        <div className="mb-4">
          <h2 className="text-xl font-semibold mb-2">Backend Health</h2>
          {health ? (
            <div className="text-green-400">Status: {health.status} <br /> Timestamp: {new Date(health.timestamp).toLocaleString()}</div>
          ) : (
            <div className="text-red-400">Unable to fetch backend health.</div>
          )}
        </div>
        <div>
          <h2 className="text-xl font-semibold mb-2">Getting Started</h2>
          <ul className="list-disc ml-6 text-gray-300">
            <li>Connect your wallet</li>
            <li>Select crypto assets</li>
            <li>Configure AI strategy and risk</li>
            <li>Start trading!</li>
          </ul>
        </div>
      </div>
    </div>
  );
}

export default App;
EOF

cat << 'EOF' > frontend/src/index.tsx
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";

const root = ReactDOM.createRoot(document.getElementById("root")!);
root.render(<React.StrictMode><App /></React.StrictMode>);
EOF

cat << 'EOF' > frontend/src/index.css
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  font-family: 'Inter', sans-serif;
}
EOF

cat << 'EOF' > frontend/README.md
# Frontend Service

React/TypeScript frontend for Quant Crypto Trading Platform.

## Features
- Tailwind CSS UI
- Connects to backend health endpoint

## Local Dev

\`\`\`bash
npm install
npm start
\`\`\`

## Docker

\`\`\`bash
docker build -t quant-frontend .
docker run -p 3000:3000 quant-frontend
\`\`\`
EOF

# Create ml files
cat << 'EOF' > ml/package.json
{
  "name": "quant-crypto-ml",
  "version": "0.1.0",
  "description": "ML microservice for Quant Crypto Trading Platform",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js"
  },
  "dependencies": {
    "@tensorflow/tfjs-node": "^4.13.0",
    "express": "^4.18.2",
    "cors": "^2.8.5"
  }
}
EOF

cat << 'EOF' > ml/Dockerfile
# ML microservice Dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 5000

CMD ["npm", "start"]
EOF

cat << 'EOF' > ml/.env.example
PORT=5000
EOF

cat << 'EOF' > ml/src/index.js
const express = require("express");
const cors = require("cors");
const tf = require("@tensorflow/tfjs-node");

const app = express();
app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ status: "ok", timestamp: Date.now() });
});

// Dummy prediction endpoint
app.post("/predict", async (req, res) => {
  // Input: { features: [...] }
  const { features } = req.body;
  // For now, random prediction
  const prediction = features.map(() => Math.random());

  res.json({ prediction });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`ML service listening on port ${PORT}`);
});
EOF

cat << 'EOF' > ml/README.md
# ML Microservice

TensorFlow.js microservice for predictions/signals.

## Features
- REST API `/health`, `/predict`

## Local Dev

\`\`\`bash
npm install
npm start
\`\`\`

## Docker

\`\`\`bash
docker build -t quant-ml .
docker run -p 5000:5000 quant-ml
\`\`\`
EOF

echo "✅ Quant Crypto Trading Platform scaffolding complete!"
echo "Next steps:"
echo "1. Install dependencies in each service directory (backend, frontend, ml)."
echo "2. Start with: docker compose -f infra/docker-compose.yml up --build"
echo "3. Access frontend at http://localhost:3000"
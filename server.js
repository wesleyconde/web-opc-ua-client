// server.js
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const pty = require('node-pty');
const path = require('path');

require('dotenv').config()
const { env } = require('node:process')

const app = express();
const server = http.createServer(app);
const io = new Server(server);

// Serve static files
app.use(express.static('public'));

// Handle socket.io connections
io.on('connection', (socket) => {
  console.log('Client connected');

  // Path to your script
  const scriptPath = path.join(__dirname, 'script.sh');

  // Spawn the shell and execute the script
  const shell = process.platform === 'win32' ? 'powershell.exe' : 'bash';
  const ptyProcess = pty.spawn(shell, [scriptPath], {
    name: 'xterm-color',
    cols: 80,
    rows: 24,
    cwd: process.env.HOME,
    env: process.env,
  });

  // Send terminal data to the client
  ptyProcess.on('data', (data) => {
    socket.emit('output', data);
  });

  // Receive input from the client
  socket.on('input', (data) => {
    ptyProcess.write(data);
  });

  // Handle terminal resize
  socket.on('resize', (cols, rows) => {
    ptyProcess.resize(cols, rows);
  });

  // Clean up on disconnect
  socket.on('disconnect', () => {
    console.log('Client disconnected');
    ptyProcess.kill();
  });
});

const PORT = 2002;
server.listen(env.PORT, '0.0.0.0', () => {
  console.log(`Server running at http://localhost:${PORT}`);
});


# Backend deployment guide for myEvent (Windows - Acer Swift 3)

This document contains explicit, step-by-step instructions to prepare the Windows server, install required software, deploy a backend API, expose it to the internet via Cloudflare Tunnel (`cloudflared`), and verify the mobile Flutter app connectivity.

This guide assumes you will use the recommended stack: Node.js + Express (backend) and PostgreSQL (database). If you already have a backend implementation, follow the "Deploy existing backend" steps. Replace placeholders (e.g. `<YOUR_REPO_URL>`, `<DB_USER>`, `<DB_PASS>`, `<TUNNEL_NAME>`) with your actual values.

--------------------------------------------------------------------------------
Prerequisites (what will run on the Acer Swift 3 Windows laptop)
- Node.js (LTS)
- Git
- PostgreSQL
- cloudflared (Cloudflare Tunnel)
- NSSM (or PM2-windows) to run the backend as a Windows service
- Backend source code (you will clone or copy)

--------------------------------------------------------------------------------
Quick overview (high level)
1. Install system dependencies (Node, Git, PostgreSQL, cloudflared, NSSM).
2. Create PostgreSQL user and database.
3. Clone the backend repo into `C:\\srv\\myevent-backend` (example path).
4. Configure environment variables (.env) with DB URL, JWT secret, port, etc.
5. Install Node dependencies and run database migrations (or import SQL schema).
6. Start and test the server locally.
7. Install and configure `cloudflared` to expose the server to the internet.
8. Configure a Windows service (NSSM) to keep the backend running.
9. Update the Flutter client `ApiService.baseUrl` to the tunnel URL and test the app.

--------------------------------------------------------------------------------
Step 0 — Open PowerShell as Administrator
All commands below should be run in an elevated PowerShell session (right-click PowerShell → Run as Administrator) unless otherwise noted.

Step 1 — Install Chocolatey (optional but recommended)
If you already have Node/Git/Postgres installed, skip this step. Chocolatey makes installing packages simpler.

PowerShell (Admin):
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex
```

Step 2 — Install required packages with Chocolatey
```powershell
choco install -y nodejs-lts git postgresql cloudflared nssm
```

Notes if you do not use Chocolatey:
- Download Node.js LTS MSI: https://nodejs.org/
- Download Git for Windows: https://git-scm.com/download/win
- Download PostgreSQL installer: https://www.postgresql.org/download/windows/
- Download cloudflared: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/
- Download NSSM: https://nssm.cc/download

Step 3 — Initialize PostgreSQL and create database + user
After installing PostgreSQL (choco or installer), initialize DB if required and open `psql`.

Open a non-admin PowerShell or `psql` shell as the `postgres` superuser (you set the `postgres` password during install).

Example psql commands (run in PowerShell):
```powershell
# Switch to postgres user folder where psql is available or add to PATH
psql -U postgres

-- Inside psql:
CREATE USER myevent_user WITH PASSWORD 'StrongPasswordHere!';
CREATE DATABASE myevent_db OWNER myevent_user;
GRANT ALL PRIVILEGES ON DATABASE myevent_db TO myevent_user;
\q
```

Store the DB credentials; you'll use them in the backend `.env`.

Step 4 — Prepare the backend source on the server
Option A — Clone your backend repo (if you have one):
```powershell
mkdir C:\\srv\\myevent-backend
cd C:\\srv\\myevent-backend
git clone <YOUR_REPO_URL> .
```

Option B — If you are creating the backend later, place the server source into `C:\\srv\\myevent-backend`.

Step 5 — Environment variables (.env)
Create an `.env` file in the backend root (example variables). Never commit real secrets.

Example `.env`:
```
PORT=3000
DATABASE_URL=postgres://myevent_user:StrongPasswordHere!@localhost:5432/myevent_db
JWT_SECRET=ReplaceWithAStrongSecret
NODE_ENV=production
```

If your backend uses separate PG env vars instead of `DATABASE_URL`, set PGHOST, PGUSER, PGPASSWORD, PGDATABASE, PGPORT accordingly.

Step 6 — Install Node dependencies and build (if applicable)
From the backend project root:
```powershell
cd C:\\srv\\myevent-backend
npm install
# If the project uses a build step (TypeScript, bundler):
npm run build   # optional
```

Step 7 — Initialize or migrate the database schema
If your backend ships migration scripts (e.g., SQL files or migration tools), run them now.

Option A — SQL schema file `migrations/schema.sql`:
```powershell
psql -U postgres -d myevent_db -f migrations\\schema.sql
```

Option B — Migration tool (example with knex/TypeORM/Sequelize):
```powershell
npm run migrate
```

Step 8 — Start the server locally and test
Start the server manually to test before creating a service:
```powershell
# If the app has a start script
npm start
# or directly
node index.js
```

Test a simple endpoint (replace port if configured):
```powershell
curl http://localhost:3000/events/popular
```

You should receive JSON or a 200 response (depending on implementation).

Step 9 — Configure the backend to run as a Windows Service using NSSM
Using NSSM is simple and avoids manual service authoring.

Example (PowerShell, adjust paths):
```powershell
# Install service
C:\\tools\\nssm\\win64\\nssm.exe install myevent-backend "C:\\Program Files\\nodejs\\node.exe" "C:\\srv\\myevent-backend\\index.js"

# (In NSSM GUI or CLI) set the working directory to C:\\srv\\myevent-backend
# Add Environment variables (NSSM GUI -> Environment): PORT, DATABASE_URL, JWT_SECRET

# Start service
nssm start myevent-backend
```

Alternative: use pm2 and pm2-windows-startup for Node.js process management.

Step 10 — Install and configure Cloudflare Tunnel (`cloudflared`)
This exposes your local `http://localhost:3000` (or configured port) to a stable public URL securely.

Authenticate and create a named tunnel:
```powershell
cloudflared login
# Follow browser-based Cloudflare authentication

# Create a named tunnel (replace <TUNNEL_NAME>)
cloudflared tunnel create <TUNNEL_NAME>

# Route a DNS name (optional - requires domain on your Cloudflare account)
cloudflared tunnel route dns <TUNNEL_NAME> myevent.example.com

# Create a config file (example: C:\\srv\\myevent-backend\\cloudflared\\config.yml)
# Example config.yml:
# tunnel: <TUNNEL_ID>
# credentials-file: C:\\Users\\<you>\\.cloudflared\\<TUNNEL_ID>.json
# ingress:
#   - hostname: myevent.example.com
#     service: http://localhost:3000
#   - service: http_status:404

# Run the tunnel
cloudflared tunnel run <TUNNEL_NAME>
```

Quick-tunnel (temporary, convenient for testing):
```powershell
cloudflared tunnel --url http://localhost:3000
```

Important: Configure `cloudflared` to run as a service so the tunnel persists across reboots. Cloudflared docs: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/run-tunnel/

Step 11 — Verify the public URL
Once the tunnel is running, it will provide a public URL (or you mapped it to your domain). Test from another machine:
```powershell
curl https://<your-tunnel-domain>/events/popular
```

If you used `cloudflared tunnel --url ...` you will see a temporary URL in the cloudflared output.

Step 12 — Update Flutter client to use the new backend URL
Edit `lib/services/api_service.dart` in your Flutter project and replace `baseUrl` with the tunnel URL (e.g., `https://myevent.example.com` or the cloudflared URL). Then rebuild the app or change environment configuration.

Step 13 — Backups (database)
Schedule regular PostgreSQL dumps using Task Scheduler with a PowerShell script. Example command to create a daily dump:
```powershell
pg_dump -U myevent_user -F c -b -v -f "C:\\backups\\myevent_db_$(Get-Date -Format yyyyMMdd).dump" myevent_db
```

Step 14 — Logs and monitoring
- Configure the backend to write logs to a file (or let NSSM capture stdout/stderr).
- Use a simple health-check endpoint (`GET /health`) and periodically curl it from a remote monitor.

Step 15 — Security & hardening checklist
- Use strong passwords and rotate `JWT_SECRET` periodically.
- Limit PostgreSQL to listen on localhost only (default) and use `cloudflared` for exposure.
- Keep Windows and installed packages updated.
- Use firewall rules to restrict direct inbound connections.

Troubleshooting tips
- If `psql` cannot connect, check PostgreSQL service is running and credentials are correct.
- If `cloudflared` fails to run, re-run `cloudflared login` to refresh credentials.
- If the mobile app shows CORS or mixed content issues, ensure the tunnel is HTTPS and the backend serves via HTTP behind the tunnel (cloudflared terminates TLS).

Useful commands summary (copy-paste)
```powershell
# Install packages (with Chocolatey)
choco install -y nodejs-lts git postgresql cloudflared nssm

# Create DB and user (psql)
psql -U postgres -c "CREATE USER myevent_user WITH PASSWORD 'StrongPasswordHere!';"
psql -U postgres -c "CREATE DATABASE myevent_db OWNER myevent_user;"

# Clone backend
mkdir C:\\srv\\myevent-backend; cd C:\\srv\\myevent-backend
git clone <YOUR_REPO_URL> .

# Install dependencies
npm install

# Run locally
npm start

# Create tunnel (quick test)
cloudflared tunnel --url http://localhost:3000

# Backup example
pg_dump -U myevent_user -F c -b -v -f "C:\\backups\\myevent_db_$(Get-Date -Format yyyyMMdd).dump" myevent_db
```

--------------------------------------------------------------------------------
What I did NOT add here
- Server implementation code (API server) — you need to provide or I can scaffold one if you want.
- Detailed migrations/SQL schema — include your migration SQL in `migrations/` or ask me to generate a starter schema matching the Flutter models.

--------------------------------------------------------------------------------
If you'd like, next I can:
- Provide a sample minimal Node.js + Express server repository implementing the exact endpoints the Flutter client expects (I will generate code and migration SQL).
- Or produce SQL schema and seeding SQL based on the Flutter `Event`, `Message`, `Ticket`, `User` models.

Choose one and I'll generate the artifacts or hold off if you prefer to implement/bring your own backend.


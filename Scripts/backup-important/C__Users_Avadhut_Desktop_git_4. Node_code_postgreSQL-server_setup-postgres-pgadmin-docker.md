# Setup PostgreSQL and pgAdmin using Docker

This guide provides step-by-step instructions to set up PostgreSQL database and pgAdmin using Docker containers.

## Prerequisites

- Docker Desktop installed and running on your system
- Terminal/Command Prompt access

## Configuration Details

> **⚠️ Security Note**: Replace all placeholder credentials with your own secure passwords before running the setup commands.

- **PostgreSQL Container**: `postgres-db`
  - Username: `postgres` (default superuser)
  - Password: `YOUR_POSTGRES_PASSWORD` (replace with your secure password)
  - Port: `5432`

- **pgAdmin Container**: `pgadmin`
  - Email: `YOUR_EMAIL@example.com` (replace with your email)
  - Password: `YOUR_PGADMIN_PASSWORD` (replace with your secure password)
  - Port: `5050`

---

## Step-by-Step Setup

### Step 1: Verify Docker is Running

First, verify that Docker is running on your system:

```bash
docker info
```

You should see Docker version information and server details. If Docker is not running, start Docker Desktop.

---

### Step 2: Create Docker Network

Create a Docker network to connect PostgreSQL and pgAdmin containers:

```bash
docker network create pgnetwork
```

**Expected Output:**
```
bb066cf4257cb513d1063f40dfaa0be708800c17fa985a64cf50c09b2a669e7c
```

This network ID confirms the network was created successfully.

My Result : 
```bash
PS C:\Users\Avadhut> docker network create pgnetwork
77bc238cc9b24b83879a2c6620d6171e19c68091f1093a261a59117ad51d1be1
PS C:\Users\Avadhut> docker network ls
NETWORK ID     NAME                            DRIVER    SCOPE
4bfd81b2fe1b   bridge                          bridge    local
315565a7bbf0   host                            host      local
6436d8c9ef36   none                            null      local
77bc238cc9b2   pgnetwork                       bridge    local
0d0072358b70   pixelplusaiv2_backend_default   bridge    local
PS C:\Users\Avadhut>
```

---

### Step 3: Create PostgreSQL Container

> **⚠️ Important: Data Persistence**
> 
> **Without volume mounting**: All your database data will be **lost permanently** if you remove the container. This includes all databases, tables, and data you create.
> 
> **With volume mounting**: Your data will persist even if you remove or recreate the container. The data is stored on your host machine and can be backed up easily.
> 
> **We strongly recommend using volume mounting for production use or any important data.**

#### Option A: With Volume Mounting (Recommended)

Run the PostgreSQL container with volume mounting to persist your data:

```bash
docker run --name postgres-db --network pgnetwork -e POSTGRES_PASSWORD=YOUR_POSTGRES_PASSWORD -p 5432:5432 -v postgres-data:/var/lib/postgresql/data -d postgres
```

**Command Breakdown:**
- `--name postgres-db`: Names the container `postgres-db`
- `--network pgnetwork`: Connects container to the `pgnetwork` network
- `-e POSTGRES_PASSWORD=YOUR_POSTGRES_PASSWORD`: Sets the PostgreSQL password (replace with your secure password)
- `-p 5432:5432`: Maps container port 5432 to host port 5432
- `-v postgres-data:/var/lib/postgresql/data`: **Mounts a named volume** to persist database data
  - `postgres-data`: Name of the Docker volume (created automatically if it doesn't exist)
  - `/var/lib/postgresql/data`: Path inside container where PostgreSQL stores data
- `-d`: Runs container in detached mode (background)
- `postgres`: Uses the official PostgreSQL Docker image

#### Option B: Without Volume Mounting (Data will be lost if container is removed)

If you don't need data persistence (e.g., for testing only):

```bash
docker run --name postgres-db --network pgnetwork -e POSTGRES_PASSWORD=YOUR_POSTGRES_PASSWORD -p 5432:5432 -d postgres
```

**Command Breakdown:**
- `--name postgres-db`: Names the container `postgres-db`
- `--network pgnetwork`: Connects container to the `pgnetwork` network
- `-e POSTGRES_PASSWORD=YOUR_POSTGRES_PASSWORD`: Sets the PostgreSQL password (replace with your secure password)
- `-p 5432:5432`: Maps container port 5432 to host port 5432
- `-d`: Runs container in detached mode (background)
- `postgres`: Uses the official PostgreSQL Docker image

**Expected Output:**
- If the image is not present locally, Docker will download it automatically
- You'll see a container ID (e.g., `8e280b47786994be3162b07526e495fe2e0a46d77c01f48ffe28cb34c190ca74`)

**Note:** The first time you run this command, Docker will download the PostgreSQL image, which may take a few minutes.

My Result : 
```bash
PS C:\Users\Avadhut> docker run --name postgres-db --network pgnetwork -e POSTGRES_PASSWORD=YOUR_POSTGRES_PASSWORD -p 5432:5432 -d postgres
07818e2976f8083cf8623865f77c67f4cb5b1c36fc7d1cf517b9284fe6200793
PS C:\Users\Avadhut>
```


---

### Step 4: Create pgAdmin Container

> **Note**: pgAdmin stores server configurations and settings. Using volume mounting will preserve your server connections and preferences even if you recreate the container.

#### Option A: With Volume Mounting (Recommended)

Run the pgAdmin container with volume mounting to persist configurations:

```bash
docker run --name pgadmin --network pgnetwork -e PGADMIN_DEFAULT_EMAIL=YOUR_EMAIL@example.com -e PGADMIN_DEFAULT_PASSWORD=YOUR_PGADMIN_PASSWORD -p 5050:80 -v pgadmin-data:/var/lib/pgadmin -d dpage/pgadmin4
```

**Command Breakdown:**
- `--name pgadmin`: Names the container `pgadmin`
- `--network pgnetwork`: Connects container to the same `pgnetwork` network
- `-e PGADMIN_DEFAULT_EMAIL=YOUR_EMAIL@example.com`: Sets pgAdmin login email (replace with your email)
- `-e PGADMIN_DEFAULT_PASSWORD=YOUR_PGADMIN_PASSWORD`: Sets pgAdmin login password (replace with your secure password)
- `-p 5050:80`: Maps container port 80 to host port 5050
- `-v pgadmin-data:/var/lib/pgadmin`: **Mounts a named volume** to persist pgAdmin configurations
  - `pgadmin-data`: Name of the Docker volume (created automatically if it doesn't exist)
  - `/var/lib/pgadmin`: Path inside container where pgAdmin stores configurations
- `-d`: Runs container in detached mode (background)
- `dpage/pgadmin4`: Uses the official pgAdmin4 Docker image

#### Option B: Without Volume Mounting

If you don't need to persist pgAdmin configurations:

```bash
docker run --name pgadmin --network pgnetwork -e PGADMIN_DEFAULT_EMAIL=YOUR_EMAIL@example.com -e PGADMIN_DEFAULT_PASSWORD=YOUR_PGADMIN_PASSWORD -p 5050:80 -d dpage/pgadmin4
```

**Command Breakdown:**
- `--name pgadmin`: Names the container `pgadmin`
- `--network pgnetwork`: Connects container to the same `pgnetwork` network
- `-e PGADMIN_DEFAULT_EMAIL=YOUR_EMAIL@example.com`: Sets pgAdmin login email (replace with your email)
- `-e PGADMIN_DEFAULT_PASSWORD=YOUR_PGADMIN_PASSWORD`: Sets pgAdmin login password (replace with your secure password)
- `-p 5050:80`: Maps container port 80 to host port 5050
- `-d`: Runs container in detached mode (background)
- `dpage/pgadmin4`: Uses the official pgAdmin4 Docker image

**Expected Output:**
- If the image is not present locally, Docker will download it automatically
- You'll see a container ID (e.g., `8ecbc2f0cd58cb2a9ba5f2bf30c2e292e39729280663ebf294073f74deaef4b4`)

**Note:** The first time you run this command, Docker will download the pgAdmin image, which may take a few minutes.

My Result : 
```bash
PS C:\Users\Avadhut> docker run --name pgadmin --network pgnetwork -e PGADMIN_DEFAULT_EMAIL=YOUR_EMAIL@example.com -e PGADMIN_DEFAULT_PASSWORD=YOUR_PGADMIN_PASSWORD -p 5050:80 -d dpage/pgadmin4
8411a9e3dddfa2c99d1fa58262da7e1ec7fee97d07a36978a55f1d35479332f5
PS C:\Users\Avadhut>
```


---

### Step 5: Verify Containers are Running

Check that both containers are running:

```bash
docker ps -a
```

**Expected Output:**
```
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS                    NAMES
8ecbc2f0cd58   dpage/pgadmin4   "/entrypoint.sh"         8 minutes ago    Up 8 minutes    443/tcp, 0.0.0.0:5050->80/tcp   pgadmin
8e280b477869   postgres         "docker-entrypoint.s…"   16 minutes ago   Up 16 minutes   0.0.0.0:5432->5432/tcp          postgres-db
```

Both containers should show status as "Up" with their respective ports mapped.

My Result : 
```bash 
PS C:\Users\Avadhut> docker ps -a
CONTAINER ID   IMAGE                           COMMAND                  CREATED              STATUS                      PORTS                                         NAMES
8411a9e3dddf   dpage/pgadmin4                  "/entrypoint.sh"         About a minute ago   Up About a minute           0.0.0.0:5050->80/tcp, [::]:5050->80/tcp       pgadmin
07818e2976f8   postgres                        "docker-entrypoint.s…"   3 minutes ago        Up 3 minutes                0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp   postgres-db
```


---

### Step 6: Access pgAdmin Web Interface

1. Open your web browser
2. Navigate to: `http://localhost:5050`
3. Login with:
   - **Email**: `YOUR_EMAIL@example.com` (the email you set in Step 4)
   - **Password**: `YOUR_PGADMIN_PASSWORD` (the password you set in Step 4)

---

### Step 7: Connect pgAdmin to PostgreSQL Database

After logging into pgAdmin, follow these steps to connect to your PostgreSQL database:

1. **Right-click on "Servers"** in the left panel
2. Select **"Register" → "Server"**
3. In the **"General"** tab:
   - **Name**: Enter any name (e.g., `PostgreSQL Server` or `postgres-db`)
4. In the **"Connection"** tab:
   - **Host name/address**: `postgres-db` (container name, since they're on the same network)
   - **Port**: `5432`
   - **Maintenance database**: `postgres`
   - **Username**: `postgres`
   - **Password**: `YOUR_POSTGRES_PASSWORD` (the password you set in Step 3)
   - Check **"Save password"** if you want pgAdmin to remember it
5. Click **"Save"**

**Note:** Since both containers are on the same Docker network (`pgnetwork`), you can use the container name `postgres-db` as the hostname instead of `localhost`.

---

### Step 8: Connect to PostgreSQL via Terminal

You can connect to your PostgreSQL database directly from the terminal using the `psql` command-line tool.

#### Method 1: Direct Connection (Recommended)

Connect directly to the PostgreSQL container:

```bash
docker exec -it postgres-db psql -U postgres
```

**Command Breakdown:**
- `docker exec -it`: Execute a command in a running container interactively
- `postgres-db`: Container name
- `psql`: PostgreSQL command-line client
- `-U postgres`: Connect as user `postgres`

**Expected Output:**
```
psql (16.3 (Debian 16.3-1.pgdg120+1))
Type "help" for help.

postgres=#
```

You'll see the `postgres=#` prompt, indicating you're connected to the `postgres` database.

#### Method 2: Connect to a Specific Database

To connect directly to a specific database:

```bash
docker exec -it postgres-db psql -U postgres -d database_name
```

Replace `database_name` with the name of your database.

#### Method 3: Connect from Host Machine (if psql is installed locally)

If you have PostgreSQL client tools installed on your host machine, you can connect using:

```bash
psql -h localhost -p 5432 -U postgres -d postgres
```

When prompted, enter the password you set in Step 3 (`YOUR_POSTGRES_PASSWORD`).

**Note:** This method requires PostgreSQL client tools to be installed on your system. For Windows, you can download them from the [PostgreSQL official website](https://www.postgresql.org/download/windows/).

---

#### Useful psql Commands

Once connected to PostgreSQL, here are some useful commands:

**List all databases:**
```sql
\l
```
or
```sql
\list
```

**Connect to a different database:**
```sql
\c database_name
```
or
```sql
\connect database_name
```

**List all tables in current database:**
```sql
\dt
```

**List all tables with more details:**
```sql
\dt+
```

**Describe a table structure:**
```sql
\d table_name
```

**List all schemas:**
```sql
\dn
```

**List all users/roles:**
```sql
\du
```

**List all users/roles with more details:**
```sql
\du+
```

---

#### Querying Users in PostgreSQL

Here are several ways to check users and get detailed information:

**1. List all users (simple):**
```sql
\du
```

**2. Count total number of users:**
```sql
SELECT COUNT(*) FROM pg_user;
```

**3. List all users with detailed information:**
```sql
SELECT 
    usename AS username,
    usesysid AS user_id,
    usecreatedb AS can_create_db,
    usesuper AS is_superuser,
    userepl AS can_replicate,
    usebypassrls AS can_bypass_rls,
    valuntil AS password_expires
FROM pg_user
ORDER BY usename;
```

**4. List all roles (users and groups):**
```sql
SELECT 
    rolname AS role_name,
    rolsuper AS is_superuser,
    rolinherit AS can_inherit,
    rolcreaterole AS can_create_roles,
    rolcreatedb AS can_create_db,
    rolcanlogin AS can_login,
    rolreplication AS can_replicate,
    rolconnlimit AS connection_limit
FROM pg_roles
ORDER BY rolname;
```

**5. Count roles that can login (actual users):**
```sql
SELECT COUNT(*) 
FROM pg_roles 
WHERE rolcanlogin = true;
```

**6. Get current user information:**
```sql
SELECT current_user, session_user;
```

**7. List users with their privileges:**
```sql
SELECT 
    r.rolname AS username,
    r.rolsuper AS is_superuser,
    r.rolcreatedb AS can_create_db,
    r.rolcreaterole AS can_create_roles,
    r.rolcanlogin AS can_login
FROM pg_roles r
WHERE r.rolcanlogin = true
ORDER BY r.rolname;
```

**Example Output:**
```
 username | is_superuser | can_create_db | can_create_roles | can_login 
----------+--------------+---------------+------------------+-----------
 postgres | t            | t             | t                | t
```

**Quick Command to Count Users:**
```sql
SELECT COUNT(*) AS total_users FROM pg_user;
```

**Quick Command to List User Names Only:**
```sql
SELECT usename FROM pg_user ORDER BY usename;
```

---

**Show current database and user:**
```sql
\conninfo
```

**Show all psql commands:**
```sql
\?
```

**Show SQL help:**
```sql
\h
```

**Show help for a specific SQL command:**
```sql
\h SELECT
```

**Execute a SQL file:**
```sql
\i /path/to/file.sql
```

**Exit psql:**
```sql
\q
```
or press `Ctrl+D`

**Clear screen:**
```sql
\! clear
```
(On Windows, use `\! cls`)

---

#### Example: Creating a Database and Table via Terminal

Here's a complete example of creating a database and table using the terminal:

```bash
# 1. Connect to PostgreSQL
docker exec -it postgres-db psql -U postgres

# 2. In psql prompt, create a new database
postgres=# CREATE DATABASE mytestdb;

# 3. Connect to the new database
postgres=# \c mytestdb

# 4. Create a table
mytestdb=# CREATE TABLE users (
mytestdb(#     id SERIAL PRIMARY KEY,
mytestdb(#     name VARCHAR(100) NOT NULL,
mytestdb(#     email VARCHAR(100) UNIQUE NOT NULL,
mytestdb(#     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
mytestdb(# );

# 5. Insert some data
mytestdb=# INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com');

# 6. Query the data
mytestdb=# SELECT * FROM users;

# 7. Exit
mytestdb=# \q
```

---

## Useful Docker Commands

### View Running Containers
```bash
docker ps
```

### View All Containers (including stopped)
```bash
docker ps -a
```

### Stop a Container
```bash
docker stop postgres-db
docker stop pgadmin
```

### Start a Stopped Container
```bash
docker start postgres-db
docker start pgadmin
```

### Restart a Container
```bash
docker restart postgres-db
docker restart pgadmin
```

### View Container Logs
```bash
docker logs postgres-db
docker logs pgadmin
```

### Access PostgreSQL Command Line
```bash
docker exec -it postgres-db psql -U postgres
```

### Access Container Shell
```bash
docker exec -it postgres-db bash
docker exec -it pgadmin bash
```

### Remove Containers

**⚠️ Important:** 
- **Without volumes**: Removing containers will **permanently delete all data**
- **With volumes**: Data will persist in volumes even after removing containers

**Remove containers (data in volumes will persist):**
```bash
docker stop postgres-db pgadmin
docker rm postgres-db pgadmin
```

**Remove containers AND volumes (⚠️ This will permanently delete all data):**
```bash
docker stop postgres-db pgadmin
docker rm postgres-db pgadmin
docker volume rm postgres-data pgadmin-data
```

### Remove Network
```bash
docker network rm pgnetwork
```

### Managing Docker Volumes (Data Persistence)

If you used volume mounting, here are commands to manage your volumes:

**List all volumes:**
```bash
docker volume ls
```

**Inspect a specific volume (see where data is stored):**
```bash
docker volume inspect postgres-data
docker volume inspect pgadmin-data
```

**View volume details (size, mount point, etc.):**
```bash
docker volume inspect postgres-data
```

**Remove a volume (⚠️ This will delete all data in the volume):**
```bash
# First, stop and remove the container
docker stop postgres-db
docker rm postgres-db

# Then remove the volume
docker volume rm postgres-data
```

**Remove all unused volumes:**
```bash
docker volume prune
```

**Backup a volume:**
```bash
# Create a backup of postgres-data volume
docker run --rm -v postgres-data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-backup.tar.gz -C /data .
```

**Restore a volume from backup:**
```bash
# Restore postgres-data volume from backup
docker run --rm -v postgres-data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/postgres-backup.tar.gz"
```

**Note for Windows users:** Replace `$(pwd)` with `%cd%` in PowerShell or use the full path:
```powershell
# PowerShell example
docker run --rm -v postgres-data:/data -v ${PWD}:/backup alpine tar czf /backup/postgres-backup.tar.gz -C /data .
```

**Check volume disk usage:**
```bash
docker system df -v
```

---

## Understanding Data Persistence

### What Happens With Volume Mounting?

✅ **With volumes (`-v postgres-data:/var/lib/postgresql/data`):**
- Data is stored in a Docker volume on your host machine
- Data persists even if you:
  - Stop the container
  - Remove the container
  - Restart Docker
  - Update the container
- You can backup, restore, and migrate your data easily
- **Recommended for production and important data**

❌ **Without volumes:**
- Data is stored only inside the container
- Data is **permanently lost** if you:
  - Remove the container (`docker rm`)
  - Remove the container with `-v` flag
  - Recreate the container
- **Only suitable for temporary/testing environments**

### Where is Volume Data Stored?

On **Windows with Docker Desktop**, volumes are typically stored in:
```
\\wsl$\docker-desktop-data\data\docker\volumes\
```

You can find the exact location using:
```bash
docker volume inspect postgres-data
```

Look for the `Mountpoint` field in the output.

---

## Migrating Existing Containers to Use Volumes

If you've already created containers **without volume mounting** and want to add data persistence, follow these steps:

### Option A: If You Have Important Data (Backup First)

**Step 1: Backup your existing PostgreSQL data**

```bash
# Create a backup directory
mkdir postgres-backup

# Export all databases to SQL dump
docker exec postgres-db pg_dumpall -U postgres > postgres-backup/full-backup.sql
```

Or backup a specific database:
```bash
docker exec postgres-db pg_dump -U postgres -d your_database_name > postgres-backup/your_database_name.sql
```

**Step 2: Stop and remove existing containers**

```bash
docker stop postgres-db pgadmin
docker rm postgres-db pgadmin
```

**Step 3: Recreate containers with volume mounting**

```bash
# Recreate PostgreSQL with volume
docker run --name postgres-db --network pgnetwork -e POSTGRES_PASSWORD=YOUR_POSTGRES_PASSWORD -p 5432:5432 -v postgres-data:/var/lib/postgresql/data -d postgres

# Recreate pgAdmin with volume
docker run --name pgadmin --network pgnetwork -e PGADMIN_DEFAULT_EMAIL=YOUR_EMAIL@example.com -e PGADMIN_DEFAULT_PASSWORD=YOUR_PGADMIN_PASSWORD -p 5050:80 -v pgadmin-data:/var/lib/pgadmin -d dpage/pgadmin4
```

**Step 4: Restore your data**

```bash
# Wait a few seconds for PostgreSQL to start
sleep 5

# Restore the backup
docker exec -i postgres-db psql -U postgres < postgres-backup/full-backup.sql
```

Or restore a specific database:
```bash
# First create the database
docker exec -it postgres-db psql -U postgres -c "CREATE DATABASE your_database_name;"

# Then restore
docker exec -i postgres-db psql -U postgres -d your_database_name < postgres-backup/your_database_name.sql
```

### Option B: If You Don't Have Important Data (Fresh Start)

**Step 1: Stop and remove existing containers**

```bash
docker stop postgres-db pgadmin
docker rm postgres-db pgadmin
```

**Step 2: Recreate containers with volume mounting**

```bash
# Recreate PostgreSQL with volume
docker run --name postgres-db --network pgnetwork -e POSTGRES_PASSWORD=YOUR_POSTGRES_PASSWORD -p 5432:5432 -v postgres-data:/var/lib/postgresql/data -d postgres

# Recreate pgAdmin with volume
docker run --name pgadmin --network pgnetwork -e PGADMIN_DEFAULT_EMAIL=YOUR_EMAIL@example.com -e PGADMIN_DEFAULT_PASSWORD=YOUR_PGADMIN_PASSWORD -p 5050:80 -v pgadmin-data:/var/lib/pgadmin -d dpage/pgadmin4
```

My Result :
```bash
PS C:\Users\Avadhut> docker run --name postgres-db --network pgnetwork -e POSTGRES_PASSWORD=jUst8e9ICE -p 5432:5432 -v postgres-data:/var/lib/postgresql/data -d postgres
ae6908e4bd6f175d971c16d7d385d41b317c0c896730ffd0fbe175f99180e3db
PS C:\Users\Avadhut> docker run --name pgadmin --network pgnetwork -e PGADMIN_DEFAULT_EMAIL=avadhutproject123@gmail.com -e PGADMIN_DEFAULT_PASSWORD=Omsairam12@# -p 5050:80 -v pgadmin-data:/var/lib/pgadmin -d dpage/pgadmin4
b8f39c6ee2931c5cca6e7bd5d322b031733fbc2252d07306c85e4312ca4ee110
PS C:\Users\Avadhut>
```

**Step 3: Verify containers are running**

```bash
docker ps -a
```

Both containers should show status as "Up".

### Quick Migration Script (PowerShell)

For Windows PowerShell, you can use this script to migrate:

```powershell
# Stop containers
docker stop postgres-db pgadmin

# Backup PostgreSQL data (if needed)
docker exec postgres-db pg_dumpall -U postgres > postgres-backup.sql

# Remove old containers
docker rm postgres-db pgadmin

# Recreate with volumes
docker run --name postgres-db --network pgnetwork -e POSTGRES_PASSWORD=YOUR_POSTGRES_PASSWORD -p 5432:5432 -v postgres-data:/var/lib/postgresql/data -d postgres

docker run --name pgadmin --network pgnetwork -e PGADMIN_DEFAULT_EMAIL=YOUR_EMAIL@example.com -e PGADMIN_DEFAULT_PASSWORD=YOUR_PGADMIN_PASSWORD -p 5050:80 -v pgadmin-data:/var/lib/pgadmin -d dpage/pgadmin4

# Wait for PostgreSQL to start
Start-Sleep -Seconds 5

# Restore backup (if you created one)
Get-Content postgres-backup.sql | docker exec -i postgres-db psql -U postgres
```

### Verify Volume Mounting

After recreating containers, verify volumes are created:

```bash
# List all volumes
docker volume ls

# You should see:
# postgres-data
# pgadmin-data

# Inspect volumes to see where data is stored
docker volume inspect postgres-data
docker volume inspect pgadmin-data
```

### Important Notes

- **After migration**: Your data will now persist in Docker volumes
- **pgAdmin**: You'll need to reconnect to your PostgreSQL server in pgAdmin (server connections are not preserved)
- **Network**: If you already have the `pgnetwork` network, you don't need to recreate it
- **Ports**: Make sure ports 5432 and 5050 are not in use by other containers

---

## Troubleshooting

### Containers Not Starting

If containers fail to start:
1. Check Docker Desktop is running
2. Check if ports 5432 or 5050 are already in use:
   ```bash
   netstat -ano | findstr :5432
   netstat -ano | findstr :5050
   ```
3. View container logs for errors:
   ```bash
   docker logs postgres-db
   docker logs pgadmin
   ```

### Cannot Connect to PostgreSQL from pgAdmin

1. Verify both containers are on the same network:
   ```bash
   docker network inspect pgnetwork
   ```
2. Ensure you're using the container name `postgres-db` as the hostname (not `localhost`)
3. Verify PostgreSQL is running:
   ```bash
   docker exec -it postgres-db psql -U postgres -c "SELECT version();"
   ```

### Forgot Password or Need to Change Password

Access PostgreSQL and change the password:
```bash
docker exec -it postgres-db psql -U postgres
```

Then in the PostgreSQL prompt:
```sql
ALTER USER postgres WITH PASSWORD 'YOUR_NEW_PASSWORD';
\q
```

---

## Summary

After completing these steps, you should have:
- ✅ PostgreSQL database running on port `5432`
- ✅ pgAdmin web interface accessible at `http://localhost:5050`
- ✅ Both containers connected via Docker network `pgnetwork`
- ✅ Ability to manage PostgreSQL databases through pgAdmin

---

## Next Steps

- Create databases and tables through pgAdmin
- Connect your Node.js application to PostgreSQL
- Set up database backups
- Configure additional PostgreSQL settings if needed

---

**Last Updated**: Based on setup process from previous configuration


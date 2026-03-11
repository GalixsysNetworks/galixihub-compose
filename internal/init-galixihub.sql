-- Create databases
CREATE DATABASE IF NOT EXISTS licdb;
CREATE DATABASE IF NOT EXISTS networkdb;
CREATE DATABASE IF NOT EXISTS membersdb;
CREATE DATABASE IF NOT EXISTS worldsdb;

-- Create user for any host
CREATE USER IF NOT EXISTS 'galixidb'@'%' IDENTIFIED BY 'galixidb';

-- Create user for localhost (unix socket)
CREATE USER IF NOT EXISTS 'galixidb'@'localhost' IDENTIFIED BY 'galixidb';

-- Grant privileges for all databases used by Galixihub
GRANT ALL PRIVILEGES ON licdb.* TO 'galixidb'@'%';
GRANT ALL PRIVILEGES ON licdb.* TO 'galixidb'@'localhost';

GRANT ALL PRIVILEGES ON networkdb.* TO 'galixidb'@'%';
GRANT ALL PRIVILEGES ON networkdb.* TO 'galixidb'@'localhost';

GRANT ALL PRIVILEGES ON membersdb.* TO 'galixidb'@'%';
GRANT ALL PRIVILEGES ON membersdb.* TO 'galixidb'@'localhost';

GRANT ALL PRIVILEGES ON worldsdb.* TO 'galixidb'@'%';
GRANT ALL PRIVILEGES ON worldsdb.* TO 'galixidb'@'localhost';

FLUSH PRIVILEGES;



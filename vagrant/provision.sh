#!/bin/bash -e
set -a
LOG=/vagrant/tmp/log/boot.log
set +a

PGVERSION=${PGVERSION:-13}
PGDATABASE=${PGDATABASE:-dvdrental}
PGPORT=${PGPORT:-5432}
PGCLUSTER=${PGCLUSTER:-main}
PGUSER=${PGUSER:-dbadmin}
PGPASSWORD=${PGPASSWORD:-devved}

mkdir -p /vagrant/tmp/log

# Hosts files
HOSTS=/etc/hosts

export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_on_timestamp

echo "install postgresql..."
PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
if [ ! -f "$PG_REPO_APT_SOURCE" ]; then
	echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >"$PG_REPO_APT_SOURCE"
	wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
fi

apt-get update

sudo apt-get install -y "python3-pip postgresql-server-dev-$PGVERSION" "postgresql-contrib-$PGVERSION"

echo "configure postgresql..."

PG_CONF="/etc/postgresql/$PGVERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PGVERSION/main/pg_hba.conf"

cat <<EOF | su - postgres -c psql
CREATE ROLE $PGUSER WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION PASSWORD '$PGPASSWORD';
EOF

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

if [ ! -z "$PGPORT" ]; then
	sed -i "/port = /c\port = $PGPORT" "$PG_CONF"
fi

echo "host    all             all             all                     md5" >>"$PG_HBA"

echo "Create test database..."
cat <<EOF | su - postgres -c psql
-- Delete db first
DROP DATABASE IF EXISTS $PGDATABASE;
-- Create the database:
CREATE DATABASE $PGDATABASE WITH OWNER $PGUSER;
-- auto explain for analyse all queries and inside functions
LOAD 'auto_explain';
SET auto_explain.log_min_duration = 0;
SET auto_explain.log_analyze = true;
EOF

systemctl restart postgresql@$PGVERSION-$PGCLUSTER

echo "Load sample db..."

su - postgres -c "psql -d $PGDATABASE -f /home/vagrant/pgfilter/vagrant/backup/dvdrental.dump >/home/vagrant/pgfilter/vagrant/log/sampledb.log 2>/home/vagrant/pgfilter/vagrant/log/sampledb.err"

# Tag the provision time:
date >"$PROVISIONED_ON"

echo "Successfully created postgres dev virtual machine with Postgres"

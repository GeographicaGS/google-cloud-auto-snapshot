
# Automatic Snapshots for Google Compute Engine

This is a Docker / Kubernetes ready bash script to to automatically snapshot Google Compute Engine disks in a Google cloud project.


## To consider in advance

Google snapshots are incremental, and don't need to be deleted. If you delete an earlier snapshot the block are automatically migrated to the later snapshot. So deleting snapshots does not save space, but for convenience, rather than an infinitely long list, it is useful to purge earlier snapshots assuming that you would never need granularity. This script will default to 60 days. You can change this behavior with the environment variable `DAYS_RETENTION`.

**For a more detailed description of what the commands do please visit [http://badlywired.com/google-compute-engine-snapshot-automation/](http://badlywired.com/2016/12/google-compute-engine-snapshot-automation/)**

Much of the inspiration for this script came from http://stackoverflow.com/questions/27418427/how-to-create-and-rotate-automatic-snapshot
and much of the installation instructions from here https://github.com/jacksegal/google-compute-snapshot


## How it works
google-cloud-auto-snapshot.sh will:

- Determine all Compute Engine Disks in the current project that do not have label 'backup=no'. This filter can be supplemented or edited with the environment variable `DISK_FILTER`.
- Take a snapshot of selected Disks and prefix their backups with `autogcs-{DISK_NAME-YYYY-MM-DD-sssssssss}`.
- Delete all associated snapshots taken by the script that are older than 60 days. This can be edited with the environment variable  `DAYS_RETENTION`.

## Permissions required
You must create a function (in section IAM & administration) with the next permissions:
- compute.disks.list
- compute.snapshots.list
- compute.disks.createSnapshot
- compute.snapshots.create
- compute.snapshots.delete
- compute.snapshots.get

## Using with Docker
Documentation in progress.

## Using with Kubernetes
Documentation in progress.

## Using locally

### Prerequisites

* the gcloud SDK must be install which includes the gcloud cli [https://cloud.google.com/sdk/downloads](https://cloud.google.com/sdk/downloads)
* the gcloud project must be set to the project that owns the disks

### Installation

Install the script (the script doesn't even have to run on Google Compute Engine instance, any linux machine will work).

**Install Script**: Download the latest version of the snapshot script and make it executable, e.g.
```
sudo mkdir -p /opt/google-cloud-auto-snapshot
sudo wget -P /opt/google-cloud-auto-snapshot/ https://raw.githubusercontent.com/GeographicaGS/google-cloud-auto-snapshot/master/google-cloud-auto-snapshot.sh
```


**Setup CRON**: You should then setup a cron job (`crontab -e`) in order to schedule a snapshot as often as you like, e.g. for daily cron:
```
0 5 * * * root /opt/google-cloud-auto-snapshot/google-cloud-auto-snapshot.sh >> /var/log/cron/snapshot.log 2>&1
```

**Manage CRON Output**: Ideally you should then create a directory for all cron outputs and add it to logrotate:

- Create new directory:
```
sudo mkdir /var/log/cron
```
- Create empty file for snapshot log:
```
sudo touch /var/log/cron/snapshot.log
```
- Change permissions on file:
```
sudo chgrp adm /var/log/cron/snapshot.log
sudo chmod 664 /var/log/cron/snapshot.log
```
- Create new entry in logrotate so cron files don't get too big :
```
sudo nano /etc/logrotate.d/cron
```
- Add the following text to the above file:
```
/var/log/cron/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 664 root adm
    sharedscripts
}
```

**To manually test the script:**
```
/opt/google-cloud-auto-snapshot/google-cloud-auto-snapshot.sh
```

## Limitations, possible future enhancements
* Prometheus integration.
* Gcloud configuration by environment variables.
* Only works for default project for the gcloud environment ( see  gcloud info )
* Only manages snapshots created by the script ( prefixed `autogcs-` )

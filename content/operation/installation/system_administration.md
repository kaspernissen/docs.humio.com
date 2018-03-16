---
title: "System administration"
---


## Root Users

See [Root User setup](/installation/authentication.md#root-user).

## Setting retention

You can make Humio delete the data after a while to keep your disks from overflowing.
This is in the web interface. Retention can be set for both size (compressed and uncompresssed) and age of data.

Retention deletes events in large chunks ("segments"), not deleting individual events.

The three types of retention are independent - data gets deleted when any one of them marks if for deleting.

### By compressed size

The "compressed" setting is designed allow the administrator to prevent the file system from overflowing.
Configure the "compressed" settings for each dataspace so that the sum of all compressed sizes is less than the space available on the disk.

The compressed size calculation deletes data based on the amount of disk space consumed taking replicas into account
until the amount on disk is below the setting. Replicas are handled by counting copies in excess of the segment-replication settings as "extra".

An example: In a cluster of 3 humio-instances, a segment-replication of 5, and a CompressedSize of 50 GB,
the total disk usage on those three machines for this dataspace would be 150 GB. This lets the users see 50 GB of compressed data.

If the segment replication setting is then changed to 2, the allowed disk usage drops to 100 GB in total on the three machines.
The retentionjob will then delete the oldest segments, leaving approximately 33 GB of searchable data at first.
When more data flows in through ingest, the user will get back to having 50 GB of searchable compressed data in the 100 GB on disk.

### By uncompressed size
The "uncompressed" setting is designed to delete data based on a promise to keep at least this much of the "input".
Original size is measured as the size stored before compression and is thus the size of the internal format,
not the data that was ingested. It also includes the size of any additional fields sent along with the raw events.

The uncompressed size retention triggers a delete when it is able to retain at least the amount specified as uncompressed limit.
Uncompressed retention does not consider multiple replicas as more than on copy, as it is based on the amount of data that the users see.

### By time

Data gets delete when the latest event in the chunk is older than the configured retention.
In order to make sure that a user cannot see events older than a certain limit, Humio also retricts the time interval allowed when searching to
the interval allowed by this reention setting.

## Backing up Humio data

You can back up your Humio installation by adding a special mounted directory when you run the Docker container. Humio writes its backup files to this directory.

Currently, this is the only backup strategy. However, Humio is designed to support other strategies, like backup to AmazonS3.

#### Steps

1. Create an empty directory on the host machine to store data for Humio:
        
        mkdir /humio-backups-on-host

    !!! tip
        We recommend creating the backup directory on a different disk from the main Humio data directory.

2. Edit the Humio configuration file to set the backup parameters. Add the following lines:

        BACKUP_NAME=humio-backup
        BACKUP_KEY=mysecretkey-myhost-+R+q(AB9QG86xZMCKGyj

    !!! note
        Humio encrypts all backups with a secret key. This means that you can safely store backups on an unencrypted disk, or send them over the Internet.

        Keep the secret key safe, and store it in another place. You cannot recover it if you lose access to it.

3. Run Humio using the Docker run command. Add the following argument to the command. It maps the backups directory on the host (here, `/humio-backups-on-host`) to the `/backup` directory in the container:

        -v /humio-backups-on-host:/backup

    Humio will start backing up data to the specified directory.


## Upgrading

To upgrade Humio, pull the latest version of the Docker container and run it using the same Docker arguments, especially the same data directories.

!!! note
    All Humio images are tagged with a version. You should specify the version of the image when you run it. In the example below latest is used.

```
docker stop humio | true
docker rm humio | true
docker pull humio/humio:latest
docker run -v $HOST_DATA_DIR:/data --net=host --detach --restart=always --name=humio --env-file=$PATH_TO_CONFIG_FILE humio/humio
```

# Minecraft Server Manager

A single init script which makes running multiple Minecraft/Bukkit servers easier for us admins.

## Installation

Supported: current Debian/Ubuntu, Fedora/RHEL (Rocky, AlmaLinux, ...) and Arch Linux, all with systemd.
The old git.io one-liners point to the unmaintained upstream and no longer work.

Copy this repository to the server (or clone it there) and run, as root or with sudo:

    ./installers/install.sh

This installs the dependencies (screen, jq, rsync, zip, wget, cron and the newest available OpenJDK of 25/21/17),
creates the `minecraft` user, installs `/usr/local/bin/msm` (with `/etc/init.d/msm` as a symlink),
the cron jobs and the systemd unit `msm.service`. An existing `/etc/msm.conf` is kept.

Optional environment variables: `MSM_UPDATE_URL` (raw URL of your hosted copy; enables `msm update`, empty = disabled),
`MSM_DIR`, `MSM_USER`, `MSM_JAVA_VERSIONS` (e.g. `"21 17"`), `MSM_NONINTERACTIVE=1`.

Or [suggest a new platform][issues].

## Getting Started

* [Install][install] MSM on your box.
* [Visit the docs][docs] for help with getting started.
* Fork and contribute your own modifications.
* Not a coder? [Post an issue][issues] with your idea for MSM instead.
* Read the [changelog][changelog] to get a picture of how MSM has evolved over time.

MSM is released under the GPLv3 licence, which is included in the repository [here][licence]. I'm open to suggestions where licencing is concerned.

## Features

As well as starting, stopping and restarting MSM has the following features:

* One script handles multiple servers, run two or more servers on one machine.
* Can create and start new servers with a single command, downloads the jars for you.
* Periodically makes [WorldEdit snapshot][we-snapshot] compatible backups of your worlds.
* Backup the entire server directory for complete protection.
* Load world's into RAM for faster access (reduces lag).
* Easily configurable global defaults, with per server overrides if needed.
* Apply server commands to one, multiple, or all servers in one go (useful for whitelisting a player on all servers.)
* Tab completion for all commands, makes everything faster and getting started a breeze.
* Keep server logs organsied by periodically "rolling" them.
* Organises jar files into groups (such as minecraft and craftbukkit) and links each server to a single jar. Includes automated download of new versions.
* Plethora of in-game commands (whitelist, blacklist, operator, gamemode, kick, say, time, toggledownfall, save)
* Send commands straight to the server via the command line.

## Support

1. If you find a problem with MSM and you think the problem is one that requires changing code [submit an issue][issues] via GitHub.

## Upcoming features

* **QuickBackup:** If you store your backups non-locally (maybe on a NAS), QuickBackup optionally creates a backup locally for speed, and then moves it after your players are building again! My initial testing shows a 54 second network backup confaltes to 23 seconds of in-game time.
* **Restore:** Roll-back to an old world or whole server backup automatically.


## Versioning

MSM uses semantic version numbers to better describe what code one might have installed, and indicate backwards incompatible changes.

Releases will be numbered in the following format:

`<major>.<minor>.<patch>`

And constructed with the following guidelines:

* Breaking backward compatibility bumps the major (and resets the minor and patch)
* New additions without breaking backward compatibility bumps the minor (and resets the patch)
* Bug fixes and misc changes bumps the patch

For more information on SemVer, visit http://semver.org/.


## Acknowledgements

This code grew out of an old version of [Ahtenus' Minecraft Init Script][ahtenus-minecraft-init].

[we-snapshot]: http://wiki.sk89q.com/wiki/WorldEdit/Snapshots
[ahtenus-minecraft-init]: https://github.com/Ahtenus/minecraft-init
[docs]: http://msmhq.com/docs/
[install]: http://msmhq.com/docs/installation.html
[changelog]: https://github.com/msmhq/msm/blob/master/CHANGELOG.markdown
[licence]: https://github.com/msmhq/msm/blob/master/LICENSE.markdown
[issues]: https://github.com/msmhq/msm/issues

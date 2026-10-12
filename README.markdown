# Minecraft Server Manager

🇩🇪 Deutsch | 🇬🇧 [English version below](#minecraft-server-manager-1)

Ein einzelnes Init-Skript, das den Betrieb mehrerer Minecraft-/Bukkit-Server für uns Admins einfacher macht.

## Installation

Unterstützt werden aktuelle Versionen von Debian/Ubuntu, Fedora/RHEL (Rocky, AlmaLinux, ...) und Arch Linux, jeweils mit systemd.
Die alten git.io-Einzeiler verweisen auf das nicht mehr gepflegte Upstream-Projekt und funktionieren nicht mehr.

Dieses Repository auf den Server kopieren (oder dort klonen) und als root oder mit sudo ausführen:

    ./installers/install.sh

Der Installer richtet die Abhängigkeiten ein (screen, jq, rsync, zip, wget, cron und das neueste verfügbare OpenJDK aus 25/21/17),
legt den Benutzer `minecraft` an und installiert `/usr/local/bin/msm` (mit `/etc/init.d/msm` als Symlink),
die Cron-Jobs und die systemd-Unit `msm.service`. Eine vorhandene `/etc/msm.conf` bleibt unverändert.

Direkt vom Fork installieren, ohne Kopieren:

    export MSM_UPDATE_URL=https://raw.githubusercontent.com/jackmcnill/msm/master
    bash <(curl -fsSL $MSM_UPDATE_URL/installers/install.sh)

Optionale Umgebungsvariablen: `MSM_UPDATE_URL` (Raw-URL der eigenen gehosteten Kopie; aktiviert `msm update`, leer = deaktiviert),
`MSM_DIR`, `MSM_USER`, `MSM_JAVA_VERSIONS` (z. B. `"21 17"`), `MSM_NONINTERACTIVE=1`.

Oder [schlage eine neue Plattform vor][issues].

## Erste Schritte

* Siehe oben, um MSM auf dem eigenen Server zu installieren.
* In der [Dokumentation][docs] gibt es Hilfe für den Einstieg.
* Fork das Projekt und steuere eigene Änderungen bei.
* Kein Programmierer? [Eröffne ein Issue][issues] mit deiner Idee für MSM.
* Im [Changelog][changelog] steht, wie sich MSM über die Zeit entwickelt hat.

MSM steht unter der GPLv3-Lizenz, die dem Repository [beiliegt][licence]. Bei Lizenzfragen bin ich für Vorschläge offen.

## Funktionen

Neben Starten, Stoppen und Neustarten kann MSM Folgendes:

* Ein Skript verwaltet mehrere Server; zwei oder mehr Server laufen auf einer Maschine.
* Neue Server lassen sich mit einem einzigen Befehl anlegen und starten, die Jars werden automatisch heruntergeladen.
* Erstellt regelmäßig Backups deiner Welten, die mit [WorldEdit-Snapshots][we-snapshot] kompatibel sind.
* Sichert das gesamte Serververzeichnis für vollständigen Schutz.
* Lädt Welten zur schnelleren Verarbeitung in den RAM (weniger Lag).
* Leicht konfigurierbare globale Standardwerte, bei Bedarf mit Überschreibungen pro Server.
* Serverbefehle auf einen, mehrere oder alle Server gleichzeitig anwenden (praktisch, um einen Spieler auf allen Servern auf die Whitelist zu setzen).
* Tab-Vervollständigung für alle Befehle; das macht alles schneller und den Einstieg leicht.
* Hält die Server-Logs durch regelmäßiges „Rollen“ übersichtlich.
* Ordnet Jar-Dateien in Gruppen (z. B. minecraft und craftbukkit) und verknüpft jeden Server mit genau einem Jar. Neue Versionen werden automatisch heruntergeladen.
* Viele Ingame-Befehle (whitelist, blacklist, operator, gamemode, kick, say, time, toggledownfall, save).
* Befehle direkt von der Kommandozeile an den Server senden.

## Support

1. Wenn du ein Problem mit MSM findest, das eine Codeänderung erfordert, [eröffne ein Issue][issues] auf GitHub.

## Geplante Funktionen

* **QuickBackup:** Wenn die Backups nicht lokal liegen (z. B. auf einem NAS), erstellt QuickBackup optional zuerst ein lokales Backup für mehr Geschwindigkeit und verschiebt es, sobald die Spieler wieder bauen. Erste Tests zeigen: Ein Netzwerk-Backup von 54 Sekunden schrumpft auf 23 Sekunden Ingame-Zeit.
* **Restore:** Automatisches Zurückspielen einer alten Welt oder eines kompletten Server-Backups.

## Versionierung

MSM verwendet semantische Versionsnummern, damit klar ist, welcher Code installiert ist und wann Änderungen nicht abwärtskompatibel sind.

Releases werden im folgenden Format nummeriert:

`<major>.<minor>.<patch>`

Und nach diesen Regeln vergeben:

* Bricht eine Änderung die Abwärtskompatibilität, steigt die Major-Nummer (Minor und Patch beginnen wieder bei 0).
* Neue Funktionen ohne Bruch der Abwärtskompatibilität erhöhen die Minor-Nummer (Patch beginnt wieder bei 0).
* Fehlerbehebungen und sonstige Änderungen erhöhen die Patch-Nummer.

Mehr zu SemVer steht auf http://semver.org/.

## Danksagung

Dieser Code ist aus einer alten Version von [Ahtenus' Minecraft Init Script][ahtenus-minecraft-init] hervorgegangen.

---

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

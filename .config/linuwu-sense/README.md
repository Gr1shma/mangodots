# linuwu-sense (runit state persistence)

Saves/restores Acer PredatorSense (`linuwu_sense` kernel module) settings
across reboots on Void Linux, since the module itself has no persistence
and the upstream project only ships a systemd unit.

## What it does

- **`bin/restore-sense`** — run at boot. Waits for `linuwu_sense` to load,
  then restores last-saved keyboard color/profile/fan settings from
  `/var/lib/linuwu-sense/state`. If no saved state exists, falls back to:
  - Keyboard: all zones white, brightness 0
  - Thermal profile: `balanced-performance` on AC, `quiet` on battery
- **`bin/save-sense`** — snapshots current sysfs values to
  `/var/lib/linuwu-sense/state`. Runs automatically on clean shutdown via
  the runit shutdown hook. Can also be run manually any time after
  tweaking settings, to make the new state the new default.
- **`sv/linuwu-sense-restore/run`** — runit service that calls
  `restore-sense` once at boot.
- **`shutdown.d/save-sense.sh`** — runit shutdown hook that calls
  `save-sense` on clean reboot/poweroff.

## Requirements

- `linuwu_sense` kernel module already built and installed
  (see the Makefile in the Linuwu-Sense repo / void port).
- Predator/Nitro laptop with `predator_sense` sysfs interface
  (tested on PHN16-71).

## Install

```sh
cd linuwu-sense
sudo ./install.sh
```

Re-running `install.sh` after editing files here is safe — it overwrites
the installed copies and re-creates the symlink.

## Manual use

```sh
sudo restore-sense   # re-apply saved/default state right now
sudo save-sense       # snapshot current state right now
sv status linuwu-sense-restore
```

## Caveat

`save-sense` only runs on a *clean* shutdown/reboot. A hard power-off
(dead battery, force shutoff) skips it, so the saved state is only as
fresh as your last clean shutdown.

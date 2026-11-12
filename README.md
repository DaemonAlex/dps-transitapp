# dps-transitapp

An lb-phone custom app that shows live train arrivals for every station, nearest station first.

## What it is for

A player on a platform cannot tell when the next train comes, or whether one comes at all. This app answers that on the phone: which train is next at each station, how far away it is, and how long until it arrives.

## Features

- One card per station, sorted by distance from the player (shown as `m` or `km`).
- Each card shows only the next service: its name, a status and an ETA.
- Station tag: `REGIONAL` (track 0) or `LIGHT RAIL` (any other track).
- Service names with their own icon: Metro, Axsellya Express, Brown Streak, Freight. Other names get the Freight icon. The server names `Light Rail` and `Regional Train` are shown as Metro and Axsellya Express.
- Status text:
  - `boarding` and `delayed` are shown as sent by the train resource.
  - A running train shows `next stop`, `1 stop away` or `N stops away`.
  - Anything else shows the raw status, or `en route` if none is sent.
- ETA shows `Due` under 45 seconds, otherwise minutes. A missing ETA shows `--`.
- A station with no arrivals shows `No service`.
- The board refreshes every 5 seconds while the app is open.
- The resource does no scheduling. It only displays what the train resource returns.

## On its own, and with other scripts

**On its own.** This script does nothing alone. It is a screen for two other resources: the phone and the train system. With `lb-phone` but no `dps-trains`, the app still installs and every station reads `No service`.

**With a paid phone (lb-phone).** The app shows on the phone home screen as Transit. The script uses one lb-phone export, `AddCustomApp`, and nothing else from the phone. It registers again when lb-phone restarts. A phone update does not break it unless that export changes.

**With dps-trains.** The board is live. Every 5 seconds the app reads the `getArrivalBoard` export from dps-trains and shows the result. It only reads. It cannot change a train, so a fault here cannot stop the railway.

**With dps-trains-stock, dps-traintools and dps-traintracks.** No direct link. dps-trains-stock is the trains, dps-traintracks is extra track, dps-trains runs them, and dps-traintools lets the player board the train the app told them about.

## Prerequisites

- `lb-phone`, with the custom app export `AddCustomApp`.
- `ox_lib` (server callback, loaded through `@ox_lib/init.lua`).
- A train resource named `dps-trains` that exports `getArrivalBoard()`.

`getArrivalBoard()` must return a list of stations. The app reads these fields:

| Field | Use |
|---|---|
| `station` | Station name |
| `track` | `0` = REGIONAL tag, otherwise LIGHT RAIL |
| `coords` | `x` and `y`, used for the distance and sorting |
| `arrivals` | List of arrivals. Only the first is shown |

Each arrival uses `train`, `color`, `status`, `stopsAway` and `eta` (seconds).

## Installation

1. Put the folder in your resources directory. Keep the folder name `dps-transitapp`.
2. In `server.cfg`, ensure it after `lb-phone` and after `dps-trains`:
   ```
   ensure lb-phone
   ensure dps-trains
   ensure dps-transitapp
   ```
3. Restart the server. No other setup is needed.

The app registers itself. `client.lua` waits for `lb-phone` to start, then calls `AddCustomApp` with identifier `dps_transit`, name `Transit`, `defaultApp = true`. It registers again if `lb-phone` restarts, so the icon returns.

The resource name must stay `dps-transitapp`. The UI runs inside lb-phone's frame and fetches `https://dps-transitapp/getBoard` by a fixed name in `ui/index.html`. `GetParentResourceName()` would return `lb-phone` there. If you rename the folder, change that URL too.

`dps-trains` is deliberately not in `dependencies` (only `lb-phone` is). FiveM stops dependents when a dependency restarts, which would remove the app from the phone. The call to `getArrivalBoard` is wrapped in `pcall`, so the app stays installed if `dps-trains` is stopped.

## Configuration

There are no config files or options. Fixed values in the code:

| Value | Default | File | Meaning |
|---|---|---|---|
| App identifier | `dps_transit` | `client.lua` | lb-phone app id |
| App name | `Transit` | `client.lua` | Name on the phone |
| `defaultApp` | `true` | `client.lua` | Installed by default |
| `size` | `512` | `client.lua` | App size reported to lb-phone |
| Icon | twemoji train image URL | `client.lua` | App icon |
| Initial register delay | 2 s after `lb-phone` is started | `client.lua` | Wait before first registration |
| Re-register delay | 5 s after `lb-phone` restarts | `client.lua` | Wait before registering again |
| Refresh interval | 5000 ms | `ui/index.html` | Board poll rate |
| `Due` threshold | 45 s | `ui/index.html` | ETA shown as `Due` below this |

To change any of these, edit the file listed.

## Troubleshooting

- **The app is not on the phone.** Check that `lb-phone` is started and this resource is ensured after it. If registration fails, the client console prints `[dps-transitapp] AddCustomApp failed: ...`.
- **The icon is missing after restarting lb-phone.** The app registers again 5 seconds after `lb-phone` restarts. Wait for that.
- **The board is empty or never updates.** Check that the folder is named `dps-transitapp`. A different name sends the UI request to the wrong resource, and the failure is silent.
- **Every station says `No service`, or the list is empty.** `dps-trains` is stopped, missing, or has no `getArrivalBoard` export. The call fails quietly and returns an empty board.
- **A station has no distance.** Its `coords` are missing or not numbers. The distance is left blank and the station sorts first.
- **A dependency change is ignored after a restart.** The server caches the parsed manifest. Run `refresh` before restarting the resource.
- **An image shows as broken.** Images in the UI must be inlined (data URI). Relative paths resolve against lb-phone and fail.

## Recent changes

- **12 November 2026.** README: what it is for, how it works alone and with paid scripts, other DPS scripts.
- **25 October 2026.** Repo brought up to what runs on the live server.
- **11 October 2026.** The header shows the DelPerroSands logo only. The LS Transit logo is removed.
- **10 October 2026.** Cream backing behind the logo. The house logo replaces the "DPS" text in the footer.
- **4 October 2026.** Light Rail shows as Metro and Regional Train as Axsellya Express. Stations on track 0 get the `REGIONAL` tag.

## Author

Made by [DaemonAlex](https://github.com/DaemonAlex) for DelPerroSands.

## Other DPS scripts

All of these are made for DelPerroSands and run together on one Qbox server. Each one works on
its own. The ones marked "pairs with" do more when both are running.

| Script | What it does |
|---|---|
| [dps-inventory](https://github.com/DaemonAlex/dps-inventory) | The inventory: ox_inventory with equipment slots, backpacks, armour plates and a self status panel, in the DelPerroSands colours. |
| [dps-medical](https://github.com/DaemonAlex/dps-medical) | Patient records, illness and diagnostic tests. A companion to wasabi_ambulance. Pairs with dps-inventory: symptoms and diagnoses show on the status panel. |
| [dps-insurance](https://github.com/DaemonAlex/dps-insurance) | Ties m-Insurance into the MDT, impound, hospital and medical chart. Pairs with dps-medical. |
| [dps-studio](https://github.com/DaemonAlex/dps-studio) | Build rooms, doors and portals in game from one panel (`/studio`), with owners and managers so staff do not have to support them. |
| [dps-shops](https://github.com/DaemonAlex/dps-shops) | Shop clerks who greet and react to a robbery, then player-owned shops. |
| [dps-fleet](https://github.com/DaemonAlex/dps-fleet) | Vehicle browser and workshop on one panel: extras, liveries and mods for emergency vehicles. |
| [dps-parking](https://github.com/DaemonAlex/dps-parking) | Parking with valet, impound, violations and reserved spots. |
| [dps-vehiclepersistence](https://github.com/DaemonAlex/dps-vehiclepersistence) | Vehicles stay where they were parked. Pairs with dps-parking. |
| [dps-towjob](https://github.com/DaemonAlex/dps-towjob) | Queue-based tow job with jg-mechanic integration. |
| [dps-services](https://github.com/DaemonAlex/dps-services) | Request a tow and follow it live on the lb-phone and lb-tablet. Pairs with dps-towjob. |
| [dps-autoshops](https://github.com/DaemonAlex/dps-autoshops) | Self-service repair shops when no mechanic is on duty. |
| [dps-cityworker](https://github.com/DaemonAlex/dps-cityworker) | City infrastructure job and career. |
| [dps-ainpcs](https://github.com/DaemonAlex/dps-ainpcs) | NPCs you can talk to, with trust, quests and intel. |
| [dps-badpeds](https://github.com/DaemonAlex/dps-badpeds) | Police interaction with NPCs: stops, arrests, intel and jail records. |
| [dps-gangwars](https://github.com/DaemonAlex/dps-gangwars) | Ambient gang NPCs, territory population and war reinforcements. |
| [dps-rotations](https://github.com/DaemonAlex/dps-rotations) | Moves dealers, harvests and other spots on a fixed schedule. |
| [dps-trains](https://github.com/DaemonAlex/dps-trains) | The train system. Pairs with dps-trains-stock, dps-traintools and dps-transitapp. |
| [dps-faceplant](https://github.com/DaemonAlex/dps-faceplant) | City help, reports and staff tools on the lb-phone and lb-tablet. |
| [dps-chat](https://github.com/DaemonAlex/dps-chat) | A command box for voice-only servers. No chat feed. |
| [dps-filmmode](https://github.com/DaemonAlex/dps-filmmode) | One key hides every HUD layer and gives a smooth free camera for recording. |

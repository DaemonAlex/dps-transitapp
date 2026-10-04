# dps-transitapp

An lb-phone custom app that shows live train arrivals for every station, nearest station first.

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

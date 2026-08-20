# dps-transitapp

**Los Santos Transit** — a live departure board on the lb-phone. Shows every
station on the network, the next service to call there, and how far away it is.

It is the passenger-facing half of the railway: `dps-trains` knows where every
train is, this turns that into something someone standing on a platform can act
on.

## What it shows

```
Los Santos Transit
Del Perro Sands · live arrivals

Sandy Shores          Axsellya Express    3 stops away    8 min
Paleto Bay            Brown Streak        next stop       2 min
Davis Interchange     Axsellya Express    boarding         —
Power Plant           —                   No service
```

Per station: the **next** service only, its name, how many calls it still has to
make before arriving, and the ETA.

**"3 stops away" rather than "en route"** because every moving train is en
route — it tells a waiting player nothing. A stop count says whether to wait or
come back later without needing to know the route. Station names were tried for
this and rejected: the line calls at Davis and Quarry in both directions, so
naming the last station departed is ambiguous by a quarter of a lap.

Two states override the stop count, because they say something it cannot:

| State | Meaning |
|---|---|
| `boarding` | standing at the platform now, doors open |
| `delayed` | held behind the train in front |

## How it works

```
dps-trains  ──getArrivalBoard()──▶  dps-transitapp  ──NUI──▶  lb-phone
```

The server calls `exports['dps-trains']:getArrivalBoard()`, which walks every
station on every tracked line and returns arrivals sorted by ETA. This resource
does no scheduling of its own — it is a view.

ETAs come from each train's real cruise speed and its distance along the track,
plus the dwell time of any station it must call at on the way. The UI polls
every 5 seconds.

The export call is `pcall`-guarded, so if `dps-trains` is stopped the board
reads **No service** and the app stays on the phone rather than erroring.

## Requires

| | |
|---|---|
| `lb-phone` | hosts the app |
| `ox_lib` | callbacks |
| `dps-trains` | supplies `getArrivalBoard` — **not** a hard dependency, see below |

## Sharp edges

**`GetParentResourceName()` does not work here.** Inside an lb-phone custom app
the UI runs in **lb-phone's** frame, so it resolves to `lb-phone` and the fetch
never reaches this resource — the board silently stays empty. The resource name
is hardcoded in `ui/index.html` for that reason. Do not "fix" it.

**Do not add `dps-trains` to `dependencies`.** FiveM force-stops dependents when
a dependency restarts and does not bring them back, so every `dps-trains`
restart unregistered the app from the phone entirely. The export call is
guarded, so the soft dependency is enough.

**Manifest changes need `refresh`.** The server caches the parsed manifest, so a
plain resource restart keeps using the old dependency graph.

**Images must be inlined.** The same frame issue that breaks `GetParentResourceName`
breaks relative image paths — they resolve against lb-phone and 404 silently. The
Los Santos Transit logo is embedded as a base64 data URI.

## Registering the app

`client.lua` calls `exports['lb-phone']:AddCustomApp` with identifier
`dps_transit`, and re-registers on `lb-phone` restart — otherwise the icon
disappears from the phone whenever the phone resource reloads.

## Related

| | |
|---|---|
| `dps-trains` | scheduling and movement; owns `getArrivalBoard` |
| `dps-trains-stock` | rolling stock and consists |
| `dps-traintools` | boarding and seating |

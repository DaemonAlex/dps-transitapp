fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'DPS Development'
description 'DPS Transit - live train arrival boards on the lb-phone'
version '1.0.0'
shared_script '@ox_lib/init.lua'
client_script 'client.lua'
server_script 'server.lua'
files { 'ui/index.html' }
-- NOT a hard dependency on dps-trains: FiveM force-stops dependents when a
-- dependency restarts, which unregisters this app from the phone entirely.
-- The getArrivalBoard export call in server.lua is pcall-guarded, so with
-- dps-trains down the board just reads 'no service' and the app stays put.
dependencies { 'lb-phone' }

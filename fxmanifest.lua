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
dependencies { 'lb-phone', 'dps-trains' }

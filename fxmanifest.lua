fx_version "cerulean"
game "gta5"
lua54 "yes"

author "Brodino"
description "Hehehe"

shared_scripts { "config.lua", }
server_scripts { "server/*", }
client_scripts { "@PolyZone/client.lua", "client/*", }

dependencies {
    "PolyZone"
}
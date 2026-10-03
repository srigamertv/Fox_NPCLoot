fx_version 'adamant'
lua54 'yes'

games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name "Fox_NPCLoot"
description "Fox_NPCLoot - adiciona recompensas configuráveis ao saquear NPCs no RedM"
author "SR.IGAMER TV | FOX"
version "1.0.0"

shared_scripts {
    'shared/*.lua',
}

client_scripts {
    'client/native.js',
    'client/*.lua',
}

server_scripts {
    'server/*.lua'
}

exports {
    'DataViewNativeGetEventData2'
}

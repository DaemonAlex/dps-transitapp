CreateThread(function()
    while GetResourceState('lb-phone') ~= 'started' do Wait(1000) end
    Wait(2000)
    local ok, err = pcall(function()
        exports['lb-phone']:AddCustomApp({
            identifier = 'dps_transit',
            name = 'Transit',
            description = 'Live train arrivals across Del Perro Sands',
            developer = 'DPS Transit Authority',
            defaultApp = true,
            size = 512,
            ui = GetCurrentResourceName() .. '/ui/index.html',
            icon = 'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f686.png',
        })
    end)
    if not ok then print('^1[dps-transitapp] AddCustomApp failed: ' .. tostring(err) .. '^7') end
end)

RegisterNUICallback('getBoard', function(_, cb)
    local board = lib.callback.await('dps-transitapp:getBoard', false) or {}
    local pos = GetEntityCoords(PlayerPedId())
    for _, st in ipairs(board) do
        st.dist = math.floor(#(vector2(pos.x, pos.y) - vector2(st.coords.x, st.coords.y)))
    end
    table.sort(board, function(a, b) return a.dist < b.dist end)
    cb(board)
end)

lib.callback.register('dps-transitapp:getBoard', function()
    local ok, board = pcall(function()
        return exports['dps-trains']:getArrivalBoard()
    end)
    return ok and board or {}
end)

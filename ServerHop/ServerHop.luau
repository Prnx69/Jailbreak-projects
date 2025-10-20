local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local Player           = Players.LocalPlayer

local CanServerHop     = true
local ServerHopping    = false
local ServerSuccess    = false

local Server, Servers  = nil, nil
local url = "PUT LINK HERE"

local function ServerHop()
    if ServerHopping then return end
    if not CanServerHop then
        repeat task.wait(0.01) until CanServerHop
    end

    ServerHopping = true
    ServerSuccess = false
    Player.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Started then
            ServerSuccess = true
        end
    end)

    pcall(function()
        repeat
            local resp = game:HttpGet(url)
            Servers = HttpService:JSONDecode(resp)
            Server  = Servers.servers[math.random(1, #Servers.servers)]
        until Server
            and Server.id ~= game.JobId
            and typeof(Server.id) == "string"
            and typeof(Server.maxPlayers) == "number"
            and typeof(Server.playing) == "number"
            and Server.playing < (Server.maxPlayers - 2)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, Player)
        TeleportService.TeleportInitFailed:Wait()
    end)

    task.delay(10, function()
        if not ServerSuccess then
            ServerHopping = false
            ServerHop()
        end
    end)
end

task.spawn(function()
    while not pcall(function()
        CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
            if child.Name == "ErrorPrompt"
                and child:FindFirstChild("MessageArea")
                and child.MessageArea:FindFirstChild("ErrorFrame") then

                ServerHopping = false
                ServerHop()
            end
        end)
    end) do
        task.wait(0.1)
    end
end)

ServerHop()
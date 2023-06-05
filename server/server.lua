
-- [ Steam API checking ]

AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() == resourceName) then
    if not GetConvar('steam_webApiKey', '') then
      print("\n\n^1┌─┐┌┬┐┌─┐┌─┐┌┬┐  ┌─┐┌─┐┬  ┬ ┬┌─┐┬─┐┌┐┌┬┌┐┌┌─┐")
      print("^1└─┐ │ ├┤ ├─┤│││  ├─┤├─┘│  │││├─┤├┬┘││││││││ ┬")
      print("^1└─┘ ┴ └─┘┴ ┴┴ ┴  ┴ ┴┴  ┴  └┴┘┴ ┴┴└─┘└┘┴┘└┘└─┘")
      print("^3[WARN] You haven't set up your Steam API Key! The Steam identifier won't work!")
      print("^5[INFO] https://forum.cfx.re/t/using-the-steam-api-key-manually-on-the-server/805987^7")
      print("^5[INFO] No further warnings will be shown.^7\n\n")
    end
  end
end)

-- [ Restart logs ]

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 500 then
        LogRestart('10')
    elseif eventData.secondsRemaining == 300 then
        LogRestart('5')
    elseif eventData.secondsRemaining == 240 then
        LogRestart('4')
    elseif eventData.secondsRemaining == 180 then
        LogRestart('3')
    elseif eventData.secondsRemaining == 120 then
        LogRestart('2')
    elseif eventData.secondsRemaining == 60 then
        LogRestart('1')
    elseif eventData.secondsRemaining <= 5 then
        LogRestart(wx.Locale.RestartingNow)
    end
end)

-- [ DM logs ]

AddEventHandler('txAdmin:events:playerDirectMessage', function(eventData)
  LogDM(eventData.author,GetPlayerName(eventData.target),eventData.message)
end)

-- [ Revoke logs ]

AddEventHandler('txAdmin:events:actionRevoked', function(eventData)
  LogRevoke(eventData.revokedBy,eventData.actionId,eventData.actionType)
end)

-- [ Kick logs ]

AddEventHandler('txAdmin:events:playerKicked', function(eventData)
  local steamid  = wx.Locale.NotFound
  local license  = wx.Locale.NotFound
  local discord  = wx.Locale.NotFound
  local ip       = wx.Locale.NotFound

for k,v in pairs(GetPlayerIdentifiers(eventData.target)) do
    if string.sub(v, 1, string.len("steam:")) == "steam:" then
      steamid = v
    elseif string.sub(v, 1, string.len("license:")) == "license:" then
      license = v
    elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
      ip = v:gsub('ip:', ''):gsub('ip:', '')
    elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
      discord = v
    end
end

  LogKick(eventData.author,GetPlayerName(eventData.target),eventData.reason,"Steam ID: "..steamid.."\nLicense: "..license.."\nDiscord: "..discord.."\nIP Address: "..ip)
end)

-- [ Ban logs - Doesn't work for offline bans ]

AddEventHandler('txAdmin:events:playerBanned', function(eventData)
  local steamid  = wx.Locale.NotFound
  local license  = wx.Locale.NotFound
  local discord  = wx.Locale.NotFound
  local ip       = wx.Locale.NotFound

if not eventData.targetNetId == nil then
  for k,v in pairs(GetPlayerIdentifiers(eventData.targetNetId)) do
    if string.sub(v, 1, string.len("steam:")) == "steam:" then
      steamid = v
    elseif string.sub(v, 1, string.len("license:")) == "license:" then
      license = v
    elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
      ip = v:gsub('ip:', '')
    elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
      discord = v
    end
end
  if eventData.expiration == false then
      LogBan(eventData.author,eventData.targetName,eventData.reason,wx.Locale.Permanent,eventData.actionId,"Steam ID: "..steamid.."\nLicense: "..license.."\nDiscord: "..discord.."\nIP Address: "..ip)
  else
      LogBan(eventData.author,eventData.targetName,eventData.reason,os.date('%d.%m.%Y %H:%M:%S', eventData.expiration),eventData.actionId,"Steam ID: "..steamid.."\nLicense: "..license.."\nDiscord: "..discord.."\nIP Address: "..ip)
  end
else
  if eventData.expiration == false then
    LogBan(eventData.author,eventData.targetName,eventData.reason,wx.Locale.Permanent,eventData.actionId,"Identifiers are unavailable, the player was banned while offline")
else
    LogBan(eventData.author,eventData.targetName,eventData.reason,os.date('%d.%m.%Y %H:%M:%S', eventData.expiration),eventData.actionId,"Identifiers are unavailable, the player was banned while offline")
end
  
end

end)

-- [ Warn logs ]

AddEventHandler('txAdmin:events:playerWarned', function(eventData)
  local steamid  = wx.Locale.NotFound
  local license  = wx.Locale.NotFound
  local discord  = wx.Locale.NotFound
  local ip       = wx.Locale.NotFound

for k,v in pairs(GetPlayerIdentifiers(eventData.target)) do
    if string.sub(v, 1, string.len("steam:")) == "steam:" then
      steamid = v
    elseif string.sub(v, 1, string.len("license:")) == "license:" then
      license = v
    elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
      ip = v:gsub('ip:', '')
    elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
      discord = v
    end
end
    LogWarning(eventData.author,GetPlayerName(eventData.target),eventData.reason,"Steam ID: "..steamid.."\nLicense: "..license.."\nDiscord: "..discord.."\nIP Address: "..ip)
end)


-- [ Heal logs ]

AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
    Author = GetPlayerName(eventData.id)
    if eventData.id ~= -1 then
        LogHeal(Author,Author)
    else
        LogHeal(Author,"Everyone") -- Doens't work idk why
    end
end)

-- [ Announcement logs ]
AddEventHandler('txAdmin:events:announcement', function(eventData)
    LogAnnouncement(eventData.author,eventData.message)
end)


-- [ Webhook functions ]

function LogRestart(time)
    local embed = {
          {
              ["color"] = wx.Restart,
              ["title"] = "**"..wx.Locale.Restarting.."**",
          ["fields"] = {
            {
              ["name"]= wx.Locale.MinutesRemaining,
              ["value"]= time,
              ["inline"] = true
            }
          }
        }
      }
    PerformHttpRequest(wx.Webhook, function(err, text, headers) end, 'POST', json.encode({username = wx.WebhookUsername, avatar_url = wx.WebhookAvatar, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function LogKick(admin, player, reason, ids)
    local embed = {
          {
              ["color"] = wx.Kick,
              ["title"] = "**"..wx.Locale.Kicked.."**",
          ["fields"] = {
            {
              ["name"]= wx.Locale.AdminName,
              ["value"]= admin,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Target,
              ["value"]= player,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Reason,
              ["value"]= reason,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Ids,
              ["value"]= ids,
              ["inline"] = true
            }
          }
        }
      }
    PerformHttpRequest(wx.Webhook, function(err, text, headers) end, 'POST', json.encode({username = wx.WebhookUsername, avatar_url = wx.WebhookAvatar, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function LogWarning(admin, player, reason, ids)
    local embed = {
          {
              ["color"] = wx.Warn,
              ["title"] = "**"..wx.Locale.Warned.."**",
          ["fields"] = {
            {
              ["name"]= wx.Locale.AdminName,
              ["value"]= admin,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Target,
              ["value"]= player,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Reason,
              ["value"]= reason,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Ids,
              ["value"]= ids,
              ["inline"] = true
            }
          }
        }
      }
    PerformHttpRequest(wx.Webhook, function(err, text, headers) end, 'POST', json.encode({username = wx.WebhookUsername, avatar_url = wx.WebhookAvatar, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function LogBan(admin, player, reason, expires, banid, ids)
    local embed = {
          {
              ["color"] = wx.Ban,
              ["title"] = "**"..wx.Locale.Banned.."**",
          ["fields"] = {
            {
              ["name"]= wx.Locale.AdminName,
              ["value"]= admin,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Target,
              ["value"]= player,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Reason,
              ["value"]= reason,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Expiration,
              ["value"]= expires,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.BanID,
              ["value"]= banid,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Ids,
              ["value"]= ids,
              ["inline"] = true
            }
          }
        }
      }
    PerformHttpRequest(wx.Webhook, function(err, text, headers) end, 'POST', json.encode({username = wx.WebhookUsername, avatar_url = wx.WebhookAvatar, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function LogHeal(admin, target)
    local embed = {
          {
              ["color"] = wx.Heal,
              ["title"] = "**"..wx.Locale.Heal.."**",
          ["fields"] = {
            {
              ["name"]= wx.Locale.AdminName,
              ["value"]= admin,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Target,
              ["value"]= target,
              ["inline"] = true
            }
          }
        }
      }
    PerformHttpRequest(wx.Webhook, function(err, text, headers) end, 'POST', json.encode({username = wx.WebhookUsername, avatar_url = wx.WebhookAvatar, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function LogRevoke(admin, banId, type)
    local embed = {
          {
              ["color"] = wx.Revoke,
              ["title"] = "**"..wx.Locale.Revoked.."**",
          ["fields"] = {
            {
              ["name"]= wx.Locale.RevokedBy,
              ["value"]= admin,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.BanID,
              ["value"]= banId,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Type,
              ["value"]= type,
              ["inline"] = true
            }
          }
        }
      }
    PerformHttpRequest(wx.Webhook, function(err, text, headers) end, 'POST', json.encode({username = wx.WebhookUsername, avatar_url = wx.WebhookAvatar, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function LogAnnouncement(admin, message)
    local embed = {
          {
              ["color"] = wx.Announcement,
              ["title"] = "**"..wx.Locale.Announcement.."**",
          ["fields"] = {
            {
              ["name"]= wx.Locale.Announcer,
              ["value"]= admin,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Message,
              ["value"]= message,
              ["inline"] = true
            }
          }
        }
      }
    PerformHttpRequest(wx.Webhook, function(err, text, headers) end, 'POST', json.encode({username = wx.WebhookUsername, avatar_url = wx.WebhookAvatar, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
function LogDM(admin,player, message)
    local embed = {
          {
              ["color"] = wx.DM,
              ["title"] = "**"..wx.Locale.DM.."**",
          ["fields"] = {
            {
              ["name"]= wx.Locale.AdminName,
              ["value"]= admin,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Target,
              ["value"]= player,
              ["inline"] = true
            },
            {
              ["name"]= wx.Locale.Message,
              ["value"]= message,
              ["inline"] = true
            }
          }
        }
      }
    PerformHttpRequest(wx.Webhook, function(err, text, headers) end, 'POST', json.encode({username = wx.WebhookUsername, avatar_url = wx.WebhookAvatar, embeds = embed}), { ['Content-Type'] = 'application/json' })
end


function ExtractIdentifiers(src)
  local identifiers = {
      steam = "",
      ip = "",
      discord = "",
      license = "",
      xbl = "",
      live = ""
  }

  --Loop over all identifiers
  for i = 0, GetNumPlayerIdentifiers(src) - 1 do
      local id = GetPlayerIdentifier(src, i)

      --Convert it to a nice table.
      if string.find(id, "steam") then
          identifiers.steam = id
      elseif string.find(id, "ip") then
          identifiers.ip = id
      elseif string.find(id, "discord") then
          identifiers.discord = id
      elseif string.find(id, "license") then
          identifiers.license = id
      elseif string.find(id, "xbl") then
          identifiers.xbl = id
      elseif string.find(id, "live") then
          identifiers.live = id
      end
  end

  return identifiers
end
local iconBgColor = rgbm(1, 0, 0, 1)

return function (dt)
  system.statusIcon(system.appIcon(), iconBgColor)
  if not YoutubeAppData.hasVideo() then return false end

  local p, n = YoutubeAppData.hasNextPrevious()
  local clicked = false
  if system.statusButton(ui.Icons.Back, 34, p) then
    YoutubeAppData.goToPrevious()
    clicked = true
  end

  if system.statusButton(YoutubeAppData.playing() and ui.Icons.Pause or ui.Icons.Play, 34) then
    YoutubeAppData.toggle()
    clicked = true
  end

  if system.statusButton(ui.Icons.Next, 34, n) then
    YoutubeAppData.goToNext()
    clicked = true
  end

  return not clicked and 'openonclick' or nil
end

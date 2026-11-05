local iconBgColor = rgbm(0, 0, 0, 1)

return function (dt)
  system.statusIcon(system.appIcon(), iconBgColor)

  local clicked = false
  if system.statusButton(ui.Icons.Back, 34) then
    ac.mediaPreviousTrack()
    clicked = true
  end
  if system.statusButton(ac.currentlyPlaying().isPlaying and ui.Icons.Pause or ui.Icons.Play, 34) then
    ac.mediaPlayPause()
    clicked = true
  end
  if system.statusButton(ui.Icons.Next, 34) then
    ac.mediaNextTrack()
    clicked = true
  end
  return not clicked and 'openonclick' or nil
end


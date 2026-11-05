local iconColor = rgbm.new('#EF5261')

return function (dt)
  system.statusIcon(system.appIcon(), iconColor)
  if not RadioAppData or not RadioAppData.lib then
    return false
  end

  local clicked = false
  if system.statusButton(ui.Icons.Back, 34) then
    RadioAppData:selectStation(-1)
    clicked = true
  end

  if system.statusButton(RadioAppData.lib.current() and ui.Icons.Pause or ui.Icons.Play, 34) then
    RadioAppData:playToggle()
    clicked = true
  end

  if system.statusButton(ui.Icons.Next, 34) then
    RadioAppData:selectStation(1)
    clicked = true
  end

  return not clicked and 'openonclick' or nil
end

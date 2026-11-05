local exchange = ac.connect({
  ac.StructItem.key('omsi-mouse-steering'),
  pos = ac.StructItem.vec2(),
  lastActive = ac.StructItem.int64()
})

function script.drawUI()
  local pos = ui.windowSize() * (exchange.pos * 0.5 + 0.5)
  ui.beginOutline()
  ui.drawSimpleLine(pos - vec2(12, 0), pos + vec2(12, 0), rgbm.colors.yellow)
  ui.drawSimpleLine(pos - vec2(0, 12), pos + vec2(0, 12), rgbm.colors.yellow)
  ui.drawCircle(pos, 8, rgbm.colors.yellow, 20)
  ui.endOutline(rgbm.colors.black)
end

function script.update()
  ac.setDrawUIActive(ac.getSim().frame - exchange.lastActive < 10)
end


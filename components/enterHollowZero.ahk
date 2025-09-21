/**
 * - 角色操作界面进入零号空洞选择界面
 */
enterHollowZero() {
  activateZZZ()
  ; 进入快捷手册
  Press(setting.handbook)
  RandomSleep(1000, 1200)
  if (PixelSearchPre(&X, &Y, c.快捷手册.挑战_灰色*)) {
    SimulateClick(X, Y)
  } else {
    pixelSearchAndClick(c.快捷手册.挑战_黑色*)
  }
  pixelSearchAndClick(c.快捷手册.零号空洞*)
  pixelSearchAndClick(c.快捷手册.前往*)
  pixelSearchAndClick(c.快捷手册.传送*)
  RandomSleep()
  while (!PixelSearchPre(&X, &Y, c.拿命验收.返回键*)) {
    Sleep(100)
    if (A_Index > 50) {
      return false
    }
  }
  RandomSleep(400, 600)
  Press('Escape')
  while (recogLocation(3) != 1) {
    if (A_Index > 6) {
      return false
    }
    Press('Escape')
  }
  RandomSleep()
  Press('F', 2)
  RandomSleep()
  while (!PixelSearchPre(&X, &Y, c.拿命验收.返回键*)) {
    Sleep(100)
    if (A_Index > 50) {
      return false
    }
  }
  RandomSleep()
  SimulateClick(c.width // 4 * 3, c.height // 2, 3)
  ; 验证是否成功进入零号空洞选择界面
  mode := recogLocation()
  if (mode != 2) {
    return false
  }
  return true
}
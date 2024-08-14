/**
 * - step 0
 * - 角色操作界面进入零号空洞选择界面
 */
charOperation() {
  activateZZZ()
  RandomSleep()
  ; 进入快捷手册
  Press('F2')
  RandomSleep(1000, 1200)
  if (PixelSearchPre(&X, &Y, c.快捷手册.挑战_灰色*)) {
    SimulateClick(X, Y)
  } else {
    pixelSearchAndClick(c.快捷手册.挑战_黑色*)
  }
  pixelSearchAndClick(c.快捷手册.零号空洞*)
  pixelSearchAndClick(c.快捷手册.前往*)
  pixelSearchAndClick(c.快捷手册.传送*)
  RandomSleep(3000, 4000)
  ; 验证是否成功进入零号空洞选择界面
  mode := recogLocation()
  if (mode != 2) {
    return false
  }
  return true
}
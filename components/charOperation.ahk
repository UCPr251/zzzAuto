/**
 * - step 0
 * - 角色操作界面进入零号空洞选择界面
 */
charOperation() {
  activateZZZ()
  RandomSleep()
  ; 进入快捷手册
  Press('Escape')
  RandomSleep(1300, 1500)
  pixelSearchAndClick(699, 949, 734, 996, 712, 972, 0xffffff)
  RandomSleep(1000, 1200)
  ; 点击挑战
  if (PixelSearchPre(&X, &Y, 1490, 160, 1535, 200, 0xbbbbbb)) {
    SimulateClick(X, Y)
  } else {
    pixelSearchAndClick(1490, 160, 1535, 200, 1513, 185, 0x000000)
  }
  RandomSleep()
  ; 点击零号空洞
  pixelSearchAndClick(275, 463, 380, 490, 330, 475, 0xaaaaaa)
  RandomSleep()
  ; 点击前往
  pixelSearchAndClick(1424, 353, 1476, 390, 1450, 370, 0xffffff)
  RandomSleep()
  ; 点击确定(传送)
  pixelSearchAndClick(1000, 600, 1100, 640, 1125, 620, 0x00cc0d)
  RandomSleep(3000, 4000)
  mode := recogLocation()
  if (mode != 2) {
    return false
  }
  return true
}
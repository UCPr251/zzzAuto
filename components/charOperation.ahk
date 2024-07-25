/**
 * - step 0
 * - 角色操作界面
 */
charOperation() {
  activateZZZ()
  RandomSleep()
  ; 进入快捷手册
  Press('Escape')
  RandomSleep(1300, 1500)
  pixelSearchAndClick(699, 949, 734, 996, 712, 972, 0xffffff)
  Sleep(1000)
  ; 点击挑战
  if (PixelSearchPre(&X, &Y, 1491, 156, 1536, 177, 0xbbbbbb, 20)) {
    SimulateClick(X, Y)
  } else {
    pixelSearchAndClick(1491, 156, 1536, 177, 1513, 166, 0x000000)
  }
  RandomSleep()
  ; 点击零号空洞
  pixelSearchAndClick(279, 463, 380, 484, 330, 473, 0xaaaaaa)
  RandomSleep()
  ; 点击前往
  pixelSearchAndClick(1424, 353, 1476, 378, 1450, 363, 0xffffff)
  RandomSleep()
  ; 点击确定(传送)
  pixelSearchAndClick(1106, 615, 1153, 636, 1123, 624, 0xffffff)
  RandomSleep(3000, 4000)
}
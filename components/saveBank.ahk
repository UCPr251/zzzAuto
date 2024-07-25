/**
 * - step7
 * - 存银行
 */
saveBank() {
  debugLog("【step7】存银行")
  Press('s')
  Press('a', 3)
  Press('s')
  Press('a', 3)
  Press('w')
  ; 进门
  Press('a')
  RandomSleep(2400, 2500)
  ; 强行闯入
  pixelSearchAndClick(1360, 600, 1390, 660, 1668, 618, 0x296bfd)
  ; 对话
  Press('Space', 8)
  ; 侵蚀
  RandomSleep(3800, 4000)
  ; 确定侵蚀铭徽
  pixelSearchAndClick(950, 630, 1000, 660, 970, 650, 0xffffff)
  RandomSleep(4500, 4800)
  Press('a', 3)
  RandomSleep(1500, 1800)
  ; 对话
  Press('Space', 18)
  ; 如果有礼包
  if (PixelSearchPre(&X, &Y, 1347, 548, 1380, 595, 0xaa7cff, 40)) {
    pixelSearchAndClick(1403, 668, 1457, 689, 1653, 678, 0xffffff) ; 不要礼包
    Press('Space', 4)
  }
  ; 存款
  Coords := pixelSearchAndClick(1360, 440, 1390, 500, 1640, 670, 0x296bfd)
  loop (6) {
    SimulateClick(Coords[1], Coords[2], 2, false)
    Press('Space', 3)
    ; 如果有礼包
    if (PixelSearchPre(&X, &Y, 1347, 548, 1380, 595, 0xaa7cff, 40)) {
      pixelSearchAndClick(1403, 668, 1457, 689, 1653, 678, 0xffffff) ; 不要礼包
    }
    ; 如果弹出选择铭徽界面
    if (PixelSearchPre(&X, &Y, 935, 779, 960, 790, 0xffffff, 30)) {
      SimulateClick(X, Y, 2, false) ; 选择铭徽
    }
    Press('Space', 3)
  }
}
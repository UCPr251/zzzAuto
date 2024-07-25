/**
 * - step3
 * - 抵达终点
 */
reachEnd() {

  /** 判断地图类型 */
  judgeMap() {
    mode := 0
    loop (10) {
      ; 对指定区域进行RGB检测
      if (PixelSearchPre(&FoundX, &FoundY, 1301, 220, 1328, 236, 0xF63B46, 30)) {
        mode := 1
        break
      }
      ; 对指定区域进行RGB检测
      if (PixelSearchPre(&FoundX, &FoundY, 1302, 876, 1333, 898, 0xEC2322, 30)) {
        mode := 2
        break
      }
      Sleep(100)
    }
    return mode
  }

  activateZZZ()
  ; 判断地图类型
  mode := judgeMap()
  if (!mode) {
    return false
  }

  /** 使用炸弹 */
  bomb() {
    Send("{r Down}")
    RandomSleep(800, 1000)
    Send("{r Up}")
    RandomSleep(1900, 2100)
  }

  /** 右上角终点 */
  above() {
    RandomSleep()
    ; 使用炸弹
    bomb()
    ; 向右移动
    Press("d")
    RandomSleep(1000, 2000)
    ; 点击选项
    SimulateClick(964, 804)
    RandomSleep(1000, 1500)
    ; 进入终点
    Press("d")
    Press("w")
    Press("w")
  }

  /** 右下角终点 */
  below() {
    RandomSleep()
    ; 代理人接应窗口
    Press('s')
    RandomSleep(800, 1200)
    Press("Space", 6)
    RandomSleep(2800, 3000)
    SimulateClick(1545, 672, 2)
    Press("Space", 6)
    RandomSleep(1800, 2000)
    ; 使用炸弹
    bomb()
    Press('s')
    RandomSleep(1500, 1800)
    ; 选择铭徽
    SimulateClick(996, 779, 2)
    RandomSleep(800, 1200)
    ; 进入终点
    Press('d', 2)
  }

  debugLog("【step3】前往终点")
  if (mode = 1) {
    above()
  } else {
    below()
  }
  ; 加载动画
  Sleep(2000)
  return true
}
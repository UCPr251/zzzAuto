/**
 * - step6
 * - 获得零号业绩
 */
getMoney() {
  activateZZZ()
  debugLog("【step6】获得零号业绩")
  RandomSleep()
  ; 进入零号业绩格子
  Press('d')
  Press('w', 2)
  Press('d', 2)
  RandomSleep(2200, 2500)
  Press('Space', 8)
  RandomSleep(2200, 2500)
  Press('d')
  ; 获得零号业绩（如果有）
  Press('w')
  ; 加载动画
  RandomSleep(2000, 2200)
  X := 1800, Y := 900
  preprocess(&X, &Y)
  ; 点击确定（如果有）
  SimulateClick(X, Y, 2)
  RandomSleep(1000, 1200)
}
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
  Press("2")
  ; 对话
  Press('Space', 8)
  ; 侵蚀
  RandomSleep(800, 1000)
  ; 确认侵蚀
  pixelSearchAndClick(c.空洞.确认*)
  RandomSleep(3800, 4000)
  Press('a', 3)
  ; 对话
  Press('Space', 18)
  ; 存款
  loop (6) {
    Press('1')
    Press('Space', 2)
    ; 如果弹出选择铭徽界面
    MingHui(true, 5)
    Press('Space', 2)
  }
}
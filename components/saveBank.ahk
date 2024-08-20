/**
 * - 存银行
 */
saveBank(step := 7, gainMode := 0) {
  activateZZZ()
  stepLog("【step" step "】存银行")

  reachDoor() {
    if (gainMode = 2) { ; 只存银行，直接去银行
      Press('a')
      Press('w', 2)
      Press('a', 2)
    } else { ; 业绩到银行
      Press('s')
      Press('a', 3)
      Press('s')
      Press('a', 3)
      Press('w')
      Press('a')
    }
  }

  ; 进检疫门
  reachDoor()
  RandomSleep(2400, 2500)
  ; 强行闯入
  Press("2")
  ; 对话
  Press('Space', 12)
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
  ; 最后判断一下是否有铭徽选择框
  RandomSleep()
  MingHui(true, 5)
}
dofile("script/include/inc_all.lua")
dofile("script/include/inc_event.lua")

function subEveCamShake(amt)
  CAMERA:SetShake(Vector2(amt, amt), TimeSec(1, TIME_TYPE.FRAME))
  TASK:Sleep(TimeSec(0.2))
  CAMERA:SetShake(Vector2(0, 0), TimeSec(0))
  TASK:Sleep(TimeSec(0.5))
end

function groundInit()
end
function groundStart()
end
function main04_tsuginoasa01_init()
end
function main04_tsuginoasa01_start()
  SYSTEM:UpdateNextDayParameter()
  CAMERA:SetAzimuthDifferenceVolume(Volume(5))
  CAMERA:SetEye(SymCam("CAMERA_04"))
  CAMERA:SetTgt(SymCam("CAMERA_04"))
  
  GROUND:SetPokemonWarehouseHeroName("Orus")
  GROUND:SetPokemonWarehousePartnerName("Laurenna")             --Set the characters' names (instead of renaming them in the save)
  
  MENU:LoadMenuTextPool("message/customCuts.bin")               --load the custom message/text file
  
  CH("PARTNER"):SetDir(RotateTarget(45))
  CH("PARTNER"):SetMotion(SymMot("EV001_SLEEP01"), LOOP.ON, TimeSec(0)) --play sleeping animation in a loop on partner
  CH("HERO"):MoveTo(Vector2(-0.3, 2),Speed(350))                --move hero to near house doorway  (0,0 = center)
  CH("HERO"):SetDir(RotateTarget(190))                          --turn hero toward Partner (approximately)
  TASK:Sleep(TimeSec(0.5))
    
  SCREEN_A:FadeIn(TimeSec(0.5), true)                           --fade in screen
  subEveFadeAfterTime()
  CH("PARTNER"):SetMotion(SymMot("EV001_SLEEP02"), LOOP.OFF)    --play partner wake up anim
  CH("PARTNER"):WaitPlayMotion()                                --wait for partner to be up
  CH("PARTNER"):DirTo(RotateTarget(90), Speed(350), ROT_TYPE.NEAR) --partner turns to face player's bed
  CH("PARTNER"):WaitRotate()                                    --wait for partner to finish turning
  TASK:Sleep(TimeSec(0.45))
  CH("PARTNER"):SetNeckRot(RotateTarget(0), RotateTarget(0), RotateTarget(20), TimeSec(0.2))  --"confused head lean"
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_QUESTION_01"), Volume(256))  --play "question mark" sound
  CH("PARTNER"):SetManpu("MP_QUESTION")                         --place '?' over partner
  CH("PARTNER"):WaitManpu()                                     --wait for '?' effect to finish
  CH("PARTNER"):ResetNeckRot(TimeSec(0.2))                      --"unlean" head
  TASK:Sleep(TimeSec(0.4))
    
  CH("PARTNER"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)    --partner turns to face hero
  CAMERA:MoveEye(Vector(4.8, 3.3, 4.8), TimeSec(1.5), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW)
  CAMERA:MoveTgt(Vector(1, 1, 2), TimeSec(1.5), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW) --move and rotate camera to hero (approximately)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.HAPPY)               --display face on player model (happy)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.HAPPY)      --display player portrait (happy)
  WINDOW:Talk(SymAct("HERO"), -1613976414)                      --player speaks ("Over here.")
  WINDOW:KeyWait()
  
  TASK:Regist(subEveDoubleJump, {CH("HERO")})                   --player plays jumping anim (non-blocking)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.GLADNESS)            --display face on player model (gladness)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.GLADNESS)   --display player portrait (gladness)
  WINDOW:Talk(SymAct("HERO"), -1613976158)                      --player speaks ("Check it out, we have our own custom\ncutscene!")
  WINDOW:KeyWait()
  
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --display face on player model (normal)
  TASK:Regist(subEveJumpSurprise, {CH("PARTNER")})              --partner plays shocked anim (non-blocking)
  CH("PARTNER"):SetManpu("MP_SHOCK_L")                          --display "shocked effect" above partner
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_SHOCK_02"), Volume(256))     --play "shocked" sound
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.SURPRISE)         --display face on partner model (SURPRISE)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.SURPRISE)--display partner portrait (shocked/surprised)
  WINDOW:Talk(SymAct("PARTNER"), -1613975902)                   --partner speaks ("What!?  We do?")
  WINDOW:KeyWait() 
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)            --display face on partner model (THINK)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)  --display partner portrait (question/think)
  WINDOW:Talk(SymAct("PARTNER"), -1613975646)                   --partner speaks ("This isn't part of the normal game?")
  WINDOW:KeyWait() 
  
  TASK:Regist(subEveNoNoNo, {CH("HERO")})                       --player plays head shake anim (non-blocking)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.HAPPY)               --display face on player model (happy)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.HAPPY)      --display player portrait (happy)
  WINDOW:Talk(SymAct("HERO"), -1613975390)                      --player speaks ("Nope.  Not at all.")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)           --display face on partner model (normal)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --display face on player model (normal)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --display player portrait (normal)  
  WINDOW:Talk(SymAct("HERO"), -1613975134)                      --player speaks ("Well, sorta. We still cant change the\nmap, or add other characters.")
  WINDOW:KeyWait()
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --display player portrait normal
  WINDOW:Talk(SymAct("HERO"), -1613974878)                      --player speaks ("But, I can walk wherever I want.")
  WINDOW:KeyWait()
  
  WINDOW:CloseMessage()                                         --remove text box and face from screen
  WINDOW:RemoveFace()
  CH("HERO"):WalkTo(Vector2(-1.5, 0), Speed(2))                 --move hero to left of house center
  CAMERA:MoveEye(Vector(4.9, 3.1, 2.6), TimeSec(1.5), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW) --move camera along with them
  CAMERA:MoveTgt(Vector(-1.2, -0.1, -1.1), TimeSec(1.5), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW)
  CH("HERO"):WaitMove()
  CH("HERO"):DirTo(CH("PARTNER"), Speed(350), ROT_TYPE.NEAR)    --hero turns to face partner
  CH("PARTNER"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)    --partner turns to face hero
  TASK:Sleep(TimeSec(0.2))
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --display player portrait (normal)
  WINDOW:Talk(SymAct("HERO"), -1613974622)                      --player speaks ("Like over here")
  WINDOW:KeyWait()
  
  TASK:Regist(subEveJump, {CH("PARTNER")})                      --partner plays jump anim (non-blocking)
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)            --display face on partner model (happy)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)  --display partner portrait (happy)
  WINDOW:Talk(SymAct("PARTNER"), -1613974366)                   --partner speaks ("Ooooh!  Can I do that?")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)           --display face on partner model (normal)
  TASK:Regist(subEveNod, {CH("HERO")})                          --partner player nod anim (non-blocking)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --display face on partner model (normal)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --display player portrait (normal)
  WINDOW:Talk(SymAct("HERO"), -1613974110)                      --player speaks ("Yeah, come on over here.")
  WINDOW:KeyWait()
  
  WINDOW:CloseMessage()                                         --remove text box and face from screen
  WINDOW:RemoveFace()
  CH("PARTNER"):WalkTo(Vector2(-1.5, -0.75),Speed(2))           --move partner to top left of house center
  CAMERA:MoveEye(Vector(5, 3, 0.5), TimeSec(1), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW)    --move camera along with them
  CAMERA:MoveTgt(Vector(-1.5, 0, -0.3), TimeSec(1), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW)
  CH("PARTNER"):WaitMove()
  CH("HERO"):DirTo(CH("PARTNER"), Speed(350), ROT_TYPE.NEAR)    --hero turns to face partner
  CH("PARTNER"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)    --partner turns to face hero
  TASK:Sleep(TimeSec(0.2))
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)            --display face on partner model (happy)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)  --display partner portrait (happy)
  WINDOW:Talk(SymAct("PARTNER"), -1613973854)                   --partner speaks ("Neat!")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)            --display face on partner model (think)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)  --display partner portrait (think)
  WINDOW:Talk(SymAct("PARTNER"), -1613973598)                   --partner speaks ("How about...")
  WINDOW:KeyWait() 
  
  WINDOW:CloseMessage()                                         --remove text box and face from screen
  WINDOW:RemoveFace()
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)           --display face on partner model (normal)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.THINK)               --display face on player model (think)
  CH("PARTNER"):MoveHeightTo(Height(5), Speed(3))               --partner floats into ceiling, player looks up at them
  CH("HERO"):SetNeckRot(RotateTarget(0), RotateTarget(30), RotateTarget(0), TimeSec(1))
  CH("PARTNER"):WaitMoveHeight() 
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.THINK)      --display player portrait (think)  
  WINDOW:Talk(SymAct("HERO"), -1613973342)                      --player speaks ("Uhh... <pause> Yeah, I guess you could do that if you wanted...")
  WINDOW:KeyWait()
  
  WINDOW:CloseMessage()                                         --remove text box and face from screen
  WINDOW:RemoveFace()
  CH("PARTNER"):MoveHeightTo(Height(0), Speed(4))               --partner floats down
  CH("HERO"):ResetNeckRot(TimeSec(1))                           --player looks back down
  CH("PARTNER"):WaitMoveHeight()
  
  TASK:Sleep(TimeSec(0.5))
  CH("HERO"):SetManpu("MP_SWEAT_R_AL")                          --display sweat drop on player
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_SWEAT"), Volume(256))        --play corresponding sound
  CH("HERO"):SetNeckRot(RotateTarget(0), RotateTarget(-15), RotateTarget(0), TimeSec(0.2))--player lowers head
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.RELIEF)              --display face on player model (relief, exasperated)
  WINDOW:DrawFace(20 ,88, SymAct("HERO"), FACE_TYPE.RELIEF)     --display player portrait (relief, exasperated)  
  WINDOW:Talk(SymAct("HERO"), -1613973086)                      --player speaks ("Right. <pause> Continuing on...")
  WINDOW:KeyWait()
  
  CH("HERO"):ResetNeckRot(TimeSec(0.2))                         --player raises head
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --display face on player model (normal)
  WINDOW:DrawFace(20 ,88, SymAct("HERO"), FACE_TYPE.NORMAL)     --display player portrait (normal)  
  WINDOW:Talk(SymAct("HERO"), -1613972830)                      --player speaks ("We can also move the camera around.")
  WINDOW:KeyWait()
  
  WINDOW:Talk(SymAct("HERO"), -1613972574)                      --player speaks ("Like this.")
  WINDOW:KeyWait()
  
  WINDOW:CloseMessage()                                         --remove text box and face from screen
  WINDOW:RemoveFace()
  CAMERA:MoveEye(Vector(4, 5, 3), Speed(3))                     --move the camera around
  CAMERA:MoveTgt(Vector(-1, 0, 0), Speed(3))
  CAMERA:WaitMove()
  CAMERA:MoveEye(Vector(4, 5, -3), Speed(3))
  CAMERA:WaitMove()
  CAMERA:MoveEye(Vector(4, 5, 0), Speed(3))
  CAMERA:WaitMove()
  CAMERA:MoveEye(Vector(4, 2, 0), Speed(3))
  CAMERA:WaitMove()
  CAMERA:MoveEye(Vector(4, 5, 0), Speed(3))
  CAMERA:WaitMove()
  CAMERA:MoveTgt(Vector(-1, 0, -2), Speed(3))
  CAMERA:WaitMove()
  CAMERA:MoveTgt(Vector(-1, 0, 2), Speed(3))
  CAMERA:WaitMove()
  CAMERA:MoveEye(Vector(5, 3, 0.5), TimeSec(1), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW)
  CAMERA:MoveTgt(Vector(-1.5, 0, -0.3), TimeSec(1), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW)
  CAMERA:WaitMove()

  TASK:Sleep(TimeSec(0.25))
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)            --display face on partner model (happy)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)  --display partner portrait (happy)
  WINDOW:Talk(SymAct("PARTNER"), -1613972318)                   --partner speaks ("Cool! <pause> Let me try...")
  WINDOW:KeyWait()
  
  WINDOW:CloseMessage()                                         --remove text box and face from screen
  WINDOW:RemoveFace()
  CAMERA:MoveFollowR(Vector(0, 0, -2), Speed(12, ACCEL_TYPE.NONE, DECEL_TYPE.NONE))--Move camera wildly
  CAMERA:WaitMove()
  CAMERA:MoveFollowR(Vector(0, 0, 4), Speed(12, ACCEL_TYPE.NONE, DECEL_TYPE.NONE))
  CAMERA:WaitMove()
  CAMERA:MoveFollowR(Vector(3, 0, -2), Speed(12, ACCEL_TYPE.NONE, DECEL_TYPE.NONE))
  CAMERA:WaitMove()
  CH("HERO"):DirTo(RotateTarget(90), Speed(350), ROT_TYPE.NEAR) --player turns to face camera
  CAMERA:MoveEye(Vector(-0.6, 0.5, 0), TimeSec(0.5), ACCEL_TYPE.HIGH, DECEL_TYPE.NONE) --camera zooms very quickly into player
  CAMERA:MoveTgt(Vector(-1.4, 0.5, 0), TimeSec(0.5), ACCEL_TYPE.HIGH, DECEL_TYPE.NONE)
  CAMERA:WaitMove()
  TASK:Regist(subEveCamShake, {0.05})                           --camera shakes
  SOUND:PlaySe(SymSnd("SE_EVT_HIT_DOKKORAA"), Volume(256))      --impact sound
  CH("HERO"):SetMotion(SymMot("DAMAGE"), LOOP.OFF)              --player is knocked back
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.DAMAGE)
  TASK:Sleep(TimeSec(0.7))
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.ANGRY)               --display face on player model (angry)
  CH("HERO"):SetMotion(SymMot("ATTACK_ROUND"), LOOP.OFF)        --player pushes camera (ATTACK, ATTACK_ROUND)
  TASK:Sleep(TimeSec(0.15))
  SOUND:PlaySe(SymSnd("SE_EVT_HIT_DOKKORAA"), Volume(256))      --impact sound
  CAMERA:MoveEye(Vector(5, 3, 0.5), TimeSec(0.5), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW)
  CAMERA:MoveTgt(Vector(-1.5, 0, -0.3), TimeSec(0.5), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW)
  TASK:Sleep(TimeSec(0.5))
  CH("HERO"):SetMotion(SymMot("WAIT02"), LOOP.ON)
  CH("HERO"):DirTo(CH("PARTNER"), Speed(350), ROT_TYPE.NEAR)    --hero turns to face partner
  CH("HERO"):WaitRotate()
  TASK:Sleep(TimeSec(0.2))
  
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_ANGRY_02"), Volume(256))     --play "angry sound"
  CH("HERO"):SetManpu("MP_ANGRY_LP")
  WINDOW:DrawFace(20 ,88, SymAct("HERO"), FACE_TYPE.ANGRY)      --display player portrait (angry)  
  WINDOW:Talk(SymAct("HERO"), -1613972062)                      --player speaks ("Hey! <pause> Watch where you're swingin' that thing!")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.CATCHBREATH)      --display face on partner model (catchbreath, concerned)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.CATCHBREATH) --display partner portrait (catchbreath, concerned)
  WINDOW:Talk(SymAct("PARTNER"), -1613971806)                   --partner speaks ("Oh, sorry!")
  WINDOW:KeyWait()
  
  WINDOW:CloseMessage()                                         --remove text box and face from screen
  WINDOW:RemoveFace()
  CH("HERO"):ResetManpu()
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --display face on player model (normal)
  TASK:Sleep(TimeSec(0.8))
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)           --display face on partner model (normal)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.NORMAL) --display partner portrait (normal)
  WINDOW:Talk(SymAct("PARTNER"), -1613971550)                   --partner speaks ("So, is there anything else?")
  WINDOW:KeyWait()

  WINDOW:DrawFace(20 ,88, SymAct("HERO"), FACE_TYPE.NORMAL)     --display player portrait (normal)  
  WINDOW:Talk(SymAct("HERO"), -1613971294)                      --player speaks ("No.  This is about it.")
  WINDOW:KeyWait()
  
  TASK:Regist(subEveDoubleJump, {CH("PARTNER")})                --partner plays jumping anim (non-blocking)
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.GLADNESS)         --display face on partner model (gladness)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.GLADNESS) --display partner portrait (gladness)
  WINDOW:Talk(SymAct("PARTNER"), -1613971038)                   --partner speaks ("Still, this great! <pause> Just imagine where we could go from here!")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)            --display face on partner model (think)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)  --display partner portrait (think)
  WINDOW:Talk(SymAct("PARTNER"), -1613970782)                   --partner speaks ("... <pause> But why is everything so blurry?")
  WINDOW:KeyWait()
  
  WINDOW:DrawFace(20 ,88, SymAct("HERO"), FACE_TYPE.NORMAL)     --display player portrait (normal)  
  WINDOW:Talk(SymAct("HERO"), -1613970526)                      --player speaks ("Oh, we're being recorded streamed off a 3DS, not from Citra.")
  WINDOW:KeyWait()
  
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)  --display partner portrait (think)
  WINDOW:Talk(SymAct("PARTNER"), -1613970270)                   --partner speaks ("Who?")
  WINDOW:KeyWait()
  
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.THINK)               --display face on player model (think)
  WINDOW:DrawFace(20 ,88, SymAct("HERO"), FACE_TYPE.THINK)      --display player portrait (think)  
  WINDOW:Talk(SymAct("HERO"), -1613970014)                      --player speaks ("Uh, that's a good question.  I...")
  WINDOW:KeyWait()  
  
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --display face on partner model (think)
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)           --display face on partner model (think)
  WINDOW:RemoveFace()

  
  WINDOW:Talk(SymAct("NOKOTCHI"), 781159719)                    --from original cutscene
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_NOTICE_LOW_02"), Volume(256))
  CH("PARTNER"):SetManpu("MP_EXCLAMATION")
  CH("HERO"):SetManpu("MP_EXCLAMATION")
  WINDOW:CloseMessage()
  CH("PARTNER"):WaitManpu()
  CH("PARTNER"):DirTo(RotateTarget(0), Speed(350), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(0.1))
  CH("HERO"):DirTo(RotateTarget(0), Speed(350), ROT_TYPE.NEAR)
  CH("HERO"):WaitRotate()
  TASK:Regist(subEveJump, {
    CH("PARTNER")
  })
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.NORMAL)
  WINDOW:SwitchTalk({PARTNER_0 = -1458073112, PARTNER_1 = -1341349719})
  WINDOW:CloseMessage()
  CH("PARTNER"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)
  CH("PARTNER"):WaitRotate()
  CH("HERO"):DirTo(CH("PARTNER"), Speed(350), ROT_TYPE.NEAR)
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)
  WINDOW:SwitchTalk({PARTNER_0 = -646808443, PARTNER_1 = -1066840636})
  
  WINDOW:DrawFace(20 ,88, SymAct("HERO"), FACE_TYPE.NORMAL)     --display player portrait (normal)  
  WINDOW:Talk(SymAct("HERO"), -1613969758)                      --player speaks ("Alright, looks like we better get back to the normal game...")
  
  WINDOW:CloseMessage()
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  CAMERA:MoveToHero(Speed(4, ACCEL_TYPE.NONE, DECEL_TYPE.HIGH))
  CAMERA:WaitMove()
  FLAG.SceneFlag = CONST.FL_SC_01_FIRST
  FLAG.SCENARIOFLAG = CONST.M04_TSUGINOASA_END
  FLAG.MapFlags = CONST.MAP_EVENT
  FLAG.FreePlay = CONST.FLAG_TRUE
  FLAG.TrigNextEvent = CONST.FLAG_FALSE
  SYSTEM:NextEntry(KEEP_PLACEMENT.ON)
end
function main04_tsuginoasa01_end()
end
function groundEnd()
end
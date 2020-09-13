--====PMD 3 Cutscene Demo====--
--MIT License
--Copyright (c) 2019 EddyK28

dofile("script/include/inc_all.lua")
dofile("script/include/inc_event.lua")

--Replacement talk function. Replaces spaces with chars that actually render spaces
local function WINDOW_Talk(ch, str)
  WINDOW:Talk(ch, str:gsub(" ","쐃"))
end

--Additional neck rotation function, takes yaw, pitch and roll angles directly
CHARA_OBJ.SetNeckRot3 = function(self, yaw, pitch, roll, speed)
  self:SetNeckRot(RotateTarget(yaw),RotateTarget(pitch),RotateTarget(roll), speed)
end

--Fade the fog from one color to another
local function fogFadeColor(st,nd,speed,nr,fr)
  speed = speed/1000
  local difr,difg,difb,difa = (nd.r-st.r)*speed,(nd.g-st.g)*speed,(nd.b-st.b)*speed,(nd.a-st.a)*speed
  while math.abs(st.r - nd.r) > speed/2 do
    st.r = st.r + difr
    st.g = st.g + difg
    st.b = st.b + difb
    st.a = st.a + difa
    MAP:SetFog(nr, fr, st)
    TASK:Sleep(TimeSec(1, TIME_TYPE.FRAME))
  end
end

--Fade the fog from one distance to another
local function fogFadeDist(color,stNr,stFr,ndNr,ndFr,speed)
  speed = speed/1000
  local difNr,difFr = (ndNr-stNr)*speed,(ndFr-stFr)*speed
  while math.abs(stNr - ndNr) > speed/2 do
    stNr = stNr + difNr
    stFr = stFr + difFr
    MAP:SetFog(stNr, stFr, color)
    TASK:Sleep(TimeSec(1, TIME_TYPE.FRAME))
  end
end

--Camera Shake Event function
local function subEveCamShake(amt)
  CAMERA:SetShake(Vector2(amt, amt), TimeSec(1, TIME_TYPE.FRAME))
  TASK:Sleep(TimeSec(0.2))
  CAMERA:SetShake(Vector2(0, 0), TimeSec(0))
  TASK:Sleep(TimeSec(0.5))
end

--Delayed shocked effect
local function subEveShockDelay(chara,delay,dirTgt)
  TASK:Sleep(TimeSec(delay))                                    --slight time delay
  TASK:Regist(subEveJumpSurprise, {chara})                      --play shocked anim (non-blocking)
  chara:SetManpu("MP_SHOCK_R")                                  --display "shocked effect"
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_SHOCK_02"), Volume(256))     --play "shocked" sound
  chara:SetFacialMotion(FACIAL_MOTION.SURPRISE)                 --display face on model (SURPRISE)
  chara:DirTo(dirTgt, Speed(350), ROT_TYPE.NEAR)
end

--Change face and display portrait after a delay with optional button wait
local function subEveFaceDelay(charaS,delay,face,portrait,px,py,wait)
  wait = wait or false
  TASK:Sleep(TimeSec(delay))
  while wait and not PAD:Data("A|B|L") do TASK:Sleep(TimeSec(0.01)) end
  CH(charaS):SetFacialMotion(face)
  WINDOW:DrawFace(px, py, SymAct(charaS), portrait)
end

--Delayed character removal (to let char tasks finish)
local function subEveRemoveCharDelay(delay, chars)
  TASK:Sleep(TimeSec(delay))
  for i,ch in ipairs(chars) do
    CHARA:DynamicRemove(ch)
  end
end

--Argument Loops
local taskExciteTalkLoop = function(chara)
  function TaskL.Loop()
    chara:SetManpu("MP_SPREE_LP")
    chara:SetMotion(SymMot("SPEAK"), LOOP.OFF)
    chara:WaitPlayMotion()
    chara:SetMotion(SymMot("WAIT02"), LOOP.ON)
    TASK:Sleep(TimeSec(1))
    chara:ResetManpu()
    TASK:Sleep(TimeSec(0.5))
    TASK:Sleep(TimeSec(2))
  end
end
local taskAngryLoop = function(chara)
  function TaskL.Loop()
    chara:SetFacialMotion(FACIAL_MOTION.ANGRY)
    chara:SetMotion(SymMot("SPEAK"), LOOP.OFF)
    chara:WaitPlayMotion()
    chara:SetMotion(SymMot("WAIT02"), LOOP.ON)
    TASK:Sleep(TimeSec(0.75))
    chara:SetManpu("MP_ANGRY_LP")
    chara:SetFacialMotion(FACIAL_MOTION.ANGRY)
    subEveDoubleJump(chara)
    TASK:Sleep(TimeSec(2))
    chara:ResetManpu()
    TASK:Sleep(TimeSec(1.5))
  end
end
local taskTalkWalkLoop = function(chara)
  function TaskL.Loop()
    chara:SetManpu("MP_LAUGH_LP")
    chara:SetMotion(SymMot("WALK"), LOOP.ON)
    chara:SetMotionRaito(Raito(2))
    TASK:Sleep(TimeSec(2))
    chara:ResetManpu()
    chara:SetMotion(SymMot("WAIT02"), LOOP.ON)
    TASK:Sleep(TimeSec(1.5))
  end
end

--Party Loops
local taskPartyTurnTalkLoop = function(chara,chA,chB)
  function TaskL.Loop()
    chara:DirTo(chA, Speed(120), ROT_TYPE.NEAR)
    chara:WaitRotate()
    chara:SetManpu("MP_LAUGH_LP")
    chara:SetMotion(SymMot("SPEAK"), LOOP.ON)
    TASK:Sleep(TimeSec(1.5))
    chara:SetMotion(SymMot("WAIT02"), LOOP.ON)
    chara:ResetManpu()
    TASK:Sleep(TimeSec(0.5))

    chara:DirTo(chB, Speed(120), ROT_TYPE.NEAR)
    chara:WaitRotate()
    chara:SetManpu("MP_LAUGH_LP")
    chara:SetMotion(SymMot("SPEAK"), LOOP.ON)
    TASK:Sleep(TimeSec(1.5))
    chara:SetMotion(SymMot("WAIT02"), LOOP.ON)
    chara:ResetManpu()
    TASK:Sleep(TimeSec(0.5))
  end
end
local taskPartyCelebrateLoop = function(chara,delay)
  function TaskL.Loop()
    chara:SetManpu("MP_SPREE_LP")
    chara:SetMotion(SymMot("SPEAK"), LOOP.OFF)
    chara:WaitPlayMotion()
    chara:SetMotion(SymMot("WAIT00"), LOOP.ON)
    TASK:Sleep(TimeSec(delay))
    chara:ResetManpu()
    TASK:Sleep(TimeSec(0.5))
    TASK:Sleep(TimeSec(delay))
  end
end

local function taskMsgClear()
  WINDOW:KeyWait()
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
end

local function taskDelayRun(func, group, delay,...)
  TASK:Sleep(TimeSec(delay))
  TASK:Regist(Group(group), func, {...})
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
  CAMERA:SetEye(Vector(3.7, 3.2, 2.7))
  CAMERA:SetTgt(Vector(-0.7, 0 , -1.3))

  GROUND:SetPokemonWarehouseHeroName("Orus")                        --Set the characters' names (instead of renaming them in the save)
  GROUND:SetPokemonWarehousePartnerName("Laurenna")                 --  Although, the save probably has the names by this point

  CHARA:DynamicLoad("Virizion", "BIRIJION")                         --add characters now to avoid pop-in
  CHARA:DynamicLoad("Dunsparce", "NOKOTCHI")                        --(may not be needed)
  CHARA:DynamicLoad("Emolga", "EMONGA")
  CH("Virizion"):SetPosition(Vector(0, 0, 4))
  CH("Dunsparce"):SetPosition(Vector(0, 0, 4))                      --move characters outside house
  CH("Emolga"):SetPosition(Vector(0, 0, 4))

  --<Prep Main Duo>--
  CH("PARTNER"):SetDir(RotateTarget(45))
  CH("PARTNER"):SetMotion(SymMot("EV001_SLEEP01"), LOOP.ON, TimeSec(0)) --play sleeping animation in a loop on Laurenna
  CH("HERO"):SetPosition(Vector(-0.3, 0, 2))                        --move Orus to near house doorway  (0,0 = center)
  TASK:Sleep(TimeSec(0.5))

  --<Fade In>--
  SCREEN_A:FadeIn(TimeSec(0.5), true)
  subEveFadeAfterTime()

  --<Orus walks up to bed and turns to Laurenna>--
  CH("HERO"):WalkTo(Vector2(-0.6, -0.9), Speed(2))                  
  CH("HERO"):WaitMove()
  CH("HERO"):DirTo(CH("PARTNER"), Speed(350), ROT_TYPE.NEAR)

  --<Orus attempts to wake Laurenna>--
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                  --normal face 
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)         --normal portrait
  WINDOW_Talk(SymAct("HERO"), "Hey [partner]!")
  WINDOW:KeyWait()

  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()

  --<Laurenna is still sleeping>--
  TASK:Sleep(TimeSec(0.2))
  CH("PARTNER"):SetManpu("MP_SLEEP_LP")                             --emit "zzz" manpu
  SOUND:PlaySe(SymSnd("SE_EVT_ZZZ"), Volume(128))                   --play sleeping sfx
  TASK:Sleep(TimeSec(1))
  CH("PARTNER"):ResetManpu()                                        --wait a little, then remove it (this manpu loops)
  SOUND:StopSe(SymSnd("SE_EVT_ZZZ"))                                --and stop the sound (it's too long)
  TASK:Sleep(TimeSec(0.2))

  --<Orus tries again, Laurenna wakes with a start>--
  SOUND:PlaySe(SymSnd("SE_EVT_JUMP_02"), Volume(128))               --play "jump" sfx
  CH("HERO"):SetManpu("MP_SPREE_LP")                                --show "excited" manpu
  TASK:Regist(subEveDoubleJump, {CH("HERO")})                       --play jumping anim (non-blocking)
  CH("HERO"):SetMotion(SymMot("WAIT00"), LOOP.ON)                   --play exaggerated idle (kinda dance-y)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.GLADNESS)                --gladness face
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.GLADNESS)       --gladness portrait
  TASK:Regist(subEveShockDelay, {CH("PARTNER"),0.3,CH("HERO")})     --delayed shocked awakening for Laurenna
  WINDOW_Talk(SymAct("HERO"), "LAURENNA![K] Time to get up sleepy head!")--Orus speaks (there's no directive for all caps name)
  WINDOW:KeyWait()

  --<Orus announces new cutscene features>--
  CH("HERO"):ResetManpu()
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.HAPPY)                   --display face on player model (happy)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.HAPPY)          --display player portrait (happy)
  WINDOW_Talk(SymAct("HERO"), "Come on, you can't sleep the whole day away.")--Orus speaks
  WINDOW:KeyWait()


  SOUND:PlaySe(SymSnd("SE_EVT_JUMP_02"), Volume(128))               --play "jump" sfx
  CH("HERO"):SetManpu("MP_SPREE_LP")                                --
  TASK:Regist(subEveDoubleJump, {CH("HERO")})                       --Orus plays jumping anim (non-blocking)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.GLADNESS)                --display face on player model (gladness)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.GLADNESS)       --display player portrait (gladness)
  WINDOW_Talk(SymAct("HERO"), "We have a bunch of new cutscene features\nto check out!")--Orus speaks
  WINDOW:KeyWait()

  CH("HERO"):ResetManpu()
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_QUESTION_01"), Volume(200))      --play "question mark" sound
  CH("PARTNER"):SetNeckRot3(0,0,10, TimeSec(0.2))                   --"confused head lean"
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)                --question/think partner face
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)      --question/think partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Oh?  Like what?")                 --Laurenna speaks
  WINDOW:KeyWait()

  --<Orus introduces spline paths>--
  CH("PARTNER"):ResetNeckRot(TimeSec(0.2))                          --"unlean" head
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)               --normal partner face
  CH("HERO"):SetMotion(SymMot("WAIT02"), LOOP.ON)                   --return to normal idle for Orus
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                  --normal player face
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)         --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "Well, we don't have to walk in just straight\nlines anymore.")--Orus speaks
  WINDOW:KeyWait()

  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --<Orus gives spline path demo>--
  CAMERA:MoveTgt(Vector(-0.7, 0, -0.5), TimeSec(1.5), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)    --unfortunately cameras can't use spline paths
  CAMERA:MoveEye(Vector(4.8, 3.2, 3.7), TimeSec(1.5), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CH("HERO"):WalkTo(SplinePath(Vector2(0,-0.6), Vector2(0.2,0), Vector2(-0.2,0.6), Vector2(-1.5,0.2)), Speed(2))
  CH("HERO"):WaitMove()
  CH("HERO"):DirTo(CH("PARTNER"), Speed(350), ROT_TYPE.NEAR)        --Orus turns to face Laurenna
  CH("PARTNER"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)        --Laurenna turns to face Orus

  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)               --display face on partner model (normal)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.NORMAL)     --display partner portrait (normal)
  WINDOW_Talk(SymAct("PARTNER"), "Nice.")                           --Laurenna speaks
  WINDOW:KeyWait()

  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()

  --<Laurenna walks along spline path to Orus>--
  CH("PARTNER"):WalkTo(SplinePath(Vector2(0,-0.6), Vector2(0,0), Vector2(-1.5,-0.8)), Speed(2))
  CH("PARTNER"):WaitMove()
  CH("HERO"):DirTo(CH("PARTNER"), Speed(350), ROT_TYPE.NEAR)        --Orus turns to face Laurenna
  CH("PARTNER"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)        --Laurenna turns to face Orus

  --<General excitement of new HD-ness>--
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.NORMAL)     --display partner portrait (normal)
  --sadly inline face changes happen at the beginning of the dialog, not when they are hit, so use a time delay instead
  TASK:Regist(subEveFaceDelay, {"PARTNER",0.6,FACIAL_MOTION.HAPPY,FACE_TYPE.HAPPY,324, 88,true})
  WINDOW_Talk(SymAct("PARTNER"), "I just realized,[K] we're not blurry anymore!")--Laurenna speaks
  WINDOW:KeyWait()

  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)               --normal partner face
  --CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                --normal player face
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)         --normal player portrait
  TASK:Regist(subEveFaceDelay, {"HERO",1.6,FACIAL_MOTION.HAPPY,FACE_TYPE.HAPPY,20, 88,true})
  WINDOW_Talk(SymAct("HERO"), "Yeah, we're being recorded from Citra this\ntime.  [K]In HD!")--Orus speaks
  WINDOW:KeyWait()

  --<...but confusion over "Citra">--
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                  --normal player face
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)                --thinking partner face
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)      --thinking partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "I still don't know who that is.") --Laurenna speaks
  WINDOW:KeyWait()

  CH("HERO"):SetManpu("MP_SWEAT_L_AL")                              --sweat drop on Orus
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_SWEAT"), Volume(256))            --corresponding sound
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.THINK)                   --thinking player face
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.THINK)          --thinking player portrait
  WINDOW_Talk(SymAct("HERO"), "I ...  [K]I don't either.")          --Orus speaks
  WINDOW:KeyWait()

  --<Awkward silence w/head motion>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  --TASK:Sleep(TimeSec(2.5)) 
  CH("PARTNER"):SetNeckRot3(15,0,0, TimeSec(1))
  TASK:Sleep(TimeSec(0.3))
  CH("HERO"):SetNeckRot3(15,0,0, TimeSec(1))
  TASK:Sleep(TimeSec(0.6))
  CH("PARTNER"):SetNeckRot3(-15,0,0, TimeSec(2))
  TASK:Sleep(TimeSec(0.3))
  CH("HERO"):SetNeckRot3(-15,0,0, TimeSec(2))
  TASK:Sleep(TimeSec(1.6))
  CH("PARTNER"):ResetNeckRot(TimeSec(1)) 
  CH("HERO"):ResetNeckRot(TimeSec(1))
  TASK:Sleep(TimeSec(1.6))

  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)               --display face on partner model (normal)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.NORMAL)     --display partner portrait (normal)
  WINDOW_Talk(SymAct("PARTNER"), "So, what else do we have?")       --Laurenna speaks
  WINDOW:KeyWait()

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                  --display face on player model (normal)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)         --display player portrait (normal)
  WINDOW_Talk(SymAct("HERO"), "Well, we can change how big we are.")--Orus speaks
  WINDOW:KeyWait()

  --<clear screen and scale Orus to 120%>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  CH("HERO"):ChangeScale(Scale(1.2, 1.2, 1.2), TimeSec(1))
  TASK:Sleep(TimeSec(1))

  --CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                --display face on player model (normal)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)         --display player portrait (normal)
  WINDOW_Talk(SymAct("HERO"), "But please don't go crazy with this one.")--Orus speaks
  WINDOW:KeyWait()

  --<clear screen and scale Laurenna to 80%>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  CH("PARTNER"):ChangeScale(Scale(0.8, 0.8, 0.8), TimeSec(1))       --scale Laurenna to 80%
  TASK:Sleep(TimeSec(0.5))
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)                --happy partner face
  TASK:Sleep(TimeSec(1))

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.HAPPY)                   --happy player face
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.HAPPY)          --happy player portrait
  WINDOW_Talk(SymAct("HERO"), "Okay, now that's just cute.")        --Orus speaks
  WINDOW:KeyWait()

  --<clear screen and wait a moment>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  TASK:Sleep(TimeSec(0.75))

  --CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)             --normal partner face
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                  --normal player face
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)         --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "And we can change colors.")          --Orus speaks
  WINDOW:KeyWait()

  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)               --normal partner face
  WINDOW:CloseMessage()                                             --remove text box and face from screen
  WINDOW:RemoveFace()
  CH("HERO"):ChangeColor(Color(0.5, 0.5, 0.5, 1), TimeSec(1))       --set color multiply
  TASK:Sleep(TimeSec(1.5))

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                  --normal player face
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)         --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "It's no palette swap, but at least it's something.")--Orus speaks
  WINDOW:KeyWait()

  --<clear screen, set partner color>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  CH("PARTNER"):ChangeColor(Color(0.7, 0.8, 1, 1), TimeSec(1))      --set color multiply
  CH("PARTNER"):ChangeAddColor(Color(0, 0, 2, 1), TimeSec(1))       --set color addition
  TASK:Sleep(TimeSec(1.5))

  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)                --happy partner face
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)      --happy partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Hehe. Look, I'm an ice snake.")   --Laurenna speaks
  WINDOW:KeyWait()
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --<reset Orus>--
  CH("HERO"):ChangeScale(Scale(1.1, 1.1, 1.1), TimeSec(1))          --"reset" scale (Keep Orus slightly larger)
  CH("HERO"):ChangeColor(Color(1, 1, 1, 1), TimeSec(1))             --reset color multiply
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                  --normal player face
  TASK:Sleep(TimeSec(0.5))

  --<reset Laurenna>--
  CH("PARTNER"):ChangeScale(Scale(1, 1, 1), TimeSec(1))             --reset scale
  CH("PARTNER"):ChangeColor(Color(1, 1, 1, 1), TimeSec(1))          --reset color multiply
  CH("PARTNER"):ChangeAddColor(Color(0, 0, 0, 1), TimeSec(1))       --reset color addition
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)               --normal partner face 
  TASK:Sleep(TimeSec(1))


  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)         --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "We can also play background music.") --Orus speaks
  WINDOW:KeyWait()

  --<clear screen, fade in background music>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  SOUND:FadeInBgm(SymSnd("BGM_EVE_ENDING_03"), TimeSec(0.75), Volume(256))--fade in over 0.75 sec
  TASK:Sleep(TimeSec(0.5))
  CH("PARTNER"):SetMotion(SymMot("WAIT00"), LOOP.ON)                --start "exaggerated" idle on Laurenna
  TASK:Sleep(TimeSec(2))


  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)                --display face on partner model (happy)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)      --display partner portrait (happy)
  WINDOW_Talk(SymAct("PARTNER"), "Oooh, I like this tune.")         --Laurenna speaks
  WINDOW:KeyWait()

  --<clear screen, fade down background music>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  SOUND:VolumeBgm(Volume(80), TimeSec(2))
  TASK:Sleep(TimeSec(1))
  CH("PARTNER"):SetMotion(SymMot("WAIT02"), LOOP.ON)                --return Laurenna to normal idle
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  TASK:Sleep(TimeSec(1))

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.HAPPY)                   --happy player face
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.HAPPY)          --happy player portrait
  WINDOW_Talk(SymAct("HERO"), "Even better, we can now add new characters\nto any scene!")--Orus speaks
  WINDOW:KeyWait()

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                  --normal player face
  SOUND:PlaySe(SymSnd("SE_EVT_JUMP_01"), Volume(128))
  TASK:Regist(subEveJump, {CH("PARTNER")})                          --Laurenna plays jumping anim (non-blocking)
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)                --happy partner face
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)      --happy partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Oh, Awesome!")                    --Laurenna speaks
  WINDOW:KeyWait()

  --<Orus invites in some friends>--
  CH("HERO"):DirTo(Vector2(0,3), Speed(350), ROT_TYPE.NEAR)         --Orus turns to door
  CH("HERO"):WaitRotate()
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)               --normal partner face 
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.GLADNESS)                --"gladness" (very happy) player face
  SOUND:PlaySe(SymSnd("SE_EVT_JUMP_02"), Volume(128))
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.GLADNESS)       --"gladness" player portrait
  TASK:Regist(subEveDoubleJump, {CH("HERO")})
  CH("HERO"):SetManpu("MP_SPREE_LP")                                --"happy lines" sprite
  WINDOW_Talk(SymAct("HERO"), "Hey guys, come on in!")              --Orus speaks
  WINDOW:KeyWait()

  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  CH("HERO"):ResetManpu()

  --<camera zooms out>--
  CAMERA:MoveTgt(Vector(-0.75, 0, -0.1), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:MoveEye(Vector(-4, 5.5, 5.5), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)

  --<Virizion, Dunsparce and Emolga walk in>--
  CH("Virizion"):WalkTo(SplinePath(Vector2(0,2.5), Vector2(1.1,1.3), Vector2(1,0.4), Vector2(0,0)), Speed(2))
  TASK:Sleep(TimeSec(1))
  CH("Dunsparce"):WalkTo(SplinePath(Vector2(0,2.5), Vector2(1.8,0.9), Vector2(1.5,-0.4), Vector2(-0.4,-0.9)), Speed(3))
  TASK:Sleep(TimeSec(1))
  CH("Emolga"):WalkTo(SplinePath(Vector2(0,2.5), Vector2(-0.2,1.2), Vector2(-0.5,1.0)), Speed(2))

  CH("Emolga"):WaitMove()
  CH("Emolga"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)         --Emolga turns to face Orus
  TASK:Sleep(TimeSec(0.12))
  CH("Dunsparce"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)      --Dunsparce turns to face Orus
  TASK:Sleep(TimeSec(0.1))
  CH("Virizion"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)       --Virizion turns to face Orus
  TASK:Sleep(TimeSec(0.1))
  CH("HERO"):DirTo(CH("Virizion"), Speed(350), ROT_TYPE.NEAR)       --Orus turns to face Virizion
  CH("PARTNER"):DirTo(CH("Virizion"), Speed(350), ROT_TYPE.NEAR)    --Laurenna turns to face Virizion

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.GLADNESS)                --very happy player face 
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.GLADNESS)       --very happy player portrait (gladness)
  CH("HERO"):SetManpu("MP_SPREE_LP")                                --excitedness sprite effect
  WINDOW_Talk(SymAct("HERO"), "Check it out guys!")                 --Orus speaks
  WINDOW:KeyWait()

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  CH("HERO"):ResetManpu()
  CH("Virizion"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --normal face on Virizion
  WINDOW:DrawFace(324, 88, SymAct("BIRIJION"), FACE_TYPE.NORMAL)    --normal Virizion portrait
  WINDOW_Talk(SymAct("BIRIJION"), "So this is one of those 'cutscenes'.")--Virizion speaks
  WINDOW:KeyWait()

  CH("Virizion"):SetFacialMotion(FACIAL_MOTION.HAPPY)               --happy face on Virizion
  WINDOW:DrawFace(324, 88, SymAct("BIRIJION"), FACE_TYPE.HAPPY)     --happy Virizion portrait
  WINDOW_Talk(SymAct("BIRIJION"), "Fascinating.")                   --Virizion speaks
  WINDOW:KeyWait()

  CH("Dunsparce"):SetFacialMotion(FACIAL_MOTION.NORMAL)             --normal face on Dunsparce
  WINDOW:DrawFace(324, 88, SymAct("NOKOTCHI"), FACE_TYPE.NORMAL)    --normal Dunsparce portrait
  WINDOW_Talk(SymAct("NOKOTCHI"), "It just looks like the inside of a house to me.")--Dunsparce speaks
  WINDOW:KeyWait()

  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_ANGRY_02"), Volume(256))         --play "angry sound"
  SOUND:StopBgm()
  SOUND:PlayBgm(SymSnd("BGM_EVE_NAZO_03"), Volume(100))             --change background music
  CH("Emolga"):SetManpu("MP_ANGRY_LP")
  CH("Emolga"):SetFacialMotion(FACIAL_MOTION.DECIDE)                --mild anger face on Emolga
  WINDOW:DrawFace(324, 88, SymAct("EMONGA"), FACE_TYPE.DECIDE)      --mild anger Emolga portrait
  WINDOW_Talk(SymAct("EMONGA"), "What?! You mean people are watching us?")--Emolga speaks
  WINDOW:KeyWait()

  SOUND:PlaySe(SymSnd("SE_EVT_BIYON"), Volume(256))
  CH("Emolga"):SetFacialMotion(FACIAL_MOTION.ANGRY)                 --angry face on Emolga
  WINDOW:DrawFace(324, 88, SymAct("EMONGA"), FACE_TYPE.ANGRY)       --angry Emolga portrait
  WINDOW_Talk(SymAct("EMONGA"), "Rude!")                            --Emolga speaks
  WINDOW:KeyWait()

  CH("Emolga"):ResetManpu()
  CH("Emolga"):SetFacialMotion(FACIAL_MOTION.DECIDE)                --mild anger face

  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_QUESTION_01"), Volume(100))
  CH("Dunsparce"):DirTo(CH("Emolga"), Speed(350), ROT_TYPE.NEAR)    --Dunsparce turns to face Emolga
  CH("Dunsparce"):SetFacialMotion(FACIAL_MOTION.THINK)              --thinking Dunsparce face
  WINDOW:DrawFace(324, 88, SymAct("NOKOTCHI"), FACE_TYPE.THINK)     --thinking Dunsparce portrait
  WINDOW_Talk(SymAct("NOKOTCHI"), "People?[K]  What people?")       --Dunsparce speaks
  WINDOW:KeyWait()

  CH("Emolga"):DirTo(Vector2(-4,5.5), Speed(350), ROT_TYPE.NEAR)    --Emolga turns to face camera
  CH("Emolga"):SetNeckRot(CAMERA:GetEye(), TimeSec(0.5))
  CH("Emolga"):SetFacialMotion(FACIAL_MOTION.DECIDE)                --mild anger face
  WINDOW:DrawFace(324, 88, SymAct("EMONGA"), FACE_TYPE.DECIDE)      --mild anger portrait
  WINDOW_Talk(SymAct("EMONGA"), "Right up there, on the other side of the screen.")--Emolga speaks
  WINDOW:KeyWait()

  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_ANGRY_02"), Volume(256))         --"angry sound"
  CH("Emolga"):SetManpu("MP_ANGRY_LP")                              --anger sprite
  CH("Emolga"):SetFacialMotion(FACIAL_MOTION.ANGRY)                 --angry face
  WINDOW:DrawFace(324, 88, SymAct("EMONGA"), FACE_TYPE.ANGRY)       --angry portrait
  WINDOW_Talk(SymAct("EMONGA"), "What's wrong with you?!")          --Emolga speaks
  WINDOW:KeyWait()

  CH("Dunsparce"):DirTo(Vector2(-4,5.5), Speed(350), ROT_TYPE.NEAR) --Dunsparce turns to face camera
  CH("Dunsparce"):SetNeckRot(CAMERA:GetEye(), TimeSec(0.5))
  CH("Dunsparce"):SetFacialMotion(FACIAL_MOTION.HAPPY)              --happy face on Dunsparce
  WINDOW:DrawFace(324, 88, SymAct("NOKOTCHI"), FACE_TYPE.HAPPY)     --happy Dunsparce portrait
  WINDOW_Talk(SymAct("NOKOTCHI"), "Oh, well... [K] Hi there.")      --Dunsparce speaks
  WINDOW:KeyWait()

  SOUND:PlaySe(SymSnd("SE_EVT_BIYON"), Volume(256))
  CH("Dunsparce"):ResetNeckRot(TimeSec(0.2))                        --Dunsparce looks back down
  CH("HERO"):DirTo(CH("Emolga"), Speed(350), ROT_TYPE.NEAR)         --Orus turns to face Emolga
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.ANGRY)                   --angry face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.ANGRY)          --angry player portrait
  WINDOW_Talk(SymAct("HERO"), "Emolga, that's the point!")          --Orus speaks
  WINDOW:KeyWait()

  CH("Emolga"):ResetManpu()
  CH("Emolga"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)
  CH("Emolga"):ResetNeckRot(TimeSec(0.2))                           --Emolga looks back down
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.DECIDE)                  --mild anger face
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.DECIDE)         --mild anger portrait
  WINDOW_Talk(SymAct("HERO"), "This is a cutscene!  It's made for people to\nwatch!")--Orus speaks
  WINDOW:KeyWait()

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  CH("Virizion"):DirTo(CH("Emolga"), Speed(350), ROT_TYPE.NEAR)     --Virizion turns to face Emolga
  CH("Virizion"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --normal face on Virizion
  WINDOW:DrawFace(324, 88, SymAct("BIRIJION"), FACE_TYPE.NORMAL)    --normal Virizion portrait
  WINDOW_Talk(SymAct("BIRIJION"), "He's right you know.")           --Virizion speaks
  WINDOW:KeyWait()

  CH("Dunsparce"):WalkTo(Vector2(-0.7,0.1), Speed(2))               --Dunsparce moves in

  SOUND:PlaySe(SymSnd("SE_EVT_BIYON"), Volume(256))
  CH("Emolga"):DirTo(CH("Virizion"), Speed(350), ROT_TYPE.NEAR)
  CH("Emolga"):SetFacialMotion(FACIAL_MOTION.DECIDE)                --mild anger face on Emolga
  WINDOW:DrawFace(324, 88, SymAct("EMONGA"), FACE_TYPE.DECIDE)      --mild anger portrait
  WINDOW_Talk(SymAct("EMONGA"), "I don't have to listen to you.")   --Emolga speaks
  WINDOW:KeyWait()

  CH("Dunsparce"):DirTo(CH("Emolga"), Speed(350), ROT_TYPE.NEAR)
  CH("Dunsparce"):SetFacialMotion(FACIAL_MOTION.NORMAL)             --normal face on Dunsparce
  WINDOW:DrawFace(324, 88, SymAct("NOKOTCHI"), FACE_TYPE.NORMAL)    --normal Dunsparce portrait
  WINDOW_Talk(SymAct("NOKOTCHI"), "But Emolga...")                  --Dunsparce speaks
  WINDOW:KeyWait()

  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()

  --<Trio starts arguing>--
  TASK:Regist(Group("argument"), taskExciteTalkLoop, {CH("Virizion")})
  TASK:Regist(Group("argument"), taskAngryLoop, {CH("Emolga")})
  TASK:Regist(Group("argument"), taskTalkWalkLoop, {CH("Dunsparce")})
  SOUND:PlaySe(SymSnd("SE_EVT_WAIWAI_LP"), Volume(180))

  --<camera pans to Orus and Laurenna>--
  TASK:Sleep(TimeSec(1))
  CAMERA:MoveTgt(Vector(-1.02, -0.37, -0.87), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:MoveEye(Vector(-3.99, 2.45, 2), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:WaitMove()

  CH("PARTNER"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)
  CH("HERO"):DirTo(CH("PARTNER"), Speed(350), ROT_TYPE.NEAR)    --Hero and partner turn to each other
  CH("HERO"):WaitRotate()                                       --wait for Orus to finish turning
  TASK:Sleep(TimeSec(0.5))
  CH("HERO"):SetManpu("MP_SWEAT_R_AL")                          --sweat drop on Orus
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_SWEAT"), Volume(256))        --corresponding sound
  CH("HERO"):SetNeckRot3(0,-15,0, TimeSec(0.2))                 --Orus lowers head
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.RELIEF)              --exasperated face on player
  WINDOW:DrawFace(20 ,88, SymAct("HERO"), FACE_TYPE.RELIEF)     --exasperated player portrait
  WINDOW_Talk(SymAct("HERO"), "Oh boy.  Maybe this was a bad idea...")--Orus speaks
  WINDOW:KeyWait()

  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()

  --<look over at the arguing trio and back>--
  TASK:Sleep(TimeSec(0.5))
  CAMERA:MoveTgt(Vector(-0.03, 0.23, 0.3), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:MoveEye(Vector(-4.12, 2.51, 2.05), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:WaitMove()
  TASK:Sleep(TimeSec(1))
  CAMERA:MoveTgt(Vector(-1.02, -0.37, -0.87), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:MoveEye(Vector(-3.99, 2.45, 2), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:WaitMove()
  TASK:Sleep(TimeSec(0.5))


  CH("HERO"):ResetNeckRot(TimeSec(0.2))                         --player raises head
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.RELIEF)              --exasperated face
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.RELIEF)     --exasperated player portrait
  WINDOW_Talk(SymAct("HERO"), "Well, I guess we'll just ...")   --Orus speaks
  WINDOW:KeyWait()

  --<clear screen and BGM>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  SOUND:StopBgm()

  --<add some more pokemon>--
  CHARA:DynamicLoad("Partymon01", "YOOTERII")   --Lillipup
  CHARA:DynamicLoad("Partymon02", "AAKEN")      --Archen
  CHARA:DynamicLoad("Partymon03", "DOKKORAA_1") --Timbur
  CHARA:DynamicLoad("Partymon04", "ZURUGGU")    --Scraggy
  CHARA:DynamicLoad("Partymon05", "BIKUTYINI")  --Victini
  CH("Partymon01"):SetPosition(Vector(0, 0, 4))
  CH("Partymon02"):SetPosition(Vector(0, 0, 4))
  CH("Partymon03"):SetPosition(Vector(0, 0, 4))
  CH("Partymon04"):SetPosition(Vector(0, 0, 4))
  CH("Partymon05"):SetPosition(Vector(0, 0, 4))

  --<Outside Mon calls in (party time)>--
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_NOTICE_LOW_02"), Volume(256))
  CH("PARTNER"):SetManpu("MP_EXCLAMATION")
  CH("HERO"):SetManpu("MP_EXCLAMATION")
  WINDOW_Talk(SymAct("???"), "Hey, are you all having a party in here?")
  TASK:Sleep(TimeSec(0.1))
  
  --<duo turns to door>--
  CH("PARTNER"):DirTo(Vector2(0, 3), Speed(350), ROT_TYPE.NEAR)
  CH("HERO"):DirTo(Vector2(0, 3), Speed(350), ROT_TYPE.NEAR)
  WINDOW:KeyWait()

  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()

  --<camera looks up>--
  CAMERA:MoveTgt(Vector(0, 2.8, 3.8), TimeSec(0.5), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW)
  CAMERA:MoveEye(Vector(0, 7.0, 9.5), TimeSec(0.5), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW)

  --<change background music>--
  SOUND:PlayBgm(SymSnd("BGM_EVE_COMICAL"), Volume(120))

  --<a bunch of Pokemon walk in and duo looks after them>--
  CH("Partymon01"):WalkTo(SplinePath(Vector2(0,2.5), Vector2(0.5, 0.9), Vector2(1, -.2)), Speed(3))
  TASK:Sleep(TimeSec(0.3))
  CH("PARTNER"):DirTo(Vector2(3, 0), Speed(50), ROT_TYPE.NEAR)
  CH("HERO"):DirTo(Vector2(3, 0), Speed(50), ROT_TYPE.NEAR)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.SURPRISE)                --Orus is shocked
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.SURPRISE)
  WINDOW:Talk(SymAct("HERO"), "Wa!")
  TASK:Regist(taskMsgClear)                                         --async message close
  CH("Partymon02"):WalkTo(SplinePath(Vector2(0,2.5), Vector2(0.5, 0.9)), Speed(3))
  TASK:Sleep(TimeSec(0.3))
  CH("Partymon03"):WalkTo(SplinePath(Vector2(0,2.5), Vector2(1.1, 1.8), Vector2(1.9, -0.6)), Speed(3))
  TASK:Sleep(TimeSec(0.3))
  CH("Partymon04"):WalkTo(SplinePath(Vector2(0,2.5), Vector2(1.1, 1.8), Vector2(2.3, 0.2)), Speed(3))
  TASK:Sleep(TimeSec(0.3))
  CH("Partymon05"):WalkTo(SplinePath(Vector2(0,2.5), Vector2(1.1, 1.8), Vector2(1.55, 0.7)), Speed(3))

  CH("PARTNER"):DirTo(Vector2(3, 0), Speed(10), ROT_TYPE.NEAR)
  CH("HERO"):DirTo(Vector2(3, 0), Speed(10), ROT_TYPE.NEAR)

  --<The "party" starts>--
  CH("Partymon02"):WaitMove()
  CH("Partymon02"):DirTo(CH("Virizion"), Speed(350), ROT_TYPE.NEAR)
  TASK:Regist(Group("party"), taskPartyTurnTalkLoop, {CH("Partymon02"),CH("Virizion"),CH("Emolga")})

  CH("Partymon05"):WaitMove()
  CH("Partymon05"):DirTo(CH("Partymon03"), Speed(350), ROT_TYPE.NEAR)
  CH("Partymon03"):DirTo(CH("Partymon05"), Speed(350), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(0.1))
  CH("Partymon04"):DirTo(CH("Partymon01"), Speed(350), ROT_TYPE.NEAR)
  CH("Partymon01"):DirTo(CH("Partymon04"), Speed(350), ROT_TYPE.NEAR)

  --start party tasks
  TASK:Regist(Group("party"), taskPartyCelebrateLoop, {CH("Partymon01"),1})
  CH("Partymon03"):SetMotion(SymMot("WAIT00"), LOOP.ON)
  TASK:Regist(Group("delay"), taskDelayRun, {taskPartyCelebrateLoop,"party",2,CH("Partymon03"),0.9})
  CH("Partymon05"):SetMotion(SymMot("WAIT00"), LOOP.ON)
  TASK:Regist(Group("delay"), taskDelayRun, {taskPartyCelebrateLoop,"party",4,CH("Partymon05"),0.7})
  CH("Partymon04"):SetMotion(SymMot("WAIT00"), LOOP.ON)
  TASK:Regist(Group("delay"), taskDelayRun, {taskPartyCelebrateLoop,"party",5,CH("Partymon04"),1.2})
  SOUND:PlaySe(SymSnd("SE_EVT_PARTY_02"), Volume(160))

  WINDOW:KeyWait()
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  CH("PARTNER"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)
  CH("HERO"):DirTo(CH("PARTNER"), Speed(350), ROT_TYPE.NEAR)    --Hero and partner turn to each other
  TASK:Sleep(TimeSec(1))

  CAMERA:MoveTgt(Vector(-1.02, -0.37, -0.87), TimeSec(3), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:MoveEye(Vector(-3.99, 2.45, 2), TimeSec(3), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  TASK:Sleep(TimeSec(1))

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.RELIEF)              --exasperated face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.RELIEF)     --exasperated player portrait
  WINDOW_Talk(SymAct("HERO"), "Urg...")                         --Orus speaks
  WINDOW:KeyWait()

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --normal face
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "Well,[K] this brings us nicely to our next\nfeature,[K] changing maps.")
  WINDOW:KeyWait()

  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "So let's get out of here.")
  WINDOW:KeyWait()

  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()

  --<Camera starts moving to door (continues through below events)>--
  CAMERA:MoveTgt(Vector(-2.94, 3.98, 1.48), TimeSec(3), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:MoveEye(Vector(-5.90, 7.76, 2.88), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  
  --<Laurenna nods>--
  TASK:Sleep(TimeSec(0.2))
  CH("PARTNER"):SetNeckRot3(0,-20,0, TimeSec(0.15))
  TASK:Sleep(TimeSec(0.15))
  CH("PARTNER"):ResetNeckRot(TimeSec(0.2))
  TASK:Sleep(TimeSec(0.2)) 
  
  --<Orus turns to door>--
  CH("HERO"):DirTo(Vector2(0,3), Speed(350), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(0.4)) 
  
  --<duo walks out door (wait for completion)>--
  CH("HERO"):WalkTo(SplinePath(Vector2(-1.2,1.3), Vector2(-0.5, 2), Vector2(0,2.5), Vector2(0,4)), Speed(2))
  TASK:Sleep(TimeSec(0.3))
  CH("PARTNER"):WalkTo(SplinePath(Vector2(-1.2,1.3), Vector2(-0.5, 2), Vector2(0,2.5), Vector2(0,4)), Speed(2.65))
  CH("PARTNER"):WaitMove()
  
  --<Fade out>--
  TASK:Sleep(TimeSec(1.6))
  SCREEN_A:FadeOut(TimeSec(0.75), true)                         --screen
  SOUND:FadeOutBgm(TimeSec(0.75))                               --BGM
  SOUND:FadeOutSe(SymSnd("SE_EVT_WAIWAI_LP"), TimeSec(0.75))    --Arguing sound
  SOUND:FadeOutSe(SymSnd("SE_EVT_PARTY_02"), TimeSec(0.75))     --Party sound
  
  --<unload map>--
  MAP:DynamicUnloadGroundMap()
  TASK:Sleep(TimeSec(0))
  TASK:Sleep(TimeSec(0))    --TODO: are these needed?

  --<Remove dynamic chars, move normal ones>--
  TASK:ExitNotifyTasks(Group("argument"))
  TASK:Regist(subEveRemoveCharDelay, {5,{"Virizion","Dunsparce","Emolga"}})

  TASK:ExitNotifyTasks(Group("party"))
  TASK:Regist(subEveRemoveCharDelay, {5,{"Partymon01","Partymon02","Partymon03","Partymon04","Partymon05"}})
  
  TASK:Sleep(TimeSec(0.5))
  
  CAMERA:SetEye(Vector(27.51, 3.13, 22.62))
  CAMERA:SetTgt(Vector(23.31, 0.42, 22.79))
  
  --<Position chars pre-load so collision doesn't interfere with motion>--
  CH("HERO"):SetPosition(Vector(21, 0, 23))
  CH("PARTNER"):SetPosition(Vector(23, 0, 23))
  CH("HERO"):DirTo(CH("PARTNER"), Speed(600), ROT_TYPE.NEAR)
  CH("PARTNER"):DirTo(Vector2(27.51, 22.62), Speed(600), ROT_TYPE.NEAR)
  
  TASK:Sleep(TimeSec(0))
  TASK:Sleep(TimeSec(0))
  
  --<load new map, set fog>--
  MAP:DynamicLoadGroundMap(SymMap("D_DANGAI_3"))
  TASK:Sleep(TimeSec(0))
  TASK:Sleep(TimeSec(0))
  
  MAP:ChangeProjectionShadowAlpha(0, TimeSec(0))                --hide cloud projections
  MAP:ChangeLightColor(Color(0.8, 0.8, 0.8, 1), TimeSec(0))     --darken ground to match fog
  MAP:SetFog(0, 6, Color(0.95, 0.95, 0.95, 1))                  --add near white fog, very thick 
  TASK:Sleep(TimeSec(1))

  --<Fade in>--
  SCREEN_A:FadeIn(TimeSec(0.75), true)
  SOUND:FadeInBgm(SymSnd("BGM_EVE_FUON_01"), TimeSec(0.75), Volume(160))
  
  --<Laurenna glances around>--
  CH("PARTNER"):SetNeckRot3(45,-5,0, TimeSec(0.5))
  TASK:Sleep(TimeSec(0.8))
  CH("PARTNER"):SetNeckRot3(-45,-5,0, TimeSec(1))
  TASK:Sleep(TimeSec(1.3))
  CH("PARTNER"):SetNeckRot3(0,10,-10, TimeSec(.5))
  
  --<Laurenna comments on fog>--
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)            --confused face on partner
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)  --confused partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "It's so foggy out here, I can't see anything.")
  WINDOW:KeyWait()
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --<Laurenna looks around further>--
  CH("PARTNER"):SetNeckRot3(35,0,0, TimeSec(0.5))
  CH("PARTNER"):DirTo(RotateOffs(30), Speed(50), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(0.8))
  CH("PARTNER"):SetNeckRot3(-35,0,0, TimeSec(1))
  CH("PARTNER"):DirTo(RotateOffs(-60), Speed(50), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(1.5))
  
  --<Orus walks up, camera re-centers on duo>--
  CH("HERO"):WalkTo(Vector2(22,23), Speed(0.6))
  CAMERA:MoveEye(Vector(22.60, 2.83, 27.65), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.HIGH)
  CAMERA:MoveTgt(Vector(22.53, 0.38, 23.29), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.HIGH)
  CH("PARTNER"):DirTo(CH("HERO"), Speed(200), ROT_TYPE.NEAR)
  CH("PARTNER"):ResetNeckRot(TimeSec(0.5)) 
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  TASK:Sleep(TimeSec(1.5))

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.THINK)               --normal face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.THINK)      --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "Hmm, this is oddly convenient.") --Orus speaks
  WINDOW:KeyWait()
  
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --normal face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "One of the new things we can do is control\nthe fog.")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)            --happy face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)  --happy partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Before you get rid of it,[K] let me try something.")
  WINDOW:KeyWait()
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.THINK)               --concerned face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.THINK)      --concerned player portrait
  WINDOW_Talk(SymAct("HERO"), "Sure, I guess so.")              --Orus speaks
  WINDOW:KeyWait()
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --<fog turns dark red>
  SOUND:FadeOutBgm(TimeSec(0.75))
  TASK:Sleep(TimeSec(0.5))
  SOUND:FadeInBgm(SymSnd("BGM_DUN_23"), TimeSec(0.75), Volume(160))
  fogFadeColor(Color(0.95, 0.95, 0.95, 1),Color(.7,.2,.2,1), 10, 0, 6) 
  
  --<camera jumps to "evil" closeup>--
  CAMERA:SetEye(Vector(21.90, 0.22, 24.24))
  CAMERA:SetTgt(Vector(25.04, 1.05, 20.44))
  
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.THINK)
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.ANGRY)            --"evil" face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.ANGRY)  --"evil" partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Now no-one can see the blood of my\nenemies when I DESTROY them!")
  WINDOW:KeyWait()
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  
  --<camera snaps back up>--
  TASK:Sleep(TimeSec(0.25))
  CAMERA:MoveEye(Vector(22.60, 2.83, 27.65), TimeSec(0.2), ACCEL_TYPE.HIGH, DECEL_TYPE.HIGH)
  CAMERA:MoveTgt(Vector(22.53, 0.38, 23.29), TimeSec(0.2), ACCEL_TYPE.HIGH, DECEL_TYPE.HIGH)
  
  SOUND:StopBgm()
  SOUND:PlayBgm(SymSnd("BGM_EVE_NAZO_01"), Volume(120))
  SOUND:PlaySe(SymSnd("SE_EVT_BIYON"), Volume(256))             --slight anger sound
  CH("HERO"):SetNeckRot3(0,-20,0, TimeSec(0.25))                --lean head down
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.DECIDE)              --mild anger face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.DECIDE)     --mild anger player portrait
  WINDOW_Talk(SymAct("HERO"), "NO. [K] Just NO.")               --Orus speaks
  WINDOW:KeyWait()
  
  CH("HERO"):ResetNeckRot(TimeSec(0.25))
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --normal face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.SPECIAL02)  --displeased player portrait
  WINDOW_Talk(SymAct("HERO"), "We're getting rid of the fog now.")--Orus speaks
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)           --normal face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.NORMAL) --normal partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Hehehe,[K] you know I'm just kidding.")  --Laurenna speaks
  WINDOW:KeyWait()
  
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.THINK)               --thinking/questioning face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.THINK)      --thinking/questioning player portrait
  WINDOW_Talk(SymAct("HERO"), "Right...")                       --Orus speaks
  WINDOW:KeyWait()
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --Move some objects so I can keep a "joke" I wrote before I knew how things would go
  GM("WARABED_01"):SetPosition(21.5, 0, 21)
  GM("WARABED_02"):SetPosition(23, 0, 21)
  
  --<Fog fades out>--
  MAP:ChangeProjectionShadowAlpha(1, TimeSec(1))
  MAP:ChangeLightColor(Color(1, 1, 1, 1), TimeSec(1))
  CAMERA:MoveEye(Vector(22.663, 5.041, 31.585), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  fogFadeDist(Color(.7,.2,.2,1),0,6,10,40,10)
  --MAP:ClearFog() --this would cause a visible jump (fog still in BG, and can't go back any more)
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)               --normal face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.SPECIAL02)  --neutral partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Wait a minute.[K]  This isn't Paradise.")
  WINDOW:KeyWait()
  
  CH("PARTNER"):DirTo(Vector2(23,21), Speed(250), ROT_TYPE.NEAR)--Laurenna turns to beds
  TASK:Sleep(TimeSec(0.2))
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_QUESTION_01"), Volume(256))
  CH("PARTNER"):SetManpu("MP_QUESTION")
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)            --confused face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)  --confused partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "And what are our beds doing out here?")  --Laurenna speaks
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)           --normal face on partner 
  CH("HERO"):DirTo(Vector2(21.5,21), Speed(250), ROT_TYPE.NEAR) --Orus turns to beds
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --normal face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "Oh.[K]  Items seem to stay behind when the map\nis changed from Lua.")--Orus speaks
  WINDOW:KeyWait()
  
  --<Duo turns back to each other>--
  CH("PARTNER"):DirTo(CH("HERO"), Speed(250), ROT_TYPE.NEAR)
  CH("HERO"):DirTo(CH("PARTNER"), Speed(250), ROT_TYPE.NEAR)
  CH("HERO"):WaitRotate()
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "I think it's being worked on.")  --Orus speaks
  WINDOW:KeyWait()

  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --<Laurenna nods>--
  TASK:Sleep(TimeSec(0.2))
  CH("PARTNER"):SetNeckRot3(0,-20,0, TimeSec(0.15))
  TASK:Sleep(TimeSec(0.15))
  CH("PARTNER"):ResetNeckRot(TimeSec(0.2))
  TASK:Sleep(TimeSec(0.7))
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "And we can go wherever we want.  It doesn't\nhave to be Paradise.")
  WINDOW:KeyWait()
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "For example ...")                --Orus speaks
  WINDOW:KeyWait()
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --<fade out, in to town>--
  --  fade out screen/BGM
  SCREEN_A:FadeOut(TimeSec(0.5), true)
  SOUND:FadeOutBgm(TimeSec(0.5))
  
  --  unload map
  MAP:DynamicUnloadGroundMap()
  MAP:ClearFog()
  TASK:Sleep(TimeSec(0.25))
  
  --  move chars, cam and beds
  CH("HERO"):SetPosition(Vector(-3, -0.2, 1))
  CH("PARTNER"):SetPosition(Vector(-1.5, -0.2, 1))
  CH("HERO"):DirTo(CH("PARTNER"), Speed(600), ROT_TYPE.NEAR)
  CH("PARTNER"):DirTo(CH("HERO"), Speed(600), ROT_TYPE.NEAR)
  CAMERA:SetEye(Vector(-5.21, 6.96, 13.53))
  CAMERA:SetTgt(Vector(-4.10, 4.67,  9.23))
  GM("WARABED_01"):SetPosition(-3, 0, -1.8)
  GM("WARABED_02"):SetPosition(-1, 0, -1.8)
  
  --  load map
  MAP:DynamicLoadGroundMap(SymMap("TOWN_RIGHT"))
  TASK:Sleep(TimeSec(0.25))
  
  --  fade in screen/BGM
  SOUND:FadeInBgm(SymSnd("BGM_MAP_TOWN_01"), TimeSec(0.5), Volume(100))
  SCREEN_A:FadeIn(TimeSec(0.5), true)
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "We could go to town.")           --Orus speaks
  WINDOW:KeyWait()
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()

  --<slight pause, Laurenna looks around>
  TASK:Sleep(TimeSec(0.8))
  CH("PARTNER"):SetNeckRot3(45,-5,0, TimeSec(0.5))
  TASK:Sleep(TimeSec(0.8))
  CH("PARTNER"):SetNeckRot3(-45,-5,0, TimeSec(1))
  TASK:Sleep(TimeSec(1.3))
  CH("PARTNER"):ResetNeckRot(TimeSec(.5))
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)               --normal face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.SPECIAL02)  --neutral partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Where is everyone?  It feels like a ghost town.")
  WINDOW:KeyWait()
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  TASK:Sleep(TimeSec(0.8))                                      --slight pause
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)            --thinking face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)  --thinking partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "It's a bit unnerving.")       --Laurenna speaks
  WINDOW:KeyWait()
  
  SOUND:PlaySe(SymSnd("SE_EVT_BIYON"), Volume(256))             --slight anger sound
  CH("HERO"):SetManpu("CH_EXCLAMATION_RED")
  CH("HERO"):SetNeckRot3(0,-20,0, TimeSec(0.25))                --lean head down
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.DECIDE)              --mild anger face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.DECIDE)     --mild anger player portrait
  WINDOW_Talk(SymAct("HERO"), "Oh, and your blood red fog was perfectly fine?")
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.CATCHBREATH)      --stunned face on partner 
  WINDOW:KeyWait()
  
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.CATCHBREATH)--stunned partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Well, I ...")                     --Laurenna speaks
  CH("HERO"):ResetNeckRot(TimeSec(0.25))
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                  --normal face on player
  WINDOW:KeyWait()
 
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)         --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "But yes, you're right.[K]  So...")   --Orus speaks
  WINDOW:KeyWait()
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --<pokemon pop in one by one>
  CHARA:DynamicLoad("Townmon01", "KOJOFUU")         --Mienfoo
  CH("Townmon01"):SetPosition(Vector(-6, 0, -4.5))  --in cafe/inn
  TASK:Sleep(TimeSec(0.6))
  CHARA:DynamicLoad("Townmon02", "KAKUREON")        --Kecleon
  CH("Townmon02"):SetPosition(Vector(1, 0, -2.1))   --in Shop
  CH("Townmon02"):DirTo(RotateTarget(-40), Speed(600), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(0.6))
  CHARA:DynamicLoad("Townmon03", "RAMUPARUDO")      --Rampardos
  CH("Townmon03"):SetPosition(Vector(0.75, 0, 4.8)) --in Shop
  CH("Townmon03"):DirTo(RotateTarget(-40), Speed(600), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(0.4))
  CHARA:DynamicLoad("Townmon04", "CHIRACHIINO")     --Cinccino
  CH("Townmon04"):SetPosition(Vector(-5.1, 0, 5.2)) --in Shop
  CH("Townmon04"):DirTo(RotateTarget(50), Speed(600), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(0.4))
  CHARA:DynamicLoad("Townmon05", "TABUNNE")         --Audino
  CH("Townmon05"):SetPosition(Vector(2.5, 0, 0.5))  --near Kecleon shop
  CH("Townmon05"):DirTo(RotateTarget(-65), Speed(600), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(0.2))
  
  --NOTE: Characters are defined in pokemon_actor_data.bin
  --      These characters do not cover all Pokemon available in the game
  --      pokemon_actor_data.bin has been modified for the following Pokemon
  CHARA:DynamicLoad("Townmon06", "DUMMY")           --Scrafty
  CH("Townmon06"):SetPosition(Vector(-5.1, 0, -.8)) --next to inn
  CH("Townmon06"):DirTo(RotateTarget(-50), Speed(600), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(0.2))
  CHARA:DynamicLoad("Townmon07", "R_RENTAL")        --Eevee
  CH("Townmon07"):SetPosition(Vector(-5.8, 0, -.2)) --next to inn
  CH("Townmon07"):DirTo(CH("Townmon06"), Speed(600), ROT_TYPE.NEAR)
  CH("Townmon07"):ChangeColor(Color(0.8, 0.7, 1, 1), TimeSec(0))
  CH("Townmon07"):ChangeAddColor(Color(0.255, 0.439, 0.988, 1), TimeSec(0))
  TASK:Sleep(TimeSec(0.3))
  
  --<pokemon each start some activity>
  CH("Townmon05"):SetMotion(SymMot("WAIT00"), LOOP.ON)  --Audino: exaggerated idle
  CH("Townmon07"):SetMotion(SymMot("WAIT00"), LOOP.ON)  --Scrafty/Eevee: "talking"
  CH("Townmon01"):WalkTo(Vector2(-2.2, 0.3), Speed(2))  --Meinfoo: walks up to duo 
   
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --normal face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "There we go.")                   --Orus speaks
  WINDOW:KeyWait()
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()

  --if CH("Townmon01"):IsMove() then
    CH("Townmon01"):WaitMove()
  --end
  TASK:Sleep(TimeSec(0.2))
  
  --<Meinfoo>--
  CH("Townmon01"):DirTo(CH("HERO"), Speed(200), ROT_TYPE.NEAR)
  TASK:Regist(Group("delay"), taskDelayRun,{function() CH("Townmon01"):DirTo(CH("PARTNER"), Speed(200), ROT_TYPE.NEAR) end, "turn", 1})
  CH("Townmon01"):SetFacialMotion(FACIAL_MOTION.HAPPY)          --Happy face on Mienfoo
  WINDOW:DrawFace(20, 88, SymAct("KOJOFUU"), FACE_TYPE.HAPPY)   --Happy Mienfoo portrait
  WINDOW_Talk(SymAct("KOJOFUU"), "Orus. Laurenna.[K]  When did you get here?")
  WINDOW:KeyWait()
  
  CH("Townmon01"):DirTo(CH("HERO"), Speed(200), ROT_TYPE.NEAR)
  CH("Townmon01"):SetFacialMotion(FACIAL_MOTION.THINK)          --Thinking face on Mienfoo
  WINDOW:DrawFace(20, 88, SymAct("KOJOFUU"), FACE_TYPE.THINK)   --Thinking Mienfoo portrait
  WINDOW_Talk(SymAct("KOJOFUU"), "And what's with the beds?")
  WINDOW:KeyWait()
  
  CH("HERO"):DirTo(CH("Townmon01"), Speed(200), ROT_TYPE.NEAR)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.HAPPY)               --Happy face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.HAPPY)      --Happy player portrait
  WINDOW_Talk(SymAct("HERO"), "Oh, Hi Niera.")                  --Orus speaks
  WINDOW:KeyWait()
  
  --<Laurenna wanders off to Kecleon Shop>--
  CH("PARTNER"):WalkTo(Vector2(.35, -1.35), Speed(1.6))
  CAMERA:MoveEye(Vector(-1.81, 3.17, 6.52), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:MoveTgt(Vector(-2.32, 0.88, 2.11), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  
  --<A small conversation with Niera>--
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --normal face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "It's a long story.[K]  Don't ask.")
  WINDOW:KeyWait()

  CH("Townmon01"):SetFacialMotion(FACIAL_MOTION.NORMAL)         --normal face on Mienfoo
  WINDOW:DrawFace(324, 88, SymAct("KOJOFUU"), FACE_TYPE.NORMAL) --normal Mienfoo portrait
  WINDOW_Talk(SymWord("Niera"), "Oh, okay.")
  WINDOW:KeyWait()
  
  CH("Townmon01"):SetFacialMotion(FACIAL_MOTION.HAPPY)          --happy face on Mienfoo
  WINDOW:DrawFace(324, 88, SymAct("KOJOFUU"), FACE_TYPE.HAPPY)  --happy Mienfoo portrait
  WINDOW_Talk(SymWord("Niera"), "So I heard you guys are having a party out in\nParadise.")
  WINDOW:KeyWait()
  WINDOW_Talk(SymWord("Niera"), "Am I invited?")
  WINDOW:KeyWait()
  
  --TODO: sprite?
  SOUND:PlaySe(SymSnd("SE_EVT_SIGN_SWEAT"), Volume(256))
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.RELIEF)              --exasperated face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.RELIEF)     --exasperated player portrait
  WINDOW_Talk(SymAct("HERO"), "Really? [K] I...")
  WINDOW:KeyWait()
  
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --normal face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.SPECIAL02)  --neutral player portrait
  WINDOW_Talk(SymAct("HERO"), "Sure, go knock yourself out.")
  WINDOW:KeyWait()
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --<Meinfoo happy anims and runs off>--
  CH("Townmon01"):SetManpu("MP_SPREE_LP")
  SOUND:PlaySe(SymSnd("SE_EVT_JUMP_01"), Volume(128))
  subEveJump(CH("Townmon01"))
  TASK:Sleep(TimeSec(0.25))
  CH("Townmon01"):RunTo(Vector2(3, 2.5), Speed(4))
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.DECIDE)
  TASK:Sleep(TimeSec(1.25))
  
  --<orus turns to where Laurenna was>--
  CH("HERO"):DirTo(Vector2(-1.5, 1), Speed(200), ROT_TYPE.NEAR)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)              --normal face on player
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "Hey [c_stammer:2]... [K] Oh.")
  WINDOW:KeyWait()
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --<Orus looks for Laurenna>--
  TASK:Sleep(TimeSec(0.2))
  CH("HERO"):SetNeckRot3(-25,0,0, TimeSec(0.3))
  TASK:Sleep(TimeSec(0.4))
  CH("HERO"):SetNeckRot3(25,0,0, TimeSec(0.6))
  TASK:Sleep(TimeSec(0.7))
  CH("HERO"):ResetNeckRot(TimeSec(.5))
  CH("HERO"):DirTo(CH("PARTNER"), Speed(200), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(0.5))
  
  --<Orus walks to Laurenna>--
  CH("HERO"):WalkTo(Vector2(-0.2, -0.6), Speed(2))
  CAMERA:MoveEye(Vector(1.28, 3.35, 5.07), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:MoveTgt(Vector(0.38, 0.98, 0.76), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CH("HERO"):WaitMove()
  
  CH("HERO"):DirTo(CH("PARTNER"), Speed(200), ROT_TYPE.NEAR)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "Hey [partner], we've got few more map\nfeatures to look at.")
  WINDOW:KeyWait()
  
  --<Laurenna turns to Orus>
  CH("PARTNER"):DirTo(CH("HERO"), Speed(200), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(.7))
  CH("PARTNER"):WalkTo(Vector2(.25, -1.25), Speed(.6))
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "How about we go somewhere a little more\nquiet?")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetNeckRot3(0,-10,0, TimeSec(0.25))             --lean head down
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.SAD)              --sad face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.SAD)    --sad partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "But... [K] But they're having a sale on Torchberries.")
  WINDOW:KeyWait()

  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "Come on, they'll still be here when we get back.")
  WINDOW:KeyWait()
  
  CH("PARTNER"):ResetNeckRot(TimeSec(0.25))
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)               --normal face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.SPECIAL02)  --neutral partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Alright...")
  WINDOW:KeyWait()
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()

  --<Duo Returns to center>--
  CH("HERO"):WalkTo(Vector2(-3, 1), Speed(2))
  CH("PARTNER"):WalkTo(Vector2(-1.5, 1), Speed(2))
  CAMERA:MoveEye(Vector(-5.21, 6.96, 13.53), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CAMERA:MoveTgt(Vector(-4.10, 4.67,  9.23), TimeSec(2), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
  CH("HERO"):WaitMove()
  CH("PARTNER"):DirTo(CH("HERO"), Speed(250), ROT_TYPE.NEAR)
  CH("HERO"):DirTo(CH("PARTNER"), Speed(250), ROT_TYPE.NEAR)
  CH("HERO"):WaitRotate()
  
  --<characters pop out>--
  CHARA:DynamicRemove("Townmon01")
  TASK:Sleep(TimeSec(0.6))
  CHARA:DynamicRemove("Townmon02")
  TASK:Sleep(TimeSec(0.6))
  CHARA:DynamicRemove("Townmon03")
  TASK:Sleep(TimeSec(0.4))
  CHARA:DynamicRemove("Townmon04")
  TASK:Sleep(TimeSec(0.4))
  CHARA:DynamicRemove("Townmon05")
  TASK:Sleep(TimeSec(0.2))
  CHARA:DynamicRemove("Townmon06")
  TASK:Sleep(TimeSec(0.2))
  CHARA:DynamicRemove("Townmon07")
  TASK:Sleep(TimeSec(0.2))
  
  --<map unloads>--
  MAP:DynamicUnloadGroundMap()
  GM("WARABED_01"):SetVisible(false)
  GM("WARABED_02"):SetVisible(false)
  CH("HERO"):SetPosition(Vector(-3, 0, 1))
  CH("PARTNER"):SetPosition(Vector(-1.5, 0, 1))
  SOUND:StopBgm()
  TASK:Sleep(TimeSec(0.6))
  
  --<another map loads (hide movements using map load)>--
  CH("HERO"):SetPosition(Vector(5, 0, 10))
  CH("PARTNER"):SetPosition(Vector(6.5, 0, 10))
  CAMERA:SetEye(Vector(2.79, 6.96, 22.53))
  CAMERA:SetTgt(Vector(3.9, 4.67,  18.23))
  MAP:DynamicLoadGroundMap(SymMap("D_SANGAKUWONUKETAGAKE"))
  SOUND:PlayBgm(SymSnd("BGM_MAP_PARADISE_03"), Volume(100))
  
  TASK:Sleep(TimeSec(0.6))
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "There, that's better.")
  WINDOW:KeyWait()
  WINDOW_Talk(SymAct("HERO"), "Now onto those last few features.")
  WINDOW:KeyWait()
  
  --<clear screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  TASK:Sleep(TimeSec(1.8))
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "First, we can change the color of maps,[K]\nmuch like with characters.")
  WINDOW:KeyWait()
  WINDOW_Talk(SymAct("HERO"), "Like this.")
  WINDOW:KeyWait()
  
  --<map tint>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  TASK:Sleep(TimeSec(0.4))
  MAP:ChangeLightColor(Color(0.2, 1, 0.6, 1), TimeSec(1))
  TASK:Sleep(TimeSec(1.6))
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)            --thinking face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)  --thinking partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "And what would we use this for?")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)            --happy/joking face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)  --happy/joking partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Green-O-Vision?")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.SPECIAL02)  --neutral player portrait
  WINDOW_Talk(SymAct("HERO"), "That's just to make it more visible for\ndemonstration.[K]  It has its uses.")
  WINDOW:KeyWait()
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "In fact, we used it for the fog scene.")
  WINDOW:KeyWait()
  WINDOW_Talk(SymAct("HERO"), "It was subtle, but still important for the visuals.")
  WINDOW:KeyWait()

  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)           --normal face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.NORMAL) --normal partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Oh, I didn't think of that.")
  WINDOW:KeyWait()
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "You can do a lot with clever color adjustment.")
  WINDOW:KeyWait()
  
  MAP:ChangeLightColor(Color(0.3, 0.4, 0.8, 1), TimeSec(1))
  CH("HERO"):ChangeColor(Color(0.3, 0.4, 0.8, 1), TimeSec(1))
  CH("PARTNER"):ChangeColor(Color(0.3, 0.4, 0.8, 1), TimeSec(1))
  WINDOW_Talk(SymAct("HERO"), "We could make it look like night time.")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)            --happy face on partner 
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)  --happy partner portrait
  WINDOW_Talk(SymAct("PARTNER"), "Oh, that's actually pretty cool!")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "Next, we can adjust the intensity of cloud\nshadows.")
  WINDOW:KeyWait()
  
  --<cloud adjust>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  TASK:Sleep(TimeSec(0.4))
  MAP:ChangeProjectionShadowAlpha(0.3, TimeSec(1))
  TASK:Sleep(TimeSec(1.6))
    
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "This one's not the most useful, but still\nimportant.")
  WINDOW:KeyWait()
  
  WINDOW_Talk(SymAct("HERO"), "After all, cloud shadows don't make much\nsense at night.")
  WINDOW:KeyWait()
  
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.NORMAL)
  WINDOW_Talk(SymAct("PARTNER"), "Yeah.")
  WINDOW:KeyWait()
  
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)     --normal player portrait
  WINDOW_Talk(SymAct("HERO"), "We can also set map backgrounds.")
  WINDOW:KeyWait()
  
  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --Don't actually bother setting background
  TASK:Sleep(TimeSec(0.4))
  CH("HERO"):SetNeckRot3(-25,0,0, TimeSec(0.3))
  TASK:Sleep(TimeSec(0.6))
  CH("HERO"):SetNeckRot3(25,0,0, TimeSec(0.6))
  TASK:Sleep(TimeSec(0.9))
  CH("HERO"):ResetNeckRot(TimeSec(.4))
  TASK:Sleep(TimeSec(0.6))
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)
  WINDOW_Talk(SymAct("HERO"), "This isn't the best map for a demo, so you'll\njust have to take my word for it.")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.SPECIAL02)
  WINDOW_Talk(SymAct("PARTNER"), "Okay.")
  WINDOW:KeyWait()
  
  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  TASK:Sleep(TimeSec(1.2))
  
  CH("PARTNER"):DirTo(Vector2(7, 7.2), Speed(250), ROT_TYPE.NEAR)
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)
  WINDOW_Talk(SymAct("PARTNER"), "I just realized,[K] where did the beds go?")
  WINDOW:KeyWait()
  
  CH("HERO"):DirTo(Vector2(5, 7.2), Speed(250), ROT_TYPE.NEAR)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.THINK)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.THINK)
  WINDOW_Talk(SymAct("HERO"), "Yeah,[K] they're gone.")
  WINDOW:KeyWait()

  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)
  WINDOW_Talk(SymAct("HERO"), "That must mean there's some way to\nmanipulate these objects from Lua.")
  WINDOW:KeyWait()
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  WINDOW_Talk(SymAct("HERO"), "Let's see ...")
  WINDOW:KeyWait()
  
  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()

  --<scale in bed 1>--
  GM("WARABED_01"):SetPosition(5, 0, 7.2)
  GM("WARABED_01"):SetScale(Scale(0))               --scale 0
  GM("WARABED_01"):SetVisible(true)                 --show
  GM("WARABED_01"):ChangeScale(Scale(1),TimeSec(1)) --scale up 
  TASK:Sleep(TimeSec(1.36))
  
  --<move the bed around>--
  GM("WARABED_01"):MoveTo(SplinePath(Vector2(7,7), Vector2(4,8), Vector2(9,7), Vector2(6,5)), Speed(3))
  GM("WARABED_01"):DirTo(RotateOffs(720), Speed(200))
  GM("WARABED_01"):MoveHeightTo(Height(1), Speed(2))
  TASK:Sleep(TimeSec(1.1))
  GM("WARABED_01"):MoveHeightTo(Height(0), Speed(2))
  GM("WARABED_01"):WaitMove()
  
  GM("WARABED_01"):MoveTo(Vector2(6,8), Speed(3))
  GM("WARABED_01"):WaitMove()
  CH("HERO"):DirTo(Vector2(6,8), Speed(250), ROT_TYPE.NEAR)

  
  --<change colors>--
  GM("WARABED_01"):ChangeColor(Color(1, 0, 0, 1), TimeSec(0.75))
  TASK:Sleep(TimeSec(0.75))
  GM("WARABED_01"):ChangeColor(Color(0, 1, 0, 1), TimeSec(1))
  TASK:Sleep(TimeSec(1))
  GM("WARABED_01"):ChangeColor(Color(0, 0, 1, 1), TimeSec(1))
  TASK:Sleep(TimeSec(1.5))

  --add manpu
  GM("WARABED_01"):SetManpu("MP_FLY_SWEAT")
  GM("WARABED_01"):WaitManpu()
  TASK:Sleep(TimeSec(0.3))
  GM("WARABED_01"):SetManpu("MP_NOTICE_R")
  GM("WARABED_01"):WaitManpu()
  
  --fade out  (doesn't work, just blinks out)
  --GM("WARABED_01"):ChangeAlpha(0, TimeSec(2))
  GM("WARABED_01"):ChangeScale(Scale(0),TimeSec(2))
  TASK:Sleep(TimeSec(2.4))
  
  CH("PARTNER"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)
  CH("HERO"):DirTo(CH("PARTNER"), Speed(350), ROT_TYPE.NEAR)
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)
  WINDOW_Talk(SymAct("HERO"), "It looks like we can work with existing objects,\nbut not add any new ones.")
  WINDOW:KeyWait()

  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)
  WINDOW_Talk(SymAct("PARTNER"), "It's a good start, right?")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)
  WINDOW_Talk(SymAct("HERO"), "Certainly.")
  WINDOW:KeyWait()
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.SPECIAL02)
  WINDOW_Talk(SymAct("HERO"), "But we still need to be able to add new objects.")
  WINDOW:KeyWait()
  
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.NORMAL)
  WINDOW_Talk(SymAct("PARTNER"), "Right.")
  WINDOW:KeyWait()
    
  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  --<Fade back to day>--
  TASK:Sleep(TimeSec(0.4))
  MAP:ChangeLightColor(Color(1, 1, 1, 1), TimeSec(1.2))
  CH("HERO"):ChangeColor(Color(1, 1, 1, 1), TimeSec(1.2))
  CH("PARTNER"):ChangeColor(Color(1, 1, 1, 1), TimeSec(1.2))
  TASK:Sleep(TimeSec(1.8))
  
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)
  WINDOW_Talk(SymAct("HERO"), "Well, that about does it for the map features.")
  WINDOW:KeyWait()
  WINDOW_Talk(SymAct("HERO"), "But how about we check out some more of\nthe maps while we're out here?")
  WINDOW:KeyWait()

  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)
  WINDOW_Talk(SymAct("PARTNER"), "Yeah!  That sounds like fun!")
  WINDOW:KeyWait()
  
  --<Orus nods head>--
  TASK:Regist(
    function()
      CH("HERO"):SetNeckRot3(0,-20,0, TimeSec(0.15))
      TASK:Sleep(TimeSec(0.15))
      CH("HERO"):ResetNeckRot(TimeSec(0.2))
      TASK:Sleep(TimeSec(0.2)) 
    end
  )

  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)
  WINDOW_Talk(SymAct("HERO"), "Alright, let's go.")
  WINDOW:KeyWait()
  
  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  
  
  --<Fade to crystal cave>--
  SCREEN_A:FadeOut(TimeSec(0.5), true)
  SOUND:FadeOutBgm(TimeSec(0.5))
  
  --  unload map
  MAP:DynamicUnloadGroundMap()
  TASK:Sleep(TimeSec(0.25))
  
  --  move chars and cam
  CH("HERO"):SetPosition(Vector(-0.5, -0.2, 1))
  CH("PARTNER"):SetPosition(Vector(1, -0.2, 1))
  CAMERA:SetEye(Vector(-0.81, 3.19, 11.54))
  CAMERA:SetTgt(Vector(-0.26, 2.00,  6.71))
  
  --  load map
  MAP:DynamicLoadGroundMap(SymMap("D_KOUZAN_END"))
  TASK:Sleep(TimeSec(0.25))
  
  --  fade in screen/BGM
  SOUND:FadeInBgm(SymSnd("BGM_DUN_03"), TimeSec(0.5), Volume(100))
  SCREEN_A:FadeIn(TimeSec(0.5), true)
  
  
  CH("PARTNER"):DirTo(RotateOffs(-80), Speed(240), ROT_TYPE.NEAR)
  TASK:Sleep(TimeSec(0.25))
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.EMOTION)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.EMOTION)
  WINDOW_Talk(SymAct("PARTNER"), "Oooh, pretty crystals.")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)
  WINDOW_Talk(SymAct("PARTNER"), "Can I take one?")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL) 
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.SPECIAL02)
  WINDOW_Talk(SymAct("HERO"), "That's not a good idea.")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetNeckRot3(0,-10,0, TimeSec(0.6))
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.SAD)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.SAD)
  WINDOW_Talk(SymAct("PARTNER"), "Oh fine...")
  WINDOW:KeyWait()
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL) 
  
  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  TASK:Sleep(TimeSec(0.75))
  
  
  --<Fade to giant frism>--
  SCREEN_A:FadeOut(TimeSec(0.5), true)
  SOUND:FadeOutBgm(TimeSec(0.5))
  
  --  unload map
  MAP:DynamicUnloadGroundMap()
  TASK:Sleep(TimeSec(1))
  
  --  move chars and cam
  CH("HERO"):SetPosition(Vector(-1, 2, -1))
  CH("PARTNER"):SetPosition(Vector(-1, 2, 0))
  CH("PARTNER"):DirTo(CH("HERO"), Speed(600), ROT_TYPE.NEAR)
  CAMERA:SetEye(Vector(-2.23, 4.56, 17.53))
  CAMERA:SetTgt(Vector(-0.90, 3.35, 12.87))
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  CH("PARTNER"):DirTo(RotateOffs(-85), Speed(900), ROT_TYPE.NEAR)
  CH("PARTNER"):ResetNeckRot(TimeSec(0.1))
  
  --  load map
  MAP:DynamicLoadGroundMap(SymMap("EV_381_FLEEZEM_AFTRE"))
  TASK:Sleep(TimeSec(0.25))
  
  --  fade in screen/BGM
  SOUND:FadeInBgm(SymSnd("BGM_DUN_12"), TimeSec(0.5), Volume(100))
  SCREEN_A:FadeIn(TimeSec(0.5), true)
  
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.HAPPY)
  WINDOW_Talk(SymAct("PARTNER"), "Whoa, a giant frism!")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.GLADNESS)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.GLADNESS)
  WINDOW_Talk(SymAct("PARTNER"), "Cool!")
  WINDOW:KeyWait()

  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  TASK:Sleep(TimeSec(1))

  
  --<Fade to skydiving>--
  SCREEN_A:FadeOut(TimeSec(0.5), true)
  SOUND:FadeOutBgm(TimeSec(0.5))
  
  --  unload map
  MAP:DynamicUnloadGroundMap()
  TASK:Sleep(TimeSec(0.25))
  
  --  move chars and cam
  CH("HERO"):SetPosition(Vector(-2.5, 0, 0.35))
  CH("HERO"):SetHeight(Height(110))
  CH("HERO"):SetDir(RotateTarget(100))
  CH("PARTNER"):SetPosition(Vector(-0.5, 0, 0.35))
  CH("PARTNER"):SetHeight(Height(110))
  CH("PARTNER"):SetDir(RotateTarget(190))
  CAMERA:SetEye(Vector(-1.05, 117.03, 1.03))
  CAMERA:SetTgt(Vector(-1.03, 112.04, 0.76))
  CH("HERO"):SetMotion(SymMot("EV001_SKYDV00"), LOOP.ON)
  CH("HERO"):SetShadow(false)
  CH("PARTNER"):SetMotion(SymMot("EV001_SKYDV00"), LOOP.ON) 
  CH("PARTNER"):SetShadow(false)
  
  --  load map
  MAP:DynamicLoadGroundMap(SymMap("EV_RAKKA"))
  TASK:Sleep(TimeSec(0.25))
  
  --  fade in screen/BGM
  SOUND:FadeInBgm(SymSnd("BGM_SYS_MINIGAME_03"), TimeSec(0.5), Volume(100))
  SCREEN_A:FadeIn(TimeSec(0.5), true)
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.SURPRISE)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.SURPRISE)
  WINDOW_Talk(SymAct("PARTNER"), "AAAAH!")
  WINDOW:KeyWait()
  WINDOW_Talk(SymAct("PARTNER"), "Change the map!  Change the map!")
  WINDOW:KeyWait()
  
  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  TASK:Sleep(TimeSec(0.6))

  
  --<Fade to void rocks>--
  SCREEN_A:FadeOut(TimeSec(0.5), true)
  SOUND:FadeOutBgm(TimeSec(0.5))
  
  --  unload map
  MAP:DynamicUnloadGroundMap()

  TASK:Sleep(TimeSec(0.25))
  
  --  move chars and cam
  CH("HERO"):SetPosition(Vector(-1.5, 0, 0))
  CH("HERO"):SetHeight(Height(0))
  CH("PARTNER"):SetPosition(Vector(0.5, 0, 0))
  CH("PARTNER"):SetHeight(Height(0))
  CH("PARTNER"):DirTo(CH("HERO"), Speed(350), ROT_TYPE.NEAR)
  CH("HERO"):DirTo(CH("PARTNER"), Speed(350), ROT_TYPE.NEAR)
  CAMERA:SetEye(Vector(-1.81, 5.28, 14.86))
  CAMERA:SetTgt(Vector(-1.34, 3.70, 10.14))
  CH("HERO"):SetMotion(SymMot("WAIT02"), LOOP.ON)
  CH("HERO"):SetShadow(true)
  CH("PARTNER"):SetMotion(SymMot("WAIT02"), LOOP.ON) 
  CH("PARTNER"):SetShadow(true)
  
  --  load map
  MAP:DynamicLoadGroundMap(SymMap("EV_UCHUURITSUNOOKA"))
  TASK:Sleep(TimeSec(0.25))
  
  --  fade in screen/BGM
  SOUND:FadeInBgm(SymSnd("BGM_DUN_29"), TimeSec(0.5), Volume(100))
  SCREEN_A:FadeIn(TimeSec(0.5), true)
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)
  WINDOW:DrawFace(324, 88, SymAct("PARTNER"), FACE_TYPE.THINK)
  WINDOW_Talk(SymAct("PARTNER"), "What is this place?")
  WINDOW:KeyWait()
  
  CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.THINK) 
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.THINK)
  WINDOW_Talk(SymAct("HERO"), "Hmm, this isn't right...")
  WINDOW:KeyWait()
  
  CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL) 
  WINDOW:DrawFace(20, 88, SymAct("HERO"), FACE_TYPE.NORMAL)
  WINDOW_Talk(SymAct("HERO"), "Let's try that again.")
  WINDOW:KeyWait()
  
  --<Clear Screen>--
  WINDOW:CloseMessage()
  WINDOW:RemoveFace()
  TASK:Sleep(TimeSec(0.6))

  
  --<Fade out>--
  SCREEN_A:FadeOut(TimeSec(0.5), true)
  SOUND:FadeOutBgm(TimeSec(0.5))
  TASK:Sleep(TimeSec(2))
    
  --<Transition to PSMD>--
  
  --intentionally crash to menu for testing purposes
  while not PAD:Data("START&R") do TASK:Sleep(TimeSec(0.1)) end
  CAMERA:MoveTgt(Vector(-1, 0, 0), Speed(1), ACCEL_TYPE.HIGH, DECEL_TYPE.LOW)

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
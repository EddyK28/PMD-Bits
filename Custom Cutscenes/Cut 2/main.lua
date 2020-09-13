--====PMD 4 Cutscene Demo====--
--MIT License
--Copyright (c) 2019 EddyK28

--NOTE: this cutscene is run from the Mod Loader.
--  Intended for use in Lively town, with partner present.

--Don't run in GTI
if bIsGates then 
  return 
end

--Replacement talk function. Replaces spaces with chars that actually render spaces
--  NOTE: gsub() has multiple returns which confuses WINDOW:Talk()
local function WINDOW_Talk(ch, str)
  --This would make this function only work with CHARA_OBJs (and maybe SymAct's?)
  --WINDOW:Talk(ch, str:gsub(" ","쐃"))
  
  str = str:gsub(" ","쐃")
  WINDOW:Talk(ch, str)
end

--Additional neck rotation function.  Takes yaw, pitch and roll angles directly
CHARA_OBJ.SetNeckRot3 = function(self, yaw, pitch, roll, speed)
  self:SetNeckRot(RotateTarget(yaw),RotateTarget(pitch),RotateTarget(roll), speed)
end

--A special walk function for traveling inclines
function CHARA_OBJ.walkVertSb(chara,pos,timeS,delay,run)
  delay = delay or 0
  run = run or false
  TASK:Sleep(TimeSec(delay))
  local nd = timeS*30
  local temp = chara:GetPosition()
  pos = pos - temp
  local speed = pos:Size()/timeS
  pos = pos/nd
  if run then
    chara:SetMotion(SymMot("RUN"), LOOP.ON)
  else
    chara:SetMotion(SymMot("WALK"), LOOP.ON)
  end
  chara:SetMotionRaito(Raito(speed))
  for var=1,nd do
    temp = chara:GetPosition()
    chara:SetPosition_NoTaiki(temp.x+pos.x,temp.y+pos.y,temp.z+pos.z)
    TASK:Sleep(TimeSec(1, TIME_TYPE.FRAME))
  end
  chara:SetMotion(SymMot("WAIT02"), LOOP.ON)
end
function CHARA_OBJ.walkVert(...)
  TASK:Regist(CHARA_OBJ.walkVertSb,{...})
end


CommonSys:EndLowerMenuNavi(true)
  
--<fade to black>--
SCREEN_A:FadeOut(TimeSec(0.1), true)
SOUND:FadeOutBgm(TimeSec(0.1))


--NOTE: There are limited named slots for characters in PSMD, so only existing character names can be used.
--  Nonexistent names all refer to the same character.
--  For example, the following will create a new Axew character, accessible by CH("Orus").
--    CHARA:DynamicLoad("Orus", "KIBAGO") --(name, actor)
--  However, any nonexistent name with refer to this character, even CH("asdfg")
--  As a result, the following will conflict with the already existing character and produce an error.
--    CHARA:DynamicLoad("Laurenna", "TSUTAAJA")
--  Surprisingly, this works as intended in Gates (go figure).

--  As a workaround, temporarily use the "HERO" and "PARTNER" slots
--  Any of RESERVE_58 through RESERVE_75 could have been used instead

--<Add Orus and Laurenna>--
CHARA:DynamicRemove("HERO")
CHARA:DynamicRemove("PARTNER")

CHARA:DynamicLoad("HERO", "KIBAGO")
CHARA:DynamicLoad("PARTNER", "TSUTAAJA")
CH("HERO"):SetPosition(Vector(8, 0, -1))
CH("PARTNER"):SetPosition(Vector(8, 0, 0))
CH("HERO"):DirTo(CH("PARTNER"), Speed(600), ROT_TYPE.NEAR)
CH("PARTNER"):DirTo(CH("HERO"), Speed(600), ROT_TYPE.NEAR)

--position camera
CAMERA:SetEye(Vector(3.49, 5.80, 6.81))
CAMERA:SetTgt(Vector(5.91, 3.14, 3.33))

--<fade in>--
TASK:Sleep(TimeSec(1))
SOUND:FadeInBgm(SymSnd("BGM_EVE_WAIWAITOWN_01"), TimeSec(1), Volume(60))
SCREEN_A:FadeIn(TimeSec(0.5), true)   
TASK:Sleep(TimeSec(0.5))


--<Laurenna looks around>
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)             --thinking face
CH("PARTNER"):SetNeckRot3(45,-5,0, TimeSec(0.4))
TASK:Sleep(TimeSec(0.7))
CH("PARTNER"):SetNeckRot3(-45,-5,0, TimeSec(0.8))
TASK:Sleep(TimeSec(1.1))
CH("PARTNER"):ResetNeckRot(TimeSec(.5))

--NOTE: WINDOW:Talk(SymWord, string) does actually work in PSMD. I though it didn't, but it's 
--  my WINDOW_Talk() that was the problem.

--Temporarily change the names of the player and partner as a workaround 
--  (from before I figured out the above problem)
local nameHero = FUNC_COMMON:GetCharaNameFromWarehouseId(0)
local namePartner = FUNC_COMMON:GetCharaNameFromWarehouseId(1)
GROUND:SetPokemonWarehouseHeroName("Orus")
GROUND:SetPokemonWarehousePartnerName("Laurenna")

WINDOW:DrawFace(324, 88, SymAct("TSUTAAJA"), FACE_TYPE.THINK)   --thinking portrait
WINDOW_Talk(CH("PARTNER"), "Hold on, we're in a different game now, aren't we?")
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

CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)               --normal face
WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.NORMAL)    --normal portrait
WINDOW_Talk(CH("HERO"), "Yeah, Super Mystery Dungeon.")
WINDOW:KeyWait()

SOUND:PlaySe(SymSnd("SE_EVT_SIGN_QUESTION_01"), Volume(200))    --question sound
CH("PARTNER"):SetNeckRot3(0,0,10, TimeSec(0.2))                 --head lean
CH("PARTNER"):SetManpu("MP_QUESTION")                           --"?" sprite
WINDOW:DrawFace(324, 88, SymAct("TSUTAAJA"), FACE_TYPE.THINK)   --thinking portrait
WINDOW_Talk(CH("PARTNER"), "How does that work?")
WINDOW:KeyWait()

WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.NORMAL)     --normal portrait
WINDOW_Talk(CH("HERO"), "It doesn't,[K] but we're just going to pretend it does.")
CH("PARTNER"):ResetNeckRot(TimeSec(0.4))
WINDOW:KeyWait()
WINDOW_Talk(CH("HERO"), "Okay?")
WINDOW:KeyWait()

CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)             --thinking face
WINDOW:DrawFace(324, 88, SymAct("TSUTAAJA"), FACE_TYPE.NORMAL)  --thinking portrait
WINDOW_Talk(CH("PARTNER"), "Oh.[K]  Alright.")
WINDOW:KeyWait()
  
WINDOW:CloseMessage()
WINDOW:RemoveFace()
TASK:Sleep(TimeSec(1.65))
  
WINDOW:DrawFace(324, 88, SymAct("TSUTAAJA"), FACE_TYPE.NORMAL)  --normal portrait
WINDOW_Talk(CH("PARTNER"), "So what are we doing here?")
WINDOW:KeyWait()

WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.NORMAL)     --normal portrait
WINDOW_Talk(CH("HERO"), "I heard Doc is back in town.[K]  I thought we should\npay him a visit.")
WINDOW:KeyWait()
  
CH("HERO"):SetFacialMotion(FACIAL_MOTION.HAPPY)                 --normal face
WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.HAPPY)      --normal portrait
WINDOW_Talk(CH("HERO"), "And this is a good opportunity to demonstrate\ncutscenes in Super Mystery Dungeon!")
WINDOW:KeyWait()

CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)              --happy face
WINDOW:DrawFace(324, 88, SymAct("TSUTAAJA"), FACE_TYPE.HAPPY)   --happy portrait
WINDOW_Talk(CH("PARTNER"), "Cool, lets go!")
WINDOW:KeyWait()

WINDOW:CloseMessage()
WINDOW:RemoveFace()
  
--<Laurenna walks "down" stairs>--
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
CH("PARTNER"):WalkTo(Vector2(10.5,-0.5), Speed(2))
CAMERA:MoveEye(Vector(10.68, 2.68, 7.56), TimeSec(1.8), ACCEL_TYPE.HIGH, DECEL_TYPE.HIGH)
CAMERA:MoveTgt(Vector(10.12, 1.03, 3.36), TimeSec(1.8), ACCEL_TYPE.HIGH, DECEL_TYPE.HIGH)
CH("PARTNER"):WaitMove()
  
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.SURPRISE)           --surprised face
SOUND:PlaySe(SymSnd("SE_EVT_SIGN_NOTICE_LOW_02"), Volume(256))
CH("PARTNER"):SetManpu("MP_EXCLAMATION")
CH("HERO"):DirTo(CH("PARTNER"), Speed(200), ROT_TYPE.NEAR)
WINDOW:DrawFace(324, 88, SymAct("TSUTAAJA"), FACE_TYPE.SURPRISE)--surprised portrait
WINDOW_Talk(CH("PARTNER"), "Ahh![K] What's going on?!")
WINDOW:KeyWait()

SOUND:PlaySe(SymSnd("SE_EVT_SIGN_HURRY"), Volume(256))
CH("PARTNER"):SetManpu("MP_FLY_SWEAT")

TASK:Regist(
  function()
    CH("PARTNER"):DirTo(RotateOffs(10), Speed(400), ROT_TYPE.NEAR)
    CH("PARTNER"):WaitRotate()
    CH("PARTNER"):DirTo(RotateOffs(-20), Speed(400), ROT_TYPE.NEAR)
    CH("PARTNER"):WaitRotate()
    CH("PARTNER"):DirTo(RotateOffs(20), Speed(400), ROT_TYPE.NEAR)
    CH("PARTNER"):WaitRotate()
    CH("PARTNER"):DirTo(RotateOffs(-20), Speed(400), ROT_TYPE.NEAR)
    CH("PARTNER"):WaitRotate()
    CH("PARTNER"):DirTo(RotateOffs(10), Speed(400), ROT_TYPE.NEAR)
  end
)
WINDOW_Talk(CH("PARTNER"), "Why am I floating?")
WINDOW:KeyWait()

SOUND:PlaySe(SymSnd("SE_EVT_HAND"), Volume(256))
CH("HERO"):SetFacialMotion(FACIAL_MOTION.CATCHBREATH)              --startled face
WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.CATCHBREATH)   --startled portrait
WINDOW_Talk(CH("HERO"), "Oh crap!  I forgot about that.")
CH("PARTNER"):DirTo(CH("HERO"), Speed(200), ROT_TYPE.NEAR)
WINDOW:KeyWait()

CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                --normal face
WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.NORMAL)     --normal portrait
WINDOW_Talk(CH("HERO"), "Characters added by scripts don't seem to follow\nthe ground height...")
WINDOW:KeyWait()
WINDOW_Talk(CH("HERO"), "And don't have any collision.")
WINDOW:KeyWait()
WINDOW_Talk(CH("HERO"), "The same happens when the map changes by script.")
WINDOW:KeyWait()

CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)              --thinking face
WINDOW:DrawFace(324, 88, SymAct("TSUTAAJA"), FACE_TYPE.THINK)   --thinking portrait
WINDOW_Talk(CH("PARTNER"), "Well, what do I do?")
WINDOW:KeyWait()

WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.NORMAL)     --normal portrait
WINDOW_Talk(CH("HERO"), "You have to use a special trick to go up and down\ninclines.")
WINDOW:KeyWait()
WINDOW_Talk(CH("HERO"), "Like this.")
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
WINDOW:KeyWait()

WINDOW:CloseMessage()
WINDOW:RemoveFace()

--<Orus walks down stairs and back up>--
CH("HERO"):WalkTo(Vector2(10.5,-0.5), Speed(2))
CH("HERO"):walkVertSb(Vector(10.7,-1,-1),1.3,0.3)
TASK:Sleep(TimeSec(0.25))
CH("HERO"):DirTo(Vector2(8.3, -1), Speed(200), ROT_TYPE.NEAR)
CH("HERO"):walkVertSb(Vector(8.3, 0, -1),1.3,1)
TASK:Sleep(TimeSec(0.25))
CH("HERO"):DirTo(CH("PARTNER"), Speed(200), ROT_TYPE.NEAR)
CH("HERO"):WaitRotate()
TASK:Sleep(TimeSec(0.15))

CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)              --happy face
WINDOW:DrawFace(324, 88, SymAct("TSUTAAJA"), FACE_TYPE.HAPPY)   --happy portrait
WINDOW_Talk(CH("PARTNER"), "Oh! I get it.")
WINDOW:KeyWait()

CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
WINDOW:CloseMessage()
WINDOW:RemoveFace()

--<Laurenna snaps to stairs top and walks down>--
CH("PARTNER"):SetPosition(Vector(8, 0, 0))
CH("PARTNER"):WalkTo(Vector2(10.5,-0.5), Speed(2))
CH("PARTNER"):walkVert(Vector(10.7,-1,-0.6),1.3,0.4)
TASK:Sleep(TimeSec(0.8))

WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.NORMAL)     --normal portrait
WINDOW_Talk(CH("HERO"), "Also, that's the wrong way.")
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.CATCHBREATH)
WINDOW:KeyWait()

SOUND:PlaySe(SymSnd("SE_EVT_HAND"), Volume(256))
CH("PARTNER"):DirTo(CH("HERO"), Speed(230), ROT_TYPE.NEAR)
WINDOW:DrawFace(324, 88, SymAct("TSUTAAJA"), FACE_TYPE.CATCHBREATH)
WINDOW_Talk(CH("PARTNER"), "Right,[K] I knew that.")
WINDOW:KeyWait()

CH("HERO"):DirTo(Vector2(0,0), Speed(200), ROT_TYPE.NEAR)
CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)                --normal face
WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.NORMAL)     --normal portrait
WINDOW_Talk(CH("HERO"), "Come on, this way.")
WINDOW:KeyWait()

WINDOW:CloseMessage()
WINDOW:RemoveFace()

CH("HERO"):WaitRotate()
CH("HERO"):WalkTo(Vector2(0,0), Speed(2))
TASK:Sleep(TimeSec(0.2))
CH("PARTNER"):walkVertSb(Vector(8.3, 0, 0),1.3)
CH("PARTNER"):WalkTo(Vector2(0,0), Speed(3))
TASK:Sleep(TimeSec(1.2))

--<Fade to bridge, duo walks across>--
SCREEN_A:FadeOut(TimeSec(0.5), true)
CAMERA:SetEye(Vector(-12.17, 5.83, 12.47))
CAMERA:SetTgt(Vector(-13.66, 4.27,  7.96))  
CH("HERO"):SetPosition(Vector(-12, 0, -1.7))
CH("PARTNER"):SetPosition(Vector(-11.5, 0, -1.2)) 
CH("HERO"):WalkTo(Vector2(-23,-2), Speed(2))
CH("PARTNER"):WalkTo(Vector2(-23,-1.5), Speed(2))
SCREEN_A:FadeIn(TimeSec(0.5), true)
SOUND:FadeOutBgm(TimeSec(6))
CH("HERO"):WaitMove()


--<fade to outside bridge>--
SCREEN_A:FadeOut(TimeSec(0.5), true)
TASK:Sleep(TimeSec(0.25))
CAMERA:SetEye(Vector(-17.90, 4.45, -4.53))
CAMERA:SetTgt(Vector(-22.24, 2.86, -2.63))
CH("HERO"):SetPosition(Vector(-23.8, 0, -2))
CH("PARTNER"):SetPosition(Vector(-23.8, 0, -1.5))
CHARA:DynamicLoad("Doc", "WARUBIRU")
CH("Doc"):ChangeColor(Color(0.5, 0.5, 0.5, 1), TimeSec(0.1))
CH("Doc"):SetPosition(Vector(-30.89, 0, 4))
SOUND:FadeInBgm(SymSnd("BGM_EVE_GAKKOU_01"), TimeSec(0.75), Volume(80))
SCREEN_A:FadeIn(TimeSec(0.5), true)


TASK:Sleep(TimeSec(0.3))
CH("Doc"):WalkTo(Vector2(-30.89,2), Speed(2))
CH("Doc"):WaitMove()

CH("Doc"):SetNeckRot3(0,-30,0, TimeSec(0.5))
TASK:Sleep(TimeSec(0.5))
CH("Doc"):SetNeckRot3(45,-35,0, TimeSec(0.3))
TASK:Sleep(TimeSec(0.6))
CH("Doc"):SetNeckRot3(-45,-35,0, TimeSec(0.8))
TASK:Sleep(TimeSec(1.1))
CH("Doc"):ResetNeckRot(TimeSec(.5))

WINDOW:DrawFace(20, 88, SymAct("WARUBIRU"), FACE_TYPE.NORMAL)
WINDOW_Talk(SymWord(""), "Damn.  Where did I put my goggles?")
WINDOW:KeyWait()

WINDOW:CloseMessage()
WINDOW:RemoveFace()

--<Orus and Laurenna Walk up>--
CH("HERO"):WalkTo(Vector2(-30.2,1), Speed(2))
CH("PARTNER"):WalkTo(Vector2(-29.8,1.8), Speed(2))
CAMERA:MoveEye(Vector(-28.58, 4.60, -4.55), TimeSec(4), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
CAMERA:MoveTgt(Vector(-29.74, 1.59, -0.72), TimeSec(4), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
TASK:Sleep(TimeSec(1.1))
CH("Doc"):DirTo(Vector2(-30,1.5), Speed(130), ROT_TYPE.NEAR)
TASK:Sleep(TimeSec(1))

CH("Doc"):SetFacialMotion(FACIAL_MOTION.HAPPY)
WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.HAPPY)
WINDOW_Talk(SymWord(""), "Orus! Laurenna!  It's good to see you guys.")
WINDOW:KeyWait()

CH("HERO"):DirTo(CH("Doc"), Speed(120), ROT_TYPE.NEAR)
CH("PARTNER"):DirTo(CH("Doc"), Speed(120), ROT_TYPE.NEAR)
CH("Doc"):SetFacialMotion(FACIAL_MOTION.NORMAL)
WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.NORMAL)
WINDOW_Talk(SymWord(""), "So how are you liking the new cutscene features?")
WINDOW:KeyWait()

WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.NORMAL)
WINDOW_Talk(CH("HERO"), "They're pretty g...")
WINDOW:KeyWait()    

TASK:Regist(subEveJump, {CH("PARTNER")})
SOUND:PlaySe(SymSnd("SE_EVT_JUMP_01"), Volume(128))
CH("PARTNER"):SetManpu("MP_SPREE_LP")
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.GLADNESS)
WINDOW:DrawFace(20, 88, SymAct("TSUTAAJA"), FACE_TYPE.GLADNESS)
WINDOW_Talk(CH("PARTNER"), "They're GREAT!")
WINDOW:KeyWait()

WINDOW:CloseMessage()
WINDOW:RemoveFace()

--<Orus gives Laurenna an angry look>
CH("HERO"):SetFacialMotion(FACIAL_MOTION.DECIDE)
TASK:Sleep(TimeSec(0.4))
CH("HERO"):DirTo(RotateOffs(25), Speed(120), ROT_TYPE.NEAR)
CH("HERO"):SetNeckRot3(30,0,0, TimeSec(0.6))
TASK:Sleep(TimeSec(0.9))
CH("HERO"):SetNeckRot3(30,-15,0, TimeSec(0.2))
SOUND:PlaySe(SymSnd("SE_EVT_BIYON"), Volume(256))
TASK:Sleep(TimeSec(0.2))
CH("PARTNER"):ResetManpu()
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.CATCHBREATH)
--TODO: keep facing & step back
TASK:Sleep(TimeSec(1))
  
CH("HERO"):DirTo(CH("Doc"), Speed(160), ROT_TYPE.NEAR)
CH("HERO"):ResetNeckRot(TimeSec(.7))
CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
TASK:Sleep(TimeSec(0.4))
WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.NORMAL)
WINDOW_Talk(CH("HERO"), "Well, they're pretty good, but some things are\nstill missing.")
WINDOW:KeyWait()

WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.NORMAL)
WINDOW_Talk(SymWord(""), "Yeah, it's all still being worked on.")
WINDOW:KeyWait()

WINDOW_Talk(SymWord(""), "But there is something else you might like.")
WINDOW:KeyWait()

CH("Doc"):SetFacialMotion(FACIAL_MOTION.HAPPY)
WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.HAPPY)
WINDOW_Talk(SymWord(""), "The new cutscene mod-loader injector!")
WINDOW:KeyWait()

CH("Doc"):SetFacialMotion(FACIAL_MOTION.NORMAL)
SOUND:PlaySe(SymSnd("SE_EVT_SIGN_QUESTION_01"), Volume(200))
CH("PARTNER"):SetNeckRot3(0,0,-10, TimeSec(0.2))
CH("PARTNER"):SetManpu("MP_QUESTION")
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.THINK)
WINDOW:DrawFace(20, 88, SymAct("TSUTAAJA"), FACE_TYPE.THINK)   
WINDOW_Talk(CH("PARTNER"), "The what?")
WINDOW:KeyWait()

CH("PARTNER"):ResetNeckRot(TimeSec(0.5))
WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.NORMAL)
WINDOW_Talk(SymWord(""), "It allows mods to be run in cutscenes without\nrequiring any modifications.")
WINDOW:KeyWait()
WINDOW_Talk(SymWord(""), "And it should work in any cutscene.[K]  Even this one.")
WINDOW:KeyWait()
WINDOW_Talk(SymWord(""), "In fact...")
WINDOW:KeyWait()
 
WINDOW:CloseMessage()
WINDOW:RemoveFace()

--<Doc turns to face camera>--
CH("Doc"):DirTo(Vector2(-28.58, -4.55), Speed(200), ROT_TYPE.NEAR)
CH("Doc"):SetNeckRot3(0,35,0, TimeSec(0.5))

CH("Doc"):SetFacialMotion(FACIAL_MOTION.HAPPY)
WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.HAPPY)
WINDOW_Talk(SymWord(""), "How about you give us a demo?")
WINDOW:KeyWait()

CH("Doc"):SetFacialMotion(FACIAL_MOTION.NORMAL)
WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.NORMAL)
WINDOW_Talk(SymWord(""), "Just hold [M:B02] and press [M:B08] or [M:B03].")
WINDOW:KeyWait()

--<user opens loader and injector controls>--

CH("Doc"):DirTo(Vector2(-30,1.5), Speed(130), ROT_TYPE.NEAR)
CH("Doc"):ResetNeckRot(TimeSec(0.5))

WINDOW_Talk(SymWord(""), "Execution stops at dialog and character\nmovements...")
WINDOW:KeyWait()
WINDOW_Talk(SymWord(""), "and you can continue step by step, or run\nnormally.") --Early newline to leave space for lower screen
WINDOW:KeyWait()
WINDOW_Talk(SymWord(""), "There are also some other handy options\nin there too.")
WINDOW:KeyWait()

WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.HAPPY)
CH("Doc"):SetFacialMotion(FACIAL_MOTION.HAPPY)
WINDOW_Talk(SymWord(""), "But most importantly, we can use it to\nrun the Free-Cam!")
WINDOW:KeyWait()

WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.NORMAL)
CH("Doc"):SetNeckRot3(35,0,0, TimeSec(0.5))
CH("Doc"):SetFacialMotion(FACIAL_MOTION.NORMAL)
WINDOW_Talk(SymWord(""), "Do try to keep it steady up there please.")
WINDOW:KeyWait()

CH("Doc"):ResetNeckRot(TimeSec(0.5))
WINDOW_Talk(SymWord(""), "Anyway, the camera now has cutscene\ninjector controls too.")
WINDOW:KeyWait()

WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.EMOTION)
CH("Doc"):SetFacialMotion(FACIAL_MOTION.EMOTION)
WINDOW_Talk(CH("HERO"), "Woah.  That's awesome.")
WINDOW:KeyWait()
  
WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.NORMAL)
WINDOW_Talk(SymWord(""), "It should also work in your home game,\nGates to Infinity.")
WINDOW:KeyWait()

WINDOW:DrawFace(20, 88, SymAct("TSUTAAJA"), FACE_TYPE.GLADNESS)
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.GLADNESS)
WINDOW_Talk(CH("PARTNER"), "Yay! Even better!")
WINDOW:KeyWait()
 
WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.NORMAL) 
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
WINDOW_Talk(SymWord(""), "It might not always be the most stable,\nbut it's good for what it does.")
WINDOW:KeyWait()

--<User closes injector here-ish>--

WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.HAPPY)
CH("HERO"):SetFacialMotion(FACIAL_MOTION.HAPPY)
WINDOW_Talk(CH("HERO"), "Still, this looks great.")
WINDOW:KeyWait()

WINDOW:DrawFace(20, 88, SymAct("TSUTAAJA"), FACE_TYPE.HAPPY)
CH("HERO"):SetFacialMotion(FACIAL_MOTION.NORMAL)
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)
WINDOW_Talk(CH("PARTNER"), "Yeah!")
WINDOW:KeyWait()

WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.HAPPY)
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
CH("Doc"):SetFacialMotion(FACIAL_MOTION.HAPPY)
WINDOW_Talk(SymWord(""), "Thanks guys!")
WINDOW:KeyWait()

WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.NORMAL) 
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
WINDOW_Talk(SymWord(""), "There's also a few other new things too, but\nthey're more for the player than us.") --TODO:<<
WINDOW:KeyWait()

WINDOW:DrawFace(20, 88, SymAct("TSUTAAJA"), FACE_TYPE.HAPPY)
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.HAPPY)
WINDOW_Talk(CH("PARTNER"), "Ooh, what are they?")
WINDOW:KeyWait()

WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.NORMAL)
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
CH("Doc"):SetFacialMotion(FACIAL_MOTION.NORMAL)
WINDOW_Talk(SymWord(""), "Some mod loader improvements, a new mod,\nand a special fork of Citra.")
WINDOW:KeyWait()

SOUND:PlaySe(SymSnd("SE_EVT_BIYON"), Volume(210))
WINDOW:DrawFace(20, 88, SymAct("TSUTAAJA"), FACE_TYPE.DECIDE)
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.DECIDE)
WINDOW_Talk(CH("PARTNER"), "Who is this 'Citra' everyone keeps talking about?")
WINDOW:KeyWait()

WINDOW:CloseMessage()
WINDOW:RemoveFace()

SOUND:PlaySe(SymSnd("SE_EVT_NYASUPAA_ALERT"), Volume(80))
TASK:Sleep(TimeSec(1))
SOUND:PlaySe(SymSnd("SE_EVT_SIGN_NOTICE_LOW_02"), Volume(200))
CH("Doc"):SetManpu("MP_EXCLAMATION")
TASK:Sleep(TimeSec(0.8))
CH("Doc"):SetNeckRot3(50,0,0, TimeSec(0.3))
TASK:Sleep(TimeSec(1.8))
CH("Doc"):ResetNeckRot(TimeSec(0.3))

WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.NORMAL)
CH("PARTNER"):SetFacialMotion(FACIAL_MOTION.NORMAL)
WINDOW_Talk(SymWord(""), "I'd love to stick around to tell you, but I've got\nto run.")
WINDOW:KeyWait()
WINDOW_Talk(SymWord(""), "But don't worry, I'll still be around.[K]  Somehwere.")
WINDOW:KeyWait()

WINDOW:DrawFace(324, 88, SymAct("WARUBIRU"), FACE_TYPE.HAPPY)
CH("Doc"):SetFacialMotion(FACIAL_MOTION.HAPPY)
WINDOW_Talk(SymWord(""), "See you all later!")
WINDOW:KeyWait()

WINDOW:CloseMessage()
WINDOW:RemoveFace()

--<Doc walks off>--
CH("Doc"):SetFacialMotion(FACIAL_MOTION.NORMAL)
CH("HERO"):SetNeckRot3(0,-20,0, TimeSec(0.15))
TASK:Sleep(TimeSec(0.15))
CH("HERO"):ResetNeckRot(TimeSec(0.2))
TASK:Sleep(TimeSec(0.4))
CH("Doc"):WalkTo(SplinePath(Vector2(-33,-8), Vector2(-35,-14)), Speed(2))
TASK:Sleep(TimeSec(1))

--<duo turns back together, camera follows>--
CH("HERO"):DirTo(CH("PARTNER"), Speed(200), ROT_TYPE.NEAR)
CH("PARTNER"):DirTo(CH("HERO"), Speed(200), ROT_TYPE.NEAR)
CAMERA:MoveEye(Vector(-36.75, 3.49, 1.64), TimeSec(1.8), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
CAMERA:MoveTgt(Vector(-32.31, 1.18, 1.49), TimeSec(1.8), ACCEL_TYPE.LOW, DECEL_TYPE.LOW)
CAMERA:WaitMove()

WINDOW:DrawFace(20, 88, SymAct("KIBAGO"), FACE_TYPE.NORMAL)
WINDOW_Talk(CH("HERO"), "I guess we should go now too.")
WINDOW:KeyWait()
WINDOW_Talk(CH("HERO"), "We need to go check on everyone out in Paradise.")
WINDOW:KeyWait()
WINDOW_Talk(CH("HERO"), "I hope they haven't broken anything yet.")
WINDOW:KeyWait()

TASK:Regist(
  function()
    CH("PARTNER"):SetNeckRot3(0,-20,0, TimeSec(0.15))
    TASK:Sleep(TimeSec(0.15))
    CH("PARTNER"):ResetNeckRot(TimeSec(0.2))
    TASK:Sleep(TimeSec(0.2)) 
  end
)
WINDOW:DrawFace(324, 88, SymAct("TSUTAAJA"), FACE_TYPE.NORMAL)
WINDOW_Talk(CH("PARTNER"), "Oh yeah.[K]  Let's go.")
WINDOW:KeyWait()

WINDOW:CloseMessage()
WINDOW:RemoveFace()

CH("HERO"):WalkTo(Vector2(-23,-2), Speed(2))
CH("PARTNER"):WalkTo(Vector2(-23,-1.5), Speed(2))

TASK:Sleep(TimeSec(2))

  
WINDOW:CloseMessage()
WINDOW:RemoveFace()
TASK:Sleep(TimeSec(0.5))
SCREEN_A:FadeOut(TimeSec(0.5), true)

SOUND:FadeOutBgm(TimeSec(1))

CHARA:DynamicRemove("Doc")
CHARA:DynamicRemove("HERO")
CHARA:DynamicRemove("PARTNER")
CHARA:DynamicLoad("HERO", "HERO")
CHARA:DynamicLoad("PARTNER", "PARTNER")

GROUND:SetPokemonWarehouseHeroName(nameHero)
GROUND:SetPokemonWarehousePartnerName(namePartner)

CAMERA:SetEye(Vector(0, 5, 5))
CAMERA:SetTgt(Vector(0, 0, 0))
TASK:Sleep(TimeSec(1))
SOUND:FadeInBgm(SymSnd("BGM_EVE_WAIWAITOWN_01"), TimeSec(1), Volume(200))
SCREEN_A:FadeIn(TimeSec(0.5), true)
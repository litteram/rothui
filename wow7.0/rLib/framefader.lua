
-- rLib: framefader
-- zork, 2016

-----------------------------
-- Variables
-----------------------------

local A, L = ...

local SpellFlyout = SpellFlyout

-----------------------------
-- Functions
-----------------------------

local function FaderOnFinished(self)
  self.__owner:SetAlpha(self.finAlpha)
end

local function CreateFaderAnimation(frame)
  if frame.fader then return end
  frame.fader = frame:CreateAnimationGroup()
  frame.fader.__owner = frame
  frame.fader.direction = nil
  frame.fader.anim = frame.fader:CreateAnimation("Alpha")
  frame.fader:HookScript("OnFinished", FaderOnFinished)
end

local function StartFadeIn(frame)
  if frame.fader.direction == "in" then return end
  frame.fader:Pause()
  frame.fader.anim:SetFromAlpha(frame:GetAlpha())
  frame.fader.anim:SetToAlpha(frame.faderConfig.fadeInAlpha)
  frame.fader.anim:SetDuration(frame.faderConfig.fadeInDuration)
  frame.fader.anim:SetSmoothing(frame.faderConfig.fadeInSmooth)
  frame.fader.finAlpha = frame.faderConfig.fadeInAlpha
  frame.fader.direction = "in"
  frame.fader:Play()
end

local function StartFadeOut(frame)
  if frame.fader.direction == "out" then return end
  frame.fader:Pause()
  frame.fader.anim:SetFromAlpha(frame:GetAlpha())
  frame.fader.anim:SetToAlpha(frame.faderConfig.fadeOutAlpha)
  frame.fader.anim:SetDuration(frame.faderConfig.fadeOutDuration)
  frame.fader.anim:SetSmoothing(frame.faderConfig.fadeOutSmooth)
  frame.fader.finAlpha = frame.faderConfig.fadeOutAlpha
  frame.fader.direction = "out"
  frame.fader:Play()
end

local function IsMouseOverFrame(frame)
  if MouseIsOver(frame) then return true end
  if not SpellFlyout:IsShown() then return false end
  if not SpellFlyout.__faderParent then return false end
  if SpellFlyout.__faderParent == frame and MouseIsOver(SpellFlyout) then return true end
  return false
end

local function FrameHandler(frame)
  if IsMouseOverFrame(frame) then
    StartFadeIn(frame)
  else
    StartFadeOut(frame)
  end
end

local function OffFrameHandler(self)
  if not self.__faderParent then return end
  FrameHandler(self.__faderParent)
end

local function SpellFlyoutOnShow(self)
  local frame = self:GetParent():GetParent():GetParent()
  if not frame.fader then return end
  --set new frame parent
  self.__faderParent = frame
  if not self.__faderHook then
    SpellFlyout:HookScript("OnEnter", OffFrameHandler)
    SpellFlyout:HookScript("OnLeave", OffFrameHandler)
    self.__faderHook = true
  end
  for i=1, NUM_ACTIONBAR_BUTTONS do --hopefully 12 is enough
    local button = _G["SpellFlyoutButton"..i]
    if not button then break end
    button.__faderParent = frame
    if not button.__faderHook then
      button:HookScript("OnEnter", OffFrameHandler)
      button:HookScript("OnLeave", OffFrameHandler)
      button.__faderHook = true
    end
  end
end
SpellFlyout:HookScript("OnShow", SpellFlyoutOnShow)

function rLib:CreateFrameFader(frame, faderConfig)
  if frame.faderConfig then return end
  frame.faderConfig = faderConfig
  frame:EnableMouse(true)
  CreateFaderAnimation(frame)
  frame:HookScript("OnEnter", FrameHandler)
  frame:HookScript("OnLeave", FrameHandler)
  FrameHandler(frame)
end

function rLib:CreateButtonFrameFader(frame, buttonList, faderConfig)
  rLib:CreateFrameFader(frame, faderConfig)
  for i, button in next, buttonList do
    if not button.__faderParent then
      button.__faderParent = frame
      button:HookScript("OnEnter", OffFrameHandler)
      button:HookScript("OnLeave", OffFrameHandler)
    end
  end
end

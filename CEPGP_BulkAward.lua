local CEPGPBA_AddonName, _addon = ... -- addonName="CEPGP_BulkAward"
CEPGPBA                         = {};

local function CreateButton(parent)
  local button
  button = CreateFrame("Button", nil, parent)
  button:SetNormalFontObject("GameFontNormal")

  local ntex
  ntex = button:CreateTexture()
  ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
  ntex:SetTexCoord(0, 0.625, 0, 0.6875)
  ntex:SetAllPoints()
  button:SetNormalTexture(ntex)

  local htex
  htex = button:CreateTexture()
  htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
  htex:SetTexCoord(0, 0.625, 0, 0.6875)
  htex:SetAllPoints()
  button:SetHighlightTexture(htex)

  local ptex
  ptex = button:CreateTexture()
  ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
  ptex:SetTexCoord(0, 0.625, 0, 0.6875)
  ptex:SetAllPoints()
  button:SetPushedTexture(ptex)

  return button
end

function CEPGPBA_OnApplyChanges(text)
  -- Split text into lines
  local input
  input = {}

  for ln in string.gmatch(text, "[^\r\n]+") do
    local player, amount, msg
    player, amount, msg = string.match(ln, "(%a+),(-?%d+),(.*)")
    do
      CEPGP_addEP(player, tonumber(amount), msg)
    end

    if _G["CEPGP_traffic"]:IsVisible() then
      CEPGP_UpdateTrafficScrollBar();
    end
  end -- end for all lines
end

function CEPGPBA_Initialise()
  -- Create interface options panel
  local panel
  panel      = CreateFrame("FRAME");
  panel.name = "CEPGP Bulk Award";

  local titleText
  titleText  = panel:CreateFontString("CEPGP_BA_titleText", "OVERLAY", "GameFontNormalLarge");
  titleText:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -15);
  titleText:SetText("CEPGP Bulk Operations: Mass Awards");

  local taskBox
  taskBox = CreateFrame("ScrollFrame", "CEPGP_BA_Task", panel, "InputScrollFrameTemplate")
  taskBox:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -10);
  taskBox:SetSize(500, 300)

  local taskBoxEditFrame
  taskBoxEditFrame = taskBox.EditBox:GetParent();
  taskBox.EditBox:SetPoint("BOTTOMRIGHT", taskBoxEditFrame, "BOTTOMRIGHT", 0, 0);
  taskBox.EditBox:SetPoint("BOTTOMLEFT", taskBoxEditFrame, "BOTTOMLEFT", 0, 0);
  taskBox.EditBox:SetPoint("TOPRIGHT", taskBoxEditFrame, "TOPRIGHT", 0, 0);
  taskBox.EditBox:SetPoint("TOPLEFT", taskBoxEditFrame, "TOPLEFT", 0, 0);
  taskBox.EditBox:SetFontObject("ChatFontNormal")
  taskBox.EditBox:SetCursorPosition(0)
  taskBox.EditBox.cursorOffset = 0
  taskBox.EditBox:SetMaxLetters(20000)
  taskBox.CharCount:Hide()

  -- Apply Button --
  local button
  button = CreateButton(panel)
  button:SetPoint("TOPLEFT", taskBox, "BOTTOMLEFT", 0, -10)
  button:SetWidth(150)
  button:SetHeight(25)
  button:SetText("Apply Changes")
  button:SetScript("OnClick",
      function()
        CEPGPBA_OnApplyChanges(taskBox.EditBox:GetText())
      end)

  InterfaceOptions_AddCategory(panel);

  -- Register plugin with CEPGP

  CEPGP_addPlugin(addonName, panel, true, function()
  end);
end

function CEPGPBA_OnEvent(self, event, arg1)
  if event == "ADDON_LOADED" and arg1 == CEPGPBA_AddonName then
    CEPGPBA_Initialise();
  end
end

function CEPGPBA_CreateFrames()
  local mainFrame
  mainFrame = CreateFrame("Frame", "CEPGP_BA_award_raid_popup", _G["CEPGP_award_raid_popup"]);
  mainFrame:SetScale(1.0);

  mainFrame:RegisterEvent("ADDON_LOADED");
  mainFrame:SetScript("OnEvent", CEPGPBA_OnEvent);
end

-- START HERE --
CEPGPBA_CreateFrames();

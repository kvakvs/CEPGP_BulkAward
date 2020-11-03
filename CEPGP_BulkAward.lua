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

local function CreateMultilineEditBox(parent)
  local backdrop = {
    bgFile   = "Interface/BUTTONS/WHITE8X8",
    edgeFile = "Interface/GLUES/Common/Glue-Tooltip-Border",
    tile     = true,
    edgeSize = 8,
    tileSize = 8,
    insets   = {
      left   = 5,
      right  = 5,
      top    = 5,
      bottom = 5,
    },
  }

  local f        = CreateFrame("Frame", "$parent_MultilineEdit", parent)
  f:SetSize(500, 300)
  --f:SetPoint("CENTER")
  f:SetFrameStrata("BACKGROUND")
  f:SetBackdrop(backdrop)
  f:SetBackdropColor(0, 0, 0)

  f.SF = CreateFrame("ScrollFrame", "$parent_ScrollFrame", f, "UIPanelScrollFrameTemplate")
  f.SF:SetPoint("TOPLEFT", f, 12, -30)
  f.SF:SetPoint("BOTTOMRIGHT", f, -30, 10)

  f.Text = CreateFrame("EditBox", "$parent_Edit", f)
  f.Text:SetMultiLine(true)
  f.Text:SetSize(500, 300)
  f.Text:SetPoint("TOPLEFT", f.SF)
  f.Text:SetPoint("BOTTOMRIGHT", f.SF)
  f.Text:SetMaxLetters(99999)
  f.Text:SetFontObject(GameFontNormal)
  f.Text:SetAutoFocus(false) -- do not steal focus from the game
  f.Text:SetScript("OnEscapePressed",
      function(self)
        self:ClearFocus()
      end)
  f.SF:SetScrollChild(f.Text)

  return f
end

function CEPGPBA_OnApplyChanges(text)
  if text == nil then
    print("CEPGP_BA: Something went wrong, can't get the task text from the editbox")
    return
  end

  -- Split text into lines
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
  taskBox = CreateMultilineEditBox(panel)
  taskBox:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -10);

  -- Apply Button --
  local okButton
  okButton = CreateButton(panel)
  okButton:SetPoint("TOPLEFT", taskBox, "BOTTOMLEFT", 0, -10)
  okButton:SetWidth(150)
  okButton:SetHeight(25)
  okButton:SetText("Apply Changes")
  okButton:SetScript("OnClick", function()
    CEPGPBA_OnApplyChanges(taskBox.Text:GetText())
  end)

  local clearButton = CreateButton(panel)
  clearButton:SetPoint("TOPLEFT", okButton, "TOPRIGHT", 10, 0)
  clearButton:SetWidth(100)
  clearButton:SetHeight(25)
  clearButton:SetText("Clear")
  clearButton:SetScript("OnClick", function()
    taskBox.Text:SetText("")
  end)

  taskBox.Text:SetFocus()

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

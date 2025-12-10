-- RedzStyle.lua - النسخة النهائية
-- رابط مباشر: loadstring(game:HttpGet("https://raw.githubusercontent.com/MrQattusa/RedzUI/main/RedzStyle.lua"))()

local MrQattusa = {}
MrQattusa.Version = "RedzStyle 3.0"
MrQattusa.Author = "Mr.Qattusa"
MrQattusa.Loaded = false

-- مكتبات النظام
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- رسالة البدء
print([[
╔══════════════════════════════════════════╗
║        🐱 Mr.Qattusa Redz Style         ║
║           النسخة النهائية 3.0           ║
║   GitHub: MrQattusa/RedzUI              ║
╚══════════════════════════════════════════╝
]])

-- نظام سيوف البحر
function MrQattusa.SeaSwords()
    print("⚔️ تفعيل سيوف البحر...")
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    
    -- إنشاء 10 سيوف
    for i = 1, 10 do
        local Sword = Instance.new("Part")
        Sword.Name = "SeaSword_" .. i
        Sword.Shape = Enum.PartType.Block
        Sword.Material = Enum.Material.Metal
        Sword.Color = Color3.fromRGB(100, 150, 255)
        Sword.Size = Vector3.new(1, 5, 1)
        Sword.CFrame = HumanoidRootPart.CFrame * 
                      CFrame.new(math.random(-10, 10), 0, math.random(-10, 10)) *
                      CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
        Sword.CanCollide = false
        Sword.Transparency = 0.3
        Sword.Parent = workspace
        
        -- جعل السيف يدور
        local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
        BodyAngularVelocity.AngularVelocity = Vector3.new(0, 10, 0)
        BodyAngularVelocity.MaxTorque = Vector3.new(10000, 10000, 10000)
        BodyAngularVelocity.Parent = Sword
        
        -- حركة السيف للأمام
        Sword.Velocity = HumanoidRootPart.CFrame.LookVector * 50 + 
                        Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
        
        -- تدمير السيف بعد 5 ثواني
        game:GetService("Debris"):AddItem(Sword, 5)
        
        -- كشف التصادم
        Sword.Touched:Connect(function(hit)
            local Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
            if Humanoid and hit.Parent ~= Character then
                Humanoid:TakeDamage(25)
            end
        end)
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "سيوف البحر",
        Text = "تم إطلاق 10 سيوف بحرية!",
        Duration = 3
    })
end

-- نظام الهدم
function MrQattusa.Destroy()
    print("💥 تفعيل نظام الهدم...")
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    
    -- انفجار كبير
    local Explosion = Instance.new("Explosion")
    Explosion.Position = HumanoidRootPart.Position
    Explosion.BlastRadius = 25
    Explosion.BlastPressure = 100000
    Explosion.ExplosionType = Enum.ExplosionType.CratersAndDebris
    Explosion.DestroyJointRadiusPercent = 1
    Explosion.Parent = workspace
    
    -- تأثيرات بصرية
    local Fire = Instance.new("Fire")
    Fire.Size = 10
    Fire.Heat = 25
    Fire.Parent = HumanoidRootPart
    
    local Smoke = Instance.new("Smoke")
    Smoke.Size = 5
    Smoke.Opacity = 0.5
    Smoke.Parent = HumanoidRootPart
    
    -- تدمير التأثيرات بعد 3 ثواني
    game:GetService("Debris"):AddItem(Fire, 3)
    game:GetService("Debris"):AddItem(Smoke, 3)
    
    -- ضرر للاعبين القريبين
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local TargetRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            if TargetRoot then
                local Distance = (TargetRoot.Position - HumanoidRootPart.Position).Magnitude
                if Distance < 25 then
                    local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                    if Humanoid then
                        Humanoid:TakeDamage(50)
                    end
                end
            end
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "نظام الهدم",
        Text = "انفجار تدميري تم تفعيله!",
        Duration = 3
    })
end

-- نظام التلفيل
function MrQattusa.Teleport()
    print("🎯 تفعيل التلفيل السريع...")
    
    local NearestPlayer = nil
    local NearestDistance = math.huge
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    
    -- البحث عن أقرب لاعب
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local TargetRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            if TargetRoot then
                local Distance = (TargetRoot.Position - HumanoidRootPart.Position).Magnitude
                if Distance < NearestDistance then
                    NearestDistance = Distance
                    NearestPlayer = Player
                end
            end
        end
    end
    
    -- التلفيل للاعب الأقرب
    if NearestPlayer and NearestPlayer.Character then
        local TargetRoot = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
        if TargetRoot then
            HumanoidRootPart.CFrame = TargetRoot.CFrame
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "التلفيل السريع",
                Text = "تم التلفيل إلى: " .. NearestPlayer.Name,
                Duration = 3
            })
            return true
        end
    end
    
    -- إذا لم يوجد لاعب قريب، تلفيل عشوائي
    local RandomCFrame = CFrame.new(
        math.random(-500, 500),
        50,
        math.random(-500, 500)
    )
    HumanoidRootPart.CFrame = RandomCFrame
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "التلفيل السريع",
        Text = "تم التلفيل لموقع عشوائي",
        Duration = 3
    })
    
    return false
end

-- نظام الفواكه
function MrQattusa.Fruits()
    print("🍓 تفعيل عاصفة الفواكه...")
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    
    -- ألوان الفواكه
    local FruitColors = {
        Color3.fromRGB(255, 100, 100),  -- أحمر
        Color3.fromRGB(100, 255, 100),  -- أخضر
        Color3.fromRGB(100, 100, 255),  -- أزرق
        Color3.fromRGB(255, 255, 100),  -- أصفر
        Color3.fromRGB(255, 100, 255)   -- بنفسجي
    }
    
    -- إطلاق 20 فاكهة
    for i = 1, 20 do
        local Fruit = Instance.new("Part")
        Fruit.Name = "Fruit_" .. i
        Fruit.Shape = Enum.PartType.Ball
        Fruit.Material = Enum.Material.Neon
        Fruit.Color = FruitColors[math.random(1, #FruitColors)]
        Fruit.Size = Vector3.new(2, 2, 2)
        Fruit.CFrame = HumanoidRootPart.CFrame * 
                      CFrame.new(math.random(-15, 15), math.random(5, 20), math.random(-15, 15))
        Fruit.CanCollide = false
        Fruit.Transparency = 0.2
        Fruit.Parent = workspace
        
        -- حركة عشوائية
        Fruit.Velocity = Vector3.new(
            math.random(-30, 30),
            math.random(10, 30),
            math.random(-30, 30)
        )
        
        -- دوران الفاكهة
        local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
        BodyAngularVelocity.AngularVelocity = Vector3.new(
            math.random(-10, 10),
            math.random(-10, 10),
            math.random(-10, 10)
        )
        BodyAngularVelocity.MaxTorque = Vector3.new(10000, 10000, 10000)
        BodyAngularVelocity.Parent = Fruit
        
        -- تدمير الفاكهة بعد 6 ثواني
        game:GetService("Debris"):AddItem(Fruit, 6)
        
        -- كشف التصادم
        Fruit.Touched:Connect(function(hit)
            local Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
            if Humanoid and hit.Parent ~= Character then
                Humanoid:TakeDamage(15)
                Fruit:Destroy()
            end
        end)
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "عاصفة الفواكه",
        Text = "تم إطلاق 20 فاكهة متفجرة!",
        Duration = 3
    })
end

-- نظام السرعة
function MrQattusa.Speed()
    print("🚀 تفعيل نظام السرعة...")
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    
    -- زيادة السرعة إلى 100
    Humanoid.WalkSpeed = 100
    
    -- تأثيرات بصرية للسرعة
    local SpeedTrail = Instance.new("Trail")
    SpeedTrail.Color = ColorSequence.new(Color3.fromRGB(255, 100, 100))
    SpeedTrail.Lifetime = 0.5
    SpeedTrail.Parent = HumanoidRootPart
    
    local SpeedLight = Instance.new("PointLight")
    SpeedLight.Color = Color3.fromRGB(255, 100, 100)
    SpeedLight.Range = 20
    SpeedLight.Brightness = 5
    SpeedLight.Parent = HumanoidRootPart
    
    -- إرجاع السرعة بعد 30 ثانية
    game:GetService("Debris"):AddItem(SpeedTrail, 30)
    game:GetService("Debris"):AddItem(SpeedLight, 30)
    
    delay(30, function()
        if Humanoid then
            Humanoid.WalkSpeed = 16
        end
    end)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "نظام السرعة",
        Text = "تم تفعيل السرعة ×6 لمدة 30 ثانية!",
        Duration = 3
    })
end

-- واجهة Redz Style
function MrQattusa.CreateRedzUI()
    print("🎮 جاري إنشاء واجهة Redz Style...")
    
    -- الواجهة الرئيسية
    local RedzGUI = Instance.new("ScreenGui")
    RedzGUI.Name = "RedzStyleGUI"
    RedzGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    RedzGUI.DisplayOrder = 999
    
    if syn and syn.protect_gui then
        syn.protect_gui(RedzGUI)
    end
    
    -- القط الأساسي
    local CatButton = Instance.new("TextButton")
    CatButton.Name = "CatButton"
    CatButton.Size = UDim2.new(0, 80, 0, 80)
    CatButton.Position = UDim2.new(0, 20, 0.5, -40)
    CatButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CatButton.BackgroundTransparency = 0.2
    CatButton.Text = "🐱"
    CatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CatButton.Font = Enum.Font.GothamBold
    CatButton.TextSize = 30
    CatButton.ZIndex = 2
    
    local CatCorner = Instance.new("UICorner")
    CatCorner.CornerRadius = UDim.new(0.3, 0)
    CatCorner.Parent = CatButton
    
    -- القائمة الرئيسية
    local MainMenu = Instance.new("Frame")
    MainMenu.Name = "MainMenu"
    MainMenu.Size = UDim2.new(0, 400, 0, 350)
    MainMenu.Position = UDim2.new(0, 110, 0.5, -175)
    MainMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainMenu.BackgroundTransparency = 0.1
    MainMenu.Visible = false
    
    local MenuCorner = Instance.new("UICorner")
    MenuCorner.CornerRadius = UDim.new(0.05, 0)
    MenuCorner.Parent = MainMenu
    
    -- شريط العنوان
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = "🐱 Mr.Qattusa Redz Style"
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    TitleBar.Parent = MainMenu
    
    -- قائمة الخيارات
    local Options = {
        {"⚔️ سيوف البحر", MrQattusa.SeaSwords, Color3.fromRGB(100, 150, 255)},
        {"💥 نظام الهدم", MrQattusa.Destroy, Color3.fromRGB(255, 100, 100)},
        {"🎯 التلفيل السريع", MrQattusa.Teleport, Color3.fromRGB(100, 255, 150)},
        {"🍓 عاصفة الفواكه", MrQattusa.Fruits, Color3.fromRGB(255, 150, 100)},
        {"🚀 نظام السرعة", MrQattusa.Speed, Color3.fromRGB(200, 100, 255)},
        {"⚙️ الإعدادات", function() 
            print("⚙️ فتح الإعدادات...")
        end, Color3.fromRGB(150, 150, 200)}
    }
    
    -- إنشاء أزرار الخيارات
    for i, option in ipairs(Options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = "Option_" .. i
        OptionButton.Text = option[1]
        OptionButton.Size = UDim2.new(0.9, 0, 0, 45)
        OptionButton.Position = UDim2.new(0.05, 0, 0.1 + (i-1) * 0.15, 0)
        OptionButton.BackgroundColor3 = option[3]
        OptionButton.BackgroundTransparency = 0.3
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.Font = Enum.Font.GothamBold
        OptionButton.TextSize = 16
        
        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0.1, 0)
        OptionCorner.Parent = OptionButton
        
        -- تنفيذ الخيار عند النقر
        OptionButton.MouseButton1Click:Connect(function()
            option[2]()
            MainMenu.Visible = false
        end)
        
        OptionButton.Parent = MainMenu
    end
    
    -- زر إغلاق
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Text = "✕ إغلاق"
    CloseButton.Size = UDim2.new(0.9, 0, 0, 40)
    CloseButton.Position = UDim2.new(0.05, 0, 0.85, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0.1, 0)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        MainMenu.Visible = false
    end)
    
    CloseButton.Parent = MainMenu
    
    -- فتح/إغلاق القائمة
    CatButton.MouseButton1Click:Connect(function()
        MainMenu.Visible = not MainMenu.Visible
    end)
    
    -- إضافة العناصر للشاشة
    CatButton.Parent = RedzGUI
    MainMenu.Parent = RedzGUI
    RedzGUI.Parent = game:GetService("CoreGui")
    
    -- حركة القط
    coroutine.wrap(function()
        while RedzGUI.Parent do
            wait(5)
            local randomX = math.random(-20, 20)
            local randomY = math.random(-20, 20)
            
            CatButton:TweenPosition(
                UDim2.new(0, 20 + randomX, 0.5, -40 + randomY),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Sine,
                2
            )
        end
    end)()
    
    print("✅ واجهة Redz Style تم إنشاؤها بنجاح!")
    return RedzGUI
end

-- تفعيل النظام كاملاً
function MrQattusa.ActivateAll()
    print("🚀 تفعيل جميع أنظمة Mr.Qattusa...")
    
    -- إنشاء الواجهة
    MrQattusa.CreateRedzUI()
    
    -- تنبيه البدء
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mr.Qattusa Redz Style",
        Text = "تم التحميل بنجاح! اضغط على القطط",
        Duration = 5
    })
    
    MrQattusa.Loaded = true
    print("✅ Mr.Qattusa Redz Style جاهز للاستخدام!")
end

-- التحميل التلقائي
MrQattusa.ActivateAll()

return MrQattusa

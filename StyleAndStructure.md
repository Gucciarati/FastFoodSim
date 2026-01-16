# Fast Food Sim - Code Style & Structure Guide

**Version:** 1.0  
**Last Updated:** January 15, 2026

---

## Table of Contents
1. [Project Philosophy](#project-philosophy)
2. [Directory Structure](#directory-structure)
3. [Naming Conventions](#naming-conventions)
4. [Code Style](#code-style)
5. [Module Patterns](#module-patterns)
6. [Architecture Patterns](#architecture-patterns)
7. [State Management](#state-management)
8. [Best Practices](#best-practices)

---

## Project Philosophy

### Core Principles
1. **Type Safety First:** All new code uses `--!strict` mode
2. **Separation of Concerns:** Clear client/server/shared boundaries
3. **Reusability:** Shared modules for common logic
4. **Maintainability:** Consistent patterns across codebase
5. **Performance:** Efficient code, minimal memory leaks

### Technology Stack
- **Luau** with strict type checking
- **Argon** for filesystem sync
- **Selene** for linting (configured in `selene.toml`)
- **Vendor libraries** for common utilities

---

## Directory Structure

```
src/
├── ReplicatedFirst/
│   └── Vendor/                    # Third-party utility libraries
│       ├── AnimationUtil.luau
│       ├── BCAS.luau             # Button Context Action System
│       ├── CameraShake.luau
│       ├── ConnectUtil.luau      # Connection helpers
│       ├── Find.luau
│       ├── LemonSignal.luau      # Custom signals
│       ├── Spring/               # Physics-based animations
│       ├── TableUtil.luau
│       ├── Tagged.luau           # CollectionService wrapper
│       └── ... (15+ utilities)
│
├── ReplicatedStorage/
│   ├── ClientMain.server.luau    # Client entry point
│   ├── Global.luau               # Global constants/enums
│   │
│   ├── Client/                   # Client-only modules
│   │   ├── PlacementClient.luau
│   │   └── GUI/
│   │       ├── Modals.luau       # Modal management
│   │       └── Computer/
│   │           ├── ComputerMainClient.luau
│   │           └── MarketClient.luau
│   │
│   ├── Config/                   # Game configuration
│   │   └── ProductsConfig.luau   # All purchasable items
│   │
│   ├── SharedModules/            # Shared between client & server
│   │   ├── GuiShared.luau        # GUI utilities
│   │   ├── PlacementShared.luau
│   │   ├── PlayerShared.luau     # Player profile logic
│   │   ├── ProductShared.luau
│   │   └── RestaurantShared.luau # Restaurant management
│   │
│   └── Utils/                    # General utilities
│       ├── CreateRegistry.luau
│       ├── GenericStateMachine.luau
│       ├── RegisterModule.luau   # Module loader
│       ├── ReplicatedEvent.luau
│       ├── RequireAttribute.luau # Attribute helper
│       ├── SFXUtil.luau
│       └── StateMachine.luau
│
├── ServerScriptService/
│   ├── ServerMain.server.luau    # Server entry point
│   └── Server/                   # Server-only modules
│       ├── PlayerServer.luau
│       └── RestaurantServer.luau
│
├── ServerStorage/                # Server-only assets
├── StarterGui/                   # UI ScreenGuis
├── StarterPlayer/                # Character/player scripts
└── Workspace/                    # 3D world assets
```

### Directory Rules

**ReplicatedFirst/Vendor/**
- Only third-party/reusable utilities
- No game-specific logic
- Document external sources in comments

**ReplicatedStorage/Client/**
- Client-only code
- Can access ReplicatedStorage and ReplicatedFirst
- Cannot access ServerScriptService or ServerStorage

**ReplicatedStorage/SharedModules/**
- Logic that runs on both client and server
- No `game:GetService("Players").LocalPlayer` usage
- No server-only services (ServerStorage, ServerScriptService)

**ServerScriptService/Server/**
- Server-authoritative logic
- Security-critical code
- Can access all services

---

## Naming Conventions

### Files
- **PascalCase** for all files: `PlayerShared.luau`, `MarketClient.luau`
- **Descriptive suffixes:**
  - `*Server.luau` - Server-only modules
  - `*Client.luau` - Client-only modules
  - `*Shared.luau` - Shared modules
  - `*Config.luau` - Configuration files
  - `*Util.luau` - Utility libraries

### Variables
```luau
-- PascalCase for services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

-- PascalCase for required modules
local PlayerShared = require(Shared.PlayerShared)
local GuiShared = require(Shared.GuiShared)

-- camelCase for local variables
local playerProfile = {}
local restaurantName = "Test"

-- PascalCase for constants/enums
local MAX_PLAYERS = 100
local DEFAULT_CASH = 200

-- PascalCase for types
export type PlayerProfile = { ... }
export type RestaurantAssembly = typeof(...)
```

### Functions
```luau
-- camelCase for all functions
function module.spawnPlayerRestaurant(owner: Player) end
function module.getPlayerProfile() end
local function calculateProfit() end
```

### Constants and Enums
```luau
-- Stored in Global.luau
local Attributes = {
    GameState = {
        ServerInitialized = "ServerInitialized",
    },
}

local Enums = {
    CurrencyEnums = {
        Robux = "Robux",
        Money = "Money",
    },
    ProductCategories = {
        Food        = "Food",
        Appliances  = "Appliances",
        Furniture   = "Furniture",
        Decoration  = "Decoration",
    },
}
```

### Tags and Attributes
```luau
-- Module-local constants with descriptive names
local module = {
    Attributes = {
        Owner = "Owner",
        VacantPlot = "VacantPlot",
    },
    Tags = {
        OpenRestaurant = "OpenRestaurant",
        PlacementArea  = "PlacementArea",
    },
}
```

---

## Code Style

### File Header
```luau
--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ReplicatedFirst     = game:GetService('ReplicatedFirst')
local Players             = game:GetService('Players')

local Shared              = ReplicatedStorage:WaitForChild('SharedModules')
local Utils               = ReplicatedStorage:WaitForChild('Utils')
local Vendor              = ReplicatedFirst.Vendor

local PlayerShared        = require(Shared.PlayerShared)
local RequireAttribute    = require(Utils.RequireAttribute)
```

**Order:**
1. `--!strict` type mode
2. Service imports (grouped)
3. Folder references
4. Module requires

### Spacing and Formatting
```luau
-- Use tabs for indentation (project standard)
-- Single blank line between logical sections
-- Align assignments for readability

function module.exampleFunction(param1: string, param2: number): boolean
	local result = false
	
	if param2 > 0 then
		result = true
	end
	
	return result
end
```

### Comments
```luau
-- Single-line comments with proper spacing

--[=[
	Multi-line documentation comments
	Use this style for function documentation
	
	@param player Player - The player instance
	@param amount number - The amount of cash
	@return boolean - Success status
]=]
function module.giveCash(player: Player, amount: number): boolean
	-- Implementation
end

-- TODO: comments for incomplete features
-- TODO: add a second argument to pass the data of the player from the database
```

### Type Annotations
```luau
-- Always annotate function parameters and returns
function module.setPlayerProfile(player: Player): PlayerProfile
	-- ...
end

-- Export types for external use
export type PlayerProfile = {
	XP       : number,
	Tutorial : number,
	Cash     : number,
	TemporaryGamePasses : {
		AutoCollect : number,
		DoubleCash  : number,
	}	
}

-- Use typeof() for instance types
export type RestaurantAssembly = typeof(RestaurantAssets['1'])

-- Type function parameters
type SidebarButtonAssembly = typeof(ComputerFrame.Sidebar.Boosts)
```

---

## Module Patterns

### Standard Module Structure
```luau
--!strict
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Imports here

-- Type definitions
export type ModuleData = {
	property: string,
}

-- Module table with constants
local module = {
	Attributes = {
		ExampleAttr = "ExampleAttr",
	},
	Tags = {
		ExampleTag = "ExampleTag",
	},
}

-- Private functions
local function privateHelper(value: string): number
	return #value
end

-- Public functions
function module.publicFunction(param: string): ModuleData
	return {
		property = param,
	}
end

-- Return module
return module
```

### Script Entry Points
```luau
--!strict
local ReplicatedStorage   = game:GetService('ReplicatedStorage')
local ServerScriptService = script.Parent
local Global              = require(ReplicatedStorage:WaitForChild('Global'))

local ServerModules = ServerScriptService.Server
local Utils         = ReplicatedStorage:WaitForChild('Utils')

local RegisterModules = require(Utils.RegisterModule)

local modules = {
	ServerModules.PlayerServer,
	ServerModules.RestaurantServer,
} :: {ModuleScript}

RegisterModules.requireModules(modules)

-- Optional: Set initialization flag
local GameState = ReplicatedStorage:WaitForChild('GameState')
GameState:SetAttribute(Global.Attributes.GameState.ServerInitialized, true)
```

### Client Scripts (Return True Pattern)
```luau
--!strict
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players           = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer.PlayerGui

-- Client initialization code here
-- Set up connections, UI, etc.

-- Return true to indicate module loaded successfully
return true
```

---

## Architecture Patterns

### Module Registration System
Uses `RegisterModule.requireModules()` to load multiple modules:

```luau
-- Supports folder hierarchies
local modules = {
	ServerModules.PlayerServer,
	ServerModules.RestaurantServer,
	ClientModules.GUI, -- Can be a folder of modules
} :: {ModuleScript}

RegisterModules.requireModules(modules)
```

**Features:**
- Automatically recurses into folders
- Checks `Enabled` attribute (can disable modules)
- Calls optional `init()` function if module has one
- Error handling with warnings

### Attribute Management
Use `RequireAttribute` to ensure attributes exist:

```luau
local RequireAttribute = require(Utils.RequireAttribute)

-- Set attribute with default if it doesn't exist
local xp = RequireAttribute.requireAttribute(player, "XP", 0)

-- Force set (4th parameter = true)
RequireAttribute.requireAttribute(plot, "VacantPlot", false, true)
```

### Tag-Based Architecture
Use `Tagged` (vendor) for tag observation:

```luau
local Tagged = require(Vendor.Tagged)

-- Observe all instances with tag
Tagged.observe(GuiShared.Tags.LeftSidebarButton, function(button)
	-- Setup button
	button.Activated:Connect(function()
		-- Handle click
	end)
	
	-- Return cleanup function (optional)
	return function()
		-- Cleanup when tag removed
	end
end)
```

### State Management with ValueObjects
```luau
-- State stored in ReplicatedStorage.GameState
local OpenModalState = ReplicatedStorage.GameState.OpenModal -- StringValue

-- React to state changes
local Connect = require(Vendor.ConnectUtil)

Connect.valueChanged(OpenModalState, function(currentValue, previousValue)
	print(`Modal changed from {previousValue} to {currentValue}`)
end, false) -- false = don't fire immediately
```

### GUI System
```luau
local GuiShared = require(Shared.GuiShared)

-- Open modal with animation
GuiShared.open(modalFrame, UDim2.fromScale(1, 1))

-- Close modal with animation
GuiShared.close(modalFrame)

-- Toggle visibility
GuiShared.toggleVisibility(frames, true)

-- Toggle all except one
GuiShared.toggleVisibilityExcept(frames, "Market", false)
```

---

## State Management

### Global State (GameState)
Located in `ReplicatedStorage.GameState`, contains `ValueObjects`:

```luau
GameState/
├── OpenModal (StringValue)
├── CurrentComputerTab (StringValue)
└── [other state values]
```

**Usage:**
```luau
-- Server sets state
OpenModalState.Value = "Computer"

-- Client reacts to state
Connect.valueChanged(OpenModalState, function(curr, prev)
	-- Update UI
end)
```

### Player State (Attributes)
Stored as attributes on Player instance:

```luau
-- Set via PlayerShared
local profile = PlayerShared.setPlayerProfile(player)

-- Access directly
local cash = player:GetAttribute("Cash")
local xp = player:GetAttribute("XP")

-- React to changes
Connect.attributeChanged(player, "Cash", function(newValue)
	-- Update UI
end)
```

### Restaurant State
Stored as attributes on restaurant Model:

```luau
-- Owner tracking
RequireAttribute.requireAttribute(restaurant, "Owner", player.UserId)

-- Open/closed state via CollectionService tag
restaurant:AddTag("OpenRestaurant")
restaurant:RemoveTag("OpenRestaurant")
```

---

## Best Practices

### Type Safety
```luau
-- ✅ DO: Use strict mode
--!strict

-- ✅ DO: Annotate all functions
function module.calculate(x: number, y: number): number
	return x + y
end

-- ✅ DO: Export types for other modules
export type Config = { price: number }

-- ❌ DON'T: Use 'any' unless absolutely necessary
-- ❌ DON'T: Skip type annotations
```

### Error Handling
```luau
-- ✅ DO: Use pcall for risky operations
local success, result = pcall(function()
	return require(someModule)
end)

if not success then
	warn("Failed to load module:", result)
end

-- ✅ DO: Validate inputs
function module.giveMoney(player: Player, amount: number)
	assert(player, "Player is nil")
	assert(amount > 0, "Amount must be positive")
	-- ...
end

-- ✅ DO: Provide helpful error messages
if #vacantPlots == 0 then
	player:Kick('No vacant plots available')
	error('no vacant plots')
end
```

### Memory Management
```luau
-- ✅ DO: Clean up connections
local connection = part.Touched:Connect(function() end)
-- Later:
connection:Disconnect()

-- ✅ DO: Use Tagged.observe for cleanup
Tagged.observe("MyTag", function(instance)
	local connection = instance.Touched:Connect(function() end)
	
	-- Return cleanup function
	return function()
		connection:Disconnect()
	end
end)

-- ✅ DO: Clear tables when done
table.clear(myTable)
```

### Performance
```luau
-- ✅ DO: Cache frequently accessed values
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- ✅ DO: Use WaitForChild sparingly
local Shared = ReplicatedStorage:WaitForChild('SharedModules')
-- Then cache requires:
local PlayerShared = require(Shared.PlayerShared)

-- ❌ DON'T: Call WaitForChild in loops
for i = 1, 100 do
	-- BAD: workspace:WaitForChild(...)
end

-- ✅ DO: Use proper loop patterns
for _, child in workspace:GetChildren() do
	-- Process child
end
```

### Security
```luau
-- ✅ DO: Validate on server
-- Client sends request to buy item
RemoteEvent.OnServerEvent:Connect(function(player, itemName)
	-- Validate player has enough money
	local cash = player:GetAttribute("Cash")
	local item = ProductsConfig[itemName]
	
	if not item then
		warn("Invalid item:", itemName)
		return
	end
	
	if cash < item.price then
		warn("Not enough cash")
		return
	end
	
	-- Process purchase
end)

-- ❌ DON'T: Trust client data
-- ❌ DON'T: Let client set cash directly
```

### Code Organization
```luau
-- ✅ DO: Group related constants
local module = {
	Attributes = { ... },
	Tags = { ... },
	Constants = { ... },
}

-- ✅ DO: Separate concerns
-- PlayerShared: Player data only
-- RestaurantShared: Restaurant logic only
-- PlacementShared: Placement system only

-- ✅ DO: Use meaningful names
function module.spawnPlayerRestaurant() -- Clear
-- Not: function module.spr() -- Unclear

-- ✅ DO: Keep functions focused
-- Each function should do ONE thing well
```

### Documentation
```luau
-- ✅ DO: Document complex functions
--[=[
	Spawns a restaurant for the player on a vacant plot.
	
	Handles:
	- Finding vacant plot
	- Cloning restaurant template
	- Setting ownership
	- Initializing tutorial state
	
	@param owner Player - The player who will own the restaurant
	@param name string - Display name for the restaurant
	@return RestaurantAssembly - The spawned restaurant instance
	@error Kicks player if no plots available
]=]
function module.spawnPlayerRestaurant(owner: Player, name: string): RestaurantAssembly
	-- ...
end

-- ✅ DO: Mark incomplete features
-- TODO: implement placement system
-- TODO: add data persistence
```

---

## Anti-Patterns to Avoid

### ❌ Magic Numbers
```luau
-- BAD
if player:GetAttribute("Cash") > 1000 then

-- GOOD
local MIN_INVESTMENT = 1000
if player:GetAttribute("Cash") > MIN_INVESTMENT then
```

### ❌ Deep Nesting
```luau
-- BAD
if condition1 then
	if condition2 then
		if condition3 then
			if condition4 then
				-- ...
			end
		end
	end
end

-- GOOD (early returns)
if not condition1 then return end
if not condition2 then return end
if not condition3 then return end
if not condition4 then return end
-- ...
```

### ❌ God Modules
```luau
-- BAD: One module does everything
-- GameManager: handles players, restaurants, gui, economy, etc.

-- GOOD: Separate concerns
-- PlayerShared: player data
-- RestaurantShared: restaurant logic
-- GuiShared: gui utilities
-- EconomyShared: currency/transactions
```

### ❌ Callback Hell
```luau
-- BAD
doAsync(function()
	doAsync(function()
		doAsync(function()
			-- deeply nested
		end)
	end)
end)

-- GOOD: Use promises or split into functions
local function step3() end
local function step2()
	task.spawn(step3)
end
local function step1()
	task.spawn(step2)
end
```

---

## Tools and Workflow

### Development Setup
1. **Rojo:** `rojo serve default.project.json`
2. **Studio:** Install Rojo plugin, connect to localhost
3. **Selene:** Run linter before committing

### Testing
- Use **Play Solo** for single-player testing
- Use **Local Server** for multiplayer testing
- Test on both PC and mobile

### Version Control
- Commit `.luau` source files (not `.rbxl`)
- Use meaningful commit messages
- Branch naming: `feature/market-system`, `fix/placement-bug`

---

## Conclusion

This style guide ensures consistency across the Fast Food Sim codebase. When in doubt:
1. Look at existing code (especially `RestaurantShared.luau` and `PlayerShared.luau`)
2. Prioritize type safety and clarity
3. Follow the principle of least surprise
4. Ask for code review before merging large changes

**Remember:** Code is read more often than written. Write for the next developer (which might be future you).

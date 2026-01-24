# TODO List for Fast Food Simulator

This document tracks the progress of the current implementation compared to the previous recode attempt. Each task is categorized and marked with its current status.

## Tasks

### Documentation
- [x] Create Game Design Document (GDD)
- [x] Create Style and Structure Guide

### Market System
- [x] Implement `MarketClient.luau`
  - [x] Product display
  - [x] Purchase flow (Buy button)
  - [x] Cart system (Add to cart, Clear cart)
  - [x] Category filtering (CurrentComputerTab)
  - [ ] Gifting system
  - [ ] Limited stock tracking
  - [ ] Ownership display
- [x] Set up server-side RemoteEvents for purchase validation (Buy.luau)
- [x] Implement server-side money deduction logic
- [ ] Implement server-side gift processing

### Inventory System
- [x] Design inventory system structure (InventoryComponent)
- [x] Implement inventory management logic (Add/Remove)
- [x] Integrate inventory with market system

### Delivery System
- [x] Create delivery truck animation system
- [x] Implement FindClosestLane helper
- [x] Implement CalculateDeliveryPoint helper
- [x] Implement CalculateDeliveryCFrames helper
- [x] Implement GeneratePackages helper
- [x] Implement MakePackagesInvisible/RevealPackages helpers
- [x] Implement DepartTruck helper
- [x] Trigger delivery on purchase via ServerEvents

### Plot System
- [x] Create PlotAssignment (assign/vacate plots on join/leave)
- [x] Implement GetVacantPlot
- [x] Implement GetPlayerPlot

### Data Persistence
- [x] Create DataService with ProfileService
- [x] Implement CFrameSerdes (Serialize/Deserialize/ToWorldSpace/ToObjectSpace)
- [x] Save furniture CFrames on player leave
- [x] Save assembly (food package) CFrames on player leave
- [x] Load and place furniture on player join
- [x] Load and place assemblies on player join
- [x] Place items without CFrame in delivery area (Spawn part)

### Furniture System
- [x] Create FurnitureComponent (Place, Unpack, PlaceAll)
- [x] Create DefaultFurnitureService (inject starter furniture)
- [x] Implement furniture unpacking from boxes
- [x] Implement packed vs unpacked state

### Food System
- [x] Create FoodComponent (PlaceAssembly, PlaceAllAssemblies, UpdatePackageAppearance)
- [x] Implement food package amount tracking
- [x] Implement RemoveFromPackage

### Grab/Release System
- [x] Create Grab.luau (DisplayGrabVisuals, ClearGrabVisuals)
- [x] Server-side grab/release via ServerEvents
- [x] Client-side grab visuals

### Replication System
- [x] Create ReplicationClient with StateValues
- [x] Create StateValue system for Fusion integration
- [x] Implement GetPlayerData RemoteFunction

### UI System
- [x] Integrate Fusion with StateValue
- [ ] Create UI for inventory system
- [ ] Implement UIHandler for managing UI interactions

### Shared Modules
- [ ] Refactor `GuiShared` module
- [ ] Refactor `PlayerShared` module
- [ ] Refactor `RequireAttribute` module

### Testing and Debugging
- [ ] Write unit tests for market system
- [ ] Write unit tests for inventory system
- [ ] Debug and optimize server-side logic

### Miscellaneous
- [ ] Review and optimize `StoreModule.luau`
- [x] Ensure alignment with new project structure
- [x] Remove unnecessary complexity from old recode attempt

## Current Sprint (January 24, 2026)

### Focus/Interaction System
- [x] Create FocusClient.luau (pure detection system, fires signals only)
- [x] Create GetInteractableStats.luau (determines type from attributes/tags/context)
- [x] Create UpdateVisuals.luau (HoverUI with type-based actions)
- [x] Create InteractionRegistry.luau (stores interaction display info)
- [x] Create ItemRegistration.luau (registers items with display info)
- [x] Create FindAssembly.luau (finds parent assembly from descendant)
- [x] Create GetKeybindString.luau (converts keybinds to display strings)
- [x] Add Events.luau signals (InteractPressed, SecondaryInteractPressed)
- [x] Implement action lists per interactable type
- [x] Implement title formats with placeholders ([Name], [Left], [Total])

### Restaurant Helpers Visibility
- [x] Create Visibility.luau utility (Hide/Show/HideChildren/ShowChildren)
- [x] Update RestaurantShared.luau to hide snap points, placement areas, waypoints
- [x] Confirm restaurants parent to PlotFolder

### Customer AI & Orders
- [ ] Make NPCs walk in
- [ ] NPCs order food
- [ ] NPCs wait for their order
- [ ] NPCs eat
- [ ] NPCs pay
- [ ] NPCs leave

### Cooking System
- [x] Create CookingComponent for session tracking
- [x] Create InventoryComponent for food storage
- [x] Create State.luau cooking state machine (keypoint-based multi-stage cooking)
- [x] Create StateClient.luau (client-side cooking state)
- [x] Create FoodPlacementServer.luau (hold/place mechanics)
- [x] Create FoodPlacementClient.luau (ingredient dragging UI)
- [x] Implement PickUpItem (hand welding)
- [x] Implement PlaceItem (unweld and position)
- [ ] Create CookingServer (snap event handler, cooking state machine integration)
- [ ] Integrate State.luau with cooking appliances
- [ ] Implement TakeIngredient (food extraction from storage)
- [ ] Implement SnapIngredient (cooking logic with validation)
- [ ] Implement appliance-specific cooking
  - [ ] Grill patty cooking with flip mechanic
  - [ ] Fryer nuggets/fries/onion rings cooking
  - [ ] Prep table general cooking
- [ ] Implement food assembly into output items
- [ ] Test ingredient validation before snapping

### Placement System (FURNITURE)
- [x] Create FurnitureComponent for data structure
- [x] Create PlacementClient.luau (furniture drag/snap/rotate UI)
- [x] Create AimTrackerClient.luau (aiming/tracking for placement)
- [ ] Create PlacementServer (furniture placement validation & persistence)
- [ ] Implement furniture cost deduction from cash
- [ ] Implement collision detection
- [ ] Implement placement area boundary checking
- [ ] Implement rotation validation (0°, 90°, 180°, 270° only)
- [ ] Implement furniture removal system with cash refund
- [ ] Test placement on different furniture types
  - [ ] Chairs with table detection
  - [ ] Appliances
  - [ ] Decorative furniture

**Last Updated:** January 24, 2026
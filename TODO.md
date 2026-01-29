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
- [x] Set up server-side RemoteEvents for purchase validation (Buy.luau)
- [x] Implement server-side money deduction logic

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

### Testing and Debugging
- [ ] Debug and optimize server-side logic

### Miscellaneous
- [x] Ensure alignment with new project structure
- [x] Remove unnecessary complexity from old recode attempt

**Last Updated:** January 29, 2026

## Current Sprint (January 28-29, 2026)

### Focus/Interaction System - Complete ✅
- [x] FocusClient detection system *(Jan 25)*
- [x] GetInteractableStats type determination *(Jan 25)*
- [x] UpdateVisuals HoverUI with type-based actions *(Jan 25)*
- [x] Mobile button integration with dedicated signals *(Jan 25)*
- [x] Events system for interaction handling *(Jan 25)*

### Cooking System - Grill & Fryer
- [ ] Implement Grill cooking (patty snap, heat application, flip mechanic)
- [ ] Implement Fryer cooking (fries/nuggets snap, timer-based cooking)
- [ ] Create CookingServer (snap event handler, state machine integration)
- [ ] Integrate State.luau with cooking appliances
- [ ] Test cooking output and completion

### Focus/Interaction System
- [x] Create FocusClient.luau (pure detection system, fires signals only) *(Jan 24)*
- [x] Create GetInteractableStats.luau (determines type from attributes/tags/context) *(Jan 24)*
- [x] Create UpdateVisuals.luau (HoverUI with type-based actions) *(Jan 24)*
- [x] Create InteractionRegistry.luau (stores interaction display info) *(Jan 24)*
- [x] Create ItemRegistration.luau (registers items with display info) *(Jan 24)*
- [x] Create FindAssembly.luau (finds parent assembly from descendant) *(Jan 24)*
- [x] Create GetKeybindString.luau (converts keybinds to display strings) *(Jan 24)*
- [x] Add Events.luau signals (InteractPressed, SecondaryInteractPressed) *(Jan 24)*
- [x] Implement action lists per interactable type *(Jan 24)*
- [x] Implement title formats with placeholders ([Name], [Left], [Total]) *(Jan 24)*

### Restaurant Helpers Visibility
- [x] Create Visibility.luau utility (Hide/Show/HideChildren/ShowChildren) *(Jan 24)*
- [x] Update RestaurantShared.luau to hide snap points, placement areas, waypoints *(Jan 24)*
- [x] Confirm restaurants parent to PlotFolder *(Jan 24)*

### Customer AI & Orders
- [ ] Make NPCs walk in
- [ ] NPCs order food
- [ ] NPCs wait for their order
- [ ] NPCs eat
- [ ] NPCs pay
- [ ] NPCs leave

### Cooking System - Grill Phase Implementation ✅
- [x] Create CookingComponent for session tracking
- [x] Create InventoryComponent for food storage
- [x] Create State.luau cooking state machine (keypoint-based multi-stage cooking)
- [x] Create StateClient.luau (client-side cooking state)
- [x] Create FoodPlacementServer.luau (hold/place mechanics)
- [x] Create FoodPlacementClient.luau (ingredient dragging UI)
- [x] Implement PickUpItem (hand welding)
- [x] Implement PlaceItem (unweld and position)
- [x] Create CookingServer (snap event handler, cooking state machine integration) *(Jan 28)*
- [x] Integrate State.luau with cooking appliances *(Jan 28)*
- [x] Implement TakeIngredient (food extraction from storage)
- [x] Implement SnapIngredient (cooking logic with validation)
- [x] Implement Grill patty cooking with flip mechanic *(Jan 28)*
  - [x] Grill_1.luau - Cook phase with progress meter
  - [x] Grill_2.luau - Flip phase with tween animation
  - [x] Grill_done.luau - Cleanup phase with visibility reset
  - [x] Initialize cooking snaps with default "Cook" action *(Jan 28)*
  - [x] Player E-key interaction to advance phases *(Jan 28)*
  - [x] CustomHoverData system for phase-based prompts *(Jan 28)*
- [ ] Implement Fryer cooking (fries/nuggets/onion rings)
- [ ] Implement Prep table general cooking
- [ ] Implement food assembly into output items
- [ ] Test ingredient validation before snapping

#### Grill System Details *(Jan 28 - Jan 29)*
- [x] Furniture visibility management (hide snaps on place, show on use)
- [x] Cleanup.luau utility for connection/instance/function cleanup
- [x] UpdateActionListDisplay.luau extracted for action prompt display
- [x] InitializeCookingSnaps.luau for snap auto-initialization with "Cook"
- [x] CookingInteractionListener.luau for E-key detection on cooking actions
- [x] ProcessId and KeypointIndex stored in CustomHoverData for phase tracking
- [x] Phase advancement: Player E → CookingInteractionListener → RegisterKeypointRE → AddKeypoint → UpdateCookingRE → CookingClient → Phase Helper
- [x] Complete end-to-end cooking flow verified (Cook → Flip → Done)

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
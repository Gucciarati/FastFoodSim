# TODO List for Fast Food Simulator

This document tracks the progress of the current implementation compared to the previous recode attempt. Each task is categorized and marked with its current status.

## Tasks

### Documentation
- [x] Create Game Design Document (GDD)
- [x] Create Style and Structure Guide

### Market System
- [ ] Implement `MarketClient.luau`
  - [ ] Product display
  - [ ] Purchase flow
  - [ ] Gifting system
  - [ ] Limited stock tracking
  - [ ] Ownership display
  - [ ] Category filtering
- [ ] Set up server-side RemoteEvents for purchase validation
- [ ] Implement server-side money deduction logic
- [ ] Implement server-side gift processing

### Inventory System
- [ ] Design inventory system structure
- [ ] Implement inventory management logic
- [ ] Integrate inventory with market system

### UI System
- [ ] Create UI for market system
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
- [ ] Ensure alignment with new project structure
- [ ] Remove unnecessary complexity from old recode attempt

## Current Sprint (January 19, 2026)

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

**Expected Completion:** Tuesday, January 19, 2026
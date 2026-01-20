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
- [ ] Use the grill to prepare food
- [ ] Use the fryer to prepare food
- [ ] Use the prep table to prepare food

### Placement System (Maybe)
- [ ] Placement/rotation for furniture/appliances

**Expected Completion:** Tuesday, January 19, 2026
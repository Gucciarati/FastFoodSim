# Fast Food Sim - Game Design Document

**Version:** 1.0  
**Last Updated:** January 15, 2026  
**Status:** Mid-Development

---

## Table of Contents
1. [Game Overview](#game-overview)
2. [Core Gameplay Loop](#core-gameplay-loop)
3. [Player Progression](#player-progression)
4. [Restaurant Management](#restaurant-management)
5. [Economy System](#economy-system)
6. [Product Catalog](#product-catalog)
7. [Monetization](#monetization)
8. [Technical Requirements](#technical-requirements)
9. [Development Roadmap](#development-roadmap)

---

## Game Overview

### High Concept
A fast-food restaurant tycoon game where players build, customize, and manage their own burger joint, serving AI customers to earn money and unlock new items.

### Genre
Tycoon / Simulator / Business Management

### Target Audience
- Primary: Ages 10-16
- Secondary: Casual tycoon game fans

### Core Pillars
1. **Build & Customize** - Create your dream restaurant layout
2. **Manage & Optimize** - Balance ingredient costs vs. profit margins
3. **Progress & Unlock** - Level up to access better equipment and items
4. **Express Yourself** - Decorate with furniture and lighting

---

## Core Gameplay Loop

### Minute-to-Minute
1. Customer enters restaurant
2. Customer orders food at register
3. Player/NPC prepares food using appliances
4. Customer receives order and eats
5. Customer pays and leaves
6. Player collects cash
7. Repeat

### Session-to-Session (10-30 minutes)
1. Check cash balance
2. Open computer/market
3. Purchase ingredients in bulk
4. Restock shelves/fridges
5. Buy new appliances/furniture
6. Rearrange restaurant layout
7. Serve customers to earn money
8. Level up from XP gains

### Long-Term Goals
- Unlock all 30+ levels of content
- Own every item category (100+ items)
- Maximize restaurant efficiency
- Create the most stylish restaurant
- Complete all tutorial steps

---

## Player Progression

### Level System
- **Starting Level:** 1
- **Max Level:** 30+
- **XP Sources:**
  - Serving customers
  - Completing orders
  - First-time purchases
  - Tutorial completion

### Unlocks by Level Tier
| Level Range | Unlocks |
|-------------|---------|
| 1-5 | Basic ingredients (buns, patties, cheese, tomatoes), starter appliances (shelf, fridge, counter, cooktop) |
| 6-11 | Drinks, register, drink dispenser, fryer, basic furniture |
| 12-17 | Lettuce, onions, food warmer, modern furniture tier |
| 18-23 | Nuggets, pickles, luxury furniture tier |
| 24-30 | Milkshakes, ice cream, premium appliances, onion rings |

### Tutorial System
- Step-by-step guidance for new players
- Visual highlighting of interactive areas
- Progressive introduction to game mechanics
- Steps stored in player profile attribute

---

## Restaurant Management

### Plot System
- Fixed number of plots in world (workspace.Plots)
- Players assigned to vacant plots on join
- Each restaurant instance is independent
- Plot reference stored for cleanup on leave

### Restaurant States
- **Closed:** Neon sign off, no customers spawn
- **Open:** Neon sign on, customers begin entering
- Players toggle state via UI

### Placement System (TODO)
- Grid-based snap placement
- Items categorized by type
- Placement restricted to designated zones (PlacementArea tag)
- Rotation support
- Collision detection
- Visual preview before placement

### Restaurant Components
- **Sign:** Displays "{PlayerName}'s Restaurant"
- **Spawn Point:** Where player spawns
- **Placement Area:** Where items can be placed
- **Tutorial Folder:** Step-by-step visual guides

---

## Economy System

### Currency Types
1. **Cash (Money):** Primary in-game currency
   - Starting amount: $200
   - Earned from: Customer purchases
   - Spent on: Most items in the market

2. **Robux:** Premium currency
   - Earned from: Real money purchases
   - Spent on: Gold/premium items, game passes

### Pricing Strategy

#### Ingredients (Bulk Purchases)
- Small profit margins (10-20% markup when sold)
- Examples:
  - 12x Burger Buns: $11.88 ($0.99 each)
  - 10x Patties: $14.90 ($1.49 each)
  - 14x Tomatoes: $23.66 ($1.69 each)

#### Appliances (One-Time Purchases)
- Medium to high cost
- Required for food prep
- Examples:
  - Shelf: $78.29
  - Fridge: $147.99
  - Cooktop: $89.59
  - Fryer: $249.79
  - Register: $219.79

#### Furniture (One-Time Purchases)
- Affects customer capacity
- Multiple tiers (Dirty < Basic < Modern < Luxury)
- Examples:
  - Basic Chair: $39.49
  - Basic Table: $129.99
  - Luxury Booth: $399.99

#### Decorations (One-Time Purchases)
- Aesthetic only
- Lower cost than functional items
- Examples:
  - Plants: $39.99 - $48.99
  - Lights: $49.99 - $148.99

---

## Product Catalog

### Food Items (26+ items)
- Burger Buns, Patties, Cheese Slices, Lettuce, Tomatoes, Pickles, Onions
- Papers (wrappers)
- Drink Cups, Milkshake Cups
- Fry Packs, Fry Boxes
- Nugget Packs, Nugget Boxes
- Ice Cream Cones
- Onion Ring Packs, Onion Ring Trays

### Appliances (15+ items)
**Essential:**
- Shelf, Fridge, Counter
- Cooktop, Fryer
- Register, Order Screen
- Drink Dispenser
- Trashbin

**Advanced:**
- Food Warmer
- Ice Cream & Milkshake Maker

**Premium (Robux):**
- Gold Cooktop
- Gold Fryer

### Furniture (20+ items)
**Tables:**
- Dirty Table, Large Dirty Table
- Basic Table, Large Basic Table
- Modern Table
- Luxury Table, Large Luxury Table
- Gold variants (Robux)

**Seating:**
- Basic Chair
- Dirty Booth, Basic Booth, Modern Booth, Luxury Booth
- Gold variants (Robux)
- Modern Stool, Luxury Stool

**Other:**
- Garbage (trash container)

### Decorations (12+ items)
**Lighting:**
- Square Light, Circle Light, Rectangle Light
- Hanging Light, Spot Light
- Chandelier

**Plants:**
- Plant 1, Plant 2, Plant 3

---

## Monetization

### Free-to-Play Model
- Core gameplay completely free
- No pay-to-win mechanics
- Grind-friendly economy

### Revenue Streams

#### 1. Game Passes (Temporary Boosts)
- **AutoCollect:** Automatically collect cash drops
- **DoubleCash:** 2x cash earnings
- **DoubleXP:** 2x experience gains
- **FastWorkers:** NPCs work faster
- **FoodPlus:** Better quality/larger portions
- **Sprint:** Increased player movement speed

**Note:** These are stored as temporary in player profile - may be time-limited or single-session

#### 2. Premium Items (Robux)
**Gold Furniture Collection:**
- Gold Booth
- Gold Table, Large Gold Table
- Gold Chair

**Gold Appliances:**
- Gold Cooktop
- Gold Fryer

**Pricing:** Not yet configured (price = 0 in config)

#### 3. Developer Products (Future)
- Cash bundles
- Instant ingredient refills
- Plot upgrades
- Custom restaurant names/signs

---

## Technical Requirements

### Performance Targets
- 60 FPS on mid-range devices
- Mobile compatibility
- Smooth placement system
- Efficient customer AI pathfinding

### Multiplayer Considerations
- Single-player plot instances
- Possible social features:
  - Visit other restaurants
  - Rating system
  - Leaderboards

### Data Persistence
- **ProfileService** or **DataStore2** (to be implemented)
- Save data includes:
  - XP, Cash, Level
  - Tutorial progress
  - Owned items inventory
  - Restaurant layout
  - Placed items (positions/rotations)

### Asset Requirements
- 100+ 3D models (items)
- 100+ icon images (UI thumbnails)
- Sound effects for:
  - Cooking
  - Cash register
  - Customer interactions
  - UI clicks

---

## Development Roadmap

### Phase 1: Core Systems (Current)
- [x] Project structure and build pipeline
- [x] Player joining and profiles
- [x] Restaurant spawning on plots
- [x] GUI modal system
- [x] Product catalog configuration
- [ ] **Data persistence (ProfileService)**
- [ ] **Market/shop purchasing**
- [ ] **Inventory system**

### Phase 2: Building & Placement
- [ ] Placement system (drag/drop/rotate)
- [ ] Grid snapping
- [ ] Collision detection
- [ ] Save/load placed items
- [ ] Item ownership validation

### Phase 3: Customer AI
- [ ] NPC spawning system
- [ ] Pathfinding to restaurant
- [ ] Order queue at register
- [ ] Eating at tables
- [ ] Payment and leaving
- [ ] Customer satisfaction system

### Phase 4: Food Preparation
- [ ] Ingredient storage (shelves/fridges)
- [ ] Cooking interactions
- [ ] Recipe system
- [ ] Order fulfillment
- [ ] Quality/timing mechanics

### Phase 5: Economy Balance
- [ ] Revenue calculations
- [ ] Profit margins tuning
- [ ] Level progression pacing
- [ ] Unlock curve balancing
- [ ] Tutorial quest rewards

### Phase 6: Polish & Features
- [ ] Sound effects
- [ ] Visual effects (cooking steam, etc.)
- [ ] Restaurant customization colors
- [ ] Employee NPC hiring
- [ ] Upgrades system
- [ ] Achievements

### Phase 7: Monetization
- [ ] Game pass implementation
- [ ] Premium item shop
- [ ] Developer products
- [ ] Daily rewards
- [ ] Starter packs

### Phase 8: Social Features
- [ ] Visit other restaurants
- [ ] Friends system integration
- [ ] Rating/review system
- [ ] Global leaderboards
- [ ] Screenshot mode

---

## Open Questions

1. **Food Recipes:** How complex should the cooking be? Simple "patty + bun = burger" or multi-step?
2. **NPC Workers:** Can players hire NPCs to automate tasks? How much should they cost?
3. **Restaurant Size:** Is the restaurant size fixed or expandable?
4. **Multiplayer:** Can friends work together in one restaurant?
5. **Time Mechanics:** Real-time or accelerated? Day/night cycle?
6. **Food Spoilage:** Do ingredients expire if not used?
7. **Customer Variety:** Different customer types with different orders?
8. **Failure States:** Can players go bankrupt? What happens?

---

## Success Metrics

### Player Retention
- Day 1: 40%+
- Day 7: 20%+
- Day 30: 10%+

### Engagement
- Average session: 20-30 minutes
- Sessions per day: 2-3
- Tutorial completion: 80%+

### Monetization
- Conversion rate: 3-5%
- ARPDAU: $0.10-0.30
- Average purchase: 100-400 Robux

### Virality
- Invite rate: 0.1+ per player
- Social shares: 5%+ of sessions
- Positive ratings: 85%+

---

## Conclusion

Fast Food Sim is positioned as an accessible, engaging tycoon experience with deep customization and progression. The focus on player expression through restaurant design, combined with satisfying management mechanics, creates a compelling loop for the target demographic.

The development is currently in the foundation phase, with core systems being built out. The next critical milestone is implementing the market/inventory and placement systems to create the first playable vertical slice.

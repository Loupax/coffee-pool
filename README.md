# Barista Billiards

A PICO-8 game where billiards meets barista. Smash into ingredients to build coffee orders, then sink the cue ball to serve!

## How to Play

1. **Aim** with left/right arrows
2. **Hold O (Z)** to charge your shot, release to fire
3. **Hit ingredients** the cue ball collides with to add them to your order
4. **Match the recipe** shown in the top-left HUD icons
5. **Sink the cue ball** into a pocket to serve the drink

Green checkmarks appear on recipe icons as you collect each ingredient. But watch out — hitting ingredients you don't need counts as a **foul**, and serving a foul order means game over!

## Controls

| Button | Action |
|--------|--------|
| Left / Right | Aim the cue ball |
| O (Z) | Hold to charge, release to shoot |
| X (X) | Advance menus |

## The 10-Level Campaign

| Level | Drink | Challenge |
|-------|-------|-----------|
| 1 | Black Coffee | Tutorial — one ingredient, one pocket |
| 2 | Latte | Adding cream to the mix |
| 3 | Sweet Latte | Hazard balls introduced (salt = foul!) |
| 4 | The Mocha | Multiple pockets to aim for |
| 5 | Spicy Mocha | Precision shots around foul-balls |
| 6 | Sugar Rush | Collect 3 sugars through clutter |
| 7 | Cinnamon Swirl | Navigate tight corridors |
| 8 | Caramel Macchiato | Break through a blockade |
| 9 | The Salt Trap | Dodge salt near the pocket |
| 10 | Master Barista | The final exam — 6 ingredients, 2 pockets |

## Scoring

- **Par** is set per level (entity count + 2 shots)
- Beat par for a **bonus multiplier** on your 1000-point level clear
- Score persists across levels — aim for a high score!

## Running the Game

### In PICO-8
```
load barista.p8
run
```

> **Note for Intel Arrow Lake GPUs:** If PICO-8 crashes your display, run with `pico8 -software_blit 1`. See `gpu-fix.md` for details.

### Play in a Browser

A pre-built HTML version is in `docs/`. Once the repo is on GitHub with Pages enabled (Settings → Pages → Source: "Deploy from a branch", Branch: `main`, Folder: `/docs`), the game will be playable at:

```
https://<username>.github.io/<repo-name>/
```

To re-export after code changes:
```
pico8 -x barista.p8 -export docs/index.html
```

## Ingredient Legend

| Color | Ingredient |
|-------|------------|
| Brown | Coffee |
| White | Sugar |
| Orange | Syrup |
| Grey | Salt |
| Black | Pepper |
| Red | Hot Sauce |
| Light Grey | Cream |
| Peach | Cinnamon |
| Dark Brown | Cocoa |

## License

[MIT](LICENSE)

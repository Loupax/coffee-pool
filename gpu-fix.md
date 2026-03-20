# PICO-8 GPU Crash Fix (Arrow Lake)

## Problem
Running PICO-8 crashes X/XWayland with: `X connection to :0 broken (explicit kill or server shutdown)`

## Cause
Intel Arrow Lake-U GPU + i915 driver has OpenGL instability. PICO-8 uses OpenGL via XWayland, which can hang the GPU context.

## System Info
- GPU: Intel Arrow Lake-U
- Driver: i915 (xe module also loaded)
- Kernel: 6.17.0-1012-oem
- Mesa: 25.2.8
- Session: Wayland

## Quick Fix
Run PICO-8 with software rendering:
```
pico8 -software_blit 1
```

## Permanent Fix
Edit `~/.lexaloffle/pico-8/config.txt` and set:
```
software_blit 1
```

## Alternative: Switch to xe Driver
Arrow Lake is better supported by the newer `xe` kernel driver. This is more invasive — research before attempting.

## Notes
Software rendering has no visual impact on a 128x128 pixel game.

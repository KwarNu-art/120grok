# Super120Hz

**Two-in-one** jailbreak tweak:

1. **High refresh prefer** — aims for panel max (up to **120 Hz** on ProMotion)
2. **Glass FPS pill** — small liquid-glass rounded counter + **auto re-apply every 5s** in the background

Credit style: built for the **Kwar Nu** line of tweaks.

## Honest limits

| Device | Max Hz |
|--------|--------|
| iPhone 7 / 7 Plus / SE (2nd) / most LCDs | **60** — Super120Hz will lock **60**, not 120 |
| ProMotion iPhones (13 Pro and later Pro models, etc.) | **120** possible |
| “iOS 26” alone does not create 120 Hz | Panel hardware decides |

## UI

- Tiny **glass / liquid** pill (rounded, soft border, light shine)
- Live **FPS** text
- Draggable
- Engine timer every **5 seconds** re-asserts frame preference

## Build

```bash
export THEOS=~/theos
cd Super120Hz
make package
make install
```

Package id: `com.super120hz.tweak`  
Main sources: `Sources/Tweak.xm`, `Sources/S120Engine.m`, `Sources/S120HUD.m`

# w-diet Color Theme

**Last Updated:** 2026-01-06

## Brand Colors

| Name | Hex | Usage |
|------|-----|-------|
| **Fire Gold** | `#F4A460` | Primary brand color, buttons, active states, carbs macro, deficit phase |
| **Energy Orange** | `#FF6B35` | Call-to-action buttons, highlights, important notifications |

## Macro Colors

| Macro | Name | Hex | Notes |
|-------|------|-----|-------|
| **Protein** | Deep Orange | `#D35400` | Darkest - substantial, building blocks |
| **Carbs** | Fire Gold | `#F4A460` | Mid - energy, fuel (same as brand) |
| **Fat** | Light Peach | `#FFCC80` | Brightest - smooth, essential |

## MATADOR Cycle Colors

| Phase | Name | Hex | Notes |
|-------|------|-----|-------|
| **Diät (Diet)** | Fire Gold | `#F4A460` | Working hard, burning calories |
| **Erhalt (Maintenance)** | Soft Mint | `#B8E0D2` | Recovery, reward phase |
| **Erhalt Accent** | Mint Medium | `#8FCDB8` | Dots/indicators in maintenance weeks |

## Semantic Colors

| State | Hex | Usage |
|-------|-----|-------|
| **Success** | `#4CAF50` | Positive actions, success messages |
| **Warning** | `#FFA726` | Warnings, caution messages |
| **Error** | `#EF5350` | Errors, destructive actions |
| **Info** | `#42A5F5` | Informational messages |

## Text Colors

| Name | Hex | Usage |
|------|-----|-------|
| **Primary** | `#2D2D2D` | Main content |
| **Secondary** | `#757575` | Supporting text |
| **Tertiary** | `#BDBDBD` | Disabled/placeholder (= gray400) |

## Background Colors

| Name | Hex | Usage |
|------|-----|-------|
| **Primary** | `#F8F8F8` | Main app background (= gray100) |
| **Secondary** | `#FFFFFF` | Cards, elevated surfaces |

## Neutral Grays

| Name | Hex | Aliases |
|------|-----|---------|
| **Gray 100** | `#F8F8F8` | = backgroundPrimary |
| **Gray 200** | `#EEEEEE` | |
| **Gray 300** | `#E0E0E0` | = disabled, divider |
| **Gray 400** | `#BDBDBD` | = textTertiary |
| **Gray 500** | `#9E9E9E` | |

---

## Consolidated Colors (Single Source of Truth)

We use **6 unique gray values** with semantic aliases:

```
#F8F8F8 → backgroundPrimary, gray100
#EEEEEE → gray200
#E0E0E0 → gray300, disabled, divider
#BDBDBD → gray400, textTertiary
#9E9E9E → gray500
#757575 → textSecondary
#2D2D2D → textPrimary
```

## Implementation

All colors defined in `Core/Theme/Theme.swift`.

**CRITICAL:** Always use `Theme.colorName` - never hardcode hex values or use `Color.red`, `Color.blue`, etc.

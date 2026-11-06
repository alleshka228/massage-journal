"""Генератор иконки 1024x1024 для «Смены» (журнал массажиста).

Запуск: python scripts/make_icon.py
"""

import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "Resources" / "Assets.xcassets" / "AppIcon.appiconset" / "AppIcon-1024.png"

SIZE = 1024
SS = 2
N = SIZE * SS

BG_A = np.array([10, 60, 56], dtype=np.float32) / 255.0
BG_B = np.array([16, 168, 150], dtype=np.float32) / 255.0
INK = (13, 105, 96)


def smoothstep(edge0, edge1, x):
    t = np.clip((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def main() -> None:
    grid = np.mgrid[0:N, 0:N].astype(np.float32) / (N - 1)
    y, x = grid

    # --- фон: диагональный градиент ---
    t = np.clip((x * 0.5 + y * 0.7) * 1.05, 0.0, 1.0)[..., None]
    rgb = BG_A * (1 - t) + BG_B * t

    # мягкий блик
    glow = np.exp(-(((x - 0.75) ** 2 + (y - 0.18) ** 2) / 0.09))
    rgb += (glow * 0.16)[..., None] * np.array([0.6, 1.0, 0.9], dtype=np.float32)

    # --- белая «страница журнала» со скруглениями ---
    card_w, card_h, radius = 0.56, 0.66, 0.09
    left, right = 0.5 - card_w / 2, 0.5 + card_w / 2
    top, bottom = 0.5 - card_h / 2, 0.5 + card_h / 2

    dx = np.maximum(np.maximum(left + radius - x, 0), x - (right - radius))
    dy = np.maximum(np.maximum(top + radius - y, 0), y - (bottom - radius))
    dist = np.sqrt(dx ** 2 + dy ** 2) - radius
    inside = np.clip(-dist * N / 2.2, 0.0, 1.0)  # мягкий край

    shadow = np.clip(-(dist + 0.012) * N / 6.0, 0.0, 1.0)
    rgb *= (1 - shadow[..., None] * 0.35)

    card = np.ones_like(rgb)

    # строки журнала: точка + полоса
    rows = 4
    row_top, row_gap = 0.245, 0.135
    for i in range(rows):
        cy = row_top + i * row_gap
        dot_d = np.sqrt((x - (left + 0.075)) ** 2 + (y - cy) ** 2)
        dot = smoothstep(0.030, 0.024, dot_d)[..., None]
        card = card * (1 - dot) + dot * np.array([0.06, 0.53, 0.48], dtype=np.float32)

        bar_w = 0.30 - i * 0.03
        bx0, bx1 = left + 0.125, left + 0.125 + bar_w
        by0, by1 = cy - 0.016, cy + 0.016
        outer = np.maximum(np.maximum(bx0 - x, x - bx1), np.maximum(by0 - y, y - by1))
        bar = np.clip(-outer * N / 2.2, 0.0, 1.0)[..., None]
        bar_color = np.array([0.80, 0.92, 0.90], dtype=np.float32) if i < rows - 1 else np.array([0.06, 0.53, 0.48], dtype=np.float32)
        card = card * (1 - bar) + bar * bar_color

    rgb = rgb * (1 - inside[..., None]) + card * inside[..., None]

    image = Image.fromarray((np.clip(rgb, 0, 1) * 255).astype(np.uint8), "RGB")

    # --- галочка «смена закрыта» ---
    overlay = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    cx, cy, r = N * 0.72, N * 0.74, N * 0.115
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, 255))
    pts = [
        (cx - r * 0.45, cy + r * 0.02),
        (cx - r * 0.12, cy + r * 0.36),
        (cx + r * 0.50, cy - r * 0.38),
    ]
    draw.line(pts, fill=(*INK, 255), width=int(r * 0.22), joint="curve")
    overlay = overlay.filter(ImageFilter.GaussianBlur(N * 0.0008))

    image = Image.alpha_composite(image.convert("RGBA"), overlay)
    image = image.convert("RGB").resize((SIZE, SIZE), Image.LANCZOS)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    image.save(OUT, "PNG")
    print(f"OK: {OUT}")


if __name__ == "__main__":
    main()

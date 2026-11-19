"""Builds the statistics-tile mascots from the Kopa brand hand drawings.

Usage: python3 scripts/make_stat_mascots.py assets/illustrations
"""
import math, os, re, sys

BRAND = os.path.join(os.path.dirname(__file__), '../../kopa_brand/Illustrations/')
OUT = sys.argv[1]
INK = '#2d1000'
W = 7.6  # line weight of the brand outlines

def paths(name):
    svg = open(BRAND + name).read()
    return re.findall(r'<path class="cls-1" d="([^"]+)"', svg)

def group(name, transform):
    body = ''.join(f'<path d="{d}"/>' for d in paths(name))
    return f'<g fill="{INK}" transform="{transform}">{body}</g>'

def ball(cx, cy, r):
    # Brand ball: centre ~(146,144), radius ~19.5.
    s = r / 19.5
    return group('20Artboard 21.svg', f'translate({cx} {cy}) scale({s:.3f}) translate(-146 -144)')

def stroke(d, dashed=False):
    dash = ' stroke-dasharray="2 16"' if dashed else ''
    return (f'<path d="{d}" fill="none" stroke="{INK}" stroke-width="{W}" '
            f'stroke-linecap="round" stroke-linejoin="round"{dash}/>')

def star(cx, cy, r, inner=0.48, rot=-90):
    pts = []
    for i in range(10):
        rr = r if i % 2 == 0 else r * inner
        a = math.radians(rot + i * 36)
        pts.append(f'{cx + rr * math.cos(a):.1f} {cy + rr * math.sin(a):.1f}')
    return stroke('M' + ' L'.join(pts) + ' Z')

def svg(parts):
    return ('<?xml version="1.0" encoding="UTF-8"?>\n'
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 290 290">'
            + ''.join(parts) + '</svg>\n')

mascots = {
    # Goal: the walking hand kicks the ball.
    'kopa_stat_goal.svg': [
        group('14Artboard 15.svg', 'translate(-28 -6)'),
        ball(224, 240, 25),
        # "Pow" lines where the ball leaves the foot.
        stroke('M244 202 L251 191'),
        stroke('M261 218 L273 212'),
        stroke('M264 241 L277 242'),
    ],
    # Assists use the existing heart-hands mascot (assets/illustrations/kopa_heart.svg).
    # Matches: the open palm keeps the ball up.
    'kopa_stat_matches.svg': [
        group('12Artboard 12.svg', 'translate(26 44) scale(0.84)'),
        ball(148, 44, 24),
        stroke('M106 34 Q98 46 106 58'),
        stroke('M190 34 Q198 46 190 58'),
    ],
    # Votes: thumbs up with stars.
    'kopa_stat_votes.svg': [
        group('2Artboard 2.svg', 'translate(-10 22) scale(0.92)'),
        star(218, 66, 30),
        star(262, 132, 13),
        star(30, 70, 13),
    ],
}

for name, parts in mascots.items():
    with open(OUT + '/' + name, 'w') as f:
        f.write(svg(parts))
print('wrote', ', '.join(mascots))

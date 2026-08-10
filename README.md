# jadeia.org

A static personal archive — plain HTML and one stylesheet, no framework and no
build step. Served by GitHub Pages at the apex domain (see `CNAME`), so every
path in the markup is root-absolute (`/assets/…`).

## Layout

```
index.html                  Home
chronicles/index.html       Index of entries
chronicles/*.html           One file per entry
plates/index.html           Gallery
404.html                    Not-found page
assets/css/site.css         The whole stylesheet
assets/img/plates/          Plate images (fetched, not committed by hand)
assets/img/sigil.svg        Favicon
tools/fetch-plates.sh       Downloads and optimises the plates
```

## The plates

Images are not generated. Every plate is a public-domain work reproduced from
the holding institution's open-access release, credited in full in the caption:

| Plate | Work | Source |
| --- | --- | --- |
| I | Aberdeen Bestiary, MS 24, folio 66r, 12th c. | [University of Aberdeen](https://www.abdn.ac.uk/bestiary/ms24/f66r) |
| II | Dürer, *Saint George and the Dragon*, woodcut, ca. 1504 | [Met 387574](https://www.metmuseum.org/art/collection/search/387574), CC0 |
| III | Dürer, *Saint Michael Fighting the Dragon* (The Apocalypse) | [Met 368340](https://www.metmuseum.org/art/collection/search/368340), CC0 |
| IV | Dürer, *Saint George Standing*, engraving, ca. 1502 | [Met 391133](https://www.metmuseum.org/art/collection/search/391133), CC0 |
| V | Dürer, *Saint George Slaying the Dragon*, woodcut, ca. 1504 | [Met 388149](https://www.metmuseum.org/art/collection/search/388149), CC0 |

The markup expects these exact paths:

```
assets/img/plates/plate-i-aberdeen-bestiary-f66r.jpg
assets/img/plates/plate-ii-durer-saint-george-and-the-dragon.jpg
assets/img/plates/plate-iii-durer-saint-michael-fighting-the-dragon.jpg
assets/img/plates/plate-iv-durer-saint-george-standing.jpg
assets/img/plates/plate-v-durer-saint-george-slaying-the-dragon.jpg
```

`bash tools/fetch-plates.sh` downloads the four Met plates and optimises them to
those filenames (1600px long edge, quality 82, metadata stripped). Plate I has
to be saved by hand from the Aberdeen page; the script reports whether it is
there, and optimises it on a second run. If the files are added by other means,
run the script anyway to normalise their size.

Until a plate file exists, its frame renders as an empty mount rather than a
broken image. That is the `onerror` attribute on each `<img>`; it can be dropped
once all five files are in place.

## Adding a chronicle

1. Copy an existing file in `chronicles/`, e.g.
   `chronicles/iv-before-the-fight.html`.
2. Update `<title>`, the description and canonical/`og:` tags, the eyebrow
   (`Chronicle VI`), the `<h1>`, the body, and the plate figure.
3. Fix the `prev`/`next` links in `.pagination` on the new file and on the entry
   that now precedes it.
4. Add a `<li>` to `chronicles/index.html` and, if it has a plate, a `<figure>`
   to `plates/index.html`.
5. Add the URL to `sitemap.xml`.

## Conventions

- Analytics: the GA4 snippet for `G-61T0721KTX` sits in the `<head>` of every
  page, unchanged.
- The line linking to ajguerin.com appears exactly once per page, in the footer,
  and nowhere else.
- Dates are Roman (`Jadeia · MMXXVI`); dividers are `✦`; captions run
  *Plate N — title — full attribution*.
- Type: Cinzel (display), EB Garamond (body), UnifrakturMaguntia (drop caps).
  The body face is set once, as `--font-body` in `assets/css/site.css`, paired
  with `--body-size` so the two candidate faces can be matched optically.

## Comparing body faces (temporary)

Open any page with `?type=compare` for a switcher between EB Garamond and IM
Fell English. The choice follows you across pages until you close the panel.
Visitors without the query string never see it.

```sh
python3 -m http.server 8000
open 'http://localhost:8000/chronicles/?type=compare'
```

Once the face is settled, remove the scaffolding: delete
`assets/js/type-compare.js` and its `<script>` tag on all nine pages, the two
blocks marked "Comparison mode" in `assets/css/site.css`, and the losing family
from each page's Google Fonts `<link>`.

## Preview

```sh
python3 -m http.server 8000
```

Then open <http://localhost:8000>. Root-absolute paths need the server root to
be the repository root, so don't open the files directly with `file://`.

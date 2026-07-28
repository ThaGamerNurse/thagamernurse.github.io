# thagamernurse.github.io

Andrew Gaston's site. Live at <https://thagamernurse.github.io>.

## How it is built

There is no build step, and that is deliberate. `index.html` is the real file.
Open it, edit it, push it. Nothing to install, nothing to remember, nothing to
break six months from now.

```
index.html     the whole site, about 31 KB
img/           every screenshot and logo, served and cached normally
img/og.jpg     the 1200x630 card that shows when the link is shared
deploy.sh      commit, push, and force a Pages rebuild
```

Images are separate files rather than inlined. An earlier version inlined all 28
as base64, which made a 3.6 MB page where every visitor redownloaded every
screenshot just to read a changed sentence.

## To update it

```bash
./deploy.sh "what changed"
```

That commits, pushes, asks GitHub to rebuild, and waits until the deploy
finishes. Give it a minute.

## Things that will bite you

**A force-push does not trigger a Pages rebuild.** The site keeps serving the old
commit and gives no indication anything is wrong. `deploy.sh` requests a build
explicitly for that reason. If you ever push by hand, check what actually
deployed:

```bash
gh api repos/ThaGamerNurse/thagamernurse.github.io/pages/builds/latest --jq .commit
```

**The page is `noindex`.** Anyone with the link can open it, but search engines
are told not to list it. Delete the `robots` meta tag in `index.html` when you
want it found rather than sent.

**No email address appears in the source.** The contact button assembles it from
character codes when someone clicks, so a scraper reading the page finds nothing.
If the address changes, edit the two number arrays in the script near the bottom,
not the markup.

**Commit as the noreply address.** Git author emails are public through the API.
This repo uses `ThaGamerNurse@users.noreply.github.com`.

## Adding a screenshot

Drop the file in `img/`, then copy an existing `<figure>` in the relevant
section. Keep the `width` and `height` attributes accurate or the page will shift
while loading, and keep `loading="lazy"` on anything below the fold.

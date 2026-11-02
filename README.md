# onehandmobilekeyboard.com

Eleventy landing page for the Handex list. HandTerm (`handterm.com`) is the tutorial site and is not this repo.

```bash
npm ci
npm run serve
```

GitHub Pages publishes `_site` on push to `main` (`.github/workflows/publish.yml`). The custom domain is the `CNAME` file. Apex DNS for Pages is the four GitHub A records, and `www` is a CNAME to `InTEGr8or.github.io`. Mail records stay on Microsoft 365 and are not part of this site.

The Handex campaign links here from `campaigns/handex/sites/onehandmobilekeyboard.com`.

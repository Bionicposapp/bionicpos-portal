# BionicPOS Reports Portal

Static dashboard for bionicpos.com. Reads sales data synced from the iOS app via Supabase.

## 1. Create the Supabase project

1. Sign up at supabase.com and create a new project.
2. In the SQL Editor, run `supabase-schema.sql` from this folder once.
3. Under Authentication > Users, add yourself as a user (email + password) — that's the login for this dashboard.
4. Under Settings > API, copy the **Project URL** and the **anon public** key (not `service_role`).

## 2. Configure this site

Edit `config.js` and replace the placeholders with the values from step 1:

```js
window.SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
window.SUPABASE_ANON_KEY = "YOUR-ANON-KEY";
```

## 3. Configure the iOS app

In the Xcode project, edit `BioncPOS2.0/SupabaseConfig.swift` with the same URL and anon key. Once that's set, completed orders and staff records sync automatically — nothing else to do in the app.

## 4. Deploy (GitHub + Cloudflare Pages)

1. Push this folder to its own GitHub repository.
2. In Cloudflare, create a Pages project connected to that repo (no build command needed — it's plain static HTML/JS).
3. Deploy; confirm the `*.pages.dev` URL works and you can log in.
4. In the Pages project's custom domains, add `bionicpos.com`.
5. At your domain registrar, point bionicpos.com at Cloudflare (switch nameservers to Cloudflare's, or add the CNAME/A record Cloudflare gives you if keeping your current DNS host).

After this, any push to `main` redeploys automatically within about a minute.

## Notes

- v1 is single-location: any logged-in user can see all data. If you ever add a second location, add a `profiles(user_id, location_id)` table and update the `SELECT` policies in `supabase-schema.sql` to filter on it.
- The `anon` key is safe to have in this public site and in the app — Row Level Security policies (not key secrecy) are what protect the data. Never put the `service_role` key in either place.

# SmartNOC / NOC Verse

SmartNOC is a Fire NOC application management system built with Flutter, Supabase, and a responsive blue-white SaaS UI.

## Features

- Role-based authentication for users and officers
- Fire NOC application submission with upload support
- AI/rule-based priority assignment
- Officer review workflow with approve, decline, hold, and under review actions
- Realtime notifications and status updates
- Responsive web and mobile layout with desktop sidebar and mobile bottom navigation
- Local demo mode when Supabase env values are not provided

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure Supabase

Create a Supabase project and run the SQL in [supabase/schema.sql](supabase/schema.sql).

Make sure you have:

- Auth enabled for email/password sign-in
- A `profiles` table
- `applications` and `notifications` tables
- A Storage bucket named `application-documents`
- Realtime enabled for `applications` and `notifications` if you want live updates

### 3. Provide runtime config

The app reads Supabase values from Dart defines via [lib/core/constants/app_config.dart](lib/core/constants/app_config.dart).

Recommended local setup:

1. Copy [env/supabase.example.json](env/supabase.example.json) to `env/supabase.local.json`.
2. Put your Supabase URL and anon key in `env/supabase.local.json`.
3. Run with `--dart-define-from-file`.

Run the app with:

```bash
flutter run --dart-define-from-file=env/supabase.local.json
```

`env/supabase.local.json` is gitignored by default.

If the values are omitted, the app falls back to a local demo repository with seeded accounts.

### 4. Demo credentials

When running in local demo mode:

- User: `user@nocverse.com`
- Password: `User1234!`
- Officer: `officer@nocverse.com`
- Password: `Officer1234!`

## Supabase Schema

Apply [supabase/schema.sql](supabase/schema.sql) to create the tables, RLS policies, and Storage bucket.

The schema includes:

- `profiles`
- `applications`
- `notifications`
- RLS policies for user-owned and officer access
- Storage policies for `application-documents`

## Run

```bash
flutter run
```

## Build Web

```bash
flutter build web --release
```

## Vercel Deployment

Use these settings in Vercel:

- Build Command: `flutter build web --release`
- Output Directory: `build/web`

The included [vercel.json](vercel.json) rewrites all routes to `index.html` for SPA support.

## Project Structure

- `lib/app.dart` - app shell and provider wiring
- `lib/core` - theme, routing, constants, and reusable widgets
- `lib/features/auth` - boot and login screens plus auth controller
- `lib/features/user` - user dashboard, create form, applications, notifications
- `lib/features/officer` - officer dashboard, application list, and review page
- `lib/features/shared` - models and repository implementations

## Notes

- The app uses a local fallback repository when Supabase config is missing.
- Uploaded documents are stored under `application-documents/{userId}/{applicationId}/`.
- Priority is derived from application text and category keywords, so users do not need to choose it manually.

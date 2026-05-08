# TODO - FINAL EMERGENCY FIX (SmartNOC Demo)

- [ ] Inspect/confirm officer screens heading behavior (optional)
- [ ] Update `DashboardShell` to support `showShellHeader` flag and avoid rendering topbar when false
- [ ] Update `app_router.dart` to disable `DashboardShell` header for user routes (0..3)
- [ ] Harden `AppSectionHeader` text layout (softWrap/maxLines/overflow)
- [ ] Improve `DashboardShell` topbar mobile layout (search + trailing wrap/stack) and prevent bottom nav overlap via padding
- [ ] Run `flutter analyze`
- [ ] Run `flutter build web --release --dart-define-from-file=env/supabase.local.json`
- [ ] Re-check: no vertical text, no duplicate headings, mobile usable, desktop stable
- [ ] Commit safe changes
- [ ] Push to GitHub main branch
- [ ] Provide final commit hash and deployment-ready status


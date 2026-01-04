# w-diet Deployment & Distribution Notes

**Author:** Kevin
**Date:** 2026-01-02

---

## Deployment Strategy

### Selected Distribution Method: **TestFlight**

**Decision:** w-diet will use Apple TestFlight for POC/beta distribution to iPhone.

**Rationale:**
- Provides 90-day app lifetime (vs 7-day with free Xcode direct install)
- Easy update distribution (push new build, users get notification)
- Can scale to up to 10,000 beta testers
- Professional workflow for iterative POC testing
- Enables sharing with friends/early testers for feedback

**Requirements:**
- Apple Developer Account: $99/year (Kevin will cover cost)
- Mac with Xcode for building and archiving
- App Store Connect access for TestFlight management

---

## Distribution Workflow

### Initial Setup (One-time)
1. Purchase Apple Developer Account ($99/year)
2. Set up App Store Connect
3. Create App ID and provisioning profiles
4. Configure TestFlight in App Store Connect

### Build & Deploy Process
1. Developer builds app in Xcode
2. Archive project for distribution
3. Upload archive to App Store Connect via Xcode
4. Add build to TestFlight
5. Invite testers via email
6. Testers install TestFlight app on iPhone
7. Testers download w-diet from TestFlight

### Update Process
1. Developer builds new version
2. Uploads to App Store Connect
3. Adds to TestFlight
4. Testers receive push notification: "New build available"
5. Testers tap "Update" in TestFlight (30 seconds)
6. New version installed automatically

---

## POC Testing Plan

### Phase 1: Solo Testing (Week 1-2)
- Kevin tests on personal iPhone
- Iterate quickly on core flows
- Validate segmented ring, meal logging, eating window

### Phase 2: Friends & Family (Week 3-4)
- Invite 5-10 close contacts
- Gather qualitative feedback
- Test onboarding clarity, macro comprehension

### Phase 3: Extended Beta (Week 5-8)
- Expand to 20-50 users
- Track retention, engagement metrics
- A/B test segmented ring comprehension
- Validate MATADOR phase switching

---

## Technical Notes

### Build Requirements
- iOS 16.0+ target (supports iPhone 12 and newer)
- SwiftUI framework
- Xcode 15.0+
- macOS Monterey or later for development

### TestFlight Limitations
- 90-day build expiration (need to push new build every 3 months)
- 10,000 external tester limit (more than enough for POC)
- 25 internal tester limit (team members)
- App Review required for external testing (1-2 day approval)

### App Store Connect Access
- Kevin as Account Holder
- Developer(s) need Admin or App Manager role
- QA testers can have Developer role

---

## Cost Summary

**One-time Costs:**
- Apple Developer Account: $99/year ✓ (Kevin covering)

**Recurring Costs:**
- TestFlight: Free (included in Developer Account)
- App Store Connect: Free (included in Developer Account)

**Optional:**
- Code signing certificate: Free (auto-managed by Xcode)
- Push notifications: Free (Apple Push Notification Service)

---

## Next Steps for Deployment

1. **Before Development:**
   - Purchase Apple Developer Account
   - Set up App Store Connect
   - Create App ID for "com.w-diet.app" (or similar)

2. **During Development:**
   - Configure Xcode project with proper Bundle ID
   - Set up provisioning profiles
   - Test local builds on iPhone via USB

3. **First TestFlight Upload:**
   - Archive first stable POC build
   - Upload to App Store Connect
   - Submit for TestFlight Beta App Review (1-2 days)
   - Invite Kevin as first tester

4. **Iteration:**
   - Push updates as needed (no review for updates)
   - Expand tester base gradually
   - Collect feedback via TestFlight or in-app feedback

---

## Questions to Resolve Later

- [ ] Who will be the primary developer? (hire vs build yourself)
- [ ] Timeline: when do we want first TestFlight build ready?
- [ ] Do we want crash reporting? (e.g., Firebase Crashlytics)
- [ ] Do we want analytics? (e.g., Mixpanel, Amplitude)
- [ ] Backend hosting decision impacts deployment (local SQLite vs cloud sync)

---

**Status:** TestFlight confirmed as distribution method. Apple Developer Account purchase pending before development phase.

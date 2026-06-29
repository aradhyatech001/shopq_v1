# FCM (Push Notifications) — Production Setup & Test

Backend uses the **FCM HTTP v1 API** (OAuth2 service account). The legacy
server-key API is shut down by Google, so v1 is the only supported path.

## 1. One-time server setup

1. **Service account key** — Firebase Console → Project settings → *Service
   accounts* → **Generate new private key**. Save the JSON as:
   ```
   storage/app/json/firebase-credentials.json
   ```
   (create the `storage/app/json/` folder if missing; keep this file **out of
   git** — it's a secret).

2. **Project id** — add to `.env`:
   ```
   FCM_PROJECT_ID=your-firebase-project-id
   ```
   (Firebase Console → Project settings → *General* → Project ID.)

3. Dependency is already installed: `google/apiclient` (composer).

4. After editing `.env` on a server that ran `php artisan optimize`:
   ```
   php artisan optimize:clear
   ```

## 2. Verify it works (no app needed)

```bash
# Auth/credentials check — sends to a dummy token. Expect "configured" then a
# "not a valid FCM registration token" error (proves OAuth + reach FCM):
php artisan fcm:test --token=DUMMY

# Real delivery to a logged-in account's device:
php artisan fcm:test --user=123
php artisan fcm:test --vendor=5
php artisan fcm:test --delivery=2

# Custom text:
php artisan fcm:test --user=123 --title="Hello" --body="Test push"
```
Errors are logged to `storage/logs/laravel.log` (search `FCM`).

## 3. How it works

- **Token storage:** each app (customer/vendor/delivery) registers its device
  token via `POST /fcm/token`, `/vendor/fcm/token`, `/delivery/fcm/token`
  → saved to the `fcm_token` column on the user/vendor/delivery row.
- **Sending:** `App\Services\FcmService`
  - `send($token, $title, $body, $data)` — single token.
  - `sendToModel($user, …)` — sends and **auto-clears** the stored token if FCM
    reports it `UNREGISTERED` (dead token cleanup).
  - `sendToMany($tokens, …)` — bulk; returns the unregistered tokens to purge.
  - The OAuth access token is **cached and reused** (~1h) so repeated/bulk sends
    don't re-authenticate every time.
- **Triggers today:** order status changes notify the customer
  (`OrderController`, `OrderStatusService`).

## 4. App side (already implemented)

`notification_service.dart` in customer / vendor / delivery apps:
requests permission, registers + refreshes the token, shows a foreground
banner, and routes on tap. Web builds include `firebase-messaging-sw.js`.

> Admin web has the service worker but no token registration (admins work in the
> panel live). Add a `notification_service.dart` there only if admin push is wanted.

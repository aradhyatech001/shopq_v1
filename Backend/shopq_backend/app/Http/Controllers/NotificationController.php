<?php

namespace App\Http\Controllers;

use App\Models\AppNotification;
use App\Models\NotificationCampaign;
use Illuminate\Http\Request;

/**
 * Notification Center API. The same controller serves the customer, vendor and
 * delivery apps — every query is scoped to the authenticated account via its
 * polymorphic (type + id), so an account only ever sees its own notifications.
 *
 * Routes are registered under the auth:sanctum / auth:vendor / auth:delivery
 * groups in routes/api.php.
 */
class NotificationController extends Controller
{
    /** Base query scoped to the current account. */
    private function scope(Request $request)
    {
        $account = $request->user();
        return AppNotification::query()
            ->where('notifiable_type', $account->getMorphClass())
            ->where('notifiable_id', $account->getKey());
    }

    /** GET /notifications?page= — paginated, newest first, non-archived. */
    public function index(Request $request)
    {
        $perPage = min((int) $request->input('per_page', 20), 50);
        $page    = $this->scope($request)->active()->latest()->paginate($perPage);

        return response()->json([
            'success' => true,
            'data'    => $page->items(),
            'meta'    => [
                'current_page' => $page->currentPage(),
                'last_page'    => $page->lastPage(),
                'total'        => $page->total(),
                'has_more'     => $page->hasMorePages(),
            ],
        ]);
    }

    /** GET /notifications/unread-count — badge number. */
    public function unreadCount(Request $request)
    {
        return response()->json([
            'success' => true,
            'unread'  => $this->scope($request)->active()->unread()->count(),
        ]);
    }

    /** POST /notifications/{id}/read */
    public function markRead(Request $request, int $id)
    {
        $n = $this->scope($request)->whereKey($id)->first();
        if ($n && $n->read_at === null) {
            $n->update(['read_at' => now()]);
            if ($n->campaign_id) {
                NotificationCampaign::whereKey($n->campaign_id)->increment('read_count');
            }
        }

        return response()->json(['success' => true]);
    }

    /** POST /notifications/read-all */
    public function markAllRead(Request $request)
    {
        $this->scope($request)->whereNull('read_at')->update(['read_at' => now()]);

        return response()->json(['success' => true]);
    }

    /** POST /notifications/{id}/archive */
    public function archive(Request $request, int $id)
    {
        $this->scope($request)->whereKey($id)
            ->update(['archived_at' => now(), 'read_at' => now()]);

        return response()->json(['success' => true]);
    }

    /** DELETE /notifications/{id} */
    public function destroy(Request $request, int $id)
    {
        $this->scope($request)->whereKey($id)->delete();

        return response()->json(['success' => true]);
    }

    /**
     * POST /notifications/{id}/opened — analytics: notification was viewed.
     * Marks it read; campaign open-counts are aggregated in a later phase.
     */
    public function opened(Request $request, int $id)
    {
        return $this->markRead($request, $id);
    }

    /**
     * POST /notifications/{id}/clicked — analytics: CTA / deeplink tapped.
     * Marks it read; campaign click-counts are aggregated in a later phase.
     */
    public function clicked(Request $request, int $id)
    {
        $n = $this->scope($request)->whereKey($id)->first();
        if (!$n) {
            return response()->json(['success' => true]);
        }

        $firstRead  = $n->read_at === null;
        $firstClick = $n->clicked_at === null;

        $n->update([
            'read_at'    => $n->read_at ?? now(),
            'clicked_at' => $n->clicked_at ?? now(),
        ]);

        if ($n->campaign_id) {
            if ($firstRead) {
                NotificationCampaign::whereKey($n->campaign_id)->increment('read_count');
            }
            if ($firstClick) {
                NotificationCampaign::whereKey($n->campaign_id)->increment('click_count');
            }
        }

        return response()->json(['success' => true]);
    }
}

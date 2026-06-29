<?php

namespace App\Http\Controllers;

use App\Jobs\DispatchCampaignJob;
use App\Models\NotificationCampaign;
use App\Services\AudienceResolver;
use App\Services\UserStatsService;
use Illuminate\Http\Request;

/**
 * Admin notification campaigns: compose, preview reach, send, schedule, report.
 * Registered under the auth:admin group.
 */
class CampaignController extends Controller
{
    /** GET /admin/campaigns — list (newest first) with counters. */
    public function index()
    {
        $campaigns = NotificationCampaign::orderByDesc('id')->paginate(20);

        return response()->json([
            'success' => true,
            'data'    => $campaigns->items(),
            'meta'    => [
                'current_page' => $campaigns->currentPage(),
                'last_page'    => $campaigns->lastPage(),
                'total'        => $campaigns->total(),
            ],
        ]);
    }

    public function show(int $id)
    {
        $c = NotificationCampaign::find($id);
        if (!$c) return response()->json(['success' => false, 'message' => 'Not found'], 404);
        return response()->json(['success' => true, 'data' => $c]);
    }

    /** POST /admin/campaigns/preview-audience — estimated reach for a segment. */
    public function preview(Request $request, AudienceResolver $resolver)
    {
        $data = $request->validate([
            'audience' => 'required|in:customers,vendors,delivery',
            'criteria' => 'nullable|array',
        ]);

        return response()->json([
            'success' => true,
            'reach'   => $resolver->count($data['audience'], $data['criteria'] ?? []),
        ]);
    }

    /** POST /admin/campaigns — create a draft (or send/schedule immediately). */
    public function store(Request $request)
    {
        $data = $request->validate([
            'type'          => 'required|string|max:50',
            'audience'      => 'required|in:customers,vendors,delivery',
            'delivery_mode' => 'nullable|in:token,topic',
            'title'         => 'required|string|max:255',
            'body'          => 'nullable|string',
            'image'         => 'nullable|string',
            'data'          => 'nullable|array',
            'criteria'      => 'nullable|array',
            'criteria.user_ids' => 'nullable|array',
            'scheduled_at'  => 'nullable|date',
            'expiry_at'     => 'nullable|date',
            'action'        => 'nullable|in:draft,send,schedule',
        ]);

        $action = $data['action'] ?? 'draft';
        $status = match ($action) {
            'send'     => NotificationCampaign::STATUS_DRAFT, // flipped to sending on dispatch
            'schedule' => NotificationCampaign::STATUS_SCHEDULED,
            default    => NotificationCampaign::STATUS_DRAFT,
        };

        $campaign = NotificationCampaign::create([
            'type'          => $data['type'],
            'audience'      => $data['audience'],
            'delivery_mode' => $data['delivery_mode'] ?? 'token',
            'title'         => $data['title'],
            'body'         => $data['body'] ?? null,
            'image'        => $data['image'] ?? null,
            'data'         => $data['data'] ?? null,
            'criteria'     => $data['criteria'] ?? null,
            'scheduled_at' => $data['scheduled_at'] ?? null,
            'next_run_at'  => $action === 'schedule' ? ($data['scheduled_at'] ?? null) : null,
            'expiry_at'    => $data['expiry_at'] ?? null,
            'status'       => $status,
            'created_by'   => optional($request->user())->getKey(),
        ]);

        if ($action === 'send') {
            // Run inline so it works without a separate queue worker.
            DispatchCampaignJob::dispatchSync($campaign->id, true);
        }

        return response()->json([
            'success'  => true,
            'message'  => $action === 'send' ? 'Campaign sent' : 'Campaign saved',
            'data'     => $campaign->fresh(),
        ]);
    }

    /** POST /admin/campaigns/{id}/send — dispatch a draft/scheduled campaign now. */
    public function send(int $id)
    {
        $c = NotificationCampaign::find($id);
        if (!$c) return response()->json(['success' => false, 'message' => 'Not found'], 404);
        if (in_array($c->status, [NotificationCampaign::STATUS_SENDING, NotificationCampaign::STATUS_SENT], true)) {
            return response()->json(['success' => false, 'message' => 'Already sent/sending']);
        }

        DispatchCampaignJob::dispatchSync($c->id, true);
        return response()->json(['success' => true, 'message' => 'Campaign sent', 'data' => $c->fresh()]);
    }

    /** POST /admin/campaigns/{id}/cancel */
    public function cancel(int $id)
    {
        $c = NotificationCampaign::find($id);
        if (!$c) return response()->json(['success' => false, 'message' => 'Not found'], 404);
        if (in_array($c->status, [NotificationCampaign::STATUS_SENT], true)) {
            return response()->json(['success' => false, 'message' => 'Already sent']);
        }
        $c->update(['status' => NotificationCampaign::STATUS_CANCELLED]);
        return response()->json(['success' => true, 'message' => 'Campaign cancelled']);
    }

    /** POST /admin/campaigns/{id} — edit a draft / scheduled campaign. */
    public function update(Request $request, int $id)
    {
        $c = NotificationCampaign::find($id);
        if (!$c) return response()->json(['success' => false, 'message' => 'Not found'], 404);
        if (in_array($c->status, [NotificationCampaign::STATUS_SENDING, NotificationCampaign::STATUS_SENT], true)) {
            return response()->json(['success' => false, 'message' => 'Cannot edit a campaign that is sending/sent']);
        }

        $data = $request->validate([
            'type'          => 'sometimes|string|max:50',
            'audience'      => 'sometimes|in:customers,vendors,delivery',
            'delivery_mode' => 'sometimes|in:token,topic',
            'title'         => 'sometimes|string|max:255',
            'body'          => 'nullable|string',
            'image'         => 'nullable|string',
            'data'          => 'nullable|array',
            'criteria'      => 'nullable|array',
            'scheduled_at'  => 'nullable|date',
            'recurrence'    => 'nullable|string|max:50',
            'expiry_at'     => 'nullable|date',
        ]);

        if (array_key_exists('scheduled_at', $data)) {
            $data['next_run_at'] = $data['scheduled_at'];
            if ($data['scheduled_at']) $data['status'] = NotificationCampaign::STATUS_SCHEDULED;
        }

        $c->update($data);
        return response()->json(['success' => true, 'message' => 'Campaign updated', 'data' => $c->fresh()]);
    }

    /** DELETE /admin/campaigns/{id} */
    public function destroy(int $id)
    {
        NotificationCampaign::where('id', $id)->delete();
        return response()->json(['success' => true, 'message' => 'Campaign deleted']);
    }

    /** POST /admin/campaigns/{id}/duplicate — clone as a fresh draft. */
    public function duplicate(int $id)
    {
        $c = NotificationCampaign::find($id);
        if (!$c) return response()->json(['success' => false, 'message' => 'Not found'], 404);

        $copy = $c->replicate();
        $copy->fill([
            'title'          => $c->title . ' (copy)',
            'status'         => NotificationCampaign::STATUS_DRAFT,
            'scheduled_at'   => null,
            'next_run_at'    => null,
            'audience_count' => 0,
            'sent_count'     => 0,
            'failed_count'   => 0,
            'read_count'     => 0,
            'click_count'    => 0,
        ]);
        $copy->save();

        return response()->json(['success' => true, 'message' => 'Campaign duplicated', 'data' => $copy]);
    }

    /** POST /admin/user-stats/rebuild — refresh the segmentation table. */
    public function rebuildStats(UserStatsService $stats)
    {
        $count = $stats->rebuild();
        return response()->json(['success' => true, 'user_stats' => $count]);
    }
}

<?php

namespace App\Services;

use Carbon\Carbon;
use Cron\CronExpression;

/**
 * Computes the next run time for a recurring campaign. Supports the simple
 * keywords daily / weekly / monthly (preserving the original time-of-day) and
 * any standard 5-field cron expression.
 */
class RecurrenceService
{
    public static function next(?string $recurrence, Carbon $from): ?Carbon
    {
        $r = strtolower(trim((string) $recurrence));
        if ($r === '') {
            return null;
        }

        return match ($r) {
            'daily'   => $from->copy()->addDay(),
            'weekly'  => $from->copy()->addWeek(),
            'monthly' => $from->copy()->addMonthNoOverflow(),
            default   => self::cronNext($r, $from),
        };
    }

    private static function cronNext(string $expr, Carbon $from): ?Carbon
    {
        try {
            if (!CronExpression::isValidExpression($expr)) {
                return null;
            }
            return Carbon::instance(
                (new CronExpression($expr))->getNextRunDate($from->toDateTime())
            );
        } catch (\Throwable $e) {
            return null;
        }
    }
}

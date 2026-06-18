<?php

namespace App\Jobs;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Mail;

class SendOrderConfirmationEmail implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 2;
    public int $timeout = 30;

    public function __construct(
        private readonly int    $orderId,
        private readonly array  $items,
        private readonly ?string $userName,
        private readonly ?string $userEmail,
        private readonly float  $discount,
        private readonly float  $deliveryCharge,
        private readonly float  $handlingCharge,
        private readonly float  $finalAmount,
        private readonly float  $cartTotal,
    ) {}

    public function handle(): void
    {
        $order = Order::find($this->orderId);
        if (!$order) return;

        $companyEmail = config('mail.from.address');
        $subject      = "Order Confirmation - #{$order->id}";

        $itemsHtml = '';
        foreach ($this->items as $item) {
            $itemsHtml .= "
                <div style='padding:10px;border-bottom:1px solid #eee;'>
                    <p style='margin:0;'><strong>" . htmlspecialchars($item['product_name']) . "</strong></p>
                    <p style='margin:4px 0 0;'>Quantity: {$item['quantity']} × ₹" . number_format((float) $item['price'], 2) . "</p>
                </div>";
        }

        $discountHtml = $this->discount > 0
            ? "<p><strong>Discount:</strong> -₹" . number_format($this->discount, 2) . "</p>"
            : '';

        $userBody = "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'>
            <title>Order Confirmation</title></head>
            <body style='font-family:Arial,sans-serif;line-height:1.6;color:#333;background:#f9f9f9;'>
            <div style='max-width:600px;margin:0 auto;background:#fff;padding:20px;border:1px solid #ddd;border-radius:5px;'>
            <div style='text-align:center;padding-bottom:20px;border-bottom:1px solid #eee;'>
            <h1 style='color:#2c3e50;margin:0;'>Order Confirmation</h1></div>
            <p>Dear " . htmlspecialchars((string) $this->userName) . ",</p>
            <p>Thank you for your order! We are pleased to confirm that we have received your order.</p>
            <div style='margin:20px 0;padding:15px;background:#f8f9fa;border-radius:5px;'>
            <h2>Order Details</h2>
            <p><strong>Order ID:</strong> <span style='background:#f1c40f;padding:2px 5px;border-radius:3px;'>#" . $order->id . "</span></p>
            <p><strong>Order Date:</strong> " . $order->order_datetime . "</p>
            <p><strong>Payment Method:</strong> " . $order->payment_method . "</p>
            <p><strong>Delivery Date:</strong> " . $order->delivery_date . " at " . $order->delivery_time . "</p></div>
            <div style='margin:20px 0;padding:15px;background:#f8f9fa;border-radius:5px;'>
            <h2>Ordered Items</h2>{$itemsHtml}</div>
            <div style='margin:20px 0;padding:15px;background:#f8f9fa;border-radius:5px;'>
            <h2>Order Summary</h2>
            <p><strong>Subtotal:</strong> ₹" . number_format($this->cartTotal, 2) . "</p>
            {$discountHtml}
            <p><strong>Delivery Charge:</strong> ₹" . number_format($this->deliveryCharge, 2) . "</p>
            <p><strong>Handling Charge:</strong> ₹" . number_format($this->handlingCharge, 2) . "</p>
            <div style='font-size:18px;font-weight:bold;color:#27ae60;margin-top:10px;padding-top:10px;border-top:1px solid #ddd;'>
            <strong>Total Amount: ₹" . number_format($this->finalAmount, 2) . "</strong></div></div>
            <div style='margin-top:30px;padding-top:20px;border-top:1px solid #eee;text-align:center;color:#7f8c8d;font-size:14px;'>
            <p>Thank you for shopping with us!</p>
            <p>© " . date('Y') . " DxMart. All rights reserved.</p></div></div></body></html>";

        $companyBody = "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>New Order</title></head>
            <body style='font-family:Arial,sans-serif;color:#333;'>
            <div style='max-width:600px;margin:0 auto;padding:20px;'>
            <h1>New Order Received</h1>
            <p><strong>Order ID:</strong> #{$order->id}</p>
            <p><strong>Customer:</strong> " . htmlspecialchars((string) $this->userName) . " (" . htmlspecialchars((string) $this->userEmail) . ")</p>
            <p><strong>Payment Method:</strong> " . $order->payment_method . "</p>
            <p style='color:#e74c3c;font-weight:bold;'><strong>Total Amount:</strong> ₹" . number_format($this->finalAmount, 2) . "</p>
            <h2>Items</h2>{$itemsHtml}</div></body></html>";

        try {
            if ($this->userEmail) {
                Mail::html($userBody, fn($m) => $m->to($this->userEmail)->subject($subject));
            }
            Mail::html($companyBody, fn($m) => $m->to($companyEmail)->subject("New Order #{$order->id}"));
        } catch (\Exception) {
            // Email failure logged by the queue worker; order is already placed.
        }
    }
}

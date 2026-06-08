<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Outbox;
use App\Models\Venta;
use Illuminate\Support\Facades\Http;

class ProcessOutbox extends Command
{
    protected $signature = 'outbox:process {--limit=50}';
    protected $description = 'Process pending outbox entries and forward them to Supabase';

    public function handle()
    {
        $limit = (int) $this->option('limit');
        $entries = Outbox::where('status', 'pending')->orderBy('created_at')->limit($limit)->get();
        if ($entries->isEmpty()) {
            $this->info('No pending outbox entries.');
            return 0;
        }

        $supabaseKey = env('SUPABASE_KEY');
        $supabaseUrl = env('SUPABASE_URL');

        foreach ($entries as $entry) {
            $this->info("Processing outbox #{$entry->id} -> {$entry->url}");
            try {
                $entry->attempts++;
                $entry->last_attempt_at = now();
                $entry->save();

                // Build destination URL: interpret custom '/supabase/...' prefixed paths
                $dest = $entry->url;
                if (str_starts_with($dest, '/supabase/')) {
                    $path = substr($dest, strlen('/supabase'));
                    $dest = rtrim($supabaseUrl, '/') . $path;
                }

                $headers = array_merge([
                    'apikey' => $supabaseKey,
                    'Authorization' => 'Bearer ' . $supabaseKey,
                    'Accept' => 'application/json',
                    'Content-Type' => 'application/json'
                ], (array) $entry->headers);

                $payload = $entry->payload ?? [];
                // If payload is minimal (only contains venta_id), hydrate it from local DB
                if (is_array($payload) && isset($payload['venta_id']) && !isset($payload['detalles'])) {
                    $venta = Venta::with(['cliente', 'usuario', 'tipoComprobante', 'detalles.producto'])->find($payload['venta_id']);
                    if ($venta) {
                        $payload = $venta->toArray();
                    }
                }

                $response = Http::withHeaders($headers)->withBody(json_encode($payload), 'application/json')
                    ->send(strtoupper($entry->method), $dest);

                if ($response->successful()) {
                    $entry->status = 'sent';
                    $entry->last_error = null;
                    $entry->save();
                    $this->info("Outbox #{$entry->id} sent successfully.");
                } else {
                    $entry->last_error = $response->body();
                    $entry->save();
                    $this->error("Outbox #{$entry->id} failed with status {$response->status()}.\n{$response->body()}");
                    if ($entry->attempts >= 5) {
                        $entry->status = 'failed';
                        $entry->save();
                    }
                }

            } catch (\Exception $e) {
                $entry->last_error = $e->getMessage();
                $entry->save();
                $this->error("Outbox #{$entry->id} exception: " . $e->getMessage());
                if ($entry->attempts >= 5) {
                    $entry->status = 'failed';
                    $entry->save();
                }
            }
        }

        return 0;
    }
}

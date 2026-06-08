<?php

namespace App\Console;

use Illuminate\Foundation\Console\Kernel as ConsoleKernel;
use Illuminate\Console\Scheduling\Schedule;

class Kernel extends ConsoleKernel
{
    protected $commands = [
        \App\Console\Commands\ProcessOutbox::class,
    ];

    protected function schedule(Schedule $schedule)
    {
        // Process outbox every minute
        $schedule->command('outbox:process')->everyMinute();
    }

    protected function commands()
    {
        // load commands
    }
}

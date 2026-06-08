<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('outbox', function (Blueprint $table) {
            $table->id();
            $table->string('method', 10)->default('POST');
            $table->text('url');
            $table->json('payload')->nullable();
            $table->json('headers')->nullable();
            $table->integer('attempts')->default(0);
            $table->text('last_error')->nullable();
            $table->string('status')->default('pending');
            $table->timestamp('last_attempt_at')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('outbox');
    }
};

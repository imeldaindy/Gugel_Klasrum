<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Tugas kelas: tugas, kuis, pertanyaan, materi + topik, penerima,
 * lampiran guru, soal kuis, serta jawaban/nilai siswa.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('topics', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->timestamps();
            $table->unique(['course_id', 'name']);
        });

        Schema::table('assignments', function (Blueprint $table) {
            $table->string('type', 16)->default('assignment')->after('course_id'); // assignment|quiz|question|material
            $table->foreignId('topic_id')->nullable()->after('type')->constrained('topics')->nullOnDelete();
            $table->boolean('assign_all')->default(true)->after('deadline'); // false = hanya siswa terpilih
            $table->string('question_type', 16)->nullable(); // short_answer | multiple_choice
            $table->json('choices')->nullable(); // pilihan jawaban (pertanyaan pilihan ganda)
        });

        // Siswa terpilih (dipakai bila assign_all = false)
        Schema::create('assignment_recipients', function (Blueprint $table) {
            $table->id();
            $table->foreignId('assignment_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->unique(['assignment_id', 'user_id']);
        });

        // Lampiran dari guru (file / link / drive)
        Schema::create('assignment_attachments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('assignment_id')->constrained()->cascadeOnDelete();
            $table->string('type', 16); // drive|photo|scan|file|link|created
            $table->string('name');
            $table->string('url', 500)->nullable();
            $table->timestamps();
        });

        // Soal kuis
        Schema::create('quiz_questions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('assignment_id')->constrained()->cascadeOnDelete();
            $table->text('text');
            $table->json('options');
            $table->unsignedTinyInteger('correct_index')->nullable();
            $table->unsignedInteger('points')->default(1);
            $table->unsignedInteger('position')->default(0);
            $table->timestamps();
        });

        Schema::table('submissions', function (Blueprint $table) {
            $table->text('answer')->nullable();   // jawaban pertanyaan
            $table->json('answers')->nullable();  // jawaban kuis (indeks pilihan per soal)
            $table->unsignedInteger('score')->nullable(); // nilai
        });
    }

    public function down(): void
    {
        Schema::table('submissions', function (Blueprint $table) {
            $table->dropColumn(['answer', 'answers', 'score']);
        });
        Schema::dropIfExists('quiz_questions');
        Schema::dropIfExists('assignment_attachments');
        Schema::dropIfExists('assignment_recipients');
        Schema::table('assignments', function (Blueprint $table) {
            $table->dropConstrainedForeignId('topic_id');
            $table->dropColumn(['type', 'assign_all', 'question_type', 'choices']);
        });
        Schema::dropIfExists('topics');
    }
};

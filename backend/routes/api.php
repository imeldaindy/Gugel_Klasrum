<?php

use App\Http\Controllers\AssignmentController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ClassworkController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\CourseController;
use App\Http\Controllers\MiscController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');
Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:10,1');

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Kelas
    Route::get('/courses', [CourseController::class, 'index']);
    Route::post('/courses', [CourseController::class, 'store']);
    Route::post('/courses/join', [CourseController::class, 'join']);
    Route::get('/courses/{id}', [CourseController::class, 'show'])->whereNumber('id');
    Route::match(['put', 'patch'], '/courses/{id}', [CourseController::class, 'update'])->whereNumber('id');
    Route::post('/courses/{id}/reset-code', [CourseController::class, 'resetCode'])->whereNumber('id');
    Route::post('/courses/{id}/leave', [CourseController::class, 'leave'])->whereNumber('id');
    Route::get('/courses/{id}/posts', [CourseController::class, 'posts'])->whereNumber('id');
    Route::post('/courses/{id}/posts', [CourseController::class, 'storePost'])->whereNumber('id');
    Route::get('/courses/{id}/assignments', [ClassworkController::class, 'index'])->whereNumber('id');
    Route::post('/courses/{id}/assignments', [ClassworkController::class, 'store'])->whereNumber('id');
    Route::post('/courses/{id}/assignments/reuse', [ClassworkController::class, 'reuse'])->whereNumber('id');
    Route::get('/courses/{id}/topics', [ClassworkController::class, 'topics'])->whereNumber('id');
    Route::post('/courses/{id}/topics', [ClassworkController::class, 'storeTopic'])->whereNumber('id');
    Route::delete('/courses/{id}/topics/{topicId}', [ClassworkController::class, 'destroyTopic'])->whereNumber(['id', 'topicId']);
    Route::get('/courses/{id}/people', [CourseController::class, 'people'])->whereNumber('id');

    // Tugas
    Route::get('/assignments', [AssignmentController::class, 'todo']);
    Route::get('/assignments/{id}', [AssignmentController::class, 'show'])->whereNumber('id');
    Route::match(['put', 'patch'], '/assignments/{id}', [AssignmentController::class, 'update'])->whereNumber('id');
    Route::delete('/assignments/{id}', [AssignmentController::class, 'destroy'])->whereNumber('id');
    Route::post('/assignments/{id}/submit', [AssignmentController::class, 'submit'])->whereNumber('id');
    Route::delete('/assignments/{id}/submit', [AssignmentController::class, 'unsubmit'])->whereNumber('id');
    Route::get('/assignments/{id}/submissions', [AssignmentController::class, 'submissions'])->whereNumber('id');
    Route::put('/assignments/{id}/submissions/{userId}', [AssignmentController::class, 'grade'])->whereNumber(['id', 'userId']);

    // Komentar kelas: type = post | assignment
    Route::get('/comments/{type}/{id}', [CommentController::class, 'index'])
        ->whereIn('type', ['post', 'assignment'])->whereNumber('id');
    Route::post('/comments/{type}/{id}', [CommentController::class, 'store'])
        ->whereIn('type', ['post', 'assignment'])->whereNumber('id');

    // Lain-lain
    Route::get('/notifications', [MiscController::class, 'notifications']);
    Route::post('/notifications/{id}/read', [MiscController::class, 'markRead'])->whereNumber('id');
    Route::post('/feedback', [MiscController::class, 'feedback']);
});

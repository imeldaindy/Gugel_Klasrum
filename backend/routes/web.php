<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Tujuan link undangan kelas: ?cjc=<kode>. Aplikasi membaca kode dari link ini.
Route::get('/join', function (\Illuminate\Http\Request $request) {
    $code = e((string) $request->query('cjc'));

    return response(
        '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
        .'<title>Gabung kelas</title>'
        .'<body style="font-family:sans-serif;max-width:480px;margin:15vh auto;padding:0 16px">'
        .'<h2>Gugel Klasrum</h2>'
        .'<p>Buka aplikasi, pilih <b>Gabung ke kelas</b>, lalu masukkan kode berikut:</p>'
        ."<p style=\"font-size:32px;letter-spacing:2px\"><b>{$code}</b></p></body>"
    );
});

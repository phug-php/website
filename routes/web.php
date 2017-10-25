<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Session;

Route::get('/', function () {
    return view('index', [
        'anchor' => Session::pull('anchor'),
    ]);
});

Route::get('/lang', function () {
    Session::flash('anchor', request('anchor'));

    return back();
})->name('lang');

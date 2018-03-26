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

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Session;

Route::get('/', function (Request $request) {
    header('X-XSS-Protection: 0');

    return view('index', [
        'tryOpened' => $request->has('try') || substr($request->getHttpHost() ?: '', 0, 4) === 'try.',
        'anchor' => Session::pull('anchor'),
    ]);
})->name('home');

Route::get('/lang', function () {
    Session::flash('anchor', request('anchor'));

    return back();
})->name('lang');

<?php

namespace App\Http\Middleware;

use Bkwld\LaravelPug\PugBladeCompiler;
use Bkwld\LaravelPug\PugCompiler;
use Closure;
use Pug\Pug;

class LoadDocumentation
{
    /**
     * Handle an incoming request.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Closure                 $next
     *
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        /** @var Pug $pug */
        $pug = app()->get('laravel-pug.pug');
        $paths = array_unique(array_filter(array_merge($pug->getOption('paths') ?: [], [
            base_path('doc/'.app()->getLocale()),
            $pug->getOption('basedir'),
        ])));
        $pug->setOption('basedir', null);
        $pug->setOption('paths', $paths);

        /** @var PugCompiler $compiler */
        $compiler = app()->get('Bkwld\LaravelPug\PugCompiler');
        $compiler->setCachePath(realpath(storage_path('framework/views/'.app()->getLocale())));

        /** @var PugBladeCompiler $compiler */
        $compiler = app()->get('Bkwld\LaravelPug\PugBladeCompiler');
        $compiler->setCachePath(realpath(storage_path('framework/views/'.app()->getLocale())));

        return $next($request);
    }
}

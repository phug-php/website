<?php

namespace App\Http\Middleware;

use Closure;
use Pug\Pug;

class LoadDocumentation
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        /** @var Pug $pug */
        $pug = app()->get('laravel-pug.pug');
        $paths = array_unique(array_filter(array_merge($pug->getOption('paths') ?: [], [
            base_path('doc/' . app()->getLocale()),
            $pug->getOption('basedir'),
        ])));
        $pug->setOption('basedir', null);
        $pug->setOption('paths', $paths);
        $pug->initCompiler();

        return $next($request);
    }
}

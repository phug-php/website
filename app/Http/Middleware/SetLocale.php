<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Cookie;
use Illuminate\Support\Facades\Request;
use Illuminate\Support\Facades\View;

class SetLocale
{
    const LOCALES = ['en', 'fr'];

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
        $locale = null;
        $pattern = '/^(?:www\.)?('.implode('|', self::LOCALES).')\./i';
        if (preg_match($pattern, Request::server('HTTP_HOST'), $match)) {
            // If the subdomain contains a locale
            $locale = $match[1];
            Cookie::queue('locale', $locale);
        } elseif (request('locale')) {
            // If the URL contains a locale
            $locale = request('locale');
            Cookie::queue('locale', $locale);
        } elseif (Cookie::has('locale')) {
            // If the session contains a locale
            $locale = Cookie::get('locale');
        }
        // If no locale found or if the locale is not available
        if (!in_array($locale, self::LOCALES)) {
            // Negotiate the locale with browser preferred languages
            $locale = $request->getPreferredLanguage(self::LOCALES) ?: self::LOCALES[0];
        }
        app()->setLocale($locale);
        View::share([
            'locales' => self::LOCALES,
            'locale'  => $locale,
        ]);

        return $next($request);
    }
}

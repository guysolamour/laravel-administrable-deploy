<?php

namespace Guysolamour\Administrable\Deploy;

use Guysolamour\Administrable\Deploy\Console\Commands\DeployCommand;


class ServiceProvider extends \Illuminate\Support\ServiceProvider
{
    // const PACKAGE_NAME = 'administrable-mailbox';

    public function boot()
    {
    }

    public function register()
    {
        if ($this->app->runningInConsole()) {
            $this->commands([
                DeployCommand::class,
            ]);
        }
    }

    public static function packagePath(string $path = ''): string
    {
        return  __DIR__ . '/../' . $path;
    }
}

#!/usr/bin/perl

use lib '/home/keith/perl/TuxedoAdmin/lib';
use Tuxedo::Admin;
use Tuxedo::Admin::Server;

$admin = new Tuxedo::Admin(
           'TUXDIR'    => '/opt/bea/tuxedo8.1',
           'TUXCONFIG' => '/home/keith/runtime/TUXCONFIG',
           'BDMCONFIG' => '/home/keith/runtime/BDMCONFIG'
         );

$lap = new Tuxedo::Admin::LocalAccessPoint($admin);
$lap->dmaccesspoint('LOCAL2');
$lap = $admin->local_access_points($lap);
die "not found\n" unless defined $lap;
$lap->remove($lap);

print $admin->status(), "\n";


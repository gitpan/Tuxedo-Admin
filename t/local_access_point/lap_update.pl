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
$lap->dmaccesspointid('mail_remote');
$lap->dmsrvgroup('GW_GRP_2');
$lap = $admin->local_access_points($lap);

$tdomain3 = new Tuxedo::Admin::TDomain($admin);
$tdomain3->dmaccesspoint('LOCAL2');
$tdomain3->dmnwaddr('mail:8767');
@tdomains = $lap->tdomains();

push @tdomains, $tdomain3;
$lap->tdomains(\@tdomains);

$lap->update();

print $admin->status(), "\n";


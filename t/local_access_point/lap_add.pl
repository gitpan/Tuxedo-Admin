#!/usr/bin/perl

use lib '/home/keith/perl/TuxedoAdmin/lib';
use Tuxedo::Admin;
use Tuxedo::Admin::Server;

$admin = new Tuxedo::Admin(
           'TUXDIR'    => '/opt/bea/tuxedo8.1',
           'TUXCONFIG' => '/home/keith/runtime/TUXCONFIG',
           'BDMCONFIG' => '/home/keith/runtime/BDMCONFIG'
         );

$lap = 
  new Tuxedo::Admin::LocalAccessPoint($admin, 'LOCAL2', 'mail_remote', 'GW_GRP_2');
$lap->add();

print $admin->status(), "\n";

$tdomain1 = new Tuxedo::Admin::TDomain($admin);
$tdomain1->dmaccesspoint('LOCAL2');
$tdomain1->dmnwaddr('mail:8765');
$tdomain1->add();

print $admin->status(), "\n";

$tdomain2 = new Tuxedo::Admin::TDomain($admin);
$tdomain2->dmaccesspoint('LOCAL2');
$tdomain2->dmnwaddr('mail:8766');
$tdomain2->add();

print $admin->status(), "\n";


package Tuxedo::Admin::Resources;

use Class::MethodMaker
  new_with_init => 'new',
  get_set => [ qw(
                  authsvc
                  bblquery
                  blocktime
                  cmtret
                  components
                  curdrt
                  curgroups
                  curinterfaces
                  curmachines
                  curqueues
                  currft
                  currtdata
                  curservers
                  curservices
                  curstype
                  curtype
                  dbblwait
                  domainid
                  encryption_required
                  gid
                  hwdrt
                  hwgroups
                  hwinterfaces
                  hwmachines
                  hwqueues
                  hwrft
                  hwrtdata
                  hwservers
                  hwservices
                  ipckey
                  ldbal
                  licexpire
                  licmaxusers
                  licserial
                  master
                  maxaccessers
                  maxaclgroups
                  maxbufstype
                  maxbuftype
                  maxconv
                  maxdrt
                  maxgroups
                  maxgtt
                  maxinterfaces
                  maxmachines
                  maxnetgroups
                  maxobjects
                  maxqueues
                  maxrft
                  maxrtdata
                  maxservers
                  maxservices
                  maxspdata
                  maxtrantime
                  mibmask
                  model
                  notify
                  operation
                  options
                  perm
                  preferences
                  sanityscan
                  scanunit
                  sec_principal_location
                  sec_principal_name
                  sec_principal_passvar
                  security
                  signature_ahead
                  signature_behind
                  signature_required
                  state
                  system_access
                  uid
                  usignal
             ) ];

use Carp;
use strict;

sub init
{
  my $self = shift;
  $self->{admin} = shift;

  croak("Invalid parameters") unless defined $self->{admin};

  my (%input_buffer, $error, %output_buffer);
  %input_buffer = $self->_fields();
  $input_buffer{'TA_CLASS'}     = [ 'T_DOMAIN' ];
  ($error, %output_buffer) = $self->{admin}->_tmib_get(\%input_buffer);
  carp($self->_status()) if ($error < 0);

  delete $output_buffer{'TA_OCCURS'};
  delete $output_buffer{'TA_ERROR'};
  delete $output_buffer{'TA_MORE'};
  delete $output_buffer{'TA_CLASS'};
  delete $output_buffer{'TA_STATUS'};

  my ($field, $key);
  foreach $field (keys %output_buffer)
  {
    $key = $field;
    $key =~ s/^TA_//;
    $key =~ tr/A-Z/a-z/;
    if (defined $output_buffer{$field}[0])
    {
      $self->{$key} = $output_buffer{$field}[0];
    }
    else
    {
      $self->{$key} = undef;
    }
  }
}

sub _fields
{
  my $self = shift;
  my ($key, $field, %data, %fields);
  %data = %{ $self };
  foreach $key (keys %data)
  {
    next if ($key eq 'admin');
    $field = "TA_$key";
    $field =~ tr/a-z/A-Z/;
    $fields{$field} = [ $data{$key} ];
  }
  return %fields;
}

sub hash
{
  my $self = shift;
  my %data = %{ $self };
  delete $data{admin};
  return %data;
}

1;

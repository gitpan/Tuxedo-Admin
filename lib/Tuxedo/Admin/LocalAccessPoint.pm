package Tuxedo::Admin::LocalAccessPoint;

use Class::MethodMaker
  new_with_init => 'new',
  get_set => [ qw(
                  dmaccesspoint
                  dmaccesspointid
                  dmauditlog
                  dmblob_shm_size
                  dmblocktime
                  dmcodepage
                  dmconnection_policy
                  dmconnprincipalname
                  dmmachinetype
                  dmmaxraptran
                  dmmaxretry
                  dmmaxtran
                  dmretry_interval
                  dmsecurity
                  dmsrvgroup
                  dmtlogdev
                  dmtlogname
                  dmtlogsize
                  dmtype
                  state
             ) ];

use Tuxedo::Admin::TDomain;
use Carp;
use strict;
use Data::Dumper;

sub init
{
  my $self               = shift || croak "init: Invalid parameters";
  $self->{admin}         = shift || croak "init: Invalid parameters";
  $self->{dmaccesspoint} = shift || croak "init: Invalid parameters";

  my (%input_buffer, $error, %output_buffer);
  %input_buffer = $self->_fields();
  $input_buffer{'TA_CLASS'}     = [ 'T_DM_LOCAL' ];
  ($error, %output_buffer) = $self->{admin}->_tmib_get(\%input_buffer);
  carp($self->_status()) if ($error < 0);

  $self->exists($output_buffer{'TA_OCCURS'}[0] eq '1');

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

sub exists
{
  my $self = shift;
  $self->{exists} = $_[0] if (@_ != 0);
  return $self->{exists};
}

sub add
{
  my $self = shift;

  croak "dmaccesspoint MUST be set"     unless $self->dmaccesspoint();
  croak "dmaccesspointid MUST be set"   unless $self->dmaccesspointid();
  croak "dmsrvgroup MUST be set"        unless $self->dmsrvgroup();

  my (%input_buffer, $error, %output_buffer, $tdomain);

  %input_buffer = $self->_fields();

  # Constraints
  delete $input_buffer{'TA_DMRETRY_INTERVAL'}
    if ($self->dmmaxretry() == 0);

  $input_buffer{'TA_CLASS'}     = [ 'T_DM_LOCAL' ];
  $input_buffer{'TA_STATE'}     = [ 'NEW' ];
  ($error, %output_buffer) = $self->{admin}->_tmib_set(\%input_buffer);
  carp($self->_status()) if ($error < 0);
  $self->exists(1) unless ($error < 0);
  return $error;
}

sub update
{
  my $self = shift;

  croak "Local Access Point does not exist!" unless $self->exists();
  croak "dmaccesspoint MUST be set"          unless $self->dmaccesspoint();

  my (%input_buffer, $error, %output_buffer, $tdomain);

  %input_buffer = $self->_fields();

  # Constraints
  delete $input_buffer{'TA_DMRETRY_INTERVAL'}; #FIXME
  #    if ($self->dmmaxretry() == 0);

  delete $input_buffer{'TA_STATE'};
  delete $input_buffer{'TA_DMFAILOVERSEQ'}; # FIXME
  delete $input_buffer{'TA_DMTLOGDEV'};     # FIXME
  delete $input_buffer{'TA_DMAUDITLOG'};    # FIXME
  delete $input_buffer{'TA_DMCODEPAGE'};    # FIXME
  delete $input_buffer{'TA_DMMAXRETRY'};    # FIXME

  $input_buffer{'TA_CLASS'}     = [ 'T_DM_LOCAL' ];
  ($error, %output_buffer) = $self->{admin}->_tmib_set(\%input_buffer);
  carp($self->_status()) if ($error < 0);
  return $error;
}

sub remove
{
  my $self = shift;

  croak "Local Access Point does not exist!" unless $self->exists();
  croak "dmaccesspoint MUST be set"          unless $self->dmaccesspoint();

  my (%input_buffer, $error, %output_buffer, $tdomain);

  foreach $tdomain ($self->tdomains())
  {
    #print "Removing tdomain...\n";
    $error = $tdomain->remove();
    $self->{admin}->print_status();
    return $error if ($error < 0);
  }
 
  $input_buffer{'TA_CLASS'}         = [ 'T_DM_LOCAL' ];
  $input_buffer{'TA_STATE'}         = [ 'INVALID' ];
  $input_buffer{'TA_DMACCESSPOINT'} = [ $self->dmaccesspoint() ];
  ($error, %output_buffer) = $self->{admin}->_tmib_set(\%input_buffer);
  carp($self->_status()) if ($error < 0);
  $self->exists(0) unless ($error < 0);
  return $error;
}

sub tdomains
{
  my $self = shift;
  croak "Invalid arguments" if (@_ != 0);
  croak "Local Access Point does not exist" unless $self->exists();
  my @tdomains =
    $self->{admin}->tdomain_list( 
      { 'dmaccesspoint' => $self->dmaccesspoint() }
    );
  return @tdomains;
}

sub _status
{
  my $self = shift;
  return $self->{admin}->status();
}

sub _fields
{
  my $self = shift;
  my ($key, $field, %data, %fields);
  %data = %{ $self };
  foreach $key (keys %data)
  {
    next if ($key eq 'admin');
    next if ($key eq 'exists');
    #next if ($key eq 'tdomains');
    $field = "TA_$key";
    $field =~ tr/a-z/A-Z/;
    $fields{$field} = [ $data{$key} ];
  }
  return %fields;
}

sub hash
{
  my $self = shift;
  my (%data);
  %data = %{ $self };
  delete $data{admin};
  #delete $data{tdomains};
  return %data;
}

=pod

Tuxedo::Admin::LocalAccessPoint

=head1 SYNOPSIS

  use Tuxedo::Admin;

  $admin = new Tuxedo::Admin;

  $local_access_point = $admin->local_access_point('ACCESS_POINT_NAME');
  
  if ($local_access_point->exists())
  {
    print "Connection Policy: ",
          $local_access_point->dmconnection_policy(), "\n";
  
    $local_access_point->dmconnection_policy('ON_DEMAND');
    $error = $local_access_point->update();
  }

=head1 DESCRIPTION

Provides methods to query, add, remove and update a local access point.

=head1 INITIALISATION

Tuxedo::Admin::LocalAccessPoint are not instantiated directly.  Instead they
are created via the local_access_pount() method of a Tuxedo::Admin object.

Example:

  $local_access_point =
    $admin->local_access_point('ACCESS_POINT_NAME');
  
This applies both for existing servers and for new servers that are being
created.

=head1 METHODS

=head2 exists()

Used to determine whether or not the local access point exists in the current
Tuxedo application.

  if ($local_access_point->exists())
  {
    ...
  }

Returns true if the local access point exists.


=head2 add()

Adds the local access point to the current Tuxedo application.

  $error = $local_access_point->add();

Croaks if the local access point already exists or if the required
dmaccesspoint, dmaccesspointid and dmsrvgroup parameters are not set.  If
$error is negative then an error occurred.

=cut

1;

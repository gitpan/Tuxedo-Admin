package Tuxedo::Admin::ExportedResource;

use Class::MethodMaker
  new_with_init => 'new',
  get_set => [ qw(
                  dmaclname
                  dmapi
                  dmcodepage
                  dmconv
                  dminbuftype
                  dmlaccesspoint
                  dmoutbuftype
                  dmremotename
                  dmresourcename
                  dmresourcetype
                  dmte_function
                  dmte_product
                  dmte_qualifier
                  dmte_rtqgroup
                  dmte_rtqname
                  dmte_target
                  state
             ) ];

use Carp;
use strict;
use Data::Dumper;

sub init
{
  my $self = shift;
  ($self->{admin}, $self->{dmresourcename}) = @_;

  croak "Invalid parameters" unless
    ((defined $self->{admin}) and
     (defined $self->{dmresourcename}));

  my (%input_buffer, $error, %output_buffer);
  %input_buffer = $self->_fields();
  $input_buffer{'TA_CLASS'}     = [ 'T_DM_EXPORT' ];
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

sub add
{
  my $self = shift;

  croak "dmresourcename MUST be set"   unless $self->dmresourcename();

  my (%input_buffer, $error, %output_buffer);

  %input_buffer = $self->_fields();

  $input_buffer{'TA_CLASS'}     = [ 'T_DM_EXPORT' ];
  $input_buffer{'TA_STATE'}     = [ 'NEW' ];
  ($error, %output_buffer) = $self->{admin}->_tmib_set(\%input_buffer);
  carp($self->_status()) if ($error < 0);
  return $error;
}

sub update
{
  my $self = shift;

  croak "dmresourcename MUST be set"  unless $self->dmresourcename();
  croak "dmlaccesspoint MUST be set"  unless $self->dmlaccesspoint();

  my (%input_buffer, $error, %output_buffer, $tdomain);

  %input_buffer = $self->_fields();

  $input_buffer{'TA_CLASS'}     = [ 'T_DM_EXPORT' ];
  ($error, %output_buffer) = $self->{admin}->_tmib_set(\%input_buffer);
  carp($self->_status()) if ($error < 0);
  return $error;
}

sub remove
{
  my $self = shift;

  croak "dmresourcename MUST be set"  unless $self->dmresourcename();
  croak "dmlaccesspoint MUST be set"  unless $self->dmlaccesspoint();

  my (%input_buffer, $error, %output_buffer, $tdomain);

  foreach $tdomain ($self->tdomains())
  {
    next unless defined $tdomain;
    $error = $tdomain->remove();
    return $error if ($error < 0);
  }

  $input_buffer{'TA_CLASS'}         = [ 'T_DM_EXPORT' ];
  $input_buffer{'TA_STATE'}         = [ 'INVALID' ];
  $input_buffer{'TA_DMRESOURCENAME'} = [ $self->dmresourcename() ];
  $input_buffer{'TA_DMLACCESSPOINT'} = [ $self->dmlaccesspoint() ];
  ($error, %output_buffer) = $self->{admin}->_tmib_set(\%input_buffer);
  carp($self->_status()) if ($error < 0);
  return $error;
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
  return %data;
}

1;

package Tuxedo::Admin::TDomain;

use Class::MethodMaker
  new_with_init => 'new',
  get_set => [ qw(
                  dmaccesspoint
                  dmcmplimit
                  dmfailoverseq
                  dmmaxencryptbits
                  dmminencryptbits
                  dmnwaddr
                  dmnwdevice
                  state
             ) ];

use Carp;
use strict;

sub init
{
  my $self = shift;
  ($self->{admin}, $self->{dmaccesspoint}, $self->{dmnwaddr}) = @_;

  croak "Invalid parameters" unless
    ((defined $self->{admin}) and
     (defined $self->{dmaccesspoint}) and
     (defined $self->{dmnwaddr}));

  my (%input_buffer, $error, %output_buffer);
  %input_buffer = $self->_fields();
  $input_buffer{'TA_CLASS'}     = [ 'T_DM_TDOMAIN' ];
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

  croak "dmaccesspoint MUST be set"     unless $self->dmaccesspoint();
  croak "dmnwaddr MUST be set"          unless $self->dmnwaddr();

  my (%input_buffer, $error, %output_buffer);
  %input_buffer = $self->_fields();
  $input_buffer{'TA_CLASS'}     = [ 'T_DM_TDOMAIN' ];
  $input_buffer{'TA_STATE'}     = [ 'NEW' ];
  ($error, %output_buffer) = $self->{admin}->_tmib_set(\%input_buffer);
  carp($self->_status()) if ($error < 0);
  return $error;
}

sub update
{
  my $self = shift;

  croak "dmaccesspoint MUST be set"     unless $self->dmaccesspoint();
  croak "dmnwaddr MUST be set"          unless $self->dmnwaddr();

  my (%input_buffer, $error, %output_buffer);

  %input_buffer = $self->_fields();
  delete $input_buffer{'TA_STATE'};
  delete $input_buffer{'TA_DMFAILOVERSEQ'}; # FIXME
  delete $input_buffer{'TA_DMNWDEVICE'};    # FIXME

  $input_buffer{'TA_CLASS'}     = [ 'T_DM_TDOMAIN' ];
  ($error, %output_buffer) = $self->{admin}->_tmib_set(\%input_buffer);
  carp($self->_status()) if ($error < 0);
  return $error;
}

sub remove
{
  my $self = shift;

  croak "dmaccesspoint MUST be set"     unless $self->dmaccesspoint();

  my (%input_buffer, $error, %output_buffer);
  #%input_buffer = $self->_fields();
  $input_buffer{'TA_CLASS'}         = [ 'T_DM_TDOMAIN' ];
  $input_buffer{'TA_STATE'}         = [ 'INVALID' ];
  $input_buffer{'TA_DMACCESSPOINT'} = [ $self->dmaccesspoint() ];
  $input_buffer{'TA_DMNWADDR'}      = [ $self->dmnwaddr() ];
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

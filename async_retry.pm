use warnings;
use strict;

use HTTP::Async;

require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/async_retry/;

sub async_retry {
    my %args = %{$_[0]};
    my @requests = @{$_[1]};
    my $callback = $_[2];

    my $retries = $args{retries} || 10;
    delete $args{retries};

    my @ids;
    my %id_map;
    my $async = HTTP::Async->new(%args);
    for my $request (@requests) {
        my $id = $async->add($request);
        $id_map{$id} = $request;
        push @ids, $id;
    }

    my $retry_count;
    my $another_id_map;
    while (1) {
        my ($response, $id) = $async->wait_for_next_response;
        my $request = $id_map{$id};

        unless ($response->is_success) {
            unless (defined $retry_count->{$request}) {
                $retry_count->{$request} = 0
            }
            $retry_count->{$request}++;
            if ($retry_count->{$request} < $retries) {
                my $new_id = $async->add($request);
                $id_map{$new_id} = $request;
                delete $id_map{$id};
                next;
            }
            else {
                $callback->($request, $response);
                delete $id_map{$id};
            }
        }
        else {
            $callback->($request, $response);
            delete $id_map{$id};
        }

        if ($async->total_count == 0) {
            last;
        }
    }
}

1;

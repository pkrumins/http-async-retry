use warnings;
use strict;

use HTTP::Request;
use async_retry qw/async_retry/;

my @urls = (
    'http://www.google.com/1',
    'http://www.google.com/2',
    'http://www.google.com/3',
    'http://www.google.com/',
    'http://www.google.com/5',
);

async_retry(
    {
        timeout => 10,
        max_request_time => 20,
        retries => 5
    },
    [
        map { HTTP::Request->new(GET => $_) } @urls
    ],
    sub {
        my ($req, $res) = @_;
        print $res->base, "\n";
    }
);

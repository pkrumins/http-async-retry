HTTP::Async with retry.

Here's an example:

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

This will retry getting the @urls via HTTP::Async 5 times.

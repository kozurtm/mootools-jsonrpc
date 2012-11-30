#!/usr/bin/env perl
use Mojolicious::Lite;
use MojoX::JSON::RPC::Service;
use MojoX::JSON::RPC::Dispatcher::Method;

get '/' => sub {
  my $self = shift;
  $self->render('index');
};

my $svc = MojoX::JSON::RPC::Service->new;
$svc->register(
    'sum',
    sub {
        my $self = shift;
        $self->stash(
            exception_handler => sub {
                my ($self, $err, $m) = @_;
                $m->invalid_params;
            });
        my $sum = 0;
        for (@_) {
            /^\d+$/ or die 'Invalid params';
            $sum += $_
        }
        return $sum;
    }, { with_self => 1 });
$svc->register(
    'uc',
    sub {
        return uc join(', ', @_);
    });

plugin 'json_rpc_dispatcher' => {
    services => {
        '/jsonrpc' => $svc,
    }};

app->start;
__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
  <body>
    <form id="myform">
      method: <input id="method" type="text"><br>
      params: <input id="params" type="text"><br>
      <input type="submit" value="send">
    </form>
    <hr>
    <div id="board"></div>
  </body>
  <script src="//ajax.googleapis.com/ajax/libs/mootools/1.4.5/mootools-yui-compressed.js"></script>
  <script src="/jsonrpc.js"></script>
  <script>
(function($) {
    window.addEvent('domready', function() {
        $('myform').addEvent('submit', function(e) {
            e.stop();

            var rpc = new Request.JSONRPC({
                url: '/jsonrpc',
                remoteMethod: 'anonymous',
                onSuccess: function(result) {
                    console.log('success');
                    $('board').set('text', 'success --> ' + JSON.encode(result));
                },
                onComplete: function() {
                    console.log('complete');
                },
                onFailure: function() {
                    console.log('failure');
                    if (arguments.length) console.dir(arguments);
                    $('board').set('text', 'failure');
                },
                onRemoteError: function(error) {
                    console.log('remote-error');
                    $('board').set('text', 'remote-error --> ' + JSON.encode(error));
                },
                onIdMismatch: function(response) {
                    console.log('id-mismatch');
                    $('board').set('text', 'id-mismatch --> ' + this.xid + ' <> ' + response.id);
                },
                onCancel: function() {
                    console.log('canceled');
                }
            });
            rpc.send(JSON.decode($('params').get('value'), true), $('method').get('value'));
            (function() { rpc.send(['hello', 'world'], 'uc'); }).delay(3000);
        });
    });
})(document.id);
  </script>
</html>

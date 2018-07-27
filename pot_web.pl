#!/usr/bin/env perl
use Mojolicious::Lite;
use Mojo::Redis2;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';
plugin 'proxy';

my $redis = Mojo::Redis2->new;
my $ipfshash = "QmcXusLcYAYDstxGmzs5iQywBKSjMHFGLkT6RzHMH9xgZk";

app->config(hypnotoad => {listen => ['http://*:9080'], pid_file => '/home/node/run/pot_web.pid'});


get '/' => sub {
  my $c = shift;
  my $host = $c->req->url->to_abs->host;
  my $file = $c->req->url->to_abs;
  my $id;
  if ($redis->exists('url_'.$host)) {
		$id = $redis->get('url_'.$host)
  } else {
		$id = $ipfshash;
		$file = "index.html";
  }
  my $base = "http://127.0.0.1:8080/ipfs/$id/$file";
  $c->proxy_to($base);
};

get '/public/*file' => sub {
  my $c = shift;
  my $host = $c->req->url->to_abs->host;
  my $file = $c->param('file');
  my $id;
  if ($redis->exists('url_'.$host)) {
		$id = $redis->get('url_'.$host)
  } else {
		$id = $ipfshash;
  }
  $file = "public/$file";
  my $base = "http://127.0.0.1:8080/ipfs/$id/$file";
  $c->proxy_to($base);
};

get '/ipfs/:id/*file' => sub {
  my $c = shift;
  my $url = $c->req->url->to_string;
  my $id = $c->param('id');
  my $file = $c->param('file');
  my $base = "http://127.0.0.1:8080/ipfs/$id/$file";
  $c->proxy_to($base);
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<h1>Welcome to the Mojolicious real-time web framework!</h1>
To learn more, you can browse through the documentation
<%= link_to 'here' => '/perldoc' %>.

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

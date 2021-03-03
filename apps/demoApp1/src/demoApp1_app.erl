%%%-------------------------------------------------------------------
%% @doc demoApp1 public API
%% @end
%%%-------------------------------------------------------------------

-module(demoApp1_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    demoApp1_sup:start_link().

stop(_State) ->
    ok.

%% internal functions

%%%-------------------------------------------------------------------
%% @doc demoApp1 top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(demoApp1_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{strategy => one_for_one,
                 intensity => 100,
                 period => 3600},
    ChildSpecs = [
      {kafka_client_svr, {kafka_client_svr, start_link, []}, permanent, 10000, worker, [kafka_client_svr]},
      {kafka_consumer_svr, {kafka_consumer_svr, start_link, []}, permanent, 10000, worker, [kafka_consumer_svr]}
    ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions

%%%-------------------------------------------------------------------
%%% @author KasunE
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Feb 2021 10:21 AM
%%%-------------------------------------------------------------------
-module(kafka_consumer_svr).
-include_lib("brod/include/brod.hrl").
-author("KasunE").

-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([init/2, handle_message/4]). %% callback api
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).
%% brod_group_subscriber behaviour callback
init(_GroupId, _Arg) -> {ok, []}.

handle_message(_Topic, Partition, Message, State) ->
  #kafka_message{ offset = Offset
    , key   = Key
    , value = Value
  } = Message,
  io:fwrite("Kafka message ~p ~n", [Message]),
  {ok, ack, State}.

%% gen_server callbacks


-define(SERVER, ?MODULE).

-record(kafka_consumer_svr_state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%% @doc Spawns the server and registers the local name (unique)
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%% @private
%% @doc Initializes the server
-spec(init(Args :: term()) ->
  {ok, State :: #kafka_consumer_svr_state{}} | {ok, State :: #kafka_consumer_svr_state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  Topic  = <<"TestTopic">>,
  %% commit offsets to kafka every 5 seconds
  GroupConfig = [{offset_commit_policy, commit_to_kafka_v2},
    {offset_commit_interval_seconds, 5}
  ],
  GroupId = <<"test_group_id">>,
  ConsumerConfig = [{begin_offset, earliest}],
  brod:start_link_group_subscriber(client1, GroupId, [Topic],
    GroupConfig, ConsumerConfig,
    _CallbackModule  = ?MODULE,
    _CallbackInitArg = []),
  {ok, #kafka_consumer_svr_state{}}.

%% @private
%% @doc Handling call messages
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #kafka_consumer_svr_state{}) ->
  {reply, Reply :: term(), NewState :: #kafka_consumer_svr_state{}} |
  {reply, Reply :: term(), NewState :: #kafka_consumer_svr_state{}, timeout() | hibernate} |
  {noreply, NewState :: #kafka_consumer_svr_state{}} |
  {noreply, NewState :: #kafka_consumer_svr_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #kafka_consumer_svr_state{}} |
  {stop, Reason :: term(), NewState :: #kafka_consumer_svr_state{}}).
handle_call(_Request, _From, State = #kafka_consumer_svr_state{}) ->
  {reply, ok, State}.

%% @private
%% @doc Handling cast messages
-spec(handle_cast(Request :: term(), State :: #kafka_consumer_svr_state{}) ->
  {noreply, NewState :: #kafka_consumer_svr_state{}} |
  {noreply, NewState :: #kafka_consumer_svr_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #kafka_consumer_svr_state{}}).
handle_cast(_Request, State = #kafka_consumer_svr_state{}) ->
  {noreply, State}.

%% @private
%% @doc Handling all non call/cast messages
-spec(handle_info(Info :: timeout() | term(), State :: #kafka_consumer_svr_state{}) ->
  {noreply, NewState :: #kafka_consumer_svr_state{}} |
  {noreply, NewState :: #kafka_consumer_svr_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #kafka_consumer_svr_state{}}).
handle_info(_Info, State = #kafka_consumer_svr_state{}) ->
  {noreply, State}.

%% @private
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #kafka_consumer_svr_state{}) -> term()).
terminate(_Reason, _State = #kafka_consumer_svr_state{}) ->
  ok.

%% @private
%% @doc Convert process state when code is changed
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #kafka_consumer_svr_state{},
    Extra :: term()) ->
  {ok, NewState :: #kafka_consumer_svr_state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State = #kafka_consumer_svr_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

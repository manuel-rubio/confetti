%%%-------------------------------------------------------------------
%%% @author Adam Rutkowski
%%% @copyright (C) 2011, jtendo
%%% @doc
%%% Confetti Management server supervisor
%%% @end
%%%-------------------------------------------------------------------
-module(confetti_mgmt_sup).
-behaviour(supervisor).

-export([start_link/0, start_socket/0]).
-export([init/1]).

-include("confetti.hrl").

start_link() ->
    {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    start_socket(),
    {ok, Pid}.

init([]) ->
    MgmtConf = case application:get_env(confetti, mgmt_config_location) of
        {ok, NewMgmtConf} -> NewMgmtConf;
        _ -> {"mgmt_conf.conf", "conf"}
    end,
    confetti:use(mgmt_conf, [
            {location, MgmtConf},
            {subscribe, false}
        ]),
    Config = get_cfg(confetti:fetch(mgmt_conf)),
    Port = proplists:get_value(port, Config, 50000),
    IpS = proplists:get_value(ip, Config, "127.0.0.1"),
    {ok, Ip} = inet_parse:ipv4_address(IpS),
    {ok, ListenSocket} = gen_tcp:listen(Port, [{active,once},
                                               {reuseaddr, true}, {ip, Ip}]),
    {ok, {{simple_one_for_one, 60, 3600},
         [{socket,
          {confetti_mgmt, start_link, [ListenSocket]},
          temporary, 1000, worker, [confetti_mgmt]}
         ]}}.

start_socket() ->
    supervisor:start_child(?MODULE, []).

get_cfg([C]=Config) when length(Config)=:=0 andalso is_list(C) ->
    proplists:get_value(confetti, C, []);
get_cfg(C) ->
    C.


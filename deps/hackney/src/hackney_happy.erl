-module(hackney_happy).

-export([connect/3, connect/4]).

-include("hackney_internal.hrl").
-include_lib("kernel/include/inet.hrl").

-define(TIMEOUT, 250).
-define(CONNECT_TIMEOUT, 5000).

connect(Hostname, Port, Opts) ->
  connect(Hostname, Port, Opts, ?CONNECT_TIMEOUT).

connect(Hostname, Port, Opts, Timeout) ->
  do_connect(parse_address(Hostname), Port, Opts, Timeout).

do_connect(Hostname, Port, Opts, Timeout) when is_tuple(Hostname) ->
  case hackney_cidr:is_ipv6(Hostname) of
    true ->
      ?report_debug("connect using IPv6", [{hostname, Hostname}, {port, Port}]),
      gen_tcp:connect(Hostname, Port, [inet6 | Opts], Timeout);
    false ->
      case hackney_cidr:is_ipv4(Hostname) of
        true ->
          ?report_debug("connect using IPv4", [{hostname, Hostname}, {port, Port}]),
          gen_tcp:connect(Hostname, Port, [inet | Opts], Timeout);
        false ->
          {error, nxdomain}
      end
  end;
do_connect(Hostname, Port, Opts, Timeout) ->
  ?report_debug("happy eyeballs, try to connect using IPv6",  [{hostname, Hostname}, {port, Port}]),
  Self = self(),
  {Ipv6Addrs, IPv4Addrs} = getaddrs(Hostname),
  {Pid6, MRef6} = spawn_monitor(fun() -> try_connect(Ipv6Addrs, Port, Opts, Self) end),
  TRef = erlang:start_timer(?TIMEOUT, self(), try_ipv4),
  receive
    {'DOWN', MRef6, _Type, _Pid, {happy_connect, OK}} ->
      _ = erlang:cancel_timer(TRef, []),
      OK;
    {'DOWN', MRef6, _Type, _Pid, _Info} ->
      _ = erlang:cancel_timer(TRef, []),
      {Pid4, MRef4} = spawn_monitor(fun() -> try_connect(IPv4Addrs, Port, Opts, Self) end),
      do_connect_2(Pid4, MRef4, Timeout);
    {timeout, TRef, try_ipv4} ->
      PidRef4 = spawn_monitor(fun() -> try_connect(IPv4Addrs, Port, Opts, Self) end),
      do_connect_1(PidRef4, {Pid6, MRef6}, Timeout)
  after Timeout -> 
          _ = erlang:cancel_timer(TRef, []),
          erlang:demonitor(MRef6, [flush]),
          {error, connect_timeout}
  end.


do_connect_1({Pid4, MRef4}, {Pid6, MRef6}, Timeout) ->
  receive
    {'DOWN', MRef4, _Type, _Pid, {happy_connect, OK}} ->
      ?report_trace("happy_connect ~p", [OK]),
      connect_gc(Pid6, MRef6),
      OK;
    {'DOWN', MRef4, _Type, _Pid, _Info} ->
      do_connect_2(Pid6, MRef6, Timeout);
    {'DOWN', MRef6, _Type, _Pid, {happy_connect, OK}} ->
      ?report_trace("happy_connect ~p", [OK]),
      connect_gc(Pid4, MRef4),
      OK;
    {'DOWN', MRef6, _Type, _Pid, _Info} ->
      do_connect_2(Pid4, MRef4, Timeout)
  after Timeout ->
          connect_gc(Pid4, MRef4),
          connect_gc(Pid6, MRef6),
          {error, connect_timeout}
  end.

do_connect_2(Pid, MRef, Timeout) ->
  receive
    {'DOWN', MRef, _Type, _Pid, {happy_connect, OK}} ->
      ?report_trace("happy_connect ~p", [OK]),
      OK;
    {'DOWN', MRef, _Type, _Pid, Info} ->
      {connect_error, Info}
  after Timeout ->
          connect_gc(Pid, MRef),
          {error, connect_timeout}
  end.

connect_gc(Pid, MRef) ->
  catch exit(Pid, normal),
  erlang:demonitor(MRef, [flush]).


-spec parse_address(inet:ip_address() | binary() | string()) -> inet:ip_address() | string().
parse_address(IPTuple) when is_tuple(IPTuple) -> IPTuple;
parse_address(IPBin) when is_binary(IPBin) ->
  parse_address(binary_to_list(IPBin));
%% IPv6 string with brackets
parse_address("[" ++ IPString) ->
  parse_address(lists:sublist(IPString, length(IPString) - 1));
parse_address(IPString) ->
  case inet:parse_address(IPString) of
    {ok, IP} -> IP;
    {error, _} -> IPString
  end.

-spec getaddrs(string()) -> {[{inet:ip_address(), 'inet6' | 'inet'}], [{inet:ip_address(), 'inet6' | 'inet'}]}.
getaddrs("localhost") ->
  {[{{0,0,0,0,0,0,0,1}, 'inet6'}], [{{127,0,0,1}, 'inet'}]};
getaddrs(Name) ->
  IP6Addrs = [{Addr, 'inet6'} || Addr <- getbyname(Name, 'aaaa')],
  IP4Addrs = [{Addr, 'inet'} || Addr <- getbyname(Name, 'a')],
  {IP6Addrs, IP4Addrs}.

getbyname(Hostname, Type) ->
  case (catch inet_res:getbyname(Hostname, Type)) of
    {'ok', #hostent{h_addr_list=AddrList}} -> lists:usort(AddrList);
    {error, _Reason} -> [];
    Else ->
      %% ERLANG 22 has an issue when g matching somee DNS server messages
      ?report_debug("DNS error", [{hostname, Hostname}
                                 ,{type, Type}
                                 ,{error, Else}]),
      []
  end.

try_connect(Ipv6Addrs, Port, Opts, Self) ->
  try_connect(Ipv6Addrs, Port, Opts, Self, {error, nxdomain}).

try_connect([], _Port, _Opts, _ServerPid, LastError) ->
  ?report_trace("happy eyeball: failed to connect", [{error, LastError}]),
  exit(LastError);
try_connect([{IP, Type} | Rest], Port, Opts, ServerPid, _LastError) ->
  ?report_trace("try to connect", [{ip, IP}, {type, Type}]),
  case gen_tcp:connect(IP, Port, [Type | Opts], ?TIMEOUT) of
    {ok, Socket} = OK ->
      ?report_trace("success to connect", [{ip, IP}, {type, Type}]),
      ok = gen_tcp:controlling_process(Socket, ServerPid),
      exit({happy_connect, OK});
    Error ->
      try_connect(Rest, Port, Opts, ServerPid, Error)
  end.

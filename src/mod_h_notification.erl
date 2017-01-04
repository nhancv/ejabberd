-module(mod_h_notification).

-behaviour(gen_mod).

-include("ejabberd.hrl").
%% Required by ?INFO_MSG macros
-include("logger.hrl").
%% ejabberd functions for JID manipulation called jlib.
-include("jlib.hrl").

%% gen_mod API callbacks
-export([start/2, stop/1, create_push_message/3]).

start(_Host, _Opts) ->
    ?INFO_MSG("Module Started", []),
    ejabberd_hooks:add(offline_message_hook, _Host, ?MODULE, create_push_message, 50).

stop(_Host) ->
    ?INFO_MSG("Stop Method of the Module Called", []),
    ejabberd_hooks:delete(offline_message_hook, _Host, ?MODULE, create_push_message, 50).

create_push_message(_From, _To, Packet) ->
    
    El = xmpp:encode(Packet),
    Sender = parse_string(jid:to_string(jid:tolower(_From))),
    Receiver = parse_string(jid:to_string(jid:tolower(_To))),
    Body = parse_string(fxml:get_subtag_cdata(El, <<"body">>)),
    XML = parse_string(fxml:element_to_binary(El)),
   
    post_push_message(Sender, Receiver, Body, XML).

post_push_message(Sender, Receiver, Body, XML) ->
    ?INFO_MSG("Posting From ~p To ~p Body ~p XML ~p~n",[Sender, Receiver, Body, XML]),

    httpc:request(post, {"http://local.beesightsoft.com:7012/notification", [], "application/x-www-form-urlencoded",
        lists:concat(["From=", Sender,"&To=", Receiver,"&Body=", Body, "&XML=", XML])}, [], []),
    
    ?INFO_MSG("Push Sent.", []).

parse_string(Input) ->
    R = lists:flatten(io_lib:format("~p",[Input])),
    string:substr(R,4,string:len(R)-6).

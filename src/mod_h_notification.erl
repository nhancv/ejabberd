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

    %%Check is notify message by: exist "type":"notify" in body
    NotNotify = ((string:equal(Body, "") == false) and (string:str(Body, "\\\"type\\\":\\\"notify\\\"") == 0)),
    case NotNotify of
        true ->
            post_push_message(Sender, Receiver, Body, XML);

        false ->
            {}
    end.

post_push_message(Sender, Receiver, Body, XML) ->
    ?INFO_MSG("Posting From ~p To ~p Body ~p XML ~p~n",[Sender, Receiver, Body, XML]),

    httpc:request(post, {"http://nhancv.github.io/notification", [], "application/x-www-form-urlencoded",
        lists:concat(["from=", Sender,"&to=", Receiver,"&body=", Body, "&xml=", XML])}, [], []),
    
    ?INFO_MSG("Push Sent.", []).

parse_string(Input) ->
    R = lists:flatten(io_lib:format("~p",[Input])),
    case string:equal(R, "<<>>") of
        true ->
            "";
        false ->
            string:substr(R,4,string:len(R)-6)
    end.


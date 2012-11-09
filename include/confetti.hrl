-record(provider, {
        opts,
        raw_conf,
        conf
    }).

-define(FETCH, fun(Provider, Key, Default) ->
        case confetti:fetch(Provider) of
            [FetchConfig] when is_list(FetchConfig) ->
                proplists:get_value(Key, FetchConfig, Default);
            FetchSimpleConfig ->
                proplists:get_value(Key, FetchSimpleConfig, Default)
        end
    end).

-define(SOCK(Msg), {tcp, _Port, Msg}).

-define(LOAD, fun(D,F) ->
        P = filename:join(D, F),
        {ok, C} = file:read_file(P),
        binary_to_list(C)
    end).

-define(HELO,
            fun() ->
                    case filelib:is_file("priv/helo.txt") of
                        true ->
                            ?LOAD("priv", "helo.txt");
                        false ->
                            case code:priv_dir(confetti) of
                                {error, bad_name} ->
                                    "Could not read helofile";
                                Dir ->
                                    ?LOAD(Dir, "helo.txt")
                            end
                    end
            end).

-define(PROMPT,
            fun() ->
                    io_lib:format("(~w)> ", [node()])
            end).

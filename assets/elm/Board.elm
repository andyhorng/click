port module Board exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String
import Char


main =
    programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }



-- MODEL


type alias Flags =
    { total_clicks : Int
    }


type alias Model =
    { total_clicks : Int
    , online_users : Int
    , sum : List Score
    , stop : Bool
    , hearts : List Heart
    }

type alias Heart =
    { ttl : Int
    , x : Int
    }


type alias Score =
    { name : String, count : Int, id : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.total_clicks 0 [] False [], Cmd.none )



-- UPDATE


type Msg
    = Click Int
    | Online Int
    | Sum (List Score)
    | Start
    | Stop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Click n ->
            if not model.stop then
                ( { model | total_clicks = model.total_clicks + n }, Cmd.none )
            else
                ( model, Cmd.none )

        Online n ->
            ( { model | online_users = n }, Cmd.none )

        Sum sum ->
            if not model.stop then
              ( { model | sum = sum }, Cmd.none )
            else
              ( model, Cmd.none )

        Start ->
            ( {model | stop = False, total_clicks = 0}, start "start" )

        Stop ->
            ( {model | stop = True}, Cmd.none )


port start : String -> Cmd msg


port clicks : (Int -> msg) -> Sub msg


port online_users : (Int -> msg) -> Sub msg


port sum : (List Score -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ clicks Click, online_users Online, sum Sum ]



-- VIEW

digits num padLen =
    let
        chs = String.toList <| String.padLeft padLen '0' <| toString num
        digit n = div [ class "pos"] [
                  span [class "animate digit", style [("top", "-" ++ (String.fromChar n) ++ "em")]]
                      [ text "0123456789" ]
                ]
    in
        List.map digit chs

view : Model -> Html Msg
view model =
    let
        sort =
            List.take 10 << List.sortBy (\score -> -score.count)

        guestIcon id =
            let
                code =
                    List.sum <|
                        List.map
                            (\c ->
                                if Char.isDigit c || Char.isUpper c then
                                    42
                                else
                                    3
                            )
                        <|
                            String.toList id
            in
                "/images/MadebyMade-Vector-LineIcons-Love-Live-" ++ (String.padLeft 2 '0' <| toString <| rem code 70) ++ ".svg"

        scores =
            div [] <|
                List.map
                    (\score ->
                        div [ class "level" ]
                            [ div [ class "level-left" ]
                                [ div [ class "level-item" ]
                                    [ figure [ class "image is-48x48" ] [ img [ src <| guestIcon score.id ] [] ]
                                    ]
                                , div [ class "level-item" ] [ span [ class "subtitle is-2" ] [ text score.name ] ]
                                ]
                            , div [ class "level-right" ] [ div [ class "level-item has-text-left" ] [ span [ class "subtitle is-3 small-pos" ]  <| digits score.count 3  ] ]
                            ]
                    )
                <|
                    sort model.sum
    in
        div [ class "columns" ]
            [ div [ class "column is-one-third" ] []
            , div [ class "column is-one-third" ]
                [ div []
                    [ div [ class "level"] [ div [ class "level-item"] [span [ class "title is-1"] <| digits model.total_clicks 5]]
                    , div [ class "level"] [ div [ class "level-item"] [span [ class "subtitle is-4"] <| digits model.online_users 3]]
                    , div [] [ scores ]
                    , div [ class "section"] [
                           div [ class "level" ]
                               [ div [ class "level-item" ] [ button [ onClick Start, class "button is-danger" ] [ text "Start" ] ]
                               , div [ class "level-item" ] [ button [ onClick Stop, class "button is-danger" ] [ text "Stop" ] ]
                               ]]
                    ]
                ]
            , div [ class "column is-one-third" ] []
            ]

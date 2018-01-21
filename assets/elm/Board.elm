port module Board exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String
import Char
import Random
import Window
import Task
import Svg
import Svg.Events as SE
import Svg.Attributes as SA
import Time as T


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
    , winHeight : Int
    , winWidth : Int
    , ttl : Int
    }


type alias Heart =
    { done : Bool
    , x : Int
    , ttl : Int
    , seq : Int
    }


type alias Score =
    { name : String, count : Int, id : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.total_clicks 0 [] False [] 0 0 0, Task.perform (\size -> Resize size.width size.height) Window.size )



-- UPDATE


type Msg
    = Click Int
    | Online Int
    | Sum (List Score)
    | Start
    | Stop
    | HeartEnter Heart
    | Resize Int Int
    | Tick T.Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Click n ->
            if not model.stop then
                ( { model | total_clicks = model.total_clicks + n }, Random.generate HeartEnter <| ((Random.int 0 100) |> Random.map (\x -> Heart False x 15 model.total_clicks)) )
            else
                ( model, Cmd.none )

        HeartEnter heart ->
            ( { model | hearts = (List.map (\h -> { h | done = True }) model.hearts) ++ [ heart ] }, Cmd.none )

        Online n ->
            ( { model | online_users = n }, Cmd.none )

        Sum sum ->
            if not model.stop then
                ( { model | sum = sum }, Cmd.none )
            else
                ( model, Cmd.none )

        Start ->
            ( { model | stop = False, total_clicks = 0, ttl = 60 }, start "start" )

        Stop ->
            ( { model | stop = True }, Cmd.none )

        Resize width height ->
            ( { model | winHeight = height, winWidth = width }, Cmd.none )

        Tick _ ->
            let
                isDead h =
                    h.ttl >= 0
                isStop = if model.ttl == 0 then True else False
                calTTL = if isStop then model.ttl else model.ttl - 1
            in
                ( { model | stop = isStop, ttl = calTTL, hearts = List.map (\h -> { h | ttl = h.ttl - 1 }) model.hearts }, Cmd.none )


port start : String -> Cmd msg


port clicks : (Int -> msg) -> Sub msg


port online_users : (Int -> msg) -> Sub msg


port sum : (List Score -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ clicks Click, online_users Online, sum Sum, Window.resizes (\size -> Resize size.width size.height), T.every (T.second) Tick ]



-- VIEW


digits num padLen =
    let
        chs =
            String.toList <| String.padLeft padLen '0' <| toString num

        digit n =
            div [ class "pos" ]
                [ span [ class "animate digit", style [ ( "top", "-" ++ (String.fromChar n) ++ "em" ) ] ]
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
                            , div [ class "level-right" ] [ div [ class "level-item has-text-left" ] [ span [ class "subtitle is-3 small-pos" ] <| digits score.count 3 ] ]
                            ]
                    )
                <|
                    sort model.sum

        heartSvg =
            Svg.svg [ SA.viewBox "0 0 100 100" ]
                [ Svg.path [ SA.class "st0", SA.d "M50.22,27.358c13.786-22.514,44.004-7.407,38.166,18.105C82.672,70.427,50.22,83.629,50.22,83.629 S17.764,70.427,12.054,45.463C6.216,19.952,36.431,4.844,50.22,27.358z" ] []
                ]

        drawHeart h =
            let
                top =
                    if not h.done then
                        model.winHeight + 100
                    else
                        -50

                left =
                    truncate <| (toFloat h.x) / 100.0 * (toFloat model.winWidth)

                opacity =
                    if not h.done then
                        1
                    else
                        0

                px n =
                    toString n ++ "px"
            in
                span [ src "/images/MadebyMade-Vector-LineIcons-Love-Live-01.svg", class "background-heart", style [ ( "top", px top ), ( "left", px left ), ( "opacity", toString opacity ) ] ] [ heartSvg ]

        heartsInBackground hearts =
            div [] <| List.map drawHeart hearts
    in
        div [ class "columns" ]
            [ div [ class "column is-one-third" ] []
            , div [ class "column is-one-third" ]
                [ div []
                    [ div [ class "level" ] [ div [ class "level-item" ] [ span [ class "title is-1" ] <| digits model.total_clicks 5 ] ]
                    , div [ class "level" ] [ div [ class "level-item" ] [ span [ class "subtitle is-4" ] <| digits model.online_users 3 ] ]
                    , div [ class "level" ] [ div [ class "level-item" ] [ span [ class "subtitle is-4" ] <| digits model.ttl 3 ] ]
                    , div [] [ scores ]
                    , div [ class "section" ]
                        [ div [ class "level" ]
                            [ div [ class "level-item" ] [ button [ onClick Start, class "button is-danger" ] [ text "Start" ] ]
                            , div [ class "level-item" ] [ button [ onClick Stop, class "button is-danger" ] [ text "Stop" ] ]
                            ]
                        ]
                    , heartsInBackground model.hearts
                    ]
                ]
            , div [ class "column is-one-third" ] []
            ]

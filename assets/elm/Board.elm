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
    }


type alias Score =
    { name : String, count : Int, id : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.total_clicks 0 [], Cmd.none )



-- UPDATE


type Msg
    = Click Int
    | Online Int
    | Sum (List Score)
    | Start


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Click n ->
            ( { model | total_clicks = model.total_clicks + n }, Cmd.none )

        Online n ->
            ( { model | online_users = n }, Cmd.none )

        Sum sum ->
            ( { model | sum = sum }, Cmd.none )

        Start ->
            ( model, start "start" )


port start : String -> Cmd msg


port clicks : (Int -> msg) -> Sub msg


port online_users : (Int -> msg) -> Sub msg


port sum : (List Score -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ clicks Click, online_users Online, sum Sum ]



-- VIEW


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
                            , div [ class "level-right" ] [ div [ class "level-item has-text-left" ] [ span [ class "subtitle is-2" ] [ text <| toString score.count ] ] ]
                            ]
                    )
                <|
                    sort model.sum
    in
        div [ class "columns" ]
            [ div [ class "column is-one-third" ] []
            , div [ class "column is-one-third" ]
                [ div []
                    [ div [] [ scores ]
                    , div [ class "level" ]
                        [ div [ class "level-item" ] [ button [ onClick Start, class "button is-danger" ] [ text "Start" ] ]
                        , div [ class "level-item" ] [ button [ onClick Start, class "button is-danger" ] [ text "Stop" ] ]
                        ]
                    ]
                ]
            , div [ class "column is-one-third" ] []
            ]

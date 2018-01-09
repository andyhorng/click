port module Click exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String
import Svg
import Svg.Events as SE
import Svg.Attributes as SA
import Time as T
import Random 


main =
    programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }



-- MODEL

type alias Heart = { x : Int, dur : Int }

type alias Flags =
    { name : String
    , clicks : Int
    }


type alias Model =
    { name : String
    , click_count : Int
    , online_guests : Int
    , hearts : List Heart
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.name flags.clicks 0 [], Cmd.none )



-- UPDATE


port click : Int -> Cmd msg


type Msg
    = Click
    | Online Int
    | Tick T.Time
    | NewHeart Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Click ->
            ( { model | click_count = model.click_count + 1 }, Cmd.batch [click 1, Random.generate NewHeart (Random.int 0 1000)] )

        Online c ->
            ( { model | online_guests = c }, Cmd.none )

        Tick _ ->
            let past heart = { heart | dur = heart.dur + 1}
                isDead heart = heart.dur < 30
            in ({model | hearts = List.filter isDead <| List.map past model.hearts}, Cmd.none)

        NewHeart x ->
            ({model | hearts = model.hearts ++ [Heart x 0]}, Cmd.none)


port online : (Int -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [online Online, T.every (T.second) Tick]


-- VIEW


view : Model -> Html Msg
view model =
    div [ class "is-unselectable" ]
        [ section [ class "section" ]
              [ div [ class "container" ]
                    [ hearts model.hearts
                    ]
              ]
        , count model
        , info model
        ]


info : Model -> Html Msg
info model =
    section [ class "section" ]
        [ div [ class "container" ]
            [ div [ class "level is-mobile" ]
                [ span [ class "level-item" ] [ span [ class "title is-large" ] [ text <| toString model.online_guests, text "人" ] ]
                ]
            ]
        ]


count : Model -> Html Msg
count model =
    section [ class "section is-paddingless" ]
        [ div [ class "container" ]
            [ div [ class "level is-mobile" ]
                [ div [ class "level-item" ] [ span [ class "tag is-xlarge is-danger" ] [ text <| toString model.click_count ] ] ]
            ]
        ]


heart : Svg.Svg Msg
heart =
    Svg.svg [ SA.viewBox "0 0 100 100", SE.onClick Click ]
        [ Svg.path [ SA.class "st0", SA.d "M50.22,27.358c13.786-22.514,44.004-7.407,38.166,18.105C82.672,70.427,50.22,83.629,50.22,83.629 S17.764,70.427,12.054,45.463C6.216,19.952,36.431,4.844,50.22,27.358z" ] []
        ]

smallHeart : Heart -> Svg.Svg Msg
smallHeart heart =
    Svg.svg [ SA.x <| toString heart.x, SA.y "1100", SA.opacity "1", SA.viewBox "0 0 1000 1000", SE.onClick Click ]
        [ Svg.animate [ SA.attributeName "y", SA.to "-100", SA.dur "5s", SA.repeatCount "1"] []
        , Svg.animate [ SA.attributeName "opacity", SA.to "0", SA.begin "2s", SA.dur "5s", SA.repeatCount "1"] []
        , Svg.path [ SA.class "st0", SA.d "M50.22,27.358c13.786-22.514,44.004-7.407,38.166,18.105C82.672,70.427,50.22,83.629,50.22,83.629 S17.764,70.427,12.054,45.463C6.216,19.952,36.431,4.844,50.22,27.358z" ] []
        ]


hearts : List Heart -> Svg.Svg Msg
hearts heartList =
    Svg.svg [ SA.viewBox "0 0 1000 1000"] ([heart] ++ List.map smallHeart heartList)

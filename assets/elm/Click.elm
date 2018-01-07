port module Click exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String

import Svg
import Svg.Events as SE
import Svg.Attributes as SA


main =
    programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }



-- MODEL

type alias Flags =
    { name : String
    , clicks : Int
    }

type alias Model =
    { name : String
    , click_count : Int
    , online_guests : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.name flags.clicks 0, Cmd.none )


-- UPDATE
port click : Int -> Cmd msg

type Msg = Click
    | Online Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Click ->
            ({model | click_count = model.click_count + 1}, click 1)
        Online c ->
            ({model | online_guests = c}, Cmd.none)


port online : (Int -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model = online Online


-- VIEW

view : Model -> Html Msg
view model =
    div [ class "is-unselectable"]
        [ section [class "hero"]
              [ div [class "hero-body"]
                    [ div [class "container"]
                          [ heart
                          ]
                    ]
              ]
        , count model
        , info model
        ]
        
info : Model -> Html Msg
info model =
    section [class "section is-medium"]
        [
         div [class "container"]
                  [ div [class "level is-mobile"]
                        [ span [ class "level-item"] [ span [ class "subtitle"] [text "在線賓客"] ]
                        , span [ class "level-item"] [span [ class "tag is-danger"] [ text <| toString model.online_guests ]]
                        ]
                  ]

        ]

count : Model -> Html Msg
count model =
    section [class "section is-medium"]
        [ div [ class "container"]
              [div [ class "level is-mobile" ]
                   [ div [class "level-item"] [ span [ class "subtitle"] [text "送上祝福"]]
                   , div [class "level-item"] [ span [ class "tag is-large is-danger"] [text <| toString model.click_count ]]]
                  ]
        ]



heart : Svg.Svg Msg
heart = Svg.svg [SA.viewBox "0 0 100 100", SE.onClick Click]
    [ Svg.g []
        [ Svg.path [ SA.class "st0", SA.d "M44.6,58.362c-3.366-14.711,14.057-23.423,22.008-10.44c3.9-6.369,10.077-7.508,14.964-5.288 c2.301-21.225-23.2-32.831-35.14-13.331C33.919,8.87,6.498,22.58,11.796,45.733C16.978,68.389,46.433,80.37,46.433,80.37 s4.608-1.88,10.494-5.543C51.812,71.123,46.256,65.601,44.6,58.362z" ]
            []
        , Svg.g []
            [ Svg.path [ SA.class "st0", SA.d "M66.69,47.921c7.95-12.983,25.375-4.271,22.008,10.44C85.404,72.757,66.69,80.37,66.69,80.37 s-18.715-7.612-22.008-22.008C41.316,43.65,58.739,34.939,66.69,47.921z" ] []
            ]
        ]
    ]

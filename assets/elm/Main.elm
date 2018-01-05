port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String


main =
    programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }



-- MODEL

type alias Flags =
    { name: String
    }

type alias Model =
    { name : String
    , click_count : Int
    , online_guests : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.name 0 0, Cmd.none )


-- UPDATE
port click : Int -> Cmd msg

type Msg = Click

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Click ->
            (model, click 1)


subscriptions : Model -> Sub Msg
subscriptions model = Sub.none


-- VIEW


view : Model -> Html Msg
view model =
    div [] [div [] [text model.name], div [] [img [ src "/images/heart.png", onClick Click] []] ]

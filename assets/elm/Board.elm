port module Board exposing (..)

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

type Msg = Click

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = (model, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model = Sub.none


-- VIEW


view : Model -> Html Msg
view model =
    div [] []

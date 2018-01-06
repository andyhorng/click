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
    { total_clicks : Int
    }

type alias Model =
    { total_clicks : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.total_clicks, Cmd.none )


-- UPDATE

type Msg = Click Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Click n ->
            ({model | total_clicks = model.total_clicks + n}, Cmd.none)

port clicks : (Int -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model = clicks Click


-- VIEW


view : Model -> Html Msg
view model =
    h1 [class "title is-1"] [ text <| toString model.total_clicks]

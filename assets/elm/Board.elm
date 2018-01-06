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
    , online_users : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.total_clicks 0, Cmd.none )


-- UPDATE

type Msg
    = Click Int
    | Online Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Click n ->
            ({model | total_clicks = model.total_clicks + n}, Cmd.none)
        Online n ->
            ({model | online_users = n}, Cmd.none)

port clicks : (Int -> msg) -> Sub msg
port online_users : (Int -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [clicks Click, online_users Online]


-- VIEW


view : Model -> Html Msg
view model =
    h1 [class "title is-1"] [ text <| toString model.total_clicks, text "|", text <| toString model.online_users]

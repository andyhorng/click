port module Click exposing (..)

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
    div [] [div [] [text model.name, text "|", text <| toString model.click_count, text "|", text <| toString model.online_guests], div [] [img [ src "/images/heart.png", onClick Click] []] ]

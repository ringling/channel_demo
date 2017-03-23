module Main exposing (..)

import Debug exposing (..)
import Html exposing (..)
import Html.Attributes exposing (value, placeholder, class)
import Html.Events exposing (onInput, onClick, onSubmit)

import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode as JE
import Json.Decode as JD exposing (map2, string, field)

type alias Model =
    { newMessage : String
    , messages : List ChatMessage
    , phxSocket : Phoenix.Socket.Socket Msg
    }

type alias ChatMessage =
    { user : String
    , body : String
    }

type Msg
    = SetNewMessage String
    | JoinChannel
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | SendMessage
    | ReceiveChatMessage JE.Value

initialModel : Model
initialModel =
    { newMessage = ""
    , messages = []
    , phxSocket = initPhxSocket
    }

socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"

initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new_msg" "room:lobby" ReceiveChatMessage

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetNewMessage string ->
            { model | newMessage = string } ! []

        JoinChannel ->
          let
                channel =
                    Phoenix.Channel.init "room:lobby"

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )
        SendMessage ->
            let
                -- We'll build our message out as a json encoded object
                payload =
                    (JE.object [ ( "body", JE.string model.newMessage ) ])

                -- We prepare to push the message
                push_ =
                    Phoenix.Push.init "new_msg" "room:lobby"
                        |> Phoenix.Push.withPayload payload

                -- We update our `phxSocket` and `phxCmd` by passing this push
                -- into the Phoenix.Socket.push function
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push_ model.phxSocket
            in
                -- And we clear out the `newMessage` field, update our model's
                -- socket, and return our Phoenix command
                ( { model
                    | newMessage = ""
                    , phxSocket = phxSocket
                  }
                , Cmd.map PhoenixMsg phxCmd
                )
        ReceiveChatMessage raw ->
          let
            x = log("Ok") raw
          in
            case JD.decodeValue chatMessageDecoder raw of
                Ok chatMessage ->
                    ( { model | messages = chatMessage :: model.messages }
                    , Cmd.none
                    )

                Err error ->
                    ( model, Cmd.none )


chatMessageDecoder : JD.Decoder ChatMessage
chatMessageDecoder =
    map2 ChatMessage
        (field "body" string)
        (field "body" string)


viewMessage : ChatMessage -> Html Msg
viewMessage message =
    div [ class "message" ]
        [ span [ class "body" ] [ text message.body ]
        ]

view : Model -> Html Msg
view model =
    div []
        [ button [ onClick JoinChannel ] [ text "Join lobby" ]
        , div [ class "messages" ]
            (List.map viewMessage model.messages)
        , form [ onSubmit SendMessage ]
            [ input [ placeholder "Message...", onInput SetNewMessage, value model.newMessage ] [] ]
        ]

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg

init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )
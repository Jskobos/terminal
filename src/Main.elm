module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Browser.Events exposing (onKeyDown)
import Html exposing (Html, a, text, div, h1, img, input, p, pre, span, textarea)
import Html.Attributes exposing (autofocus, class, classList, cols, href, id, placeholder, rows, src, style, tabindex, value)
import Html.Events exposing (on, onInput)
import Json.Decode as Json
import Keyboard.Event exposing (KeyboardEvent, decodeKeyboardEvent)
import Task

type alias Flags = {}

---- MODEL ----

type ActiveView =
    Welcome | Summary | Experience | Education | Links | Feedback | Language | Theme

type alias Model =
    {
        activeView: ActiveView,
        inputText: String
    }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( {
        activeView = Welcome,
        inputText = ""
    }, Dom.focus "outermost" |> Task.attempt (always NoOp) )



---- UPDATE ----

type Msg
    = HandleKeyboardEvent KeyboardEvent
    | TextInput String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HandleKeyboardEvent event ->
            let
                newView = getActiveView event.ctrlKey event.key
            in
            case newView of
                Just v ->
                    ( { model | activeView = v }
                    , Cmd.none
                    )
                Nothing ->
                    ( model, Cmd.none )
        TextInput input ->
            ( { model | inputText = input }, Cmd.none )
        NoOp ->
            ( model, Cmd.none )

getActiveView : Bool -> Maybe String -> Maybe ActiveView
getActiveView ctrl event =
    if (not ctrl) then Nothing
    else
        case event of
            Just key ->
                case key of
                    "s" ->
                        Just Summary
                    "w" ->
                        Just Experience
                    "e" ->
                        Just Education
                    "f" ->
                        Just Feedback
                    "z" ->
                        Just Language
                    "t" ->
                        Just Theme
                    "l" ->
                        Just Links
                    _ ->
                        Nothing
            Nothing ->
                Nothing


---- VIEW ----


view : Model -> Html Msg
view model =
    div [ on "keydown" <|
            Json.map HandleKeyboardEvent decodeKeyboardEvent
        , tabindex 0
        , id "outermost"
        , style "position" "absolute"
        , style "height" "100%"
        , style "width" "100%"
        , style "overflow" "hidden"
        , style "outline" "none"
        ]
        [
            div [class "h-screen w-screen"]
                [ topBar, body model
                ]
        ]

topBar =
    div [class "flex flex-row items-center justify-start topbar bg-grey-darkest"] [
        div [class "flex flex-row items-center justify-center pl-2"] [dot "bg-red-light",
        dot "bg-yellow",
        dot "bg-green"]
    ]

dot : String -> Html Msg
dot color = 
    div [classList
        [ (color, True)
        , ("dot", True),
          ("m-1", True)
        ] ] []

body model =
    div [class "terminal bg-black"] [terminalHeader model.activeView, div [class "terminal-content"] [terminalContent model], terminalFooter model.activeView]

terminalContent model =
    case model.activeView of
        Welcome -> 
            welcome model
        Summary ->
            summary
        Education ->
            education
        Experience ->
            experience
        Links ->
            links
        Feedback ->
            feedback model
        _ -> 
            text "Section coming soon"
  


terminalFooter : ActiveView -> Html Msg
terminalFooter terminalView =
    case terminalView of
        Feedback ->
            div [class "terminal-footer"] []
        _ ->
            div [class "terminal-footer"] [
                div [class "flex flex-row flex-wrap"] [
                    footerItem "^S" "Summary",
                    footerItem "^W" "Work Experience",
                    footerItem "^E" "Education",
                    footerItem "^L" "Links",
                    footerItem "^F" "Leave feedback",
                    footerItem "^Z" "Change Language",
                    footerItem "^T" "Change Theme"
                ]]

terminalHeader activeView =
    div [class "terminal-header "] [
        div [class "bg-grey-light w-full flex flex-row items-center justify-start p-1"] [
            p [class "w-1/3 flex justify-start"] [text "JSK resume 0.0.1"],
            p [class "w-2/3 flex justify-start"] [text (if activeView /= Welcome then "File: " ++ (headerText activeView) else headerText activeView)]
        ]
    ]

headerText : ActiveView -> String
headerText currentView =
    case currentView of
        Summary ->
            "summary.txt"
        Education ->
            "education.txt"
        Experience ->
            "work_experience.txt"
        Feedback ->
            "feedback_form.txt"
        Theme ->
            "theme.txt"
        Language ->
            "language_select.txt"
        Welcome ->
            "New Buffer"
        Links ->
            "links.txt"


footerItem : String -> String -> Html Msg
footerItem key description =
    div [class "flex flex-row text-white p-1 w-1/6"] [
        p [class "m-2 bg-grey-light text-black"] [text key],
        p [class "m-2"] [text description]
    ]


--- DISPLAY SECTIONS ---


sectionTitle : String -> Html Msg
sectionTitle title =
    p [class "text-2xl"] [text title]

summary =
    div [class "text-left ml-2 body-text"] [
        sectionTitle "Summary",
        p [] [text "Jared Kobos"],
        p [] [text "JavaScript Developer at Linode"],
        p [] [text "Build things with React, Redux, Jest, Typescript, and Hugo. Also a fan of Elm, Go, and Python."]
    ]

education =
    div [class "text-left ml-2 body-text flex flex-col justify-between h-full"] [
        div [] [
            sectionTitle "Education",
            p [] [text "Bachelor of Music Education (University of Delaware)"],
            p [] [text "Master of Music (Florida State University)"],
            p [] [text "Doctor of Musical Arts* (Michigan State University)"]
        ],
        div [] [
            p [class "text-right"] [text "* (it's a long story)"]
        ]     
    ]

type alias WorkItem = 
    {
        company : String,
        position : String,
        location : String,
        start : String,
        end : String,
        description : List String
    }

items = 
    [
        WorkItem "Linode" "JavaScript Developer" "Philadelphia, PA" "05-01-18" "" [
            "Build and maintain features for front end applications",
            "Coordinate releases",
            "Research and present patterns to improve the codebase"
            ],
        WorkItem "Linode" "Technical Writer" "Philadelphia, PA" "09-06-17" "05-01-18" [
            "Write, edit, and tech edit documentation on Linux-related topics",
            "Use continuous integration and scripting to improve quality of documentation library"
            ],
        WorkItem "EF Education First" "Content Writer" "Shanghai, CN" "02-04-16" "08-21-17" [
            "Write textbook and online content for an international education company"
            ],
        WorkItem "EF Education First" "International Teacher" "Shanghai, CN" "07-18-13" "02-04-16" [
            "Teach English to Chinese kids"
            ]
    ]

experience =
    div [class "text-left ml-2 body-text"] [
        sectionTitle "Work Experience",
        div [] (List.map renderWorkItem items)
    ]

renderWorkItem : WorkItem -> Html Msg
renderWorkItem item =
    let 
        dates = if item.end == "" then (item.start ++ " - Present")
                else (item.start ++ " - " ++ item.end)
    in 
    div [class "mt-6"] [
        p [class "leading-tight w-full flex flex-row justify-between"] [
            span [] [text (item.position ++ "  :  " ++ (item.company ++ " (" ++ item.location ++ ")"))],
            span [class "mr-6"] [text dates]
        ],
        div [class "leading-normal"] (List.map renderDescription item.description)
    ]

renderDescription : String -> (Html Msg)
renderDescription desc =
    p [] [text (" - " ++ desc)]

links =
    div [class "text-left ml-2 body-text"] [
        sectionTitle "Links",
        renderLinkItem "https://github.com/jskobos" "GitHub Profile",
        renderLinkItem "https://gitbhub.com/jskobos/old-resume" "Previous GitHub portfolio (Vanilla Javascript MVC)"
    ]

renderLinkItem url description =
    p [class "mt-6 ml-4"] [a [href url, class "link-item"] [text description]]

welcome model =
    div [class "flex flex-column justify-start w-full"] [
        text ""
    ]

feedback model =
    div [class "flex flex-column justify-start w-full h-full"] [
        textarea [autofocus True, cols 40, rows 20, placeholder "Leave some feedback..." ,value model.inputText, onInput TextInput, class "bg-black text-white text-left w-full" ] []
    ]

---- SUBSCRIPTIONS ----

subscriptions : Model -> Sub Msg
subscriptions model =
    onKeyDown (Json.map HandleKeyboardEvent decodeKeyboardEvent)

---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }

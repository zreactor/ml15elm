port module App exposing (main)

import Converters exposing (..)
import Constants exposing (..)
import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import String
import String.Format
import Html.Attributes as Ats
import Html.Events exposing (onClick, onInput)
import Http
import Debug exposing (log)
import Browser.Events exposing (onAnimationFrameDelta)
import Time
import Json.Decode as D exposing (Value)
import Json.Encode as Encode
import Animation exposing (..)
import Url exposing (Url)
import Array

port playSound : String -> Cmd msg

-- view base HTML
basehtml: Model -> List (Html Actions)
basehtml model =
    [Html.div [Ats.id "titleElement"] [Html.text "ML15 非公式 ELM app"],        
    Html.div [Ats.id "clockTimeDisplay"][
        Html.span [Ats.style "padding" "15px", Ats.style "display" "inline-block"] [Html.text (getReadableTime model.time_passed)]
        ],
    Html.div [Ats.class "centred-div", Ats.style "text-align" "center"] [
        Html.span [Ats.style "padding" "10px", Ats.style "display" "inline-block"][
            Html.button [Ats.class (if model.clock_interval == 0 then "btn btn-light" else "btn btn-dark"), onClick (TriggerClock)][Html.span [][Html.text (if model.clock_interval == 0 then "Start Clock" else "Stop Clock")]]
            ],
        Html.span [Ats.style "padding" "10px", Ats.style "display" "inline-block"][
            Html.button [Ats.class "btn btn-dark", onClick (ResetTicks)][Html.span [][Html.text "Clear"]]]
    ],
    Html.div[Ats.id "geturl"][
        Html.input[
            Ats.placeholder "ML15 page URL", 
            Ats.style "margin-right" "15px", 
            Ats.style "padding" "7px",
            Ats.size 70,
            onInput UpdateUrlName
            ][],
        Html.button [
            Ats.class "btn btn-light", 
            onClick (GetJson)
            ][
                Html.span [] [Html.text "+"] 
            ]
    ],
    Html.div [Ats.id "addPresenter"][
        Html.span [
            Ats.class "addPresenterTitle"
        ][
            Html.text "発表者を追加する: "
        ],
        Html.input[
            Ats.placeholder "Presenter name", 
            Ats.style "margin-right" "15px", 
            Ats.style "padding" "7px",
            onInput UpdateName
            ][],
        Html.button [
            Ats.class "btn btn-light", 
            onClick (AddPresenter)
            ][
                Html.span [] [Html.text "+"] 
            ],
        Html.button [
            Ats.class "btn btn-dark",
            Ats.style "margin-left" "5px",
            onClick (ClearPresenters)
            ][
                Html.span [] [Html.text "clear all"]
            ],
        Html.div [Ats.class "presentersDisplay"][Html.text (String.append (String.fromInt model.nr_presenters) " presenters to go")]       
        ]     
    ]


-- init function 
initFxn: Value -> Url -> Nav.Key -> ( Model, Cmd Actions )
initFxn flags url navKey = ({ clock = 0, nr_presenters = 0, presenters = [], current_presenter = "", url_string = "", clock_interval = 0, time_passed = 0}, Cmd.none)

-- model definition
type alias Model = {
    nr_presenters: Int,
    presenters: List String,
    current_presenter: String,
    url_string: String,
    clock: Clock,
    time_passed: Int,
    clock_interval: Int
    }


-- view function
viewFxn: Model -> Browser.Document Actions
viewFxn model = {
    title = "C", 
    body = [Html.div [] (
    List.append (basehtml model) 
        (texttodivs model.presenters))
    --         Html.div [] (
    -- List.append ([]) 
    --     (texttodivs model.be_presenters))
        ]}


-- model update function
updateFxn: Actions -> Model -> (Model, Cmd Actions)
updateFxn msg model =
    case msg of
        AddPresenter ->
            (let rr = Debug.log "current model: " model in
            { model | 
            nr_presenters = model.nr_presenters + 1, 
            presenters = (model.current_presenter :: model.presenters)
            }, Cmd.none)
        UpdateName newvalue ->
            ({ model | current_presenter = newvalue}, Cmd.none)
        UpdateUrlName newvalue ->
            ({ model | url_string = newvalue}, Cmd.none)
        SetPresenter newvalue ->
            ({ model | presenters = (newvalue :: model.presenters)}, Cmd.none)
        RemovePresenter presentername ->
            (let new_presenters = (filterpresenters model.presenters presentername) in
            { model | 
            presenters = new_presenters,
            nr_presenters = (List.length new_presenters)
            }, Cmd.none)
        Tick nr ->
            ({ model | 
            clock = model.clock + nr, 
            time_passed = model.time_passed + model.clock_interval
            }, (
                if model.time_passed == warning_time then 
                playSound("WARNING_TIME") 
                
                else if model.time_passed == end_time then
                playSound("END_TIME")
                
                else Cmd.none)
            )
        ResetTicks ->
            ({ model | 
            clock = 0,
            time_passed = 0
            }, Cmd.none)
        TriggerClock ->
            ({ model | clock_interval = (flipClockAction model.clock_interval)}, playSound ("flipping clock action"))
        ChangedUrl _ -> ({model | clock=model.clock}, Cmd.none)
        ClickedLink _ -> ({model | clock=model.clock}, Cmd.none)
        ClearPresenters -> ({model | 
            presenters = [],
            nr_presenters = 0
            }, Cmd.none )
        GetJson -> (model, (getPresenters model.url_string))
        GotJson result -> 
            case result of
                Ok presrs ->
                    ( { model | 
                    presenters = presrs ++ model.presenters,
                    nr_presenters = (List.length (presrs ++ model.presenters))
                    }, Cmd.none )
                
                Err _ ->
                    ( model, Cmd.none)



jsonBody : Encode.Value -> Http.Body
jsonBody value =
  Http.stringBody "application/json" (Encode.encode 0 value)


getPresenters: String -> Cmd Actions
getPresenters url_path = 
    Http.request
        {
            method = "POST",
            url = "http://localhost:8001/getpresenters",
            headers = [
              Http.header "Access-Control-Allow-Origin" "*",
              Http.header "Access-Control-Allow-Headers" "Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token",
              Http.header "Access-Control-Allow-Methods" "PUT, GET, POST, DELETE, OPTIONS",
              Http.header "Content-Type" "application/json"                
            ],
            body = (Http.stringBody "application/json" url_path),
            expect = Http.expectJson GotJson (D.list (D.field "presenter" D.string)),
            timeout = Nothing,
            tracker = Nothing
        }

-- subscriptions
subscriptions: Model -> Sub Actions
subscriptions _ = 
    Sub.batch [ onAnimationFrameDelta Tick ]

-- program main exposed method
main: Program Value Model Actions
main = Browser.application {
    init = initFxn,
    onUrlChange = ChangedUrl,
    onUrlRequest = ClickedLink,
    subscriptions = subscriptions,
    view = viewFxn,
    update = \msg model -> (updateFxn msg model)
    }
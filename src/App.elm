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
import Debug exposing (log)
import Browser.Events exposing (onAnimationFrameDelta)
import Time
import Json.Decode as Decode exposing (Value)
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
        Html.div [Ats.class "presentersDisplay", Ats.style "background-color" "salmon"][Html.text (String.append (String.fromInt model.nr_presenters) " presenters")]       
        ]     
    ]


-- init function 
initFxn: Value -> Url -> Nav.Key -> ( Model, Cmd Actions )
initFxn flags url navKey = ({ clock = 0, nr_presenters = 0, presenters = [], current_presenter = "", clock_interval = 0, time_passed = 0}, Cmd.none)

-- model definition
type alias Model = {
    nr_presenters: Int,
    presenters: List String,
    current_presenter: String,
    clock: Clock,
    time_passed: Int,
    clock_interval: Int
    }


-- view function
viewFxn: Model -> Browser.Document Actions
viewFxn model = {title = "C", body = [Html.div [] (
    List.append (basehtml model) 
        (texttodivs model.presenters))]}


-- model update function
updateFxn: Actions -> Model -> (Model, Cmd msg)
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
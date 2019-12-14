port module App exposing (main)

import Converters exposing (..)
import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import String
import String.Format
import Html.Attributes as Ats
import Html.Events exposing (onClick, onInput)
import Debug exposing (log)
import Browser
import Browser.Events exposing (onAnimationFrameDelta)
import Time
import Json.Decode as Decode exposing (Value)
import Animation exposing (..)
import Url exposing (Url)
import Array

port playSound : String -> Cmd msg




-- type Actions = UpdateName String | AddPresenter | SetPresenter String

second : Float
second = 1000

ms : Float
ms = 1

type Actions = UpdateName String | AddPresenter | SetPresenter String | RemovePresenter String | Tick Float | ResetTicks | TriggerClock | ChangedUrl Url | ClickedLink Browser.UrlRequest 

first list =
    Array.get 1 (Array.fromList list)

texttodivs divslist =
    List.map texttodiv (List.reverse divslist)

texttodiv presentertext =
    Html.div[
        Ats.style "background-color" "#323542", 
        Ats.style "color" "ghostwhite", 
        Ats.style "padding" "15px",
        Ats.id presentertext
        ][
            Html.text presentertext,
            Html.button [
                Ats.class "btn btn-dark", 
                Ats.style "float" "right",
                onClick (RemovePresenter presentertext)
                ][Html.text "-"]
            ]  




basehtml: Model -> List (Html Actions)
basehtml model =
    [Html.div [Ats.id "titleElement"] [Html.text "ML15 非公式 ELM app"],
    -- Html.div [Ats.class "thisclass", Ats.style "background-color" "salmon"][Html.text (String.append (String.fromInt model.nr_presenters) " presenters")],
    
        
    Html.div [Ats.id "clockTimeDisplay"][
        Html.span [Ats.style "padding" "15px", Ats.style "display" "inline-block"] [Html.text (clockFormatter (floor ( toFloat model.time_passed / 60)))]
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

warning_time_min: Int
warning_time_min = 1

end_time_min: Int
end_time_min = warning_time_min + 1

seconds_in_min: Int
seconds_in_min = 60 * 60


secondsToMinutes: Int -> Int
secondsToMinutes seconds = seconds // 60
-- floor (seconds / 60)

warning_time: Int
warning_time = (warning_time_min * seconds_in_min)

end_time: Int
end_time = (end_time_min * seconds_in_min)


secondsToLeftoverSeconds: Int -> Int
secondsToLeftoverSeconds seconds = modBy 60 seconds

clockFormatter: Int -> String
clockFormatter seconds = 
    "{{ mins }}:{{ secs }}" 
        |> String.Format.namedValue "mins" (String.fromInt (secondsToMinutes seconds))
        |> String.Format.namedValue "secs" (padSecsValue (secondsToLeftoverSeconds seconds))

padSecsValue: Int -> String
padSecsValue seconds = 
    if seconds < 10 then (addLeadingZero seconds) else (String.fromInt seconds)

flipClockAction: Int -> Int
flipClockAction interVal =
    if interVal == 1 then 0 else 1
    
     
addLeadingZero: Int -> String
addLeadingZero number =
    "0{{ }}"
        |> String.Format.value (String.fromInt number)

viewFxn: Model -> Browser.Document Actions
viewFxn model = {title = "C", body = [Html.div [] (
    List.append (basehtml model) 
        (texttodivs model.presenters))]}


filterpresenters presenterlist deletetext =
    List.filter (\a -> a /= deletetext ) presenterlist

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
            ({ model | clock_interval = (flipClockAction model.clock_interval)}, playSound ("clock flip"))
        ChangedUrl _ -> ({model | clock=model.clock}, Cmd.none)
        ClickedLink _ -> ({model | clock=model.clock}, Cmd.none)
        -- SendDataToJS -> (model, playSound (clockFormatter (floor ( toFloat model.time_passed / 60))))

 

subscriptions : Model -> Sub Actions
subscriptions _ = 
    Sub.batch [ onAnimationFrameDelta Tick ]

type alias Model = {
    mytext: String,
    nr_presenters: Int,
    presenters: List String,
    current_presenter: String,
    clock: Clock,
    time_passed: Int,
    clock_interval: Int
    }

initFxn : Value -> Url -> Nav.Key -> ( Model, Cmd Actions )
initFxn flags url navKey = ({ clock = 0, mytext = "", nr_presenters = 0, presenters = [], current_presenter = "", clock_interval = 0, time_passed = 0}, Cmd.none)

main : Program Value Model Actions
main = Browser.application {
    init = initFxn,
    onUrlChange = ChangedUrl,
    onUrlRequest = ClickedLink,
    subscriptions = subscriptions,
    view = viewFxn,
    update = \msg model -> (updateFxn msg model)
    }
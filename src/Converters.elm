module Converters exposing (..)
import Html exposing (Html)
import Html.Attributes as Ats
import Html.Events exposing (onClick, onInput)
import Array
import String
import String.Format
import Url exposing (Url)
import Browser
import Http

type Actions = UpdateName String | UpdateUrlName String | AddPresenter | SetPresenter String | RemovePresenter String | Tick Float | ResetTicks | TriggerClock | ChangedUrl Url | ClickedLink Browser.UrlRequest | GotJson (Result Http.Error (List String)) | GetJson | ClearPresenters

-- a maybe monad
getItem: Maybe String -> String
getItem item =
    case item of
        Just y ->
            y
        Nothing ->
            ""

secondsToLeftoverSeconds: Int -> Int
secondsToLeftoverSeconds seconds = modBy 60 seconds

secondsToMinutes: Int -> Int
secondsToMinutes seconds = seconds // 60

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

filterpresenters presenterlist deletetext =
    List.filter (\a -> a /= deletetext ) presenterlist

first list =
    Array.get 1 (Array.fromList list)

texttodivs divslist =
    List.map texttodiv (List.reverse divslist)

getReadableTime: Int -> String
getReadableTime timepassed = clockFormatter (floor (toFloat timepassed / 60))


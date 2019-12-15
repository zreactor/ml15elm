module Converters exposing (..)
import Html exposing (Html)
import Html.Attributes as Ats
import Html.Events exposing (onClick, onInput)
import Array



button = 100

getItem: Maybe String -> String
getItem item =
    case item of
        Just y ->
            y
        Nothing ->
            ""

-- divmaker: Int -> Maybe String -> List (Html Actions)
-- divmaker nr innertext = 
--     let txt = (getItem innertext)
--     in List.repeat nr (Html.div[Ats.style "background-color" "#323542", Ats.style "color" "ghostwhite", Ats.style "padding" "15px"][Html.text txt])




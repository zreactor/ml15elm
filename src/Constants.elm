module Constants exposing (..)
second: Float
second = 1000

ms: Float
ms = 1

-- minutes after which to sound the warning chime (14 for ML15)
warning_time_min: Int
warning_time_min = 14

-- minutes after which to sound the end chime (15)
end_time_min: Int
end_time_min = warning_time_min + 1

seconds_in_min: Int
seconds_in_min = 60 * 60

warning_time: Int
warning_time = (warning_time_min * seconds_in_min)

end_time: Int
end_time = (end_time_min * seconds_in_min)
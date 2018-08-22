module DeliveryPerson exposing
    ( DeliveryPerson
    , Location(..)
    , animate
    , initial
    , navigateTo
    )

import Actions exposing (Action(..))
import AnimationState exposing (AnimatedObject, animateFrame)
import Astar
import MapObject exposing (MapObject)
import Time exposing (Time)


type Location
    = At MapObject (Maybe Action)
    | OnTheWayTo MapObject (Maybe Action)
    | Initial


type alias DeliveryPerson =
    AnimatedObject
        { location : Location
        , route : List ( Int, Int )
        , position : ( Float, Float )
        , capacity : Int
        , size : ( Float, Float )
        }


pushThePedals : Time -> DeliveryPerson -> DeliveryPerson
pushThePedals time deliveryPerson =
    case deliveryPerson.location of
        OnTheWayTo _ _ ->
            animateFrame 3 time deliveryPerson

        _ ->
            deliveryPerson


currentDestination : DeliveryPerson -> Maybe ( Float, Float )
currentDestination deliveryPerson =
    case deliveryPerson.route of
        [] ->
            Nothing

        first :: _ ->
            Just ( toFloat (Tuple.first first), toFloat (Tuple.second first) )


absValue : ( Float, Float ) -> Float
absValue ( x, y ) =
    sqrt (x ^ 2 + y ^ 2)


diff : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
diff ( x1, y1 ) ( x2, y2 ) =
    ( x1 - x2, y1 - y2 )


add : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
add ( x1, y1 ) ( x2, y2 ) =
    ( x1 + x2, y1 + y2 )


scale : Float -> ( Float, Float ) -> ( Float, Float )
scale a ( x, y ) =
    ( a * x, a * y )


speed : Float
speed =
    0.036


nextLocation : List ( Int, Int ) -> Location -> Location
nextLocation route location =
    case route of
        [] ->
            case location of
                OnTheWayTo mapObject maybeAction ->
                    At mapObject maybeAction

                _ ->
                    location

        _ ->
            location


moveToNext : Time -> ( Float, Float ) -> DeliveryPerson -> DeliveryPerson
moveToNext time dest deliveryPerson =
    let
        maxDelta =
            diff dest deliveryPerson.position

        absMax =
            absValue maxDelta

        dvect =
            scale (1 / absMax) maxDelta

        speedDelta =
            scale speed dvect

        absSpeed =
            absValue speedDelta

        actualDelta =
            if absSpeed > absMax then
                maxDelta

            else
                speedDelta

        remainderTime =
            if absSpeed > absMax then
                time - time * absMax / absSpeed

            else
                0

        nextPosition =
            add deliveryPerson.position actualDelta

        nextRoute =
            if absSpeed >= absMax then
                List.drop 1 deliveryPerson.route

            else
                deliveryPerson.route

        location =
            nextLocation nextRoute deliveryPerson.location

        updatedPerson =
            { deliveryPerson
                | position = nextPosition
                , location = location
                , route = nextRoute
            }
    in
    if remainderTime > 0 then
        moveOnPath remainderTime updatedPerson

    else
        updatedPerson


stayThere : DeliveryPerson -> DeliveryPerson
stayThere deliveryPerson =
    { deliveryPerson
        | location = nextLocation [] deliveryPerson.location
        , route = []
    }


moveOnPath : Time -> DeliveryPerson -> DeliveryPerson
moveOnPath time deliveryPerson =
    case currentDestination deliveryPerson of
        Nothing ->
            stayThere deliveryPerson

        Just d ->
            moveToNext time d deliveryPerson


animate : Time -> DeliveryPerson -> ( DeliveryPerson, Maybe Action )
animate time deliveryPerson =
    let
        newDeliveryPerson =
            deliveryPerson
                |> pushThePedals time
                |> moveOnPath time
    in
    case newDeliveryPerson.location of
        At location maybeAction ->
            ( { newDeliveryPerson | location = At location Nothing }, maybeAction )

        _ ->
            ( newDeliveryPerson, Nothing )


initial : ( Float, Float ) -> DeliveryPerson
initial position =
    { location = Initial
    , position = position
    , size = ( 2, 1 )
    , route = []
    , elapsed = 0
    , timeout = 96
    , frame = 0
    , capacity = 4
    }


navigationStart : DeliveryPerson -> ( Int, Int )
navigationStart { position, route } =
    Maybe.withDefault
        ( round (Tuple.first position)
        , round (Tuple.second position)
        )
        (List.head route)


appendPath : List ( Int, Int ) -> List ( Int, Int ) -> List ( Int, Int )
appendPath current new =
    case current of
        [] ->
            new

        first :: rest ->
            first :: new


navigateTo : ( Int, Int ) -> List ( Int, Int ) -> Location -> ( Int, Int ) -> DeliveryPerson -> DeliveryPerson
navigateTo gridSize obstacles location destination deliveryPerson =
    { deliveryPerson
        | location = location
        , route =
            appendPath
                deliveryPerson.route
                (Astar.findPath gridSize obstacles (navigationStart deliveryPerson) destination)
    }

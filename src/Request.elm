module Request exposing
    ( Request
    , RequestCategory(..)
    , animate
    , inTime
    , isInReturn
    , isOrdered
    , orderedCategories
    , orders
    , returnArticles
    )

import Article exposing (Article)
import Category exposing (Category)
import Customer exposing (Customer)
import Dict exposing (Dict)
import IHopeItWorks
import MapObject exposing (MapObject)
import Random


type RequestCategory
    = Order Category
    | Return Article


type alias Request =
    { timeout : Float
    , elapsed : Float
    , house : MapObject
    , category : RequestCategory
    , blinkHidden : Bool
    }


request : RequestCategory -> MapObject -> Request
request category house =
    { timeout = 60000
    , elapsed = 0
    , blinkHidden = False
    , house = house
    , category = category
    }


orderedCategories : List Request -> List Category
orderedCategories requests =
    case requests of
        [] ->
            []

        request_ :: rest ->
            case request_.category of
                Order category ->
                    category :: orderedCategories rest

                _ ->
                    orderedCategories rest


returnArticles : Dict Int Customer -> List Article -> List Request
returnArticles customers articles =
    case articles of
        [] ->
            []

        article :: restArticles ->
            case Article.house customers article of
                Just house ->
                    request (Return article) house :: returnArticles customers restArticles

                Nothing ->
                    returnArticles customers restArticles


orders : Int -> List MapObject -> List Category -> Random.Generator (List Request)
orders number houses categories =
    if number <= 0 then
        Random.map (always []) (Random.int 0 0)

    else
        Random.pair (IHopeItWorks.pickRandom houses) (IHopeItWorks.pickRandom categories)
            |> Random.andThen
                (\pair ->
                    case pair of
                        ( Just house, Just category ) ->
                            Random.map
                                ((::) (request (Order category) house))
                                (orders
                                    (number - 1)
                                    (IHopeItWorks.remove ((==) house) houses)
                                    (IHopeItWorks.remove ((==) category) categories)
                                )

                        _ ->
                            Random.map (always []) (Random.int 0 0)
                )


isInReturn : MapObject -> Article -> Request -> Bool
isInReturn house article request_ =
    case request_.category of
        Return article_ ->
            house == request_.house && article_ == article

        _ ->
            False


isOrdered : MapObject -> Category -> Request -> Bool
isOrdered house category request_ =
    case request_.category of
        Order category_ ->
            house == request_.house && category_ == category

        _ ->
            False


flash : Float -> Bool
flash elapsed =
    let
        z =
            30000

        -- time while it doesn't blink
        a =
            0.00000024

        -- acceleration of blinking speed
        b =
            0.003

        -- initial blinking speed
        m =
            0.015

        -- max speed
    in
    if elapsed < z then
        False

    else
        let
            x =
                elapsed - z

            s =
                if a * x + b > m then
                    m

                else
                    a * x + b
        in
        0 < sin (s * x)


animate : Float -> Request -> Request
animate time request_ =
    { request_
        | elapsed = request_.elapsed + time
        , blinkHidden = flash request_.elapsed
    }


inTime : Request -> Bool
inTime { elapsed, timeout } =
    elapsed < timeout

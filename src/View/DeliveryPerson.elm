module View.DeliveryPerson exposing (render)

import Basics exposing (atan2)
import Box exposing (Box)
import DeliveryPerson exposing (DeliveryPerson)
import Layers exposing (layers)
import Textures


calculateDirection : ( Float, Float ) -> Int
calculateDirection ( x, y ) =
    modBy 8 (round (2 + atan2 y x * 4 / pi))


direction : DeliveryPerson -> Int
direction { route, position } =
    case route of
        ( x, y ) :: rest ->
            calculateDirection
                ( toFloat x - Tuple.first position
                , toFloat y - Tuple.second position
                )

        [] ->
            0


boxesOffset : Int -> ( Float, Float )
boxesOffset direction_ =
    case direction_ of
        2 ->
            ( -0.5, -2 )

        3 ->
            ( -0.25, -2.25 )

        5 ->
            ( 0.25, -2.25 )

        6 ->
            ( 0.5, -2 )

        _ ->
            ( 0, -2 )


render : Int -> DeliveryPerson -> List Box
render numberOfBoxes deliveryPerson =
    let
        frame =
            direction deliveryPerson * 3 + deliveryPerson.frame

        boxes =
            [ Box.offsetTextured
                ( 0, -2 )
                Textures.DeliveryPersonBack
                deliveryPerson.position
                frame
                ( layers.obstacle, 0 )
            , Box.offsetTextured
                (boxesOffset (direction deliveryPerson))
                Textures.Boxes
                deliveryPerson.position
                ((4 - numberOfBoxes) * 6 + modBy 2 (direction deliveryPerson) * 3 + deliveryPerson.frame)
                ( layers.obstacle, 2 )
            , Box.offsetTextured
                ( 0, -2 )
                Textures.DeliveryPersonFront
                deliveryPerson.position
                (if frame >= 9 && frame <= 17 then
                    frame - 6

                 else
                    0
                )
                ( layers.obstacle, 3 )
            ]
    in
    case deliveryPerson.location of
        DeliveryPerson.OnTheWayTo _ _ ->
            boxes

        _ ->
            [ Box.offsetTextured
                ( 0, -2 )
                Textures.DeliveryPersonBack
                deliveryPerson.position
                (24 + numberOfBoxes)
                ( layers.obstacle, 0 )
            ]

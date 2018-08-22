module View.Customer exposing (render)

import Article exposing (Article)
import Box exposing (Box)
import Category exposing (Category)
import Customer exposing (Customer)
import Layers exposing (layers)
import Textures


shirtFrameOffset : Customer -> Int -> Int
shirtFrameOffset { happiness, frame } color =
    if happiness > 0 then
        color * 3

    else
        color * 3 + 1 + frame


customerFrameOffset : Customer -> Int
customerFrameOffset { typ, happiness, frame } =
    case happiness of
        0 ->
            typ * 6 + 2 + frame

        1 ->
            typ * 6 + 1

        _ ->
            typ * 6


render : List Article -> ( Float, Float ) -> Customer -> List Box
render articles position customer =
    let
        categories =
            articles
                |> List.filter (\{ state } -> state == Article.DeliveredToCustomer customer.id)
                |> List.map .category

        shirtColor =
            Category.getColor Category.Shirt categories
                |> Maybe.map (shirtFrameOffset customer)

        shoesColor =
            Category.getColor Category.Shoes categories

        pantsColor =
            Category.getColor Category.Pants categories

        scarfColor =
            Category.getColor Category.Scarf categories

        renderColor maybeColor layer sprite =
            case maybeColor of
                Just color ->
                    [ Box.textured sprite position color ( layers.obstacle, layer ) ]

                Nothing ->
                    []

        renderHeart =
            if customer.isDressed then
                [ Box.textured Textures.Heart position customer.frame ( layers.obstacle, 6 ) ]

            else
                []
    in
    renderColor scarfColor 5 Textures.Scarves
        ++ renderColor pantsColor 4 Textures.Trousers
        ++ renderColor shoesColor 3 Textures.Shoes
        ++ renderColor shirtColor 2 Textures.Shirts
        ++ renderHeart
        ++ [ Box.textured Textures.Customers position (customerFrameOffset customer) ( layers.obstacle, 1 )
           ]

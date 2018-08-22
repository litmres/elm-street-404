module View.Category exposing (render)

import Box exposing (Box)
import Category exposing (Category, Kind(..))
import Layers exposing (layers)
import Textures


getFrame : Category -> Int
getFrame { kind, color } =
    case kind of
        Shirt ->
            color

        Shoes ->
            color + 3

        Pants ->
            color + 6

        Scarf ->
            color + 9


render : ( Float, Float ) -> Category -> Box
render position category =
    Box.textured
        Textures.Categories
        position
        (getFrame category)
        ( layers.article, 0 )

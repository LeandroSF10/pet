{-# LANGUAGE TemplateHaskell, QuasiQuotes #-}
module Import where

import Yesod
import Yesod.Static
 
pRoutes = [parseRoutes|
   /pet PetR GET POST
   /listar ListPetR GET
   /static StaticR Static getStatic
--   /ima ImgR GET
   /login LoginR GET POST
   / WelcomeR GET
   /bye ByeR GET
   /admin AdminR GET
|]

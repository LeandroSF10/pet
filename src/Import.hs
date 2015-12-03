{-# LANGUAGE TemplateHaskell, QuasiQuotes #-}
module Import where

import Yesod
import Yesod.Static
 
pRoutes = [parseRoutes|
   /pet PetR GET POST
   /serv ServicoR GET POST
   /petServ PetServR GET POST
   /listar ListPetR GET
   /listS ListarServR GET
   /static StaticR Static getStatic
--   /img ImgR Static getStatic
   /favicon FaviconR GET
--   /ima ImgR GET
   /login LoginR GET POST
   / WelcomeR GET
   /bye ByeR GET
   /admin AdminR GET
|]

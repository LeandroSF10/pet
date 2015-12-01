{-# LANGUAGE OverloadedStrings, QuasiQuotes,
             TemplateHaskell #-}
 
module Handlers where
import Import
import Yesod
import Yesod.Static
import Foundation
import Control.Monad.Logger (runStdoutLoggingT)
import Control.Applicative
import Data.Text
import Text.Lucius

import Database.Persist.Postgresql

mkYesodDispatch "Sitio" pRoutes

widgetForm :: Route Sitio -> Enctype -> Widget -> Text -> Text -> Widget
widgetForm x enctype widget y val = do
     msg <- getMessage
     $(whamletFile "form.hamlet")
     toWidget $(luciusFile "teste.lucius")

formPet :: Form Pet
formPet = renderDivs $ Pet <$>
    areq textField "Nome do pet" Nothing <*>
    areq textField "Senha" Nothing

getPetR :: Handler Html
getPetR = do
    (wid,enc) <- generateFormPost formPet
    defaultLayout $ widgetForm PetR enc wid "Cadastro de Pets" "Cadastrar"

--getImgR :: Handler Html
--getImgR = defaultLayout [whamlet| 
--    <img src=@{StaticR empolgou_jpg}> 
--apaguei a tag de fechamento do whamlet aqui!!!

getWelcomeR :: Handler Html
getWelcomeR = do
     usr <- lookupSession "_ID"
     defaultLayout [whamlet|
        $maybe m <- usr
            <h1> Welcome #{m}
     |]

getLoginR :: Handler Html
getLoginR = do
    (wid,enc) <- generateFormPost formPet
    defaultLayout $ widgetForm LoginR enc wid "" "Log in"

postLoginR :: Handler Html
postLoginR = do
    ((result,_),_) <- runFormPost formPet
    case result of
        FormSuccess pt -> do
            usuario <- runDB $ selectFirst [PetNome ==. petNome pt, PetSenha ==. petSenha pt ] []
            case usuario of
                Just (Entity uid pt) -> do
                    setSession "_ID" (petNome pt)
                    redirect WelcomeR
                Nothing -> do
                    setMessage $ [shamlet| Invalid pet |]
                    redirect LoginR 
        _ -> redirect LoginR

postPetR :: Handler Html
postPetR = do
    ((result,_),_) <- runFormPost formPet
    case result of
        FormSuccess pt -> do
            runDB $ insert pt
            setMessage $ [shamlet| <p> Pet inserido com sucesso! |]
            redirect PetR
        _ -> redirect PetR

getListPetR :: Handler Html
getListPetR = do
    listaP <- runDB $ selectList [] [Asc PetNome]
    defaultLayout $(whamletFile "list.hamlet")

getByeR :: Handler Html
getByeR = do
    deleteSession "_ID"
    defaultLayout [whamlet| BYE! |]

getAdminR :: Handler Html
getAdminR = defaultLayout [whamlet| <h1> Bem-vindo ADMIN!! |]

connStr = "dbname=d73o4i4c3984an host=ec2-54-83-204-228.compute-1.amazonaws.com user=ttjvxdkfuiwwlb password=F9agSMEM7uPTF4w4XXdVtv6Alj"

main::IO()
main = runStdoutLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do 
       runSqlPersistMPool (runMigration migrateAll) pool
       s <- static "."
       warpEnv (Sitio pool s)

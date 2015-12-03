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
import Data.Time
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

formServ :: Form Servico
formServ = renderDivs $ Servico <$>
    areq textField "Servico" Nothing <*>
    areq doubleField "Preco" Nothing 

formPetServ :: Form PetServ
formPetServ = renderDivs $ PetServ <$>
--    pure (lookupSession "_ID") <*>
    areq (selectField pet) "Pet" Nothing <*>
    areq (selectField serv) "Servicos" Nothing

serv = do
    entidades <- runDB $ selectList [] [Asc ServicoNome]
    optionsPairs $ fmap (\ent -> (servicoNome $ entityVal ent, entityKey ent)) entidades

pet = do
    entidades <- runDB $ selectList [] [Asc PetNome]
    optionsPairs $ fmap (\ent -> (petNome $ entityVal ent, entityKey ent)) entidades
    
getPetR :: Handler Html
getPetR = do
    (wid,enc) <- generateFormPost formPet
    defaultLayout $ widgetForm PetR enc wid "Cadastro de Pets" "Cadastrar"

getServicoR :: Handler Html
getServicoR = do
    (wid,enc) <- generateFormPost formServ
    defaultLayout $ widgetForm ServicoR enc wid "Cadastro de Servicos" "Cadastrar"


getPetServR :: Handler Html
getPetServR = do
    (wid,enc) <- generateFormPost formPetServ
    defaultLayout $ widgetForm PetServR enc wid "Agenda de Servicos" "Cadastrar"

--getImgR :: Handler Html
--getImgR = defaultLayout [whamlet| 
--    <img src=@{StaticR empolgou_jpg}> 
--apaguei a tag de fechamento do whamlet aqui!!!
{-
getWelcomeR :: Handler Html
getWelcomeR = do
     usr <- lookupSession "_ID"
     defaultLayout [whamlet|
        $maybe m <- usr
            <h1> Welcome #{m}
                <ul>
                    <a href="/serv">Cadastro de servicos<br/><br/>
                    <a href=@{ListPetR}>Listar pets<br/><br/>
                    <a href=@{StaticR}>Static<br/><br/>
                    <a href=@{PetR}>Cadastrar Pet<br/><br/> 
                    <a href=@{PetServR}>Agendar Servico para seu pet!<br/><br/>
                    <a href=@{ListarServR}>Listar servicos<br/><br/>
                    <a href=@{LoginR}>Login<br/><br/>
                    <a href=@{WelcomeR}>Welcome<br/><br/>
                    <a href=@{ByeR}>Bye!!<br/><br/>
                    <a href=@{AdminR}>Admin<br/><br/> 
     |]
-}

getWelcomeR :: Handler Html
getWelcomeR = do
    usr <- lookupSession "_ID"
    defaultLayout $(whamletFile "menu.hamlet")

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

postServicoR :: Handler Html
postServicoR = do
    ((result,_),_) <- runFormPost formServ
    case result of
        FormSuccess srv -> do
            runDB $ insert srv
            setMessage $ [shamlet| <p> Servico inserido com sucesso! |]
            redirect ServicoR
        _ -> redirect ServicoR

postPetServR :: Handler Html
postPetServR = do
    ((result,_),_) <- runFormPost formPetServ
    case result of
        FormSuccess psrv -> do
            runDB $ insert psrv
            setMessage $ [shamlet| <p> Servico agendado com sucesso! |]
            redirect PetServR
        _ -> redirect PetServR

getListPetR :: Handler Html
getListPetR = do
    listaP <- runDB $ selectList [] [Asc PetNome]
    defaultLayout $(whamletFile "list.hamlet")

getListarServR :: Handler Html
getListarServR = do
    listaS <- runDB $ selectList [] [Asc ServicoNome]
    defaultLayout $(whamletFile "listS.hamlet")

getByeR :: Handler Html
getByeR = do
    deleteSession "_ID"
    defaultLayout [whamlet| BYE! |]

getAdminR :: Handler Html
getAdminR = defaultLayout [whamlet| <h1> Bem-vindo ADMIN!! |]

connStr = "dbname=debfcicpp14ho6 host=ec2-50-19-208-138.compute-1.amazonaws.com user=xnqwtfkdbgizwv password= qpSfDkYhOUe6qgjP8QXpqLDt-P"

main::IO()
main = runStdoutLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do 
       runSqlPersistMPool (runMigration migrateAll) pool
       s <- static "."
       warpEnv (Sitio pool s)

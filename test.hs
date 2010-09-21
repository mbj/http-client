{-# LANGUAGE OverloadedStrings #-}
import Network.HTTP.Enumerator
import OpenSSL
import Network
import qualified Data.ByteString as S
import qualified Data.ByteString.Lazy as L
import qualified Data.ByteString.Lazy.Char8 as L8
import Data.Enumerator (consume, Iteratee)
import System.Environment (getArgs)

main :: IO ()
main = withSocketsDo $ withOpenSSL $ do
    let _req1 = Request
            { host = "localhost"
            , port = 80
            , secure = False
            , requestHeaders = []
            , path = "/"
            , queryString = [("foo", "bar")]
            , requestBody = L8.pack "baz=bin"
            , method = "POST"
            }
    [url] <- getArgs
    _req2 <- parseUrl url
    Response sc hs b <- http _req2 toLBS
    print sc
    mapM_ (\(x, y) -> do
        S.putStr x
        putStr ": "
        S.putStr y
        putStrLn "") hs
    putStrLn ""
    L.putStr b

toLBS :: Monad m => Iteratee S.ByteString m L.ByteString
toLBS = L.fromChunks `fmap` consume

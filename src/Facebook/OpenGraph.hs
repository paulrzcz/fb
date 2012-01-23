module Facebook.OpenGraph
    ( createAction
    , Action(..)
    , (#=)
    , SimpleType(..)
    ) where

-- import Control.Applicative
-- import Control.Monad (mzero)
-- import Data.ByteString.Char8 (ByteString)
import Data.Text (Text)
-- import Data.Typeable (Typeable, Typeable1)
import Data.Int (Int8, Int16, Int32)
import Data.Word (Word8, Word16, Word32, Word)
import Data.String (IsString(..))
import Network.HTTP.Types (Ascii)
import System.Locale (defaultTimeLocale)

-- import qualified Control.Exception.Lifted as E
-- import qualified Data.Aeson as A
-- import qualified Data.ByteString.Char8 as B
import qualified Data.Conduit as C
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.Time as TI
-- import qualified Network.HTTP.Types as HT


import Facebook.Types
import Facebook.Monad
-- import Facebook.Base
import Facebook.Graph


-- | Creates an Open Graph action on the user's timeline. Returns
-- the 'Id' of the newly created action.  For example:
--
-- > now <- liftIO getCurrentTime
-- > createAction "cook"
-- >              [ "recipe" #= "http://example.com/cookie.html"
-- >              , "when"   #= now ]
-- >              token
createAction :: C.ResourceIO m =>
                Action     -- ^ Action kind to be created.
             -> [Argument] -- ^ Arguments of the action.
             -> AccessToken User
             -> FacebookT Auth m Id
createAction (Action action) query token = do
  creds <- getCreds
  postObject ("/me/" <> appName creds <> ":" <> action) query token


-- | An action of your app.  Please refer to Facebook's
-- documentation at
-- <https://developers.facebook.com/docs/opengraph/keyconcepts/#actions-objects>
-- to see how you can create actions.
--
-- This is a @newtype@ of 'Ascii' that supports only 'IsString'.
-- This means that to create an 'Action' you should use the
-- @OverloadedStrings@ language extension.  For example,
--
-- > {-# LANGUAGE OverloadedStrings #-}
-- >
-- > foo token = do
-- >   ...
-- >   createAction "cook" [...] token
newtype Action = Action { unAction :: Ascii }

instance Show Action where
    show = show . unAction

instance IsString Action where
    fromString = Action . fromString


-- | Create an 'Argument' with a 'SimpleType'.  See the docs on
-- 'createAction' for an example.
(#=) :: SimpleType a => Ascii -> a -> Argument
p #= v = (p, TE.encodeUtf8 (encodeFbParam v))



-- | Class for data types that may be represented as a Facebook
-- simple type. (see
-- <https://developers.facebook.com/docs/opengraph/simpletypes/>).
class SimpleType a where
    encodeFbParam :: a -> Text

-- | Facebook's simple type @Boolean@.
instance SimpleType Bool where
    encodeFbParam b = if b then "1" else "0"

-- | Facebook's simple type @DateTime@ with only the date.
instance SimpleType TI.Day where
    encodeFbParam = T.pack . TI.formatTime defaultTimeLocale "%Y-%m-%d"
-- | Facebook's simple type @DateTime@.
instance SimpleType TI.UTCTime where
    encodeFbParam = T.pack . TI.formatTime defaultTimeLocale "%Y%m%dT%H%MZ"
-- | Facebook's simple type @DateTime@.
instance SimpleType TI.ZonedTime where
    encodeFbParam = encodeFbParam . TI.zonedTimeToUTC

-- @Enum@ doesn't make sense to support as a Haskell data type.

-- | Facebook's simple type @Float@ with less precision than supported.
instance SimpleType Float where
    encodeFbParam = showT
-- | Facebook's simple type @Float@.
instance SimpleType Double where
    encodeFbParam = showT

-- | Facebook's simple type @Integer@.
instance SimpleType Int where
    encodeFbParam = showT
-- | Facebook's simple type @Integer@.
instance SimpleType Word where
    encodeFbParam = showT
-- | Facebook's simple type @Integer@.
instance SimpleType Int8 where
    encodeFbParam = showT
-- | Facebook's simple type @Integer@.
instance SimpleType Word8 where
    encodeFbParam = showT
-- | Facebook's simple type @Integer@.
instance SimpleType Int16 where
    encodeFbParam = showT
-- | Facebook's simple type @Integer@.
instance SimpleType Word16 where
    encodeFbParam = showT
-- | Facebook's simple type @Integer@.
instance SimpleType Int32 where
    encodeFbParam = showT
-- | Facebook's simple type @Integer@.
instance SimpleType Word32 where
    encodeFbParam = showT

-- | Facebook's simple type @String@.
instance SimpleType Text where
    encodeFbParam = id

showT :: Show a => a -> Text
showT = T.pack . show
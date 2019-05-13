{-# OPTIONS_GHC -fno-warn-missing-signatures #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE EmptyCase #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ImpredicativeTypes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE UndecidableInstances #-}

module Common.Types.RepoBuildInfo where

------------------------------------------------------------------------------
import           Data.Text (Text)
import qualified Data.Text as T
import           Database.Beam
import           Database.Beam.Backend.SQL
import           Database.Beam.Backend.Types
import           Database.Beam.Migrate.Generics
import           Database.Beam.Migrate.SQL
------------------------------------------------------------------------------

data RepoEvent = RepoPush | RepoPullRequest
  deriving (Eq,Ord,Show,Read,Enum,Bounded)

instance HasSqlValueSyntax be String => HasSqlValueSyntax be RepoEvent where
  sqlValueSyntax = autoSqlValueSyntax

instance (BeamBackend be, FromBackendRow be Text) => FromBackendRow be RepoEvent where
  fromBackendRow = read . T.unpack <$> fromBackendRow

instance BeamMigrateSqlBackend be => HasDefaultSqlDataType be RepoEvent where
  defaultSqlDataType _ _ _ = varCharType Nothing Nothing

data RepoBuildInfoT f = RepoBuildInfo
  { _rbi_repoName :: C f Text
  , _rbi_repoFullName :: C f Text
  , _rbi_repoEvent :: C f RepoEvent
  , _rbi_cloneUrlSsh :: C f Text
  , _rbi_cloneUrlHttp :: C f Text
  , _rbi_gitRef :: C f Text
  , _rbi_commitHash :: C f Text
  } deriving (Generic)

RepoBuildInfo
  (LensFor rbi_repoName)
  (LensFor rbi_repoFullName)
  (LensFor rbi_repoEvent)
  (LensFor rbi_cloneUrlSsh)
  (LensFor rbi_cloneUrlHttp)
  (LensFor rbi_gitRef)
  (LensFor rbi_commitHash)
  = tableLenses

type RepoBuildInfo = RepoBuildInfoT Identity

deriving instance Eq RepoBuildInfo
deriving instance Show RepoBuildInfo

instance Beamable RepoBuildInfoT

prettyRBI ::RepoBuildInfo -> Text
prettyRBI rbi = T.unlines
  [ _rbi_repoName rbi
  , _rbi_repoFullName rbi
  , _rbi_cloneUrlSsh rbi
  , _rbi_cloneUrlHttp rbi
  , _rbi_commitHash rbi
  ]

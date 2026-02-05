///|
/// Shared types for the Mooncakes Mirror Registry

///|
/// Stats data from the registry
pub struct Stats {
  total_packages : Int
  total_owners : Int
  yanked_count : Int
  last_sync_packages : Int
  last_sync_owners : Int
  last_sync : String
} derive(Default)

///|
/// Package version information from index files
pub struct PackageVersion {
  name : String
  version : String
  readme : String
  repository : String
  license : String
  keywords : Array[String]
  checksum : String
  created_at : String
  yanked : Bool
  deprecated : String
} derive(Default)

///|
/// Yanked package info
pub struct YankedPackage {
  name : String
  version : String
  reason : String
} derive(Default)

///|
/// Publisher info with package count
pub struct Publisher {
  name : String
  package_count : Int
} derive(Default)

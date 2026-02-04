///|
/// JSON parsing utilities

///|
/// Helper to get int from Json object
pub fn get_int(obj : Map[String, Json], key : String) -> Int {
  match obj.get(key) {
    Some(Number(n, ..)) => n.to_int()
    _ => 0
  }
}

///|
/// Helper to get string from Json object
pub fn get_string(obj : Map[String, Json], key : String) -> String {
  match obj.get(key) {
    Some(String(s)) => s
    _ => ""
  }
}

///|
/// Helper to get bool from Json object
pub fn get_bool(obj : Map[String, Json], key : String) -> Bool {
  match obj.get(key) {
    Some(True) => true
    _ => false
  }
}

///|
/// Helper to get string array from Json object
pub fn get_string_array(obj : Map[String, Json], key : String) -> Array[String] {
  match obj.get(key) {
    Some(Array(arr)) => {
      let result : Array[String] = []
      for item in arr {
        match item {
          String(s) => result.push(s)
          _ => ()
        }
      }
      result
    }
    _ => []
  }
}

///|
/// Parse stats JSON and return Stats struct
pub fn parse_stats(json_str : String) -> Stats {
  let result = try {
    @json.parse(json_str[:])
  } catch {
    _ => return Stats::default()
  }
  match result {
    Object(obj) => {
      total_packages: get_int(obj, "totalPackages"),
      total_owners: get_int(obj, "totalOwners"),
      yanked_count: get_int(obj, "yankedCount"),
      last_sync_packages: get_int(obj, "lastSyncPackages"),
      last_sync_owners: get_int(obj, "lastSyncOwners"),
      last_sync: get_string(obj, "lastSync"),
    }
    _ => Stats::default()
  }
}

///|
/// Parse yanked JSON and return array of YankedPackage
pub fn parse_yanked(json_str : String) -> Array[YankedPackage] {
  let result : Array[YankedPackage] = []
  let parsed = try {
    @json.parse(json_str[:])
  } catch {
    _ => return result
  }
  match parsed {
    Object(obj) => {
      match obj.get("yankedPackages") {
        Some(Array(arr)) => {
          for item in arr {
            match item {
              Object(pkg_obj) => {
                result.push({
                  name: get_string(pkg_obj, "name"),
                  version: get_string(pkg_obj, "version"),
                  reason: get_string(pkg_obj, "reason"),
                })
              }
              _ => ()
            }
          }
        }
        _ => ()
      }
    }
    _ => ()
  }
  result
}

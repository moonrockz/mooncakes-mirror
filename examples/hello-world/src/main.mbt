///|
/// Example MoonBit project that uses the mooncakes-mirror registry
/// This is used as a test fixture for E2E testing

fn main {
  // Simple test that uses a dependency from moonbitlang/x
  let duration = @time.Duration::from_seconds(42)
  println("Hello from MoonCakes Mirror!")
  println("Duration: \{duration.to_string()}")
}

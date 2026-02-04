///|
/// Example MoonBit project for E2E testing the mooncakes-mirror registry
/// This verifies that moon update works with the mirror

fn main {
  println("Hello from MoonCakes Mirror!")
  println("Registry test successful!")

  // Simple computation to verify the build works
  let numbers = [1, 2, 3, 4, 5]
  let sum = numbers.fold(init=0, fn(acc, x) { acc + x })
  println("Sum of 1-5: \{sum}")
}

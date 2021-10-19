package org.matihost.learning

// Scala 3
//
// sample top method
// private def sample() : String = "World"

// Scala 3 way of main method
// @main
// def app() = {
//   App.amain(Array("a", "b", "c"))
// }

/**
 * @author ${user.name}
 */
object App {

  private def foo(x : Array[String]) = x.foldLeft("")((a,b) => a + b)

  // Scala2 way of doing main method, backward compatible with Scala 3
  def main(args : Array[String]) : Unit = {
    println("Hello World!")
    println(s"concat arguments = ${foo(args)}")
  }

}

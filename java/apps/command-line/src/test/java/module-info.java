open module org.matihost.learning.apps.commandline.test {
  requires org.matihost.learning.apps.commandline;

  requires transitive spring.boot.test;
  requires transitive org.assertj.core;
  // to mitigate https://github.com/mockito/mockito/issues/2282
  requires transitive net.bytebuddy;

  // junit
  requires transitive org.junit.jupiter.engine;
  requires transitive org.junit.jupiter.api;
  requires transitive org.junit.jupiter.params;
}

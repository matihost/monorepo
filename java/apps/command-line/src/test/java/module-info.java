open module org.matihost.learning.apps.commandline.test {
  requires org.matihost.learning.apps.commandline;

  // spring boot test
  requires spring.boot.test;
  requires spring.boot;
  requires spring.test;

  // junit4
  requires junit;
  // junit5
  requires transitive org.junit.jupiter.engine;
  requires transitive org.junit.jupiter.api;
  requires transitive org.junit.jupiter.params;

  requires org.mockito.junit.jupiter;

  requires transitive org.assertj.core;
  // to mitigate https://github.com/mockito/mockito/issues/2282
  requires transitive net.bytebuddy;
  requires transitive net.bytebuddy.agent;


}

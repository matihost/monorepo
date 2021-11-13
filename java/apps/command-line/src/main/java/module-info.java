module org.matihost.learning.apps.commandline {
  exports org.matihost.learning.java.utils;
  exports org.matihost.learning.java.handlers;

  requires java.net.http;
  requires transitive java.xml;
  // logging
  requires org.slf4j;
  // spring
  requires spring.beans;
  requires spring.context;
  requires transitive spring.boot;
  requires spring.boot.autoconfigure;

  // to let Spring and Test framework access non public members
  opens org.matihost.learning.java to spring.core, spring.beans, spring.context, org.mockito;
  opens org.matihost.learning.java.beans to spring.core, spring.beans, spring.context, org.mockito;
  opens org.matihost.learning.java.handlers to spring.core, spring.beans, spring.context, org.mockito;
}

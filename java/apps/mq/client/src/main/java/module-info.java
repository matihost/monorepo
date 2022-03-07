module org.matihost.learning.mq.client {
  exports org.matihost.learning.mq.utils;
  exports org.matihost.learning.mq.handlers;


  // logging
  requires org.slf4j;
  // spring
  requires spring.beans;
  requires spring.context;
  requires transitive spring.boot;
  requires spring.boot.autoconfigure;

  //
  requires org.apache.commons.lang3;
  requires com.ibm.mq.allclient;
  requires javax.jms.api;

  // to let Spring and Test framework access non public members
  opens org.matihost.learning.mq to spring.core, spring.beans, spring.context, org.mockito;
  opens org.matihost.learning.mq.beans to spring.core, spring.beans, spring.context, org.mockito;
  opens org.matihost.learning.mq.handlers to spring.core, spring.beans, spring.context, org.mockito;
}

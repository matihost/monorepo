package org.matihost.learning.mq.beans;

import org.matihost.learning.mq.utils.MqClientManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.jms.JMSException;

@Configuration
public class ApplicationConfiguration {

  @Bean
  public MqClientManager mqClientManager(MqConfiguration conf) throws JMSException {
    return new MqClientManager(conf);
  }
}

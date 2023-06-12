package org.matihost.learning.mq.handlers;

import org.matihost.learning.mq.utils.MqClientManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.stereotype.Component;

import javax.jms.JMSException;
import java.util.function.Consumer;

import static org.matihost.learning.mq.utils.CmdLineUtils.blockCurrentThread;

@Component
@Qualifier("get")
public class GetHandler implements Consumer<ApplicationArguments> {
  private static final Logger logger = LoggerFactory.getLogger(GetHandler.class);

  @Autowired
  private MqClientManager mqClientManager;

  @Value("${mq.queue}")
  private String queue;

  @Override
  public void accept(ApplicationArguments appArgs) {
    var connection = mqClientManager.getQueueConnection(queue);

    connection.asyncReceive(message -> {
      try {
        logger.info("Message {} has been received from: {}", message.getBody(String.class), connection.getQueueName());
      } catch (JMSException e) {
        logger.error(String.format("Unable to convert message body to String from queue: %s", this.queue), e);
      }
    });
    // block application from shutdown
    blockCurrentThread();
  }
}

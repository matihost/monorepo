package org.matihost.learning.mq.handlers;

import org.apache.commons.lang3.StringUtils;
import org.matihost.learning.mq.utils.MqClientManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.function.Consumer;

import static org.matihost.learning.mq.utils.CmdLineUtils.getArg;

@Component
@Qualifier("put")
public class PutHandler implements Consumer<ApplicationArguments> {
  private static final Logger logger = LoggerFactory.getLogger(PutHandler.class);

  @Autowired
  private MqClientManager mqClientManager;

  @Value("${mq.queue}")
  private String queue;

  @Override
  public void accept(ApplicationArguments appArgs) {
    var message = retrieveMessageToPut(appArgs);
    var connection = mqClientManager.getQueueConnection(queue);

    connection.sendMessage(message);

    logger.info("Message has been send to {}", connection.getQueueName());
  }

  private String retrieveMessageToPut(ApplicationArguments appArgs) {
    var message = getArg(appArgs, "message", null);
    if (StringUtils.isEmpty(message)) {
      var filePath = getArg(appArgs, "f", null);
      if (StringUtils.isNotEmpty(filePath)) {
        try {
          message = Files.readString(Paths.get(filePath));
        } catch (IOException e) {
          throw new RuntimeException(String.format("Unable to read message from file: %s", filePath), e);
        }
      }
    }
    if (StringUtils.isEmpty(message)) {
      throw new IllegalStateException("Message cannot be empty");
    }
    return message;
  }
}

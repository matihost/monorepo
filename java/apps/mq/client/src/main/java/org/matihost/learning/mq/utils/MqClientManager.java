package org.matihost.learning.mq.utils;

import com.ibm.msg.client.jms.JmsConnectionFactory;
import com.ibm.msg.client.jms.JmsFactoryFactory;
import com.ibm.msg.client.wmq.WMQConstants;
import org.apache.commons.lang3.StringUtils;
import org.matihost.learning.mq.beans.MqConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jms.JMSException;
import javax.jms.Queue;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;


public class MqClientManager implements AutoCloseable {
  private static final Logger logger = LoggerFactory.getLogger(MqClientManager.class);

  private final JmsConnectionFactory cf;
  private final Map<String, MqConnection> queues = new ConcurrentHashMap<>();

  public MqClientManager(MqConfiguration conf) throws JMSException {
    JmsFactoryFactory ff = JmsFactoryFactory.getInstance(WMQConstants.WMQ_PROVIDER);
    cf = ff.createConnectionFactory();
    cf.setStringProperty(WMQConstants.WMQ_HOST_NAME, conf.getHost());
    cf.setIntProperty(WMQConstants.WMQ_PORT, conf.getPort());
    cf.setStringProperty(WMQConstants.WMQ_CHANNEL, conf.getChannel());
    cf.setIntProperty(WMQConstants.WMQ_CONNECTION_MODE, WMQConstants.WMQ_CM_CLIENT);
    cf.setStringProperty(WMQConstants.WMQ_QUEUE_MANAGER, conf.getQmName());
    cf.setStringProperty(WMQConstants.WMQ_APPLICATIONNAME, conf.getSecurity().getApplicationName());
    cf.setBooleanProperty(WMQConstants.USER_AUTHENTICATION_MQCSP, conf.getSecurity().isMqscpAuthenMode());
    cf.setStringProperty(WMQConstants.USERID, conf.getSecurity().getUsername());
    cf.setStringProperty(WMQConstants.PASSWORD, conf.getSecurity().getPassword());
    if (conf.isTls()) {
      cf.setStringProperty(WMQConstants.WMQ_SSL_CIPHER_SUITE, "*TLS13");
      // in case other vendor of JDK than IBM is in use
      System.setProperty("com.ibm.mq.cfg.useIBMCipherMappings", "false");
    }
    logger.debug("Created JMS Factory with: {}", cf);
  }

  public MqConnection getQueueConnection(String queue) {
    return queues.computeIfAbsent(queue, s -> new MqConnection(cf, s));
  }

  public MqConnection getQueueConnection(Queue queue) {
    return new MqConnection(cf, queue);
  }

  public static String extractQueueName(Queue queue) {
    try {
      return queue.getQueueName();
    } catch (JMSException e) {
      throw new IllegalStateException(String.format("Unable to retrieve queue name from %s", queue));
    }
  }

  @Override
  public void close() {
    queues.forEach((s, c) -> {
      try {
        c.close();
      } catch (Exception e) {
        // ignore
      }
    });
  }
}

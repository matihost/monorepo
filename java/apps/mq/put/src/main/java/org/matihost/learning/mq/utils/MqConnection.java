package org.matihost.learning.mq.utils;

import com.ibm.msg.client.jms.JmsConnectionFactory;

import javax.jms.JMSContext;
import javax.jms.JMSException;
import javax.jms.Queue;

public class MqConnection implements AutoCloseable {
  private final Queue queue;
  private final JMSContext context;

  public MqConnection(JmsConnectionFactory cf, String queue) {
    this.context = cf.createContext();
    this.queue = context.createQueue("queue:///" + queue);
  }

  public void sendMessage(String message) {
    var producer = context.createProducer();
    var textMessage = context.createTextMessage(message);
    producer.send(queue, textMessage);
  }

  public Queue getQueue() {
    return queue;
  }

  public String getQueueName() {
    try {
      return queue.getQueueName();
    } catch (JMSException e) {
      throw new IllegalStateException(String.format("Unable to retrieve queue name from %s", queue));
    }
  }

  public JMSContext getContext() {
    return context;
  }

  @Override
  public void close() throws Exception {
    context.close();
  }
}

package org.matihost.learning.mq.utils;

import com.ibm.msg.client.jms.JmsConnectionFactory;

import javax.jms.*;
import java.util.concurrent.ThreadLocalRandom;

public class MqConnection implements AutoCloseable {
  private final Queue queue;
  private final JMSContext context;

  public MqConnection(JmsConnectionFactory cf, String queue) {
    this.context = cf.createContext(JMSContext.AUTO_ACKNOWLEDGE);
    this.queue = context.createQueue("queue:///" + queue);
  }

  public MqConnection(JmsConnectionFactory cf, Queue queue) {
    this.context = cf.createContext(JMSContext.AUTO_ACKNOWLEDGE);
    this.queue = queue;
  }

  public void sendMessage(String message) {
    var textMessage = context.createTextMessage(message);
    context.createProducer()
      .setDeliveryMode(DeliveryMode.NON_PERSISTENT)
      .setTimeToLive(60_000) // in milliseconds,
      .send(queue, textMessage);
  }

  public String sendAndReceive(String rqMessage, String replyQueue, long replyTimeoutMs) {
    var correlationId = Long.toHexString(ThreadLocalRandom.current().nextLong());
    var textMessage = context.createTextMessage(rqMessage);
    var replyToQueue = context.createQueue(replyQueue);
    context.createProducer()
      .setDeliveryMode(DeliveryMode.NON_PERSISTENT)
      .setTimeToLive(60_000) // in milliseconds,
      .setJMSReplyTo(replyToQueue)
      .setJMSCorrelationID(correlationId)
      .send(this.queue, textMessage);

    return context.createConsumer(replyToQueue, String.format("JMSCorrelationID='ID:%s'", correlationId))
      .receiveBody(String.class, replyTimeoutMs);
  }

  public void reply(Message rq, String responseMessage) throws JMSException {
    var rsMessage = context.createTextMessage(responseMessage);

    var rqCorrelationID = rq.getJMSCorrelationID();
    context.createProducer()
      .setJMSCorrelationID(rqCorrelationID)
      .setDeliveryMode(DeliveryMode.NON_PERSISTENT)
      .setTimeToLive(60_000) // in milliseconds,
      .send(queue, rsMessage);
  }

  /**
   * Start receiving traffic and handle them with provided listener
   */
  public void asyncReceive(MessageListener listener) {
    context.createConsumer(queue).setMessageListener(listener);
  }

  public Queue getQueue() {
    return queue;
  }

  public String getQueueName() {
    return MqClientManager.extractQueueName(queue);
  }

  public JMSContext getContext() {
    return context;
  }

  @Override
  public void close() throws Exception {
    context.close();
  }
}

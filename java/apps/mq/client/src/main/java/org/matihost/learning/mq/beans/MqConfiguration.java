package org.matihost.learning.mq.beans;

import org.apache.commons.lang3.ObjectUtils;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties("mq")
public class MqConfiguration {

  private String host;
  private int port = 1414;

  private String qmName;
  private String channel;

  private String supportedTLSSuite;  // empty means no TLS, possible value: *TLS12

  private final Security security = new Security();


  public String getHost() {
    return ObjectUtils.requireNonEmpty(host, "MQ host cannot be empty");
  }

  public void setHost(String host) {
    this.host = host;
  }

  public int getPort() {
    return port;
  }

  public void setPort(int port) {
    this.port = port;
  }

  public String getQmName() {
    return ObjectUtils.requireNonEmpty(qmName, "MQ qmName cannot be empty)");
  }

  public void setQmName(String qmName) {
    this.qmName = qmName;
  }

  public String getChannel() {
    return ObjectUtils.requireNonEmpty(channel, "MQ channel cannot be empty");
  }

  public void setChannel(String channel) {
    this.channel = channel;
  }

  public Security getSecurity() {
    return security;
  }

  public String getSupportedTLSSuite() {
    return supportedTLSSuite;
  }

  public void setSupportedTLSSuite(String supportedTLSSuite) {
    this.supportedTLSSuite = supportedTLSSuite;
  }

  public static class Security {

    /**
     * https://www.ibm.com/docs/en/ibm-mq/9.2?topic=authentication-connection-java-client
     */
    private boolean mqscpAuthenMode = true;
    private String applicationName = "MQ_PUT";
    private String username;
    private String password;


    public String getPassword() {
      return password;
    }

    public void setPassword(String password) {
      this.password = password;
    }

    public String getUsername() {
      return username;
    }

    public void setUsername(String username) {
      this.username = username;
    }

    public String getApplicationName() {
      return applicationName;
    }

    public void setApplicationName(String applicationName) {
      this.applicationName = applicationName;
    }

    public boolean isMqscpAuthenMode() {
      return mqscpAuthenMode;
    }

    public void setMqscpAuthenMode(boolean mqscpAuthenMode) {
      this.mqscpAuthenMode = mqscpAuthenMode;
    }
  }
}

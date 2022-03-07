package org.matihost.learning.mq.beans;

import org.matihost.learning.mq.utils.CmdLineUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.function.Consumer;

@Component
public class CommandLineProcessor implements ApplicationRunner {
  private static Logger logger = LoggerFactory.getLogger(CommandLineProcessor.class);

  @Autowired
  @Qualifier("put")
  private Consumer<ApplicationArguments> put;


  @Autowired
  @Qualifier("get")
  private Consumer<ApplicationArguments> get;

  @Autowired
  @Qualifier("sendAndReceive")
  private Consumer<ApplicationArguments> sendAndReceive;


  @Autowired
  @Qualifier("getAndReply")
  private Consumer<ApplicationArguments> getAndReply;


  @Override
  public void run(ApplicationArguments args) {
    var appMode = CmdLineUtils.getArg(args, "mode", null);
    logger.info("Application started with arguments names : {}", args.getOptionNames());
    switch (appMode) {
      case "get" -> get.accept(args);
      case "put" -> put.accept(args);
      case "sendAndReceive" -> sendAndReceive.accept(args);
      case "getAndReply" -> getAndReply.accept(args);
      default -> throw new IllegalStateException("Application started w/o valid parameter mode. Accepted values: get, put");
    }
  }
}

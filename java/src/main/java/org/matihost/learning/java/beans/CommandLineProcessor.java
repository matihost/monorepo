package org.matihost.learning.java.beans;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.function.Consumer;

@Component
public class CommandLineProcessor implements ApplicationRunner {
  private static Logger logger = LoggerFactory.getLogger(CommandLineProcessor.class);

  @Autowired
  private List<Consumer<ApplicationArguments>> services;

  @Override
  public void run(ApplicationArguments args) {
    logger.info("Application started with arguments names : {}", args.getOptionNames());
    services.forEach(c -> c.accept(args));
  }
}

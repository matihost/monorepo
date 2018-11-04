package org.matihost.learning.java.beans;

import org.matihost.learning.java.utils.NBPExchangeRate;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ApplicationConfiguration {

  @Bean
  public NBPExchangeRate nbpEchangeRate(){
    return new NBPExchangeRate();
  }
}

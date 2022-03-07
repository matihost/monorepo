package org.matihost.learning.mq;

import org.springframework.boot.Banner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@ConfigurationPropertiesScan({ "org.matihost.learning.mq.beans", }) // needed to scan @ConfigurationProperties
public class Application {
	public static void main(String[] args) {
    SpringApplication app = new SpringApplication(Application.class);
    app.setBannerMode(Banner.Mode.OFF);
    app.run(args);
	}
}

package org.matihost.learning.java.utils;

import org.springframework.boot.ApplicationArguments;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.List;

import static java.lang.String.format;
import static java.util.Optional.ofNullable;

/**
 * Utils
 */
public class Utils {

  public static String getArg(ApplicationArguments appArgs, String argName, String defaultValue) {
    return ofNullable(appArgs.getOptionValues(argName))
        .orElse(List.of()).stream()
        .findFirst()
        .orElse(defaultValue);
  }

  public static String httpGet(String url) {
    var request = HttpRequest.newBuilder()
        .uri(URI.create(url))
        .GET()
        .build();
    var client = java.net.http.HttpClient.newHttpClient();
    HttpResponse<String> response;
    try {
      response = client.send(request, HttpResponse.BodyHandlers.ofString());
    } catch (IOException | InterruptedException e) {
      throw new RuntimeException(format("Unable to retrieve %s content", url), e);
    }
    return response.body();
  }
}

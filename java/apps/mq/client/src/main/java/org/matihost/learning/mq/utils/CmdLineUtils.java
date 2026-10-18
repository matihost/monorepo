package org.matihost.learning.mq.utils;

import org.springframework.boot.ApplicationArguments;

import java.util.List;

import static java.util.Optional.ofNullable;

public class CmdLineUtils {

  public static String getArg(ApplicationArguments appArgs, String argName, String defaultValue) {
    return ofNullable(appArgs.getOptionValues(argName))
      .orElse(List.of()).stream()
      .findFirst()
      .orElse(defaultValue);
  }

  /**
   * Neutralizes characters which would let a value break out of a single log line (log injection / log forging, CWE-117):
   * CR, LF and other control characters are replaced with underscore.
   * Use for any value which comes from outside the application (messages from queues, user input) before it is logged.
   */
  public static String sanitizeForLog(Object value) {
    if (value == null) {
      return null;
    }
    return String.valueOf(value).replaceAll("\\p{Cntrl}", "_");
  }

  public static void blockCurrentThread(){
    try {
      Thread.currentThread().join();
    } catch (InterruptedException e) {
      // ignore
    }
  }
}

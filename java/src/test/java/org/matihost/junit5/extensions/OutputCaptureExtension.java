package org.matihost.junit5.extensions;

import org.junit.jupiter.api.extension.AfterAllCallback;
import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.concurrent.locks.ReentrantLock;

/**
 * JUnit 5 version of Spring's org.springframework.boot.test.rule.OutputCaptureExtension class
 * JUnit 5 does not support JUnit 4 generic TestRules classes (only some TestRule implementations via @EnableRuleMigrationSupport)
 * <p>
 * Usage:
 * <p>
 * Just add
 *
 * @ExtendWith(OutputCapture.class) to your JUnit 5 test class
 * and in the assertion phase of the test get output via OutputCaptureExtension.getCapturedOutput()
 * <p>
 * When tests are run in parallel, the output may contain entries from parallel tests as well.
 */
public class OutputCaptureExtension implements BeforeAllCallback, AfterAllCallback {

  private static CaptureOutputStream captureOut;
  private static CaptureOutputStream captureErr;
  private static ByteArrayOutputStream copy;


  private static ReentrantLock lock = new ReentrantLock();
  private static int parallelism = 0;

  @Override
  public void afterAll(ExtensionContext context) throws Exception {
    try {
      lock.lock();
      parallelism = --parallelism < 0 ? 0 : parallelism;
      if (parallelism == 0) {
        releaseOutput();
      }
    } finally {
      lock.unlock();
    }
  }

  @Override
  public void beforeAll(ExtensionContext context) throws Exception {
    try {
      lock.lock();
      if (parallelism++ == 0) {
        captureOutput();
      }
    } finally {
      lock.unlock();
    }
  }


  public static String getCapturedOutput() {
    flush();
    return copy.toString();
  }

  private static void captureOutput() {
    copy = new ByteArrayOutputStream();
    captureOut = new CaptureOutputStream(System.out, copy);
    captureErr = new CaptureOutputStream(System.err, copy);
    System.setOut(new PrintStream(captureOut));
    System.setErr(new PrintStream(captureErr));
  }

  private static void releaseOutput() {
    System.setOut(captureOut.getOriginal());
    System.setErr(captureErr.getOriginal());
    copy = null;
    captureOut = null;
    captureErr = null;
  }

  private static void flush() {
    try {
      captureOut.flush();
      captureErr.flush();
    } catch (IOException ex) {
      // ignore
    }
  }


  private static class CaptureOutputStream extends OutputStream {
    private final PrintStream original;
    private final OutputStream copy;

    CaptureOutputStream(PrintStream original, OutputStream copy) {
      this.original = original;
      this.copy = copy;
    }

    @Override
    public void write(int b) throws IOException {
      this.copy.write(b);
      this.original.write(b);
      this.original.flush();
    }

    @Override
    public void write(byte[] b) throws IOException {
      write(b, 0, b.length);
    }

    @Override
    public void write(byte[] b, int off, int len) throws IOException {
      this.copy.write(b, off, len);
      this.original.write(b, off, len);
    }

    public PrintStream getOriginal() {
      return this.original;
    }

    @Override
    public void flush() throws IOException {
      this.copy.flush();
      this.original.flush();
    }
  }
}

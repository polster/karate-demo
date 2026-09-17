function fn() {
  var env = karate.env || 'dev';
  karate.log('karate.env =', env);

  // 'mock.server.url' is injected at runtime:
  //  - functional tests: support/MockServerLifecycle.java sets it to the random port
  //    the in-process mock server started on (see @BeforeAll in TestUsersRunner)
  //  - load test: support/MockServerMain.java runs the mock as a standalone process
  //    on a fixed port, so the localhost:8080 fallback below applies
  var config = {
    env: env,
    baseUrl: java.lang.System.getProperty('mock.server.url', 'http://localhost:8080'),
    connectTimeout: 5000,
    readTimeout: 5000
  };

  // demonstrates per-environment overrides, driven by -Dkarate.env=<name>
  if (env == 'ci') {
    config.readTimeout = 10000; // shared CI runners can be slower than a laptop
  } else if (env == 'load') {
    config.connectTimeout = 2000;
    config.readTimeout = 2000; // fail fast under load so slow responses surface as errors
  }

  karate.configure('connectTimeout', config.connectTimeout);
  karate.configure('readTimeout', config.readTimeout);

  return config;
}

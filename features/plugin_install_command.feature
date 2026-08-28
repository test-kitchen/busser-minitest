Feature: Plugin install command
  In order to use this plugin
  As a user of Busser
  I want to run the postinstall for this plugin

  Background:
    Given a non bundler environment
    And a test BUSSER_ROOT directory named "busser-minitest-install"
    And a sandboxed GEM_HOME directory named "busser-minitest-gem-home"
    And this plugin is installed from the working tree

  Scenario: Running the postinstall generator
    When I successfully run `busser plugin install busser-minitest --force-postinstall`
    Then a gem named "minitest" is installed with version "6.*"

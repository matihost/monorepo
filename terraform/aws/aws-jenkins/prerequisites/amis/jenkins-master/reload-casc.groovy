import io.jenkins.plugins.casc.ConfigurationAsCode

// Reloading CASC upon Jenkins startup is not automatic:
// https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/docs/features/configurationReload.md

ConfigurationAsCode.get().configure()

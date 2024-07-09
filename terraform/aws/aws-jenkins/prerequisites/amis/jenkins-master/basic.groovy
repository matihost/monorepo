import jenkins.model.*
import hudson.security.*
import jenkins.install.*;
import hudson.util.*;

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount("admin", "admin")
instance.setSecurityRealm(hudsonRealm)
instance.save()

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
instance.save()

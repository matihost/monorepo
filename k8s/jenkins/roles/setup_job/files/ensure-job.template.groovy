
import jenkins.model.*

def jobName = "{{ job.name }}"
def configXml = """{{ job_definition }}"""

def xmlStream = new ByteArrayInputStream( configXml.toString().getBytes("UTF-8") )

Jenkins.instance.createProjectFromXML(jobName, xmlStream)
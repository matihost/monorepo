
import jenkins.model.*
import javax.xml.transform.stream.*

def jobName = "{{ job.name }}"
def configXml = """{{ job_definition }}"""

def xmlStream = new ByteArrayInputStream( configXml.toString().getBytes("UTF-8") )

def job = Jenkins.getInstance().getItemByFullName(jobName)

if (job == null) {
  println "Constructing job ${jobName}"
  Jenkins.instance.createProjectFromXML(jobName, xmlStream)
}
else {
  println "Updating job ${jobName}"
  job.updateByXml(new StreamSource(xmlStream));
}
